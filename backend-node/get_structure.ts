/*******************************
 * create_user.ts              *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 19, 2021 *
 *******************************/

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
 * Create a new user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getStructure(con: any, req: any, res: any) {

  var body: GetStructureArgs = req.body;

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
 * @param {GetStructureArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: GetStructureArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null) {

    verifyToken(con, body.internal_id, body.token, (authStat: number, vtErr: Object) => {
      if (authStat == 1) {
        callback(200, null);
      } else {
        if (vtErr) { //only time authStat == 0
          callback(500, {
            success: false,
            error: "DBG_ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: vtErr
          });
        } else if (authStat == 2) {
          callback(401, {
            success: false,
            error: "ERR_TOKEN_NOT_AVAILABLE",
            message: "A token has not been created for this user."
          });
        } else if (authStat == 3) {
          callback(401, {
            success: false,
            error: "ERR_INVALID_TOKEN",
            message: "The token is invalid."
          });
        } else if (authStat == 4) {
          callback(401, {
            success: false,
            error: "ERR_TOKEN_EXPIRED",
            message: "Token expired; please renew."
          });
        } else {
          // This error should never be shown
          // If it does, something is seriously wrong
          callback(500, {
            success: false,
            error: "ERR_TOKEN_VERIFY",
            message: "Unable to verify token due to server-side malfunction."
          });
        }
      }
    });
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
function performAction(con: any, req: any, res: any, body: GetStructureArgs, callback: (statusCode: number, output: Object) => void) {
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
