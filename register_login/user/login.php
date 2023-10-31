<?php
session_start();

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

if (isset($_POST["username"]) && isset($_POST["pass_word"])) {
    $username = $_POST["username"];
    $password = $_POST["pass_word"];

    $sql = "SELECT * FROM data_user WHERE username = '$username' AND pass_word = '$password'";
    $resultOfQuery = $connectNow->query($sql);

    if ($resultOfQuery->num_rows > 0) {
        $userRecord = array();
        while ($rowFound = $resultOfQuery->fetch_assoc()) {
            $userRecord[] = $rowFound;
        }

        $secretKey = '37c20f19f3272b5ccc3a5d80587eb9deb3f4afcf568c4280fb195568da8eb1a2';

        if (!isset($_SESSION['exp']) || $_SESSION['exp'] < time()) {
            $_SESSION['exp'] = time() + (5 * 60); 
        }

        $exp = $_SESSION['exp'];

        $header = base64UrlEncode(json_encode([
            'alg' => 'HS256',
            'typ' => 'JWT'
        ]));

        $payload = base64UrlEncode(json_encode([
            'username' => $username,
            'email' => $userRecord[0]['email'],
            'role' => $userRecord[0]['role'],
            'exp' => $exp
        ]));

        $dataToSign = "$header.$payload";
        $signature = generateSignature($dataToSign, $secretKey);
        $jwt = "$dataToSign.$signature";

        echo json_encode(
            array(
                "success" => true,
                "token" => $jwt,
                "userData" => $userRecord[0]
            )
        );
        return;
    } else {
        echo json_encode(array("success" => false));
    }
}
?>
