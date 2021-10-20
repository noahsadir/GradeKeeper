import express from 'express';
import bcrypt from 'bcrypt';
import * as crypto from "crypto";
import * as bodyParser from "body-parser";
import {
  Credentials,
  QueryError
} from './interfaces';

var mysql = require('mysql2');

var credentials: Credentials = require('./credentials.json');

const app = express();
app.use(express.json());
var con = mysql.createConnection(credentials);
var isConnected: boolean = false;

con.connect(function(err: QueryError) {
  if (err) throw err;
  isConnected = true;
});

app.post('/create_user', (req, res) => {

  interface ArgumentBody {
    api_key: string;
    email: string;
    password: string;
  }

  var body: ArgumentBody = req.body;
  if (body.api_key != null && body.email != null && body.password != null) {

    //Check API Key
    checkAPIKey(body.api_key, (apiKeySuccess: boolean, apiKeyError: QueryError) => {

      if (apiKeySuccess) {
        //https://stackoverflow.com/questions/52456065/how-to-format-and-validate-email-node-js
        //Validate email
        if (body.email.match("^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+\/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-*\.?[a-zA-Z0-9])*\.[a-zA-Z](-?[a-zA-Z0-9])+$")) {

          //https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
          //At least one letter, number, and special char
          if (body.password.match("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$")) {

            //Generate internal ID
            generateRandomString(16, (internalID: string) => {
              if (internalID != null) {

                //Hash password
                bcrypt.hash(body.password, 10, function(err, hash) {
                  if (!err) {

                    //Insert new user into database
                    var sql = "INSERT INTO logins (email, password, internal_id) VALUES ('" + body.email + "', '" + hash + "', '" + internalID + "')";
                    con.query(sql, function (err: Object, result: Object) {
                      if (!err) {
                        res.statusCode = 200;
                        res.json({
                          success: true,
                          message: "Successfully generated user!"
                        });
                      } else {
                        res.statusCode = 500;
                        res.json({
                          success: false,
                          error: "ERR_DATABASE_INSERT",
                          message: "Unable to store user in database."
                        });
                      }
                    });
                  } else {
                    res.statusCode = 500;
                    res.json({
                      success: false,
                      error: "ERR_PASSWORD_HASH",
                      message: "Unable to hash password."
                    });
                  }
                });
              } else {
                res.statusCode = 500;
                res.json({
                  success: false,
                  error: "ERR_RANDSTR_GENERATION",
                  message: "Unable to generate random string for internal ID."
                });
              }
            });
          } else {
            res.statusCode = 400;
            res.json({
              success: false,
              error: "ERR_INSECURE_PASSWORD",
              message: "The password must be at least 8 characters and contain at least one uppercase and lowercase letter, one number, and one special character."
            });
          }
        } else {
          res.statusCode = 400;
          res.json({
            success: false,
            error: "ERR_INVALID_EMAIL",
            message: "The provided email is invalid."
          });
        }
      } else {
        if (apiKeySuccess == null) {
          res.statusCode = 500;
          res.json({
            success: false,
            error: "ERR_SQL_QUERY",
            message: "Unable to perform query.",
            details: apiKeyError
          });
        } else {
          res.statusCode = 400;
          res.json({
            success: false,
            error: "ERR_INVALID_API_KEY",
            message: "The API Key is invalid."
          });
        }

      }
    });
  } else {
    res.statusCode = 400;
    res.json({
      success: false,
      error: "ERR_MISSING_ARGS",
      message: "The request is missing required arguments."
    });
  }
});

app.get('*', (req, res) => {
  res.statusCode = 405;
  res.json({
    success: false,
    error: "ERR_HTTP",
    message: "Error 405: GET Requests Not Allowed"
  });
});

app.post('*', (req, res) => {
  res.statusCode = 400;
  res.json({
    success: false,
    error: "ERR_HTTP",
    message: "Error 400: Bad Request"
  });
});

app.listen(3000, () => {
    console.log('The application is listening on port 3000!');
});

function checkAPIKey(apiKey: string, callback: (success: boolean, error: QueryError) => void) {
  var sql = "SELECT * FROM api_keys WHERE api_key = '" + apiKey + "';";
  con.query(sql, function(err: QueryError, result: Object, fields: Object) {
    if (err) {
      callback(null, err);
    } else if (Object.keys(result).length == 0) {
      callback(false, null);
    } else {
      callback(true, null);
    }
  });
}

function generateRandomString(length: number, callback: (str: string) => void) {
  crypto.randomBytes(length, function(err, buffer) {
    if (err) {
      callback(null);
    } else {
      callback(buffer.toString('hex').substring(0, length));
    }
  });
}
