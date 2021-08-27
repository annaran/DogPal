<?php 


require_once('db.php');

$sOwnerId = $_POST['ownerid'] ?? '';
$sWalkerId = $_POST['walkerid'] ?? '';
$sReview = $_POST['review'] ?? '';
$sRating = $_POST['rating'] ?? '';
$sTitle = $_POST['title'] ?? '';

$errMsg = '';

/* validate title */
if (strlen($sTitle) < 2) {
    $errMsg = 'Title must be at least 2 characters long';
}


if ($errMsg != '') {
	$aAddReviewResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aAddReviewResp);
} else 
{
	
				try {
					$stmt = $db->prepare("insert into reviews(owner_id,walker_id,rating,title,review)
													values(:iOwnerId,:iWalkerId,:iRating,:sTitle,:sReview)");

					$stmt->bindValue(':iOwnerId', intval($sOwnerId));
					$stmt->bindValue(':iWalkerId', intval($sWalkerId));
					$stmt->bindValue(':iRating', intval($sRating));
					$stmt->bindValue(':sTitle', $sTitle);
					$stmt->bindValue(':sReview', $sReview);
					
					$stmt->execute();
					$iDogId = $db->lastInsertId();
					$aAddReviewResp = array("status"=>"Success", "msg"=>"Review added");
					echo json_encode($aAddReviewResp);	
					

				} catch (PDOEXception $ex) {
					$aAddReviewResp = array("status"=>"Error", "msg"=>"Exception adding review");
					echo json_encode($aAddReviewResp);
				}
			
				
	

}









