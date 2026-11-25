#DECLARE()

// Load the sample selected on the Convert page, inspect it and show a
// preview. The inspection envelope is mirrored into sourceInfo so the demo
// always shows what the converter saw before a conversion is requested.

var $sample : Object
var $file : 4D.File
var $converter : cs.WebP.Converter
var $inspection : Object
var $picture : Picture
var $previous : Text
var $text : Text

$sample:=Form.samples[Form.sourceChoice.index]
$file:=Studio_SampleFile($sample.sample)
$converter:=cs.WebP.Converter.new("macOS-universal")
$inspection:=$converter.inspect($file)

If ($inspection.ok)
	Form.sourceMeta:=$inspection.value.input
	$text:=$sample.label+"\n"
	$text:=$text+$inspection.value.input.format+" · "
	$text:=$text+String($inspection.value.input.width)+"×"+String($inspection.value.input.height)+" · "
	$text:=$text+String($inspection.value.input.frames)+" frame(s) · "
	$text:=$text+Choose($inspection.value.input.has_alpha; "alpha"; "no alpha")
	$text:=$text+"\n"+Studio_Bytes(BLOB size($file.getContent()))+" on disk"
	If ($inspection.value.input.frames>1)
		$text:=$text+"\nmulti-page input: convert() refuses it without an explicit page; the Batch page passes page 1."
	End if
	Form.sourceInfo:=$text
Else
	Form.sourceMeta:=Null
	Form.sourceInfo:="inspect → "+$inspection.failureKind+"\n" \
		+$inspection.error.code+"\n"+$inspection.error.message
End if

If ($file.exists)
	$previous:=Method called on error(ek local)
	ON ERR CALL("Studio_TraceError"; ek local)
	READ PICTURE FILE($file.platformPath; $picture)
	ON ERR CALL($previous; ek local)
End if
Form.sourcePicture:=$picture

Form.status:="Inspected "+$sample.label
