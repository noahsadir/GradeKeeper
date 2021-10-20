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

export function hashPassword(password: string, callback: (err: Object, hash: String) => void) {
  bcrypt.hash(password, 10, function(err, hash) {
    callback(err, hash);
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
