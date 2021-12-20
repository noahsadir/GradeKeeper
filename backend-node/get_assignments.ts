/*******************************
 * authenticate_user.ts        *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 21, 2021 *
 *******************************/

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
 * Create a new user
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function getAssignments(con: any, req: any, res: any) {

  var body: GetAssignmentsArgs = req.body;

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
 * @param {GetAssignmentsArgs} body the arguments provided by the user
 */
 function validateInput(con: any, req: any, res: any, body: GetAssignmentsArgs, callback: (statusCode: number, output: Object) => void) {
   if (body.internal_id != null && body.token != null && body.class_id != null) {

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
 * @param {GetAssignmentsArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: GetAssignmentsArgs, callback: (statusCode: number, output: Object) => void) {
  var sql: string = "SELECT * FROM items WHERE class_id = ?";
  var args: [string] = [body.class_id];
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
