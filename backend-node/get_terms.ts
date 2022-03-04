// get_terms.ts
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
  GetTermsArgs
} from './interfaces';

import {
  verifyToken,
  numberFromSqlDec
} from './helper';

/**
 * Get all of the terms for the user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getTerms(con: any, req: any, res: any) {

  var body: GetTermsArgs = req.body;

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
 * @param {GetTermsArgs} body the arguments provided by the user
 */
 function validateInput(con: any, req: any, res: any, body: GetTermsArgs, callback: (statusCode: number, output: Object) => void) {
   if (body.internal_id != null && body.token != null) {
     verifyToken(con, body.internal_id, body.token, callback);
   } else {
     callback(400, {
       success: false,
       error: "ERR_MISSING_ARGS",
       message: "The request is missing required arguments."
     });
   }
 }

function getCourseIDsForTermSequentially(con: any, req: any, res: any, termIDs: string[], current: number, terms: any, callback: (modifiedTerms: any, err: QueryError) => void) {
  var termID = termIDs[current];
  var sql: string = "SELECT class_id FROM classes WHERE term_id = ?";
  var args: [string] = [termID];
  con.query(sql, args, (err: QueryError, res: any[]) => {
    if (!err) {
      if (current < termIDs.length) {
        var courseIDs: string[] = [];
        for (var index in res) {
          courseIDs.push(res[index].class_id);
        }
        terms[termID]["class_ids"] = courseIDs;

        getCourseIDsForTermSequentially(con, req, res, termIDs, current + 1, terms, callback);
      } else {
        callback(terms, null);
      }
    } else {
      callback(null, err);
    }
  });
}

/**
 * Perform action after validating user input.
 * Errors here should typically return HTTP code 500.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 * @param {GetTermsArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: GetTermsArgs, callback: (statusCode: number, output: Object) => void) {
  var sql: string = "SELECT * FROM terms WHERE internal_id = ?";
  var args: [string] = [body.internal_id];
  con.query(sql, args, (err: QueryError, res: any[]) => {
    if (!err) {
      var termIDs: string[] = [];
      var terms: any = {};
      for (var i in res) {
        terms[res[i].term_id] = {
          term_title: res[i].title,
          start_date: res[i].start_date,
          end_date: res[i].end_date,
          class_ids: []
        }
        termIDs.push(res[i].term_id);
      }

      getCourseIDsForTermSequentially(con, req, res, termIDs, 0, terms, (modifiedTerms, crstrmErr) => {
        if (!crstrmErr) {
          callback(200, {
            success: true,
            terms: modifiedTerms
          });
        } else {
          callback(500, {
            success: false,
            error: "DBG_ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: crstrmErr
          });
        }
      });
    } else {
      callback(500, {
        success: false,
        error: "DBG_ERR_SQL_QUERY",
        message: "Unable to perform query.",
        details: err
      });
    }
  });
}
