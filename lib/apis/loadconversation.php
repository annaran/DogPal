<?php

require_once('db.php');

$sUserId = $_GET['id'] ?? '';
$sUserId2 = $_GET['id2'] ?? '';


if (empty($sUserId)) {
	$errMsg = 'Userid cannot be empty';
	exit;
}

if (empty($sUserId2)) {
	$errMsg = 'Userid2 cannot be empty';
	exit;
}


try {

$stmt = $db->prepare('SELECT m.*, s.displayname as sender, r.displayname as receiver 
					FROM messages m
					left join users s
					on m.sender_id = s.id
					left join users r
					on m.receiver_id = r.id
					where (sender_id = :iUserId and receiver_id = :iUserId2) or (sender_id = :iUserId2 and receiver_id = :iUserId) 		               
					order by m.id desc'								 
			
					);
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->bindValue(':iUserId2', intval($sUserId2));
$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}




