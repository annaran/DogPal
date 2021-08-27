<?php 


require_once('db.php');

$sUserId = $_POST['senderid'] ?? '';
$sUserId2 = $_POST['receiverid'] ?? '';
$sMessage = $_POST['message'] ?? '';


$errMsg = '';

/* validate message */
if (strlen($sMessage) < 1) {
    $errMsg = 'Message cannot be empty';
}







if ($errMsg != '') {
	$aSendMessageResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aSendMessageResp);
} else 
{
	
				try {
					$stmt = $db->prepare("insert into messages(sender_id,receiver_id,message)
													values(:iUserId,:iUserId2,:sMessage)");

			
					$stmt->bindValue(':sMessage', $sMessage);
					$stmt->bindValue(':iUserId', intval($sUserId));
					$stmt->bindValue(':iUserId2', intval($sUserId2));
				
					
					$stmt->execute();
			
					$aSendMessageResp = array("status"=>"Success", "msg"=>"Message sent");
					echo json_encode($aSendMessageResp);	
					

				} catch (PDOEXception $ex) {
					echo json_encode($ex);
				}
			
				
	

}









