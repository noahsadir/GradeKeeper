// get_structure.ts
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
  GetStructureArgs,
  Gradebook
} from './interfaces';

import {
  generateRandomString,
  occurrencesInTable,
  verifyToken,
  selectAllFromWhere,
  numberFromSqlDec
} from './helper';

/**
 * Get the structure of the class data.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getStructure(con: any, req: any, callback: (stat: number, output: Object) => void) {

  var body: GetStructureArgs = req.body;

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
 * @param {GetStructureArgs} body the arguments provided by the user
 */
function validateInput(con: any, body: GetStructureArgs, callback: (statusCode: number, output: Object) => void) {
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

/**
 * Perform action after validating user input.
 * Errors here should typically return HTTP code 500.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 * @param {GetStructureArgs} body the arguments provided by the user
 */
function performAction(con: any, body: GetStructureArgs, callback: (statusCode: number, output: Object) => void) {
  var gradebook: Gradebook = {classes: {}};
  selectAllFromWhere(con, "class_id","edit_permissions","internal_id", body.internal_id, (result: any[], err: QueryError) => {
    var classIDs: string[] = [];
    for (var i in result) {
      classIDs.push(result[i].class_id);
    }
    getClassDataSequentially(con, classIDs, 0, gradebook, (newGradebook: Gradebook, gcdsErr: QueryError) => {
      if (!gcdsErr) {
        callback(200, {
          success: true,
          gradebook: newGradebook
        })
      } else {
        callback(500, {
          success: false,
          error: "DBG_ERR_SQL_QUERY",
          message: "Unable to perform query.",
          details: gcdsErr
        });
      }
    });
  });
}

//Asynchronous Recursion... isn't that fun?
function getClassDataSequentially(con: any, classIDs: string[], index: number, gradebook: Gradebook, callback: (newGradebook: Gradebook, err: QueryError) => void) {
  var sql = "SELECT `id` FROM `classes` WHERE `class_id` = ?";
  var args: [string] = [classIDs[index]];
  con.query(sql, args, (err: QueryError, result: any[], fields: Object) => {
    if (!err) {
      var catSql = "SELECT `category_id` FROM `categories` WHERE `class_id` = ?";
      var args: [string] = [classIDs[index]];
      con.query(catSql, args, (catErr: QueryError, catRes: any[], catFields: Object) => {
        var grdSql = "SELECT `grade_id` FROM `grade_scales` WHERE `class_id` = ?";
        con.query(grdSql, args, (grdErr: QueryError, grdRes: any[], grdFields: Object) => {
          var asgSql = "SELECT `item_id`, `category_id` FROM `items` WHERE `class_id` = ?";
          con.query(asgSql, args, (asgErr: QueryError, asgRes: any[], asgFields: Object) => {
            if (!catErr && !grdErr && !asgErr && result.length == 1) {
              gradebook.classes[classIDs[index]] = {
                grade_scale: {},
                categories: {}
              };

              for (var i in catRes) {
                gradebook.classes[classIDs[index]].categories[catRes[i].category_id] = {
                  assignments: {}
                };
              }

              for (var i in grdRes) {
                gradebook.classes[classIDs[index]].grade_scale[grdRes[i].grade_id] = null;
              }

              for (var i in asgRes) {
                gradebook.classes[classIDs[index]].categories[asgRes[i].category_id].assignments[asgRes[i].item_id] = null;
              }

              if (index == classIDs.length) {
                callback(gradebook, err);
              } else {
                getClassDataSequentially(con, classIDs, index + 1, gradebook, (recGB: Gradebook, recErr: QueryError) => {
                  callback(recGB, recErr);
                });
              }
            } else {
              if (catErr) {
                callback(gradebook, catErr);
              } else if (grdErr) {
                callback(gradebook, grdErr);
              } else if (asgErr) {
                callback(gradebook, asgErr);
              } else {
                callback(gradebook, null);
              }
            }
          });
        });
      });
    } else {
      callback(gradebook, err);
    }
  });
}
