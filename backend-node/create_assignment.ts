/*******************************
 * create_item.ts              *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 27, 2021 *
 *******************************/

import {
  Credentials,
  QueryError,
  CreateAssignmentArgs
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
export function createAssignment(con: any, req: any, res: any) {

  var body: CreateAssignmentArgs = req.body;

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
 * @param {CreateAssignmentArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: CreateAssignmentArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.class_id != null && body.category_id != null) {

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
 * @param {CreateAssignmentArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: CreateAssignmentArgs, callback: (statusCode: number, output: Object) => void) {
  //Generate internal ID
  generateUniqueRandomString(con, 16, "items", "assignment_id", (assignmentID: string) => {
    if (assignmentID != null) {
      getEditPermissionsForClass(con, body.class_id, body.internal_id, (hasPermission: boolean, editErr: QueryError) => {
        if (!editErr && hasPermission) {
          var modifyDate = Math.round(Date.now() / 1000);
          var sql = "INSERT INTO items (class_id, category_id, assignment_id, title, description, grade_id, act_score, max_score, weight, due_date, assign_date, graded_date, penalty, modify_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
          var args: [string, string, string, string, string, string, number, number, number, number, number, number, number, number] = [body.class_id, body.category_id, assignmentID, body.title, body.description, body.grade_id, body.act_score, body.max_score, body.weight, body.due_date, body.assign_date, body.graded_date, body.penalty, modifyDate];
          con.query(sql, args, function (addasgErr: Object, result: Object) {
            if (!addasgErr) {
              callback(200, {
                success: true,
                message: "Successfully added assignment to category in class."
              });
            } else {
              callback(500, {
                success: false,
                error: "DBG_ERR_SQL_QUERY",
                message: "Unable to perform query.",
                details: addasgErr
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
    } else {
      callback(500, {
        success: false,
        error: "ERR_RANDSTR_GENERATION",
        message: "Unable to generate random string for assignment ID."
      });
    }
  });
}
