<?php

require_once('db.php');

$sUserId = $_GET['userid'] ?? '';
$sDate = $_GET['date'] ?? '';
$sTimeslots = $_GET['timeslots'] ?? '';
$sLocations = $_GET['locations'] ?? '';
$sSizes = $_GET['sizes'] ?? '';


$sWhere = '';





if (!empty($sTimeslots) && $sTimeslots != 'null' ) {
	$sWhere = $sWhere . " and timeslot_id in (" . $sTimeslots . ")";
}

if (!empty($sSizes) && $sSizes != 'null' ) {
	$sWhere = $sWhere . " and size_id in (" . $sSizes . ")";
}


if (!empty($sLocations) && $sLocations != 'null' ) {
	$sWhere = $sWhere . " and location in (" . $sLocations . ")";
}



if (!empty($sDate)) {
	$sWhere = $sWhere . " and date = cast('" . $sDate."' as date)";
}



try {

	$query = 'SELECT c.*, t.description, d.name, b.breed, p.url, u.location, s.size
	FROM calendar c					
	left join timeslots t
	on t.id = c.timeslot_id 
	left join dogs d 
	on c.dog_id = d.id 
	left join pictures p			
	on d.picture_id = p.id 
	left join users u			
	on d.owner_id = u.id  
	left join sizes s 
	on d.size_id = s.id 
	left join breeds b 
	on d.breed_id = b.id         
	where c.status = "A" and d.owner_id != :iUserId ' . $sWhere ;


$stmt = $db->prepare($query);
$stmt->bindValue(':iUserId', intval($sUserId));
$stmt->execute();
$rows = $stmt->fetchAll();

echo json_encode($rows);
} catch (PDOEXception $ex) {
    echo $ex;
}

