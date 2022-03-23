// set_class_schedule.ts
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
  Timeslot,
  SetCourseScheduleArgs
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
export function setCourseSchedule(con: any, req: any, callback: (stat: number, output: Object) => void) {

  var body: SetCourseScheduleArgs = req.body;

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
 * @param {SetCourseScheduleArgs} body the arguments provided by the user
 */
function validateInput(con: any, body: SetCourseScheduleArgs, callback: (statusCode: number, output: Object) => void) {
  if (body.internal_id != null && body.token != null && body.course_id != null && body.timeslots != null) {
    var validTimeslots: boolean = true;

    for (var i in body.timeslots) {
      if (body.timeslots[i].day_of_week == null || body.timeslots[i].start_time == null || body.timeslots[i].end_time == null) {
        validTimeslots = false;
      }
    }

    if (validTimeslots) {
      verifyToken(con, body.internal_id, body.token, callback);
    } else {
      callback(400, {
        success: false,
        error: "ERR_INVALID_TIMESLOT",
        message: "One or more invalid timeslots found."
      })
    }
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
 * @param {SetCourseScheduleArgs} body the arguments provided by the user
 */
function performAction(con: any, body: SetCourseScheduleArgs, callback: (statusCode: number, output: Object) => void) {
  //Generate internal ID
  getEditPermissionsForClass(con, body.course_id, body.internal_id, (hasPermission: boolean, editErr: QueryError) => {
    if (!editErr && hasPermission) {
      deleteSchedule(con, body, (delErr: QueryError) => {
        if (!delErr) {
          addTimeSlotsRecursively(con, body, 0, (errInd: number, atsErr: QueryError) => {
            if (errInd >= body.timeslots.length - 1) {
              callback(200, {
                success: true,
                message: "Successfully set course schedule."
              });
            } else if (!atsErr) {
              callback(500, {
                success: false,
                error: "ERR_TIMESLOT_ADD",
                message: "Unable to add timeslot " + errInd.toString(),
              });
            } else {
              callback(500, {
                success: false,
                error: "DBG_ERR_SQL_QUERY",
                message: "Unable to perform query.",
                details: atsErr
              });
            }
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
        message: "User does not have edit permissions for this course."
      });
    }
  });
}

function deleteSchedule(con: any, body: SetCourseScheduleArgs, callback: (error: QueryError) => void) {
  var sql = "DELETE FROM schedule WHERE class_id = ?";
  var args: [string] = [body.course_id];

  con.query(sql, args, (err: QueryError, res: any[]) => {
    callback(err);
  });
}

function addTimeSlotsRecursively(con: any, body: SetCourseScheduleArgs, index: number, callback: (index: number, error: QueryError) => void) {

  var selectedTimeslot: Timeslot = body.timeslots[index];
  if (selectedTimeslot != null) {
    var sql = "INSERT INTO schedule (class_id, day_of_week, start_time, end_time, start_date, end_date, description, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    var args: [string, number, number, number, number, number, string, string] = [body.course_id, selectedTimeslot.day_of_week, selectedTimeslot.start_time, selectedTimeslot.end_time, selectedTimeslot.start_date, selectedTimeslot.end_date, selectedTimeslot.description, selectedTimeslot.address];

    con.query(sql, args, (err: QueryError, res: any[]) => {
      if (!err) {
        if (index < body.timeslots.length - 1) {
          addTimeSlotsRecursively(con, body, index + 1, callback);
        } else {
          callback(index, null);
        }
      } else {
        callback(index, err);
      }
    });
  } else {
    callback(index, null);
  }
}
