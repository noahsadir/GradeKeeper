<?php
$error = $_SERVER['REDIRECT_STATUS'];
if (isset($_GET['error'])) {
  $error = $_GET['error'];
}

$explanation = "Unable to Perform Request";

if ($error == 400) {
  $explanation = "Bad Request";
} else if ($error == 401) {
  $explanation = "Not Authorized";
} else if ($error == 403) {
  $explanation = "Forbidden";
} else if ($error == 404) {
  $explanation = "Not Found";
} else if ($error == 503) {
  $explanation = "Service Temporarily Unavailable";
}

$html = '{"success": false, "error": "ERR_HTTP", "message": "Error '.$error.': '.$explanation.'"}';

header('Content-type: application/json');
echo($html);
?>
