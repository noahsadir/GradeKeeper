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

import { createUser } from './create_user';
import { authenticateUser } from './authenticate_user';

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
  createUser(con, req, res);
});

app.post('/authenticate_user', (req, res) => {
  authenticateUser(con, req, res);
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
