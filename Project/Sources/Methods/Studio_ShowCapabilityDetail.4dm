#DECLARE()

// Render the restrictions of the selected capability entry. This is the
// part of the registry that matters: "read: yes" says nothing about
// whether pages, alpha or metadata survive.

var $rows; $entries : Collection
var $row; $entry : Object
var $text : Text
var $item : Text
var $index : Integer

$rows:=Form.capRows
$entries:=Form.capabilities
If (($rows=Null) | ($entries=Null) | ($rows.length=0))
	return
End if

$index:=0
If (Form.selectedCap#Null)
	If (Value type(Form.selectedCap)=Is object)
		$index:=$rows.indexOf(Form.selectedCap)
	End if
End if
If ($index<0)
	$index:=0
End if

$row:=$rows[$index]
$entry:=$entries[$index]

$text:=$row.format+" · backend "+$row.backend+"\n"
$text:=$text+"read "+$row.read+" · write "+$row.write+" · alpha "+$row.alpha \
	+" · animation "+$row.animation+" · pages "+Choose($entry.pages_read; "read"; "—")+"\n"
$text:=$text+"bit depth: "+$entry.bit_depth_limit+"\n"
$text:=$text+"metadata read: "+$entry.metadata_read.join(", ")+"\n"
$text:=$text+"metadata write: "+Choose($entry.metadata_write.length>0; $entry.metadata_write.join(", "); "none")+"\n\n"
$text:=$text+"Restrictions:\n"

If ($entry.restrictions.length=0)
	$text:=$text+"• none reported"
Else
	For each ($item; $entry.restrictions)
		$text:=$text+"• "+$item+"\n"
	End for each
End if

Form.capDetail:=$text
Form.status:="Capability detail: "+$row.format
