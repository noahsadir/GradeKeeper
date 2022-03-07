// app.ts
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

import express from 'express';
import * as bodyParser from "body-parser";

import {
  Credentials,
  QueryError
} from './interfaces';

import { authenticateUser } from './authenticate_user';

import { createUser } from './create_user';
import { createClass } from './create_class';
import { createCategory } from './create_category';
import { createGrade } from './create_grade';
import { createAssignment } from './create_assignment';
import { createTerm} from './create_term';

import { setClassSchedule } from './set_class_schedule';

import { getClasses } from './get_classes';
import { getLogs } from './get_logs';
import { getStructure } from './get_structure';
import { getAssignments } from './get_assignments';
import { getTerms } from './get_terms';

import { modifyClass } from './modify_class';
import { modifyCategory } from './modify_category';
import { modifyGrade } from './modify_grade';
import { modifyAssignment } from './modify_assignment';
import { modifyTerm } from './modify_term';

import { deleteAssignment } from './delete_assignment';
import { deleteCategory } from './delete_category';
import { deleteGrade } from './delete_grade';
import { deleteClass } from './delete_class';
import { deleteTerm } from './delete_term';

var mysql = require('mysql2');

var credentials: Credentials = require('./credentials.json');

const app = express();
app.use(express.json());

var postCalls: any = {
  authenticate_user: authenticateUser,
  create_user: createUser,
  create_class: createClass,
  create_assignment: createAssignment,
  create_category: createCategory,
  create_grade: createGrade,
  create_term: createTerm,
  delete_assignment: deleteAssignment,
  delete_category: deleteCategory,
  delete_class: deleteClass,
  delete_grade: deleteGrade,
  delete_term: deleteTerm,
  get_assignments: getAssignments,
  get_classes: getClasses,
  get_logs: getLogs,
  get_structure: getStructure,
  get_terms: getTerms,
  modify_assignment: modifyAssignment,
  modify_class: modifyClass,
  modify_category: modifyCategory,
  modify_grade: modifyGrade,
  modify_term: modifyTerm,
  set_class_schedule: setClassSchedule
}

// configure all api calls
for (var callType in postCalls) {
  app.post('/' + callType, (req, res) => {
    var key = req.path.replace("/","");
    logRequest("post", key, req);
    makeRequest(req, res, postCalls[key]);
  });
}

app.get('*', (req, res) => {
  logRequest("get", "*", req);
  res.statusCode = 405;
  res.json({
    success: false,
    error: "ERR_HTTP",
    message: "Error 405: GET Requests Not Allowed"
  });
});

app.post('*', (req, res) => {
  logRequest("post", "*", req);
  res.statusCode = 400;
  res.json({
    success: false,
    error: "ERR_HTTP",
    message: "Error 400: Bad (unrecognized) Request"
  });
});

app.listen(3000, () => {
    console.log('The application is listening on port 3000!');
});

function makeRequest(req: any, res: any, apiFunc: (apiCon: any, apiRes: any, apiCallback: (status: number, output: Object) => void) => void) {
  var con = mysql.createConnection(credentials);
  con.connect(function(err: QueryError) {
    if (err) {
      res.statusCode = 500;
      res.json({
        success: false,
        error: "DBG_ERR_DB_ACCESS",
        message: "Unable to access database.",
        details: err
      });
      con.end();
    } else {
      apiFunc(con, req, (status: number, output: Object) => {
        res.statusCode = status;
        res.json(output);
        con.end();
      });
    }
  });
}

function logRequest(method: string, callName: string, req: any) {
  var con = mysql.createConnection(credentials);
  con.connect(function(err: QueryError) {
    if (!err) {
      var body: any = req.body;
      var internalID = null;
      var apiKey = null;
      if (body) {
        internalID = body.internal_id;
        apiKey = body.api_key;
      }

      var sql = "INSERT INTO usage_log (method, call_type, internal_id, api_key, timestamp) VALUES (?, ?, ?, ?, ?)";
      var args: [string, string, string, string, number] = [method, callName, internalID, apiKey, Math.round(Date.now() / 1000)];
      con.query(sql, args);
      con.end();
    }
  });
}
