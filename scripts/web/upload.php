<?php
    if (file_exists("phpuploads/" . $_FILES["file"]["name"]))
    {
        echo $_FILES["file"]["name"] . " already exists. ";
    }
    else
    {
        move_uploaded_file($_FILES["file"]["tmp_name"],
        "phpuploads/" . $_FILES["file"]["name"]);
        echo "Stored in: " . "phpuploads/" . $_FILES["file"]["name"];
    }
?>
