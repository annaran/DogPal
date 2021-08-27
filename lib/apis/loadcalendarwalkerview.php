<?php

require_once('db.php');

$sDogId = $_GET['dogid'] ?? '';
$sUserId = $_GET['id'] ?? '';



if (empty($sDogId)) {

	exit;
}

if (empty($sUserId)) {

	exit;
}


try {

$stmt = $db->prepare('SELECT c.*, t.description
					FROM calendar c					
					left join timeslots t
					on t.id = c.timeslot_id            
					where c.dog_id = :iDogId and (c.walker_id is null or c.walker_id = :iUserId)						 
					order by c.timeslot_id 
					');
$stmt->bindValue(':iDogId', intval($sDogId));
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}




