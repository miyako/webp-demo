//%attributes = {"invisible":true}
// Developer helper used to produce the README screenshots. Not part of the demo.
//
//   /Applications/4D.app/Contents/MacOS/4D --project Project/webp-demo.4DProject \
//     --startup-method=CaptureScreenshots --dataless \
//     --user-param "Action:Page:/path/to/output.png"
//
// Requires full 4D (tool4d has no DIALOG, and headless auto-dismisses the form).
// The page change and the screenshot must be in separate cycles: this method
// only opens the form, CaptureAct changes state, CaptureShot captures.

var $userParamValue : Text
var $unused : Real
$unused:=Get database parameter(User param value; $userParamValue)

var $params : Collection
$params:=Split string($userParamValue; ":")

If ($params.length<3)
	QUIT 4D
End if

var $form : Object
$form:=New object( \
	"__action"; $params[0]; \
	"__page"; Num($params[1]); \
	"__screenshotPath"; $params.slice(2).join(":"))

If ($form.__page<1)
	$form.__page:=1
End if

var $window : Integer
$window:=Open form window("Studio")
DIALOG("Studio"; $form; *)

CALL FORM($window; Formula(CaptureAct))
