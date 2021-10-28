/*******************************
 * create_user.ts              *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 19, 2021 *
 *******************************/

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
export function modifyGrade(con: any, req: any, res: any) {

  var body: ModifyGradeArgs = req.body;

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
 * @param {ModifyGradeArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: ModifyGradeArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.class_id != null && body.grade_id != null) {

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
 * @param {ModifyGradeArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: ModifyGradeArgs, callback: (statusCode: number, output: Object) => void) {

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
