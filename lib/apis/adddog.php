<?php 


require_once('db.php');

$iUserId = $_POST['id'] ?? '';
$sName = $_POST['name'] ?? '';
$sDescription = $_POST['description'] ?? '';
$iSize = $_POST['size'] ?? '';
$iBreed = $_POST['breed'] ?? '';

$errMsg = '';

/* validate name */
if (strlen($sName) < 2) {
    $errMsg = 'Name must be at least 2 characters long';
}


if ($errMsg != '') {
	$aAddDogResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aAddDogResp);
} else 
{
	
				try {
					$stmt = $db->prepare("insert into dogs(name,description,size_id,breed_id,owner_id)
													values(:sName,:sDescription,:iSize,:iBreed,:iUserId)");

					$stmt->bindValue(':sName', $sName);
					$stmt->bindValue(':sDescription', $sDescription);
					$stmt->bindValue(':iSize', $iSize);
					$stmt->bindValue(':iBreed', $iBreed);
					$stmt->bindValue(':iUserId', $iUserId);
					
					$stmt->execute();
					$iDogId = $db->lastInsertId();
					$aAddDogResp = array("status"=>"Success", "msg"=>"Dog added", "dogid"=>$iDogId);
					echo json_encode($aAddDogResp);	
					

				} catch (PDOEXception $ex) {
					echo json_encode($ex);
				}
			
				
	

}









