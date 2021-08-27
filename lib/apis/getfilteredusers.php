<?php

require_once('db.php');

$sUserId = $_GET['userid'] ?? '';
$sLocations = $_GET['locations'] ?? '';

$sWhere = '';


if (empty($sUserId)) {

	exit;
}

if (!empty($sLocations) && $sLocations != 'null' ) {
	$sWhere = $sWhere . " and location in (" . $sLocations . ")";
}

try {

$stmt = $db->prepare('SELECT u.*, p.url
					FROM users u
					left join pictures p			
					on u.picture_id = p.id        
					where u.id != :iUserId' . $sWhere );
$stmt->bindValue(':iUserId', intval($sUserId));

$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}




