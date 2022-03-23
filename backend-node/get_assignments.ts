// get_assignments.ts
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
  GetAssignmentsArgs
} from './interfaces';

import {
  verifyToken,
  numberFromSqlDec
} from './helper';

/**
 * Get all assignments for user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getAssignments(con: any, req: any, callback: (stat: number, output: Object) => void) {

  var body: GetAssignmentsArgs = req.body;

  validateInput(con, body, (viStatus: number, viOutput: Object) => {
    if (viStatus == 200) {
      performAction(con, body, callback);
    } else {
      callback(viStatus, viOutput);
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
 * @param {GetAssignmentsArgs} body the arguments provided by the user
 */
 function validateInput(con: any, body: GetAssignmentsArgs, callback: (statusCode: number, output: Object) => void) {
   if (body.internal_id != null && body.token != null && body.course_id != null) {
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
 * @param {GetAssignmentsArgs} body the arguments provided by the user
 */
function performAction(con: any, body: GetAssignmentsArgs, callback: (statusCode: number, output: Object) => void) {
  var sql: string = "SELECT * FROM items WHERE class_id = ?";
  var args: [string] = [body.course_id];
  con.query(sql, args, (err: QueryError, res: any[]) => {
    if (!err) {
      var assignments: any = {};
      for (var i in res) {
        if (body.ignore_before_date == null || res[i].modify_date >= body.ignore_before_date) {
          assignments[res[i].assignment_id] = {
            title: res[i].title,
            description: res[i].description,
            grade_id: res[i].grade_id,
            act_score: numberFromSqlDec(res[i].act_score),
            max_score: numberFromSqlDec(res[i].max_score),
            weight: numberFromSqlDec(res[i].weight),
            penalty: numberFromSqlDec(res[i].penalty),
            due_date: res[i].due_date,
            assign_date: res[i].assign_date,
            graded_date: res[i].graded_date,
            modify_date: res[i].modify_date
          }
        }
      }
      callback(200, {
        success: true,
        fetch_date: Math.round(Date.now() / 1000),
        assignments: assignments
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
