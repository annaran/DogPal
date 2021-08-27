<?php

require_once('db.php');

$query = 'SELECT distinct location
			FROM users

';
$stmt = $db->prepare($query);

$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);



