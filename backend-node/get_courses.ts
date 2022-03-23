// get_classes.ts
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
  GetCoursesArgs,
  Gradebook,
  Timeslot
} from './interfaces';

import {
  generateRandomString,
  occurrencesInTable,
  verifyToken,
  selectAllFromWhere,
  numberFromSqlDec
} from './helper';

var currentClassID = "";

/**
 * Get all class data (not including assignments or files) for user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getCourses(con: any, req: any, callback: (stat: number, output: Object) => void) {

  var body: GetCoursesArgs = req.body;

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
 * @param {GetCoursesArgs} body the arguments provided by the user
 */
function validateInput(con: any, body: GetCoursesArgs, callback: (statusCode: number, output: Object) => void) {
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
 * @param {GetCoursesArgs} body the arguments provided by the user
 */
function performAction(con: any, body: GetCoursesArgs, callback: (statusCode: number, output: Object) => void) {
  var gradebook: Gradebook = {classes: {}};
  selectAllFromWhere(con, "class_id","edit_permissions","internal_id", body.internal_id, (result: any[], err: QueryError) => {
    var classIDs: string[] = [];
    for (var i in result) {
      classIDs.push(result[i].class_id);
    }
    getClassDataSequentially(con, classIDs, 0, gradebook, (newGradebook: Gradebook, gcdsErr: QueryError) => {
      if (!gcdsErr && newGradebook != null) {
        callback(200, {
          success: true,
          gradebook: newGradebook
        });
      } else if (gcdsErr == null && newGradebook == null) {
        callback(400, {
          success: false,
          error: "ERR_MISSING_COURSE",
          message: ("Course " + currentClassID + " is missing.")
        });
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
  var sql = "SELECT `class_name`, `class_code`, `color`, `weight`, `instructor` FROM `classes` WHERE `class_id` = ?";
  var args: [string] = [classIDs[index]];
  currentClassID = classIDs[index];
  con.query(sql, args, (err: QueryError, result: any[], fields: Object) => {
    if (!err) {
      var catSql = "SELECT `category_id`, `category_name`, `drop_count`, `weight` FROM `categories` WHERE `class_id` = ?";
      con.query(catSql, args, (catErr: QueryError, catRes: any[], catFields: Object) => {
        var grdSql = "SELECT `grade_id`, `min_score`, `max_score`, `credit` FROM `grade_scales` WHERE `class_id` = ?";
        con.query(grdSql, args, (grdErr: QueryError, grdRes: any[], grdFields: Object) => {
          var asgSql = "SELECT `assignment_id`, `category_id` FROM `items` WHERE `class_id` = ?";
          con.query(asgSql, args, (asgErr: QueryError, asgRes: any[], asgFields: Object) => {
            var schSql = "SELECT * FROM schedule WHERE class_id = ?";
            con.query(schSql, args, (schErr: QueryError, schRes: any[]) => {
              if (!catErr && !grdErr && !asgErr && !schErr && result.length == 1) {
                gradebook.classes[classIDs[index]] = {
                  name: result[0].class_name,
                  code: result[0].class_code,
                  color: result[0].color,
                  weight: numberFromSqlDec(result[0].weight),
                  instructor: result[0].instructor,
                  grade_scale: {},
                  categories: {},
                  timeslots: []
                };


                for (var i in schRes) {
                  var newTimeslot: Timeslot = {
                    day_of_week: schRes[i].day_of_week,
                    start_time: schRes[i].start_time,
                    end_time: schRes[i].end_time,
                    start_date: schRes[i].start_date,
                    end_date: schRes[i].end_date,
                    description: schRes[i].description,
                    address: schRes[i].address
                  };

                  gradebook.classes[classIDs[index]].timeslots.push(newTimeslot);
                }

                for (var i in catRes) {
                  gradebook.classes[classIDs[index]].categories[catRes[i].category_id] = {
                    category_name: catRes[i].category_name,
                    drop_count: catRes[i].drop_count,
                    weight: numberFromSqlDec(catRes[i].weight),
                    assignments: []
                  };
                }

                for (var i in grdRes) {
                  gradebook.classes[classIDs[index]].grade_scale[grdRes[i].grade_id] = {
                    min_score: numberFromSqlDec(grdRes[i].min_score),
                    max_score: numberFromSqlDec(grdRes[i].max_score),
                    credit: numberFromSqlDec(grdRes[i].credit)
                  };
                }

                for (var i in asgRes) {
                  if (gradebook.classes[classIDs[index]].categories[asgRes[i].category_id] != null) {
                    gradebook.classes[classIDs[index]].categories[asgRes[i].category_id].assignments.push(asgRes[i].assignment_id);
                  }
                }

                if (index == classIDs.length - 1) {
                  callback(gradebook, err);
                } else {
                  getClassDataSequentially(con, classIDs, index + 1, gradebook, (recGB: Gradebook, recErr: QueryError) => {
                    callback(recGB, recErr);
                  });
                }
              } else {
                if (catErr) {
                  callback(null, catErr);
                } else if (grdErr) {
                  callback(null, grdErr);
                } else if (asgErr) {
                  callback(null, asgErr);
                } else if (schErr) {
                  callback(null, schErr);
                } else if (result.length != 1){
                  callback(null, null);
                }
              }
            });
          });
        });
      });
    } else {
      callback(null, err);
    }
  });
}
