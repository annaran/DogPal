<?php

require_once('db.php');
$sUserId = $_GET['id'] ?? '';
$query = 'SELECT d.*, b.breed, p.url, u.location, s.size
			FROM dogs d			
			left join pictures p			
			on d.picture_id = p.id
			left join users u			
			on d.owner_id = u.id
			left join breeds b 
			on d.breed_id = b.id 
			left join sizes s 
			on d.size_id = s.id 
			where d.owner_id != :iUserId';
$stmt = $db->prepare($query);
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);



