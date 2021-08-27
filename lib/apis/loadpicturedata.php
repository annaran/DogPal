<?php

require_once('db.php');

$sUserId = $_GET['id'] ?? '';
$sDogId = $_GET['dogid'] ?? '';
$sImageType = $_GET['imagetype'] ?? '';



if (empty($sUserId)) {
	
	exit;
}


if (empty($sImageType)) {
	
	exit;
}


try {

	if($sImageType == 'D')
	{
		$stmt = $db->prepare('SELECT d.*, p.url
		FROM dogs d
		left join pictures p
		on d.picture_id = p.id
		 where d.id = :iDogId');
		$stmt->bindValue(':iDogId', intval($sDogId));
		$stmt->execute();
		$row = $stmt->fetch();
	} else {

		$stmt = $db->prepare('SELECT u.*, p.url
							FROM users u
							left join pictures p
							on u.picture_id = p.id
							where u.id = :iUserId');
		$stmt->bindValue(':iUserId', intval($sUserId));
		$stmt->execute();
		$row = $stmt->fetch();
	}
} catch (PDOEXception $ex) {
    echo $ex;
}
echo json_encode($row);



