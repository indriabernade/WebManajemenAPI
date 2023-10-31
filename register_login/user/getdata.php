<?php
include '../connect.php';

if (isset($_GET['id'])) {
    $id = $connectNow->real_escape_string($_GET['id']);

    $sql = "SELECT * FROM data_user WHERE id = '$id'";
} else {
    $sql = "SELECT * FROM data_user";
}

$resultOfQuery = $connectNow->query($sql);

$data = array();
if ($resultOfQuery->num_rows > 0) {
    while ($row = $resultOfQuery->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode($data);

$connectNow->close();
?>
