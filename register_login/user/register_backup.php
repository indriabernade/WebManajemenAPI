<?php
include '../connect.php';

function base64UrlEncode($data)
{
    $urlSafeData = strtr(base64_encode($data), '+/', '-_');
    return rtrim($urlSafeData, '=');
}

function generateSignature($data, $secretKey)
{
    return base64UrlEncode(hash_hmac('sha256', $data, $secretKey, true));
}

if (isset($_POST["username"]) && isset($_POST["email"]) && isset($_POST["pass_word"]) && isset($_POST["role"])) {

    $username = $_POST["username"];
    $email = $_POST["email"];
    $password = $_POST["pass_word"];
    $role = $_POST["role"];

    $sql = "INSERT INTO data_user SET username = '$username', email = '$email', pass_word = '$password', role = '$role'";
    $resultOfQuery = $connectNow->query($sql);

    if ($resultOfQuery) {
        $header = base64UrlEncode(json_encode([
            'alg' => 'HS256',
            'typ' => 'JWT'
        ]));

        $payload = base64UrlEncode(json_encode([
            'username' => $username,
            'email' => $email,
            'role' => $role
        ]));

        $secretKey = 'your_secret_key'; // Replace with your actual secret key

        $dataToSign = "$header.$payload"; // Concatenate header and payload

        $signature = generateSignature($dataToSign, $secretKey);

        $jwt = "$dataToSign.$signature"; // Construct the JWT token

        $response = array("success" => true, "token" => $jwt);

        error_log(print_r($response, true)); // Print the response to the PHP error log

        echo json_encode($response);
    } else {
        $response = array("success" => false);

        error_log(print_r($response, true)); // Print the response to the PHP error log

        echo json_encode($response);
    }
}
?>