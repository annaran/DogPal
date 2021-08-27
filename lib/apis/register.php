<?php 


require_once('db.php');

$sEmail = $_POST['email'] ?? '';
$sPassword = $_POST['password'] ?? '';

$errMsg = '';

/* validate email */

if (empty($sEmail)) {
    $errMsg = 'Email cannot be empty';
}
if (!filter_var($sEmail, FILTER_VALIDATE_EMAIL)) {
    $errMsg = 'This is not a valid email address';
}

/* validate password */
$sPassword = $_POST['password'] ?? '';
if (empty($sPassword)) {
    $errMsg = 'Password cannot be empty';
}
if (strlen($sPassword) < 4) {
    $errMsg = 'Password must be at least 4 characters long';
}
if (strlen($sPassword) > 50) {
    $errMsg = 'Password too long';
}

/* validate confirm password */
$sPassword2 = $_POST['password2'] ?? '';
if (empty($sPassword2)) {
    $errMsg = 'Repeated password cannot be empty';
}

if ($sPassword != $sPassword2) {
    $errMsg ='Passwords do not match';
}


if ($errMsg != '') {
	$aRegisterResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aRegisterResp);
} else 
{
	try {
		$stmt = $db->prepare('SELECT * FROM users where email like :sEmail');
		$stmt->bindValue(':sEmail', $sEmail);
		$stmt->execute();
		$aRows = $stmt->fetchAll();

	} catch (PDOEXception $ex) {
		echo json_encode($ex);
	}
	

		if (count($aRows) > 0) {
			$aRegisterResp = array("status"=>"Error", "msg"=>"Email already registered");
			echo json_encode($aRegisterResp);
		} else {


				try {
					$stmt = $db->prepare("insert into users(email,password)
													values(:sEmail,:sPassword)");


					$stmt->bindValue(':sEmail', $sEmail);
					$stmt->bindValue(':sPassword', password_hash($sPassword, PASSWORD_DEFAULT));
					$stmt->execute();
					

				} catch (PDOEXception $ex) {
					echo json_encode($ex);
				}
				$aRegisterResp = array("status"=>"Success", "msg"=>"Account registered successfuly");
			echo json_encode($aRegisterResp);	
				
		}

}









