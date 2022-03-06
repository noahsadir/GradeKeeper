// modify_grade.ts
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
  ModifyGradeArgs
} from './interfaces';

import {
  generateUniqueRandomString,
  occurrencesInTable,
  verifyToken,
  getEditPermissionsForClass
} from './helper';

/**
 * Create a new user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function modifyGrade(con: any, req: any, callback: (stat: number, output: Object) => void) {

  var body: ModifyGradeArgs = req.body;

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
 * @param {ModifyGradeArgs} body the arguments provided by the user
 */
function validateInput(con: any, body: ModifyGradeArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.class_id != null && body.grade_id != null) {
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
 * @param {ModifyGradeArgs} body the arguments provided by the user
 */
function performAction(con: any, body: ModifyGradeArgs, callback: (statusCode: number, output: Object) => void) {

  getEditPermissionsForClass(con, body.class_id, body.internal_id, (hasPermission: boolean, editErr: QueryError) => {
    if (hasPermission && !editErr) {
      var delSql = "DELETE FROM grade_scales WHERE class_id = ? AND grade_id = ?";
      var delArgs: [string, string] = [body.class_id, body.grade_id];
      con.query(delSql, delArgs, (delErr: QueryError, delRes: any, delFields: Object) => {
        if (!delErr) {
          var sql = "INSERT INTO grade_scales (class_id, grade_id, min_score, max_score, credit) VALUES (?, ?, ?, ?, ?)";
          var args: [string, string, number, number, number] = [body.class_id, body.grade_id, body.min_score, body.max_score, body.credit];

          con.query(sql, args, function (grdErr: Object, result: Object) {
            if (!grdErr) {
              callback(200, {
                success: true,
                message: "Successfully modified grade to scale for class."
              });
            } else {
              callback(500, {
                success: false,
                error: "DBG_ERR_SQL_QUERY",
                message: "Unable to perform query.",
                details: grdErr
              });
            }
          });
        } else {
          callback(500, {
            success: false,
            error: "DBG_ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: delErr
          });
        }
      });
    } else if (editErr) {
      callback(500, {
        success: false,
        error: "DBG_ERR_SQL_QUERY",
        message: "Unable to perform query.",
        details: editErr
      });
    } else {
      callback(400, {
        success: false,
        error: "ERR_EDIT_PERMISSSION",
        message: "User does not have edit permissions for this class."
      });
    }
  });
}
