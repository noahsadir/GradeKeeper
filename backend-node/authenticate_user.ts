/*******************************
 * authenticate_user.ts        *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 21, 2021 *
 *******************************/

import {
  Credentials,
  QueryError,
  AuthenticateUserArgs
} from './interfaces';

import {
  checkAPIKey,
  generateRandomString,
  hashPassword,
  verifyPassword,
  occurrencesInTable,
  selectFromWhere
} from './helper';

/**
 * Create a new user
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function authenticateUser(con: any, req: any, res: any) {

  var body: AuthenticateUserArgs = req.body;

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
 * @param {AuthenticateUserArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: AuthenticateUserArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.api_key != null && body.email != null && body.password != null) {

    //Check API Key
    checkAPIKey(con, body.api_key, (apiKeySuccess: boolean, apiKeyError: QueryError) => {
      if (apiKeySuccess) {
        occurrencesInTable(con, "logins", "email", body.email, (count: number, emoccErr: QueryError) => {
          if (count == 1) {
            verifyPassword(con, body.email, body.password, (isCorrect: boolean, vpassErr: Object) => {
              if (isCorrect) {
                callback(200, null);
              } else if (isCorrect == null) {
                if (vpassErr) {
                  callback(500, {
                    success: false,
                    error: "ERR_SQL_QUERY",
                    message: "Unable to perform query",
                    details: vpassErr
                  });
                }
              } else if (isCorrect == false) {
                callback(400, {
                  success: false,
                  error: "ERR_INCORRECT_PASSWORD",
                  message: "The password is incorrect."
                });
              }
            });
          } else if (count > 1) {
            callback(500, {
              success: false,
              error: "ERR_MULTIPLE_EMAILS",
              message: "Multiple accounts exist with the same email (that shouldn't happen)"
            });
          } else {
            callback(400, {
              success: false,
              error: "ERR_EMAIL_NOT_REGISTERED",
              message: "The provided email is not registered."
            });
          }
        });
      } else {
        if (apiKeySuccess == null) {
          callback(500, {
            success: false,
            error: "ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: apiKeyError
          });
        } else {
          callback(400, {
            success: false,
            error: "ERR_INVALID_API_KEY",
            message: "The API Key is invalid."
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
 * @param {AuthenticateUserArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: AuthenticateUserArgs, callback: (statusCode: number, output: Object) => void) {
  //Generate temp token
  generateRandomString(64, (token: string) => {
    if (token != null) {
      const expiration: number = Math.round(Date.now() / 1000) + 1800; // 30 minutes from now

      //Get internal id for user
      selectFromWhere(con, "internal_id", "logins", "email", body.email, (internalID: string, sfwErr: QueryError) => {
        if (!sfwErr) {
          if (internalID != null) {

            //Check if token exists
            occurrencesInTable(con, "tokens", "internal_id", internalID, (count: number, idoccErr: QueryError) => {
              if (!idoccErr) {
                if (count == 1 || count == 0) {

                  // Add/update token & expiration, depending on whether one exists or not
                  var sql: string = (count == 0 ? "INSERT INTO `tokens` (internal_id, token, expiration) VALUES (?, ?, ?)" : "UPDATE `tokens` SET `token` = ?, `expiration` = ? WHERE `internal_id` = ?");
                  var args: any[] = (count == 0 ? [internalID, token, expiration] : [token, expiration, internalID]);

                  con.query(sql, args, function (addtokErr: Object, result: Object) {
                    if (!addtokErr) {
                      callback(200, {
                        success: true,
                        internal_id: internalID,
                        token: token
                      });
                    } else {
                      callback(500, {
                        success: false,
                        error: "ERR_SQL_QUERY",
                        message: "Unable to perform query.",
                        details: addtokErr
                      });
                    }
                  });
                } else {
                  callback(500, {
                    success: false,
                    error: "ERR_TOKEN_COUNT",
                    message: "Abnormal token count (Not 1 or 0)."
                  });
                }
              } else {
                callback(500, {
                  success: false,
                  error: "ERR_SQL_QUERY",
                  message: "Unable to perform query.",
                  details: idoccErr
                });
              }
            });
          } else {
            callback(500, {
              success: false,
              error: "ERR_RANDSTR_GENERATION",
              message: "Unable to generate random string for token."
            });
          }
        } else {
          callback(500, {
            success: false,
            error: "ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: sfwErr
          });
        }
      });
    } else {
      callback(500, {
        success: false,
        error: "ERR_RANDSTR_GENERATION",
        message: "Unable to generate random string for token."
      });
    }
  });
}
