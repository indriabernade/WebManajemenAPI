<?php
include '../connect.php';

if(isset($_POST["id"]) && isset($_POST["notice"])) {
    $id = (int)$_POST["id"]; 
    $notice = $_POST["notice"];

    $sql = "UPDATE data_user SET notice = '$notice' WHERE id = $id";
    $resultOfQuery = $connectNow->query($sql);

    if($resultOfQuery) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false));
    }
}


?>
