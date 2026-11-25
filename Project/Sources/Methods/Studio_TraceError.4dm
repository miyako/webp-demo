//%attributes = {"invisible":true}

// ON ERR CALL handler. 4D runtime errors are part of this demo's story: the
// corrupt fixture makes READ PICTURE FILE fail before the converter is even
// called. Record code, method, line and description instead of hiding it.

var $line : Text
$line:="ERROR "+String(Error code)+" in "+String(Error method)+":"+String(Error line) \
	+" — "+String(Error description)

LOG EVENT(Into system standard outputs; $line)

// do not let a failing trace write re-enter this handler
ON ERR CALL(""; ek local)

var $work : 4D.Folder
$work:=Studio_WorkFolder
var $file : 4D.File
var $existing : Text

$file:=$work.file("runtime-errors.log")
If ($file.exists)
	$existing:=$file.getText()
End if
$file.setText($existing+$line+"\n")
