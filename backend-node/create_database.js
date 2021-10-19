var mysql = require('mysql2');
var credentials = require('./credentials.json');
var con = mysql.createConnection(credentials);

con.connect(function(err) {
  if (err) throw err;
  var sql = "";

});
