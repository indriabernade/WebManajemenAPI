<?php
include '../connect.php';

if(isset($_POST["email"])){

   $email = $_POST["email"];
   $sqlQuery = "SELECT * FROM data_user WHERE email = '$email'";
   $resultOfQuery = $connectNow->query($sqlQuery);

if($resultOfQuery->num_rows > 0)
{
echo json_encode(array("emailFound"=>true));
}
else
{
echo json_encode(array("emailFound"=>false));
}
}

?>