<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: myHeader");

$serverHost = "localhost";
$user = "root";
$password = "123456";
$database = "manajemen_api";

$connectNow = new mysqli($serverHost, $user, $password, $database);

/*$username = "root";
$password = "indria123!";
$host = "172.17.32.141";
$database = "manajemen_api";
$port = "3307"; 

$connectNow = new mysqli($host. ':' .$port, $username, $password, $database);*/

/*$conn = mysql_connect($host.':'.$port, $username, $password);
$db=mysql_select_db($database,$conn);*/

?>