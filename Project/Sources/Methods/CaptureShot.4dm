//%attributes = {"invisible":true}
// Called via CALL FORM: the page is rendered now.

var $screenshot : Picture
var $file : 4D.File

FORM SCREENSHOT($screenshot)
$file:=File(Form.__screenshotPath)
$file.parent.create()
WRITE PICTURE FILE($file.platformPath; $screenshot)

ACCEPT
QUIT 4D
