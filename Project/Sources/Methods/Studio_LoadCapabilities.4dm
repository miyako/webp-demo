#DECLARE()

// Ask the bundled CLI what this build can actually do, and display the
// machine-readable answer. The registry is data: the demo never hard-codes
// the format matrix.

var $converter : cs.WebP.Converter
var $result : Object
var $rows : Collection
var $entry; $row : Object
var $alpha; $animation; $metadata : Text

$converter:=cs.WebP.Converter.new("macOS-universal")
$result:=$converter.capabilities()

If (Not($result.ok))
	Form.capRows:=New collection
	Form.capSummary:="capabilities() failed"
	Form.capDetail:=$result.failureKind+" / "+$result.error.code+"\n"+$result.error.message
	return
End if

$rows:=New collection
For each ($entry; $result.value.capabilities)
	$alpha:=Choose($entry.alpha_read & $entry.alpha_write; "read+write"; Choose($entry.alpha_read; "read"; Choose($entry.alpha_write; "write"; "—")))
	$animation:=Choose($entry.animation_read & $entry.animation_write; "read+write"; Choose($entry.animation_read; "read"; Choose($entry.animation_write; "write"; "—")))
	If ($entry.metadata_write.length>0)
		$metadata:=Uppercase($entry.metadata_write.join(", "))
	Else
		$metadata:="—"
	End if
	$row:=New object( \
		"format"; Uppercase($entry.format); \
		"read"; Choose($entry.read; "yes"; "no"); \
		"write"; Choose($entry.write; "yes"; "no"); \
		"alpha"; $alpha; \
		"animation"; $animation; \
		"metadata"; $metadata; \
		"backend"; $entry.backend)
	$rows.push($row)
End for each

Form.capRows:=$rows
Form.capabilities:=$result.value.capabilities
Form.capSummary:=String($rows.length)+" formats reported by webp-convert " \
	+Form.cliVersion+" · protocol "+String($result.value.protocol)

If ($rows.length>0)
	Form.selectedCap:=Null
	Studio_ShowCapabilityDetail
End if

Form.status:="Capabilities refreshed"
