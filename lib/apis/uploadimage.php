<?php
	require_once('db.php');


    $sImageName = $_FILES['image']['name'];
    $sUserId = $_POST['id'];
    $sImageType = $_POST['imagetype'];
    $sDogId = $_POST['dogid'];
    $errMsg = '';
    $sOldPictureName = null;
    $iOldPictureId = null; 

	$imagePath = 'images/'.$sImageName;
    $sUrl = $_FILES['image']['tmp_name'];
    
    if (empty($sUserId)) {
        $errMsg = 'Userid is empty';
    }

    if (empty($sImageName)) {
        $errMsg = 'Image name is empty';
    }

    if (empty($sImageType)) {
        $errMsg = 'Image type empty';
    }





    if ($errMsg != '') {
        $aUploadImageResp = array("status"=>"Error", "msg"=>$errMsg);
        echo json_encode($aUploadImageResp);
    } else 
    {

        
        move_uploaded_file($sUrl, $imagePath);
        try {
            $db->beginTransaction();
            if($sImageType == 'U'){            
            /* retrieve old user image info */
            $stmt = $db->prepare('Select p.* 
                                    from users u
                                    left join pictures p
                                    on u.picture_id = p.id 
                                    where u.id = :iUserId');
            $stmt->bindValue(':iUserId', intval($sUserId));
            $stmt->execute();
            $aRows = $stmt->fetch();
            $sOldPictureName = $aRows->url;
            $iOldPictureId = $aRows->id;
            } else
            {
               
                /* retrieve old dog image info */
                $stmt = $db->prepare('Select p.* 
                                        from dogs d
                                        left join pictures p
                                        on d.picture_id = p.id 
                                        where d.id = :iDogId');
                $stmt->bindValue(':iDogId', intval($sDogId));
                $stmt->execute();
                $aRows = $stmt->fetch();
                $sOldPictureName = $aRows->url;
                $iOldPictureId = $aRows->id;
            }

            /* delete old image from db */
            if($iOldPictureId != null){
            $stmt = $db->prepare('delete from pictures 
            where id=:iOldPictureId         
                                ');
            $stmt->bindValue(':iOldPictureId', $iOldPictureId);
            $stmt->execute();
            }

            $stmt = $db->prepare('Insert into pictures(url)                                   
                                    values(:sImageName)');           
            $stmt->bindValue(':sImageName', $sImageName);
            $stmt->execute();
            $iPictureId = $db->lastInsertId();

            if($sImageType == 'U'){
            $stmt = $db->prepare('Update users
                                  set picture_id = :iPictureId                       
                                  where id = :iUserId');
            $stmt->bindValue(':iUserId', intval($sUserId));
            $stmt->bindValue(':iPictureId', $iPictureId);
            $stmt->execute();        

            } else {             
                $stmt = $db->prepare('Update dogs
                set picture_id = :iPictureId                      
                where id = :iDogId');
                $stmt->bindValue(':iDogId', intval($sDogId));
                $stmt->bindValue(':iPictureId', $iPictureId);
                $stmt->execute();
            }  

            /* transaction end */
            $db->commit();

                       /* delete old image from server */
                       if($sOldPictureName != null){
                       if (file_exists('images/' . $sOldPictureName)) {
                        unlink('images/' . $sOldPictureName);
                    }
                }

            $aUploadImageResp = array("status"=>"Success", "msg"=>"Image uploaded");
            echo json_encode($aUploadImageResp);

 
    
        } catch (PDOEXception $ex) {
            $db->rollback();
            echo $ex;
            $aUploadImageResp = array("status"=>"Success", "msg"=>$ex);
            echo json_encode($aUploadImageResp);
        }
    
    }