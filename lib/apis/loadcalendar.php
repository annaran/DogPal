<?php

require_once('db.php');

$sDogId = $_GET['dogid'] ?? '';



if (empty($sDogId)) {

	exit;
}



try {

$stmt = $db->prepare('SELECT c.*, t.description
					FROM calendar c					
					left join timeslots t
					on t.id = c.timeslot_id            
					where c.dog_id = :iDogId						 
			
					');
$stmt->bindValue(':iDogId', intval($sDogId));

$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}




