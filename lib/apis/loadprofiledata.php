<?php

require_once('db.php');

$sUserId = $_GET['id'] ?? '';

if (empty($sUserId)) {

	exit;
}

try {

$stmt = $db->prepare('SELECT u.*, p.url
					 FROM users u
					 left join pictures p
					 on u.picture_id = p.id
					  where u.id = :iUserId');
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$row = $stmt->fetch();
} catch (PDOEXception $ex) {
    echo $ex;
}
echo json_encode($row);



