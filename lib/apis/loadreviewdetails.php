<?php

require_once('db.php');

$sReviewId = $_GET['id'] ?? '';

if (empty($sReviewId)) {
	
	exit;
}

try {

$stmt = $db->prepare('SELECT r.*, u.displayname, p.url, u.location
					 FROM reviews r
					 left join users u 
					 on u.id = r.owner_id
					 left join pictures p
					 on u.picture_id = p.id				
					 where r.id = :iReviewId');
$stmt->bindValue(':iReviewId', intval($sReviewId));
$stmt->execute();
$row = $stmt->fetch();
} catch (PDOEXception $ex) {
    echo $ex;
}
echo json_encode($row);



