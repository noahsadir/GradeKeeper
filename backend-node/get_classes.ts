/*******************************
 * create_user.ts              *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 19, 2021 *
 *******************************/

import {
  Credentials,
  QueryError,
  GetClassesArgs,
  Gradebook
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
 * Create a new user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getClasses(con: any, req: any, res: any) {

  var body: GetClassesArgs = req.body;

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
 * @param {GetClassesArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: GetClassesArgs, callback: (statusCode: number, output: Object) => void) {
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
 * @param {GetClassesArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: GetClassesArgs, callback: (statusCode: number, output: Object) => void) {
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
            if (!catErr && !grdErr && !asgErr && result.length == 1) {
              gradebook.classes[classIDs[index]] = {
                name: result[0].class_name,
                code: result[0].class_code,
                color: result[0].color,
                weight: numberFromSqlDec(result[0].weight),
                instructor: result[0].instructor,
                grade_scale: {},
                categories: {}
              };

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
              } else if (result.length != 1){
                callback(null, null);
              }
            }
          });
        });
      });
    } else {
      callback(null, err);
    }
  });
}
