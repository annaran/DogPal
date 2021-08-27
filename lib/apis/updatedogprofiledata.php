<?php 


require_once('db.php');



$sDogId = $_POST['id'] ?? '';
$sName = $_POST['name'] ?? '';
$sDescription = $_POST['description'] ?? '';
$sSizeId = $_POST['size_id'] ?? '';
$sBreedId = $_POST['breed_id'] ?? '';

$errMsg = '';

/* validate name */

if (empty($sName)) {
    $errMsg = 'Name cannot be empty';
}


if ($errMsg != '') {
	$aUpdateDogProfileDataResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aUpdateDogProfileDataResp);
} else 
{
	try {
		$stmt = $db->prepare('Update dogs
								set 
								name = :sName,								
								description = :sDescription,
								size_id = :iSizeId,
								breed_id = :iBreedId
							  where id = :iDogId');
		$stmt->bindValue(':iDogId', intval($sDogId));
		$stmt->bindValue(':iSizeId', intval($sSizeId));
		$stmt->bindValue(':iBreedId', intval($sBreedId));
		$stmt->bindValue(':sName', $sName);	
		$stmt->bindValue(':sDescription', $sDescription);
		$stmt->execute();
		

		$aUpdateDogProfileDataResp = array("status"=>"Success", "msg"=>"Dog profile updated");
		echo json_encode($aUpdateDogProfileDataResp);

	} catch (PDOEXception $ex) {
		echo $ex;
	}

}









