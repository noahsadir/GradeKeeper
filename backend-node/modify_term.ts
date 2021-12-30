/*******************************
 * create_user.ts              *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 19, 2021 *
 *******************************/

import {
  Credentials,
  QueryError,
  ModifyTermArgs
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
export function modifyTerm(con: any, req: any, res: any) {

  var body: ModifyTermArgs = req.body;

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
 * @param {ModifyTermArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: ModifyTermArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.term_id != null && body.term_title != null) {

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
 * @param {ModifyTermArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: ModifyTermArgs, callback: (statusCode: number, output: Object) => void) {
  var sql = "UPDATE terms SET (title = ?, start_date = ?, end_date = ?) WHERE (internal_id = ? AND term_id = ?)";
  var args: [string, number, number, string, string] = [body.term_title, body.start_date, body.end_date, body.internal_id, body.term_id];

  con.query(sql, args, function (trmErr: Object, result: Object) {
    if (!trmErr) {
      callback(200, {
        success: true,
        message: "Successfully modified category in class."
      });
    } else {
      callback(500, {
        success: false,
        error: "DBG_ERR_SQL_QUERY",
        message: "Unable to perform query.",
        details: trmErr
      });
    }
  });
}
