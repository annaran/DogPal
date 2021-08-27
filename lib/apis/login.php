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



if ($errMsg != '') {
	$aLoginResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aLoginResp);
} else 
{
	
		$stmt = $db->prepare('SELECT * FROM users where email like :sEmail');
		$stmt->bindValue(':sEmail', $sEmail);
		$stmt->execute();
		$aRows = $stmt->fetch();



		if (!isset($aRows->email)) {
			$aLoginResp = array("status"=>"Error", "msg"=>"Email not registered in the database");
			echo json_encode($aLoginResp);
		} else {
					
				$sHashedPassword = $aRows->password;
				if (!password_verify($sPassword, $sHashedPassword)) {
					$aLoginResp = array("status"=>"Error", "msg"=>"Password incorrect");
					echo json_encode($aLoginResp);
				} else {
					$iUserId = $aRows->id;	
					$aLoginResp = array("status"=>"Success", "userid"=>$iUserId);
					echo json_encode($aLoginResp);
				}			
					
				
				}

}









