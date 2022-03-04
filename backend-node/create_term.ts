// create_term.ts
/*
 Copyright (c) 2021-2022 Noah Sadir

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import {
  Credentials,
  QueryError,
  CreateTermArgs
} from './interfaces';

import {
  generateUniqueRandomString,
  occurrencesInTable,
  verifyToken,
  getEditPermissionsForClass
} from './helper';

/**
 * Create a new term.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function createTerm(con: any, req: any, res: any) {

  var body: CreateTermArgs = req.body;

  validateInput(con, req, res, body, (viStatus: number, viOutput: Object) => {
    if (viStatus == 200) {
      performAction(con, req, res, body, (paStatus: number, paOutput: Object) => {
        res.statusCode = paStatus;
        res.json(paOutput);
      });
    } else {
      res.statusCode = viStatus;
      res.json(viOutput);
    }
  });

}

/**
 * Validate user input before performing request.
 * Errors here should typically return HTTP code 400.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 * @param {CreateTermArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: CreateTermArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.term_title != null) {
    verifyToken(con, body.internal_id, body.token, callback);
  } else {
    callback(400, {
      success: false,
      error: "ERR_MISSING_ARGS",
      message: "The request is missing required arguments."
    });
  }
}

/**
 * Perform action after validating user input.
 * Errors here should typically return HTTP code 500.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 * @param {CreateTermArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: CreateTermArgs, callback: (statusCode: number, output: Object) => void) {
  //Generate internal ID
  generateUniqueRandomString(con, 16, "terms", "term_id", (termID: string) => {
    if (termID != null) {
      var sql = "INSERT INTO terms (internal_id, term_id, title, start_date, end_date) VALUES (?, ?, ?, ?, ?)";
      var args: [string, string, string, number, number] = [body.internal_id, termID, body.term_title, body.start_date, body.end_date];

      con.query(sql, args, function (addtrmErr: Object, result: Object) {
        if (!addtrmErr) {
          callback(200, {
            success: true,
            message: "Successfully added term."
          });
        } else {
          callback(500, {
            success: false,
            error: "DBG_ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: addtrmErr
          });
        }
      });
    } else {
      callback(500, {
        success: false,
        error: "ERR_RANDSTR_GENERATION",
        message: "Unable to generate random string for term ID."
      });
    }
  });
}
