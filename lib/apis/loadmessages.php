<?php

require_once('db.php');

$sUserId = $_GET['id'] ?? '';


if (empty($sUserId)) {
	
	exit;
}

try {

$stmt = $db->prepare(
					'SELECT m.*, s.displayname as sender, r.displayname as receiver 
					FROM messages m
					left join users s
										 on m.sender_id = s.id
										 left join users r
										 on m.receiver_id = r.id
										               
										 
										 
					WHERE m.id IN (
						SELECT MAX(id) AS last_msg_id 
						FROM messages WHERE receiver_id = :iUserId OR sender_id = :iUserId
						GROUP BY IF(sender_id = :iUserId, receiver_id, sender_id)
					)
					order by m.id desc'
					 
);
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();
echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}




