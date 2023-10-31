<?php
include '../connect.php';

if(isset($_POST["id"]) && isset($_POST["username"]) && isset($_POST["email"]) && isset($_POST["pass_word"]) && isset($_POST["role"])) {
    $id = (int)$_POST["id"]; // Convert id to integer
    $username = $_POST["username"];
    $email = $_POST["email"];
    $password = $_POST["pass_word"];
    $role = $_POST["role"];

    $sql = "UPDATE data_user SET username = '$username', email = '$email', pass_word = '$password', role = '$role' WHERE id = $id";
    $resultOfQuery = $connectNow->query($sql);

    if($resultOfQuery) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false));
    }
}


?>
