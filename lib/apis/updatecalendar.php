<?php 


require_once('db.php');

$sDogId = $_POST['dogid'] ?? '';
$sTimeslotId = $_POST['timeslot'] ?? '';
$dDate = $_POST['date'] ?? '';
$sUserType = $_POST['usertype'] ?? '';
$sUserId = $_POST['id'] ?? '';
$iYesNo = $_POST['yesno'] ?? '';


$errMsg = '';
$status = '';
$iUserId = 0;
$statusMsg = 0;
$currstatus = '';

/* validate dogid */
if (strlen($sDogId) == '') {
    $errMsg = 'Dogid missing';
}

/* validate timeslot */
if (strlen($sTimeslotId) == '') {
    $errMsg = 'Timeslot missing';
}

/* validate dogid */
if (strlen($dDate) == '') {
    $errMsg = 'Date missing';
}




if ($errMsg != '') {
	$aUpdateCalendarResp = array("status"=>"Error", "msg"=>$errMsg);
	echo json_encode($aUpdateCalendarResp);
} else 

{
			
				/* does record exist */
				$stmt = $db->prepare('SELECT * FROM calendar where dog_id = :iDogId and date = :dDate and timeslot_id = :iTimeslotId');
				$stmt->bindValue(':iDogId', intval($sDogId));
				$stmt->bindValue(':iTimeslotId', intval($sTimeslotId));
				$stmt->bindValue(':dDate', $dDate);
				$stmt->execute();
				$aRows = $stmt->fetch();

				if (isset($aRows)){
					$currstatus = $aRows->status;
					$walkerid = $aRows->walker_id;
				}



		 
				if($sUserType == 'O')
				{

				/* record does not exist, inserting */
				if (!$aRows){
				try {
					$stmt = $db->prepare("insert into calendar(date,dog_id,timeslot_id, status)
													values(:dDate,:iDogId,:iTimeslotId,'A')");

					$stmt->bindValue(':dDate', $dDate);				
					$stmt->bindValue(':iDogId', intval($sDogId));
					$stmt->bindValue(':iTimeslotId', intval($sTimeslotId));
				
					
					$stmt->execute();
				
					$aUpdateCalendarResp = array("status"=>"Success", "msg"=>"Available timeslot added");
					echo json_encode($aUpdateCalendarResp);	
					

				} catch (PDOEXception $ex) {
					echo json_encode($ex);
				}
				} else {

					if($currstatus == "R" && $iYesNo == '1'){
						/* record exists, updating status to Confirmed */
						$status = "C";						
						$statusMsg = "Reservation confirmed";


						try {
							$stmt = $db->prepare('update calendar 
							set status = :status
							where dog_id = :iDogId and timeslot_id = :iTimeslotId and date = :dDate           
												');
												$stmt->bindValue(':iDogId', intval($sDogId));										
												$stmt->bindValue(':iTimeslotId', intval($sTimeslotId));
												$stmt->bindValue(':dDate', $dDate);
												$stmt->bindValue(':status', $status);
							$stmt->execute();
							$aUpdateCalendarResp = array("status"=>"Success", "msg"=>$statusMsg);
							echo json_encode($aUpdateCalendarResp);
								} catch (PDOEXception $ex) {
									echo json_encode($ex);
								}



					} elseif($currstatus == "C"){
						/* record exists, updating status to available, previous reservation cancelled */
						$status = "A";						
						$statusMsg = "Reservation cancelled";


						try {
							$stmt = $db->prepare('update calendar 
							set status = :status, walker_id = null
							where dog_id = :iDogId and timeslot_id = :iTimeslotId and date = :dDate           
												');
												$stmt->bindValue(':iDogId', intval($sDogId));										
												$stmt->bindValue(':iTimeslotId', intval($sTimeslotId));
												$stmt->bindValue(':dDate', $dDate);
												$stmt->bindValue(':status', $status);
							$stmt->execute();
							$aUpdateCalendarResp = array("status"=>"Success", "msg"=>$statusMsg);
							echo json_encode($aUpdateCalendarResp);
								} catch (PDOEXception $ex) {
									echo json_encode($ex);
								}



					}  elseif ($currstatus == "R" && $iYesNo == '0'){
						/* record exists, updating status to available, rejecting reservation */
						$status = "A";						
						$statusMsg = "Reservation rejected";


						try {
							$stmt = $db->prepare('update calendar 
							set status = :status, walker_id = null
							where dog_id = :iDogId and timeslot_id = :iTimeslotId and date = :dDate           
												');
												$stmt->bindValue(':iDogId', intval($sDogId));										
												$stmt->bindValue(':iTimeslotId', intval($sTimeslotId));
												$stmt->bindValue(':dDate', $dDate);
												$stmt->bindValue(':status', $status);
							$stmt->execute();
							$aUpdateCalendarResp = array("status"=>"Success", "msg"=>$statusMsg);
							echo json_encode($aUpdateCalendarResp);
								} catch (PDOEXception $ex) {
									echo json_encode($ex);
								}



					}
					
					elseif ($currstatus == "A")
					{
						/* record exists, available, deleting */
										
						$statusMsg = "Available timeslot removed";

						try {

							
								$stmt = $db->prepare('delete from calendar 
								where id=:iId         
													');
								$stmt->bindValue(':iId', $aRows->id);
							
								$stmt->execute();
								$aUpdateCalendarResp = array("status"=>"Success", "msg"=>$statusMsg);
								echo json_encode($aUpdateCalendarResp);
			
							} catch (PDOEXception $ex) {
								echo json_encode($ex);
							}


					} else {
						$errMsg = "Unable to update timeslot status";
						$aUpdateCalendarResp = array("status"=>"Error", "msg"=>$errMsg);
						echo json_encode($aUpdateCalendarResp);
					}


					
				
				
				}
				



			} else {

				if($currstatus == "A" and $walkerid == null){
					$status = "R";
					$iUserId = intval($sUserId);
					$statusMsg = "Timeslot reserved";
				} elseif ($currstatus == "R" and $walkerid == $sUserId)
				{
					$status = 'A';
					$iUserId = null;
					$statusMsg = "Reservation canceled";
				} elseif ($currstatus == "C" and $walkerid == $sUserId)
				{
					$status = 'A';
					$iUserId = null;
					$statusMsg = "Reservation canceled";
				}
				
				else {
					$errMsg = "Unable to update timeslot status";
				}

				if($errMsg != ''){
					$aUpdateCalendarResp = array("status"=>"Error", "msg"=>$errMsg);
					echo json_encode($aUpdateCalendarResp);

				} else{
				/*  updating status to Reserved / cancelling reservation (for walker) */
				try {
				$stmt = $db->prepare('update calendar 
				set status = :status, walker_id = :iUserId
				where dog_id = :iDogId and timeslot_id = :iTimeslotId and date = :dDate           
									');
									$stmt->bindValue(':iDogId', intval($sDogId));
									$stmt->bindValue(':iUserId', $iUserId);
									$stmt->bindValue(':iTimeslotId', intval($sTimeslotId));
									$stmt->bindValue(':dDate', $dDate);
									$stmt->bindValue(':status', $status);
				$stmt->execute();
				$aUpdateCalendarResp = array("status"=>"Success", "msg"=>$statusMsg);
				echo json_encode($aUpdateCalendarResp);
					} catch (PDOEXception $ex) {
						echo json_encode($ex);
					}
				}
				
			}



				


}









