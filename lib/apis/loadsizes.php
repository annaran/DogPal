<?php

require_once('db.php');

$query = 'SELECT *
			FROM sizes		
		
';
$stmt = $db->prepare($query);

$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);



