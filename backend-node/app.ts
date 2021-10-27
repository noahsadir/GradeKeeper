/*******************************
 * app.ts                      *
 * --------------------------- *
 * Created by Noah Sadir       *
 *         on October 19, 2021 *
 *******************************/

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

import { getClasses } from './get_classes';
import { getLogs } from './get_logs';
import { getStructure } from './get_structure';
import { getAssignments } from './get_assignments';

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
    message: "Error 400: Bad Request"
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
