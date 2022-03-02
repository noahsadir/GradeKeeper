/********************************
 * delete_category.ts           *
 * ---------------------------- *
 * Created by Noah Sadir        *
 *         on December 27, 2021 *
 ********************************/

import {
  Credentials,
  QueryError,
  DeleteTermArgs
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
export function deleteTerm(con: any, req: any, res: any) {

  var body: DeleteTermArgs = req.body;

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
 * @param {DeleteAssignmentArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: DeleteTermArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.term_id != null) {
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
 * @param {DeleteAssignmentArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: DeleteTermArgs, callback: (statusCode: number, output: Object) => void) {
  var delSql = "DELETE FROM terms WHERE term_id = ? AND internal_id = ?";
  var delArgs: [string, string] = [body.term_id, body.internal_id];
  con.query(delSql, delArgs, (delErr: QueryError, delRes: any, delFields: Object) => {
    if (!delErr) {
      callback(200, {
        success: true,
        message: "Successfully deleted term."
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
}
