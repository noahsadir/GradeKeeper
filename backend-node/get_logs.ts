// get_logs.ts
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
  GetLogsArgs
} from './interfaces';

import {
  checkAPIKey
} from './helper';

/**
 * Get API usage logs.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getLogs(con: any, req: any, res: any) {

  var body: GetLogsArgs = req.body;

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
 * @param {GetLogsArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: GetLogsArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.api_key != null) {

    //Check API Key
    checkAPIKey(con, body.api_key, (apiKeySuccess: boolean, apiKeyError: QueryError) => {
      if (apiKeySuccess) {
        callback(200, null);
      } else {
        if (apiKeySuccess == null) {
          callback(500, {
            success: false,
            error: "DBG_ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: apiKeyError
          });
        } else {
          callback(400, {
            success: false,
            error: "ERR_INVALID_API_KEY",
            message: "The API Key is invalid."
          });
        }

      }
    });
  } else {
    callback(400, {
      success: false,
      error: "ERR_MISSING_ARGS",
      message: "The request is missing required arguments.",
      details: body
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
 * @param {GetLogsArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: GetLogsArgs, callback: (statusCode: number, output: Object) => void) {
  var sql: string = "SELECT * FROM usage_log"
  var args: any[] = []
  con.query(sql, args, (err: QueryError, res: any) => {
    if (!err) {
      callback(200, {
        success: true,
        usage_log: res
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
