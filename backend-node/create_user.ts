/*******************************
 * create_user.ts              *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 19, 2021 *
 *******************************/

import {
  Credentials,
  QueryError,
  CreateUserArgs
} from './interfaces';

import {
  checkAPIKey,
  generateUniqueRandomString,
  hashPassword,
  occurrencesInTable
} from './helper';

/**
 * Create a new user.
 *
 * @param {any} con the MySQL connection
 * @param {any} req the Express request
 * @param {any} res the Express result
 */
export function createUser(con: any, req: any, res: any) {

  var body: CreateUserArgs = req.body;

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
 * @param {CreateUserArgs} body the arguments provided by the user
 */
function validateInput(con: any, req: any, res: any, body: CreateUserArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.api_key != null && body.email != null && body.password != null) {

    //Check API Key
    checkAPIKey(con, body.api_key, (apiKeySuccess: boolean, apiKeyError: QueryError) => {
      if (apiKeySuccess) {
        occurrencesInTable(con, "logins", "email", body.email, (count: number, emoccErr: QueryError) => {
          if (count == 0) {
            //https://stackoverflow.com/questions/52456065/how-to-format-and-validate-email-node-js
            //Validate email
            if (body.email.match("^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+\/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-*\.?[a-zA-Z0-9])*\.[a-zA-Z](-?[a-zA-Z0-9])+$")) {

              //https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
              //At least one letter, number, and special char
              if (body.password.match("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$")) {
                callback(200, null);
              } else {
                callback(400, {
                  success: false,
                  error: "ERR_INSECURE_PASSWORD",
                  message: "The password must be at least 8 characters and contain at least one uppercase and lowercase letter, one number, and one special character."
                });
              }
            } else {
              callback(400, {
                success: false,
                error: "ERR_INVALID_EMAIL",
                message: "The provided email is invalid."
              });
            }
          } else {
            callback(400, {
              success: false,
              error: "ERR_EMAIL_REGISTERED",
              message: "The provided email is already registered."
            });
          }
        });
      } else {
        if (apiKeySuccess == null) {
          callback(500, {
            success: false,
            error: "DBG_ERR_SQL_QUERY",
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
 * @param {CreateUserArgs} body the arguments provided by the user
 */
function performAction(con: any, req: any, res: any, body: CreateUserArgs, callback: (statusCode: number, output: Object) => void) {
  //Generate internal ID
  generateUniqueRandomString(con, 16, "logins", "internal_id", (internalID: string) => {
    if (internalID != null) {

      //Hash password
      hashPassword(body.password, (err, hash) => {
        if (!err) {

          //Insert new user into database
          var sql = "INSERT INTO logins (email, password, internal_id) VALUES (?, ?, ?)";
          var args: [string, string, string] = [body.email, hash, internalID];
          con.query(sql, args, function (err: Object, result: Object) {
            if (!err) {
              callback(200, {
                success: true,
                message: "Successfully generated user!"
              });
            } else {
              callback(500, {
                success: false,
                error: "ERR_DATABASE_INSERT",
                message: "Unable to store user in database."
              });
            }
          });

        } else {
          callback(500, {
            success: false,
            error: "ERR_PASSWORD_HASH",
            message: "Unable to hash password."
          });
        }
      });
    } else {
      callback(500, {
        success: false,
        error: "ERR_RANDSTR_GENERATION",
        message: "Unable to generate random string for internal ID."
      });
    }
  });
}
