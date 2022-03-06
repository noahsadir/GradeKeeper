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

var isConnected: boolean = false;

function createRequest(req: any, res: any, apiFunc: (apiCon: any, apiRes: any, apiCallback: (status: number, output: Object) => void) => void) {
  var con = mysql.createConnection(credentials);
  con.connect(function(err: QueryError) {
    if (err) {
      res.statusCode = 500;
      res.json({
        success: false,
        error: "ERR_DB_ACCESS",
        message: "Unable to access database."
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

app.post('/create_user', (req, res) => {
  logRequest("post", "create_user", req);
  createRequest(req, res, createUser);
});

app.post('/authenticate_user', (req, res) => {
  logRequest("post", "authenticate_user", req);
  createRequest(req, res, authenticateUser);
});

app.post('/create_class', (req, res) => {
  logRequest("post", "create_class", req);
  createRequest(req, res, createClass);
});

app.post('/set_class_schedule', (req, res) => {
  logRequest("post", "set_class_schedule", req);
  createRequest(req, res, setClassSchedule);
});

app.post('/get_classes', (req, res) => {
  logRequest("post", "get_classes", req);
  createRequest(req, res, getClasses);
});

app.post('/get_structure', (req, res) => {
  logRequest("post", "get_structure", req);
  createRequest(req, res, getStructure);
});

app.post('/get_logs', (req, res) => {
  logRequest("post", "get_logs", req);
  createRequest(req, res, getLogs);
});

app.post('/get_terms', (req, res) => {
  logRequest("post", "get_terms", req);
  createRequest(req, res, getTerms);
});

app.post('/get_assignments', (req, res) => {
  logRequest("post", "get_assignments", req);
  createRequest(req, res, getAssignments);
});

app.post('/create_category', (req, res) => {
  logRequest("post", "create_category", req);
  createRequest(req, res, createCategory);
});

app.post('/create_grade', (req, res) => {
  logRequest("post", "create_grade", req);
  createRequest(req, res, createGrade);
});

app.post('/create_assignment', (req, res) => {
  logRequest("post", "create_assignment", req);
  createRequest(req, res, createAssignment);
});

app.post('/create_term', (req, res) => {
  logRequest("post", "create_term", req);
  createRequest(req, res, createTerm);
});

app.post('/modify_class', (req, res) => {
  logRequest("post", "modify_class", req);
  createRequest(req, res, modifyClass);
});

app.post('/modify_category', (req, res) => {
  logRequest("post", "modify_category", req);
  createRequest(req, res, modifyCategory);
});

app.post('/modify_grade', (req, res) => {
  logRequest("post", "modify_grade", req);
  createRequest(req, res, modifyGrade);
});

app.post('/modify_assignment', (req, res) => {
  logRequest("post", "modify_assignment", req);
  createRequest(req, res, modifyAssignment);
});

app.post('/modify_term', (req, res) => {
  logRequest("post", "modify_term", req);
  createRequest(req, res, modifyTerm);
});

app.post('/delete_assignment', (req, res) => {
  logRequest("post", "delete_assignment", req);
  createRequest(req, res, deleteAssignment);
});

app.post('/delete_category', (req, res) => {
  logRequest("post", "delete_category", req);
  createRequest(req, res, deleteCategory);
});

app.post('/delete_class', (req, res) => {
  logRequest("post", "delete_class", req);
  createRequest(req, res, deleteClass);
});

app.post('/delete_grade', (req, res) => {
  logRequest("post", "delete_grade", req);
  createRequest(req, res, deleteGrade);
});

app.post('/delete_term', (req, res) => {
  logRequest("post", "delete_term", req);
  createRequest(req, res, deleteTerm);
});

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
    }
  });
}
