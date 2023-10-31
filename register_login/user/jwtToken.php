<?php
include '../connect.php';

// Check if the 'token' key exists in the POST request
if (isset($_POST['token'])) {
    $jwtToken = $_POST['token'];

    // Verify and decode the JWT token
    $secretKey = '37c20f19f3272b5ccc3a5d80587eb9deb3f4afcf568c4280fb195568da8eb1a2'; // Replace with your actual secret key

    try {
        $decodedToken = JWT::decode($jwtToken, $secretKey, ['HS256']);
        $userData = json_decode(json_encode($decodedToken), true);

        // Retrieve the user's login information from the decoded token
        $username = $userData['username'];
        $email = $userData['email'];
        // Other user information...

        // Verify that the token's information matches the user's login information
        if ($username === $_POST['username'] && $email === $_POST['email']) {
            // Token verification successful
            // Proceed with the database query

            // Create the SQL query
            $sql = "SELECT * FROM data_user WHERE username = '$username' AND pass_word = '$password'";

            // Execute the query
            $resultOfQuery = $connectNow->query($sql);

            if ($resultOfQuery->num_rows > 0) {
                // User record found
                // You can process the record or return it as needed
                $userRecord = $resultOfQuery->fetch_assoc();
                echo json_encode(array('status' => 'success', 'userData' => $userRecord));
            } else {
                // User record not found
                echo json_encode(array('status' => 'error', 'message' => 'User record not found'));
            }
        } else {
            // Token verification failed
            // Return an error response to the Flutter app
            echo json_encode(array('status' => 'error', 'message' => 'Token verification failed'));
        }
    } catch (Exception $e) {
        // Invalid token or other error occurred
        // Return an error response to the Flutter app
        echo json_encode(array('status' => 'error', 'message' => 'Invalid token'));
    }
} else {
    // 'token' key not found in the POST request
    // Return an error response to the Flutter app
    echo json_encode(array('status' => 'error', 'message' => 'Token not provided'));
}
?>
