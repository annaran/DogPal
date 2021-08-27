<?php 


require_once('db.php');

$sUserId = $_POST['id'] ?? '';
$sPassword = $_POST['password'] ?? '';
$sNewPassword = $_POST['newpassword'] ?? '';
$sNewPassword2 = $_POST['newpassword2'] ?? '';

$errMsg = '';


if (empty($sUserId)  ) {
	$errMsg = 'Id cannot be empty';
	
}

if ( empty($sPassword) || empty($sNewPassword) || empty($sNewPassword2) ) {
	$errMsg = 'Fill out all fields';	
}



/* validate new password */
$sNewPassword = $_POST['newpassword'] ?? '';

if (strlen($sNewPassword) < 4) {
    $errMsg = 'Password must be at least 4 characters long';
}
if (strlen($sNewPassword) > 50) {
    $errMsg = 'Password too long';
}

/* validate confirm new password */

if ($sNewPassword != $sNewPassword2) {
    $errMsg ='Passwords do not match';
}



if($errMsg != '')
{
	$aUpdatePassResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aUpdatePassResp);
} else
{

	$stmt = $db->prepare('SELECT * FROM users where id like :iUserId');
	$stmt->bindValue(':iUserId', intval($sUserId));
	$stmt->execute();
	$aRow = $stmt->fetch();
	
	
	$sHashedPassword = $aRow->password;
	
	
	if (!password_verify($sPassword, $sHashedPassword)) {
		
		$errMsg = 'Current password incorrect';
		$aUpdatePassResp = array("status"=>"Error", "msg"=>$errMsg);
		echo json_encode($aUpdatePassResp);
	} else {


		try {
			$stmt = $db->prepare('Update users 
			set password = :sHashedPassword			
			where id like :iUserId');
			$stmt->bindValue(':iUserId', intval($sUserId));
			$stmt->bindValue(':sHashedPassword', password_hash($sNewPassword, PASSWORD_DEFAULT));
			$stmt->execute();
			$aUpdatePassResp = array("status"=>"Success", "msg"=>"Password updated");
			echo json_encode($aUpdatePassResp);
	
		} catch (PDOEXception $ex) {
			echo json_encode($ex);
		}



	}
	

	}
















