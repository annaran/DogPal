<?php 


require_once('db.php');


$sEmail = $_POST['email'] ?? '';
$sUserId = $_POST['id'] ?? '';
$sLocation = $_POST['location'] ?? '';
$sDisplayName = $_POST['displayname'] ?? '';
$sDescription = $_POST['description'] ?? '';

$errMsg = '';

/* validate email */

if (empty($sEmail)) {
    $errMsg = 'Email cannot be empty';
}
if (!filter_var($sEmail, FILTER_VALIDATE_EMAIL)) {
    $errMsg = 'This is not a valid email address';
}



if ($errMsg != '') {
	$aUpdateProfileDataResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aUpdateProfileDataResp);
} else 
{
	try {
		$stmt = $db->prepare('Update users
								set email = :sEmail,
								displayname = :sDisplayName,
								location = :sLocation,
								description = :sDescription
							    where id = :iUserId');
		$stmt->bindValue(':iUserId', intval($sUserId));
		$stmt->bindValue(':sEmail', $sEmail);
		$stmt->bindValue(':sDisplayName', $sDisplayName);
		$stmt->bindValue(':sLocation', $sLocation);
		$stmt->bindValue(':sDescription', $sDescription);
		$stmt->execute();


		$aUpdateProfileDataResp = array("status"=>"Success", "msg"=>"Profile updated");
		echo json_encode($aUpdateProfileDataResp);

	} catch (PDOEXception $ex) {
		echo $ex;
	}

}









