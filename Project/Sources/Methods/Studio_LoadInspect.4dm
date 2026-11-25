#DECLARE()

// Inspect the sample selected on the Inspector page and show the raw
// inspection document beside the preview. The notes explain the one real
// trap: inspect() reads structure, not pixels.

var $sample : Object
var $file : 4D.File
var $converter : cs.WebP.Converter
var $result : Object
var $picture; $blank : Picture
var $previous : Text

$sample:=Form.samples[Form.inspectChoice.index]
$file:=Studio_SampleFile($sample.sample)
$converter:=cs.WebP.Converter.new("macOS-universal")
$result:=$converter.inspect($file)

If ($result.ok)
	Form.inspectText:=JSON Stringify($result.value; *)
	Form.inspectNotes:="inspect() answered with format, dimensions, frame count and alpha. " \
		+"These four fields are a structural probe, not a decode: a truncated PNG " \
		+"still reports 640×400 here, while convert() rejects its pixels with " \
		+"corrupt_input. Use inspect() as a routing gate, not as proof the file is readable."
Else
	Form.inspectText:=JSON Stringify($result; *)
	Form.inspectNotes:=$result.failureKind+" / "+$result.error.code+"\n"+$result.error.message
End if

$picture:=$blank
If ($file.exists)
	$previous:=Method called on error(ek local)
	ON ERR CALL("Studio_TraceError"; ek local)
	READ PICTURE FILE($file.platformPath; $picture)
	ON ERR CALL($previous; ek local)
End if
Form.inspectPicture:=$picture

Form.status:="Inspector: "+$sample.label
