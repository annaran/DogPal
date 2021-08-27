<?php

require_once('db.php');






$query = 'SELECT t.* 
			FROM timeslots t
			
			';

$stmt = $db->prepare($query);

$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);



