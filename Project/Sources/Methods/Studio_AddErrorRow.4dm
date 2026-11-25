#DECLARE($scenario : Text; $result : Object)

// Append one failure (or unexpected success) to the Error Lab table and
// surface its envelope in the detail pane.

var $row : Object
var $kind; $code; $message : Text

If ($result.ok)
	$kind:="ok !"
	$code:="—"
	$message:="unexpected success — this case should fail"
Else
	$kind:=$result.failureKind
	$code:=$result.error.code
	$message:=$result.error.message
End if

$row:=New object( \
	"scenario"; $scenario; \
	"kind"; $kind; \
	"code"; $code; \
	"message"; $message; \
	"envelope"; JSON Stringify($result; *))

Form.errorsRows.push($row)
Form.errorDetail:=$row.envelope
Form.status:="Error Lab: "+$kind+" / "+$code
