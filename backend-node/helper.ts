// helper.ts
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

import bcrypt from 'bcrypt';
import * as crypto from "crypto";
import {
  QueryError
} from './interfaces';

/**
 * Check how many times a value occurs for a certain column in a given table.
 * Useful for checking for duplicates or if an entry already exists.
 *
 * @param {any} con the MySQL connection
 * @param {string} table the table to search
 * @param {string} column the column in the table to search
 * @param {string} value the value to search for
 * @param {function} callback the function to call after the query is performed
 */
export function occurrencesInTable(con: any, table: string, column: string, value: string, callback: (count: number, err: QueryError) => void) {
  var sql = "SELECT `id` FROM `" + table + "` WHERE `" + column + "` = ?";
  var args: [string] = [value];
  con.query(sql, args, function(err: QueryError, result: Object, fields: Object) {
    if (err) {
      callback(null, err);
    } else {
      callback(Object.keys(result).length, null);
    }
  });
}


export function selectFromWhere(con: any, desired: string, table: string, column: string, value: string, callback: (result: any, err: QueryError) => void) {
  var sql = "SELECT `" + desired + "` FROM `" + table + "` WHERE `" + column + "` = ?";
  var args: [string] = [value];
  con.query(sql, args, function(err: QueryError, result: any[], fields: Object) {
    if (err) {
      callback(null, err);
    } else if (result.length != 1) {
      callback(null, null);
    } else {
      callback(result[0][desired], null);
    }
  });
}

export function selectAllFromWhere(con: any, desired: string, table: string, column: string, value: string, callback: (result: any, err: QueryError) => void) {
  var sql = "SELECT `" + desired + "` FROM `" + table + "` WHERE `" + column + "` = ?";
  var args: [string] = [value];
  con.query(sql, args, function(err: QueryError, result: any[], fields: Object) {
    if (err) {
      callback(null, err);
    } else {
      callback(result, null);
    }
  });
}

export function checkAPIKey(con: any, apiKey: string, callback: (success: boolean, error: QueryError) => void) {
  occurrencesInTable(con, "api_keys", "api_key", apiKey, (count: number, err: QueryError) => {
    if (count == null) {
      callback(null, err);
    } else if (count == 0) {
      callback(false, null);
    } else {
      callback(true, null);
    }
  });
}

export function hashPassword(password: string, callback: (err: Object, hash: string) => void) {
  bcrypt.hash(password, 10, function(err, hash) {
    callback(err, hash);
  });
}

export function verifyPassword(con: any, email: string, password: string, callback: (isCorrect: boolean, err: Object) => void) {
  var sql = "SELECT `password` FROM `logins` WHERE `email` = ?";
  var args: [string] = [email];
  con.query(sql, args, function(err: QueryError, result: any[], fields: Object) {
    if (err) {
      callback(null, err);
    } else if (result.length != 1) {
      callback(null, null);
    } else {
      var hash: string = result[0]['password'];
      bcrypt.compare(password, hash, (err: Object, res: boolean) => {
        if (err) {
          callback(null, err);
        } else {
          callback(res, null);
        }
      });
    }
  });
}

export function verifyToken(con: any, internalID: string, token: string, callback: (vtStatusCode: number, vtErr: Object) => void) {
  var sql = "SELECT `token`, `expiration` FROM `tokens` WHERE `internal_id` = ?";
  var args: [string] = [internalID];
  con.query(sql, args, (err: QueryError, result: any[], fields: Object) => {
    if (err) {
      callback(500, {
        success: false,
        error: "DBG_ERR_SQL_QUERY",
        message: "Unable to perform query.",
        details: err
      });
    } else if (result.length != 1) {
      callback(401, {
        success: false,
        error: "ERR_TOKEN_NOT_AVAILABLE",
        message: "A token has not been created for this user."
      });
    } else {
      var fetchedToken: string = result[0]['token'];
      var expiration: number = result[0]['expiration'];
      if (token == fetchedToken) {
        if (expiration > Math.round(Date.now() / 1000)) {
          callback(200, null);
        } else {
          callback(401, {
            success: false,
            error: "ERR_TOKEN_EXPIRED",
            message: "Token expired; please renew."
          });
        }
      } else {
        callback(401, {
          success: false,
          error: "ERR_INVALID_TOKEN",
          message: "The token is invalid."
        });
      }
    }
  });
}

export function generateRandomString(length: number, callback: (str: string) => void) {
  crypto.randomBytes(length, function(err, buffer) {
    if (err) {
      callback(null);
    } else {
      callback(buffer.toString('hex').substring(0, length));
    }
  });
}

export function getEditPermissionsForClass(con: any, classID: string, internalID: string, callback: (hasPermission: boolean, err: QueryError) => void) {
  var sql = "SELECT `id` FROM `edit_permissions` WHERE class_id = ? AND internal_id = ?";
  var args: [string, string] = [classID, internalID];
  con.query(sql, args, (editErr: QueryError, result: any[]) => {
    if (editErr) {
      callback(false, editErr);
    } else {
      if (result.length == 1) {
        callback(true, null);
      } else {
        callback(false, null);
      }
    }
  });
}

/**
 * Generate random string and check table column to ensure no conflicts.
 */
export function generateUniqueRandomString(con: any, length: number, table: string, column: string, callback: (str: string) => void) {
  crypto.randomBytes(length, function(err, buffer) {
    if (err) {
      callback(null);
    } else {
      var randStr: string = buffer.toString('hex').substring(0, length);
      occurrencesInTable(con, table, column, randStr, (count: number, occErr: QueryError) => {
        if (occErr || count != 0) {
          callback(null);
        } else {
          callback(randStr);
        }
      });
    }
  });
}

export function numberFromSqlDec(decimalVal: string) {
  if (decimalVal == null) {
    return null;
  }
  return parseFloat(decimalVal);
}
