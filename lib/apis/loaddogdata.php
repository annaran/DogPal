<?php

require_once('db.php');

$sDogId = $_GET['id'] ?? '';

if (empty($sDogId)) {
	
	exit;
}

try {

$stmt = $db->prepare('SELECT d.*, b.breed, p.url,  s.size, u.location
					 FROM dogs d
					 left join pictures p
					 on d.picture_id = p.id
					 left join breeds b 
					 on d.breed_id = b.id 
					 left join sizes s 
					 on d.size_id = s.id 
					 left join users u 
					 on u.id = d.owner_id
					  where d.id = :iDogId');
$stmt->bindValue(':iDogId', intval($sDogId));
$stmt->execute();
$row = $stmt->fetch();
} catch (PDOEXception $ex) {
    echo $ex;
}
echo json_encode($row);



