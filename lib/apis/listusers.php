<?php

require_once('db.php');
$sUserId = $_GET['id'] ?? '';


$query = 'SELECT u.*, p.url 
			FROM users u
			left join pictures p 
			on u.picture_id = p.id 
			where u.id != :iUserId';

$stmt = $db->prepare($query);
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);



