#DECLARE()

// Convert every fixture to WebP with one fixed policy, including the two
// unreadable fixtures. The page is a small capability demo on its own:
// animated GIF becomes animated WebP, the multi-page TIFF is converted with
// an explicit page, the 750 KB BMP collapses to a few KB, and the two bad
// files fail one by one without aborting the batch.

var $converter : cs.WebP.Converter
var $work : 4D.Folder
var $rows : Collection
var $sample; $row; $inspection; $result; $options : Object
var $input; $output : 4D.File
var $inBytes; $outBytes; $totalIn; $totalOut : Real
var $ok; $failed; $blocked : Integer
var $format; $note : Text

$rows:=New collection
$converter:=cs.WebP.Converter.new("macOS-universal")
$work:=Studio_WorkFolder
$totalIn:=0
$totalOut:=0
$ok:=0
$failed:=0
$blocked:=0

For each ($sample; Form.samples)

	$input:=Studio_SampleFile($sample.sample)
	$inBytes:=0
	$inspection:=$converter.inspect($input)
	$options:=New object("to"; "webp"; "quality"; 80; "overwrite"; True)

	$row:=New object( \
		"sample"; $sample.label; \
		"input"; "?"; \
		"mode"; "—"; \
		"inSize"; "—"; \
		"outSize"; "—"; \
		"saving"; "—"; \
		"result"; "—"; \
		"note"; "")

	If ($inspection.ok)
		$format:=$inspection.value.input.format
		$row.input:=Uppercase($format)
		$row.inSize:=Studio_Bytes(BLOB size($input.getContent()))
		$inBytes:=BLOB size($input.getContent())
		// Multi-page inputs are never silently truncated: the batch states
		// the chosen page explicitly. Animated GIF/WebP keep all frames in
		// one stream and must NOT be given a page (the CLI rejects it).
		If (($inspection.value.input.format="tiff") & ($inspection.value.input.frames>1))
			$options["page"]:=1
			$row.note:="page 1 of "+String($inspection.value.input.frames)
		End if
	End if

	$output:=$work.file(Replace string($sample.sample; "."; "_")+".webp")
	$result:=$converter.convert($input; $output; $options)

	If ($result.ok)
		$ok:=$ok+1
		$outBytes:=$result.value.output.bytes
		$totalIn:=$totalIn+$inBytes
		$totalOut:=$totalOut+$outBytes
		// webp-convert 1.0.0 puts the written path in output.mode, not a mode token
		$row.mode:=Uppercase($result.value.output.format)
		$row.outSize:=Studio_Bytes($outBytes)
		If ($inBytes>0)
			$row.saving:=String(Round(100*((($inBytes-$outBytes)/$inBytes)); 1))+"%"
		End if
		$row.result:="OK"
		If (($row.note="") & ($result.value.diagnostics.length>0))
			$row.note:=$result.value.diagnostics[0].code
		End if
	Else
		If ($result.error.code="invalid_protocol")
			$blocked:=$blocked+1
			$row.result:="BLOCKED"
			$row.note:="invalid_protocol — CLI printed info on stderr (20.0.0 defect)"
		Else
			$failed:=$failed+1
			$row.result:="FAILED"
			$row.note:=$result.failureKind+"/"+$result.error.code
		End if
	End if

	$rows.push($row)

End for each

Form.batchRows:=$rows

If ($totalIn>0)
	Form.batchSummary:="Batch: "+String($ok)+" of "+String(Form.samples.length) \
		+" converted · "+Studio_Bytes($totalIn)+" → "+Studio_Bytes($totalOut) \
		+" · "+String(Round(100*(1-($totalOut/$totalIn)); 1))+"% smaller" \
		+" · "+String($blocked)+" blocked by the protocol check · "+String($failed)+" rejected"
Else
	Form.batchSummary:="Batch: no successful conversion."
End if

Form.status:="Batch finished — "+String($ok)+" ok, "+String($blocked)+" blocked, "+String($failed)+" failed"
