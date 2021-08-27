<?php

require_once('db.php');


$sUserId = $_GET['id'] ?? '';





if (empty($sUserId)) {

	exit;
}


try {

$stmt = $db->prepare('SELECT c.*, t.description
					FROM calendar c					
					left join timeslots t
					on t.id = c.timeslot_id            
					where c.walker_id = :iUserId 						 
					order by c.timeslot_id 
					');

$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}




