<?php
include '../connect.php';

if (isset($_POST["username"]) && isset($_POST["email"]) && isset($_POST["pass_word"]) && isset($_POST["role"])) {
    $username = $_POST["username"];
    $email = $_POST["email"];
    $password = $_POST["pass_word"];
    $role = $_POST["role"];

    $createdAt = date("Y-m-d H:i:s"); // Current date and time

    $sql = "INSERT INTO data_user (username, email, pass_word, role, created_at) VALUES ('$username', '$email', '$password', '$role', '$createdAt')";
    $resultOfQuery = $connectNow->query($sql);

    if ($resultOfQuery) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false));
    }
}
?>