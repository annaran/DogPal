<?php

require_once('db.php');

$sUserId = $_GET['id'] ?? '';

if (empty($sUserId)) {
	$errMsg = 'Userid cannot be empty';
	exit;
}

try {

$stmt = $db->prepare('SELECT r.*, u.displayname, p.url, u.location
					 FROM reviews r
					 left join users u 
					 on u.id = r.owner_id
					 left join pictures p
					 on u.picture_id = p.id		
			
					  where r.walker_id = :iUserId
					 order by date desc 
					  ');
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();
} catch (PDOEXception $ex) {
    echo $ex;
}
echo json_encode($rows);



