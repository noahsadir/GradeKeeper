// app.ts
/*
 Copyright (c) 2021-2022 Noah Sadir

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
import { getClassSchedule } from './get_class_schedule';

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
var con = mysql.createConnection(credentials);
var isConnected: boolean = false;

con.connect(function(err: QueryError) {
  if (err) throw err;
  isConnected = true;
});

app.post('/create_user', (req, res) => {
  logRequest("post", "create_user", req);
  createUser(con, req, res);
});

app.post('/authenticate_user', (req, res) => {
  logRequest("post", "authenticate_user", req);
  authenticateUser(con, req, res);
});

app.post('/create_class', (req, res) => {
  logRequest("post", "create_class", req);
  createClass(con, req, res);
});

app.post('/set_class_schedule', (req, res) => {
  logRequest("post", "set_class_schedule", req);
  setClassSchedule(con, req, res);
});

app.post('/get_class_schedule', (req, res) => {
  logRequest("post", "get_class_schedule", req);
  getClassSchedule(con, req, res);
});

app.post('/get_classes', (req, res) => {
  logRequest("post", "get_classes", req);
  getClasses(con, req, res);
});

app.post('/get_structure', (req, res) => {
  logRequest("post", "get_structure", req);
  getStructure(con, req, res);
});

app.post('/get_logs', (req, res) => {
  logRequest("post", "get_logs", req);
  getLogs(con, req, res);
});

app.post('/get_terms', (req, res) => {
  logRequest("post", "get_terms", req);
  getTerms(con, req, res);
});

app.post('/get_assignments', (req, res) => {
  logRequest("post", "get_assignments", req);
  getAssignments(con, req, res);
});

app.post('/create_category', (req, res) => {
  logRequest("post", "create_category", req);
  createCategory(con, req, res);
});

app.post('/create_grade', (req, res) => {
  logRequest("post", "create_grade", req);
  createGrade(con, req, res);
});

app.post('/create_assignment', (req, res) => {
  logRequest("post", "create_assignment", req);
  createAssignment(con, req, res);
});

app.post('/create_term', (req, res) => {
  logRequest("post", "create_term", req);
  createTerm(con, req, res);
});

app.post('/modify_class', (req, res) => {
  logRequest("post", "modify_class", req);
  modifyClass(con, req, res);
});

app.post('/modify_category', (req, res) => {
  logRequest("post", "modify_category", req);
  modifyCategory(con, req, res);
});

app.post('/modify_grade', (req, res) => {
  logRequest("post", "modify_grade", req);
  modifyGrade(con, req, res);
});

app.post('/modify_assignment', (req, res) => {
  logRequest("post", "modify_assignment", req);
  modifyAssignment(con, req, res);
});

app.post('/modify_term', (req, res) => {
  logRequest("post", "modify_term", req);
  modifyTerm(con, req, res);
});

app.post('/delete_assignment', (req, res) => {
  logRequest("post", "delete_assignment", req);
  deleteAssignment(con, req, res);
});

app.post('/delete_category', (req, res) => {
  logRequest("post", "delete_category", req);
  deleteCategory(con, req, res);
});

app.post('/delete_class', (req, res) => {
  logRequest("post", "delete_class", req);
  deleteClass(con, req, res);
});

app.post('/delete_grade', (req, res) => {
  logRequest("post", "delete_grade", req);
  deleteGrade(con, req, res);
});

app.post('/delete_term', (req, res) => {
  logRequest("post", "delete_term", req);
  deleteTerm(con, req, res);
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
