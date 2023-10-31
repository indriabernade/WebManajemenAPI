<?php
include '../connect.php';

if (isset($_POST["id"])) {
    $id = (int)$_POST["id"]; // Convert id to integer

    $sql = "UPDATE data_user SET notice = NULL WHERE id = $id";
    $resultOfQuery = $connectNow->query($sql);

    if ($resultOfQuery) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false));
    }
}
?>
