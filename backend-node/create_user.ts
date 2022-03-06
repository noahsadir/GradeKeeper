// create_user.ts
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
export function createUser(con: any, req: any, callback: (stat: number, output: Object) => void) {

  var body: CreateUserArgs = req.body;

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
 * @param {CreateUserArgs} body the arguments provided by the user
 */
function validateInput(con: any, body: CreateUserArgs, callback: (statusCode: number, output: Object) => void) {
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
function performAction(con: any, body: CreateUserArgs, callback: (statusCode: number, output: Object) => void) {
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
