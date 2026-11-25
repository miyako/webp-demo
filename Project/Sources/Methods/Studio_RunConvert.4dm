#DECLARE()

// Convert the sample selected on the Convert page, render the result and
// report the full envelope: metrics on success, the raw failure document on
// rejection. Nothing is pre-validated except the colour format, so the demo
// shows the component's own verdicts.

var $sample : Object
var $input; $output : 4D.File
var $converter : cs.WebP.Converter
var $options : Object
var $result : Object
var $format; $background; $extension; $text : Text
var $diagnostic : Object
var $inBytes; $outBytes; $ratio : Real
var $picture : Picture
var $blank : Picture
var $previous : Text

$sample:=Form.samples[Form.sourceChoice.index]
$input:=Studio_SampleFile($sample.sample)
$format:=Form.formatChoice.currentValue
$extension:=Studio_Extension($format)

$options:=New object("to"; Lowercase($format))
If (Form.lossless)
	$options["lossless"]:=True
Else
	$options["quality"]:=Form.quality
End if

If ($format="JPEG")
	$background:=Trim(Form.background)
	If ($background#"")
		If (Not(Match regex("^#?[0-9A-Fa-f]{6}$"; $background)))
			Form.outputInfo:="Background must be #RRGGBB, for example #FF3366."
			Form.status:="Nothing sent: invalid background colour"
			Form.diagnostics:="The demo validates only this one field itself.\n" \
				+"Everything else is left to the component so its verdict stays visible."
			return
		End if
		If (Substring($background; 1; 1)#"#")
			$background:="#"+$background
		End if
		$options["background"]:=$background
	End if
End if

If (Form.carryMetadata)
	// Note: on webp 20.0.0 this makes the CLI emit an info diagnostic on
	// stderr, and the component then reports protocol/invalid_protocol even
	// though the file was written. See README "Known upstream issues".
	$options["metadata"]:="all"
	$options["orient"]:="auto"
End if

If (Form.dryRun)
	$options["dry-run"]:=True
Else
	$options["overwrite"]:=True
End if

$output:=Studio_WorkFolder.file("preview."+$extension)
$converter:=cs.WebP.Converter.new("macOS-universal")
$result:=$converter.convert($input; $output; $options)

$inBytes:=BLOB size($input.getContent())

If ($result.ok)
	$outBytes:=$result.value.output.bytes
	Form.diagnostics:=""
	If (Value type($result.value.diagnostics)=Is collection)
		For each ($diagnostic; $result.value.diagnostics)
			Form.diagnostics:=Form.diagnostics+$diagnostic.severity+" · "+$diagnostic.code+"\n"+$diagnostic.message+"\n\n"
		End for each
	End if
	If (Form.diagnostics="")
		Form.diagnostics:="No diagnostics — nothing was dropped or adapted."
	End if
	Form.diagnostics:=Form.diagnostics+"\noutput: "+$output.platformPath

	If (Form.dryRun)
		$picture:=$blank
		Form.savings:=0
		$text:=Lowercase($result.value.input.format)+" → "+$format+"\n" \
			+"mode: dry-run (nothing written)\n" \
			+"would write: "+Studio_Bytes($outBytes)
		Form.outputInfo:=$text
		Form.status:="Dry run: the CLI reported success without writing a file"
	Else
		$ratio:=((($inBytes-$outBytes)/$inBytes)*100)
		If ($ratio<0)
			$ratio:=0
		End if
		If ($ratio>100)
			$ratio:=100
		End if
		Form.savings:=Round($ratio; 0)
		$text:=Lowercase($result.value.input.format)+" → "+$result.value.output.format+"\n"
		$text:=$text+"output: "+$result.value.output.mode+" · "
		If (Form.lossless)
			$text:=$text+"lossless"
		Else
			$text:=$text+"quality "+String(Form.quality)
		End if
		$text:=$text+"\n"+Studio_Bytes($outBytes)+" out · "+Studio_Bytes($inBytes)+" in\n"
		$text:=$text+Choose($ratio>=0; "−"+String(Round(Abs($ratio); 1))+"% smaller"; "+"+String(Round(Abs($ratio); 1))+"% larger")
		Form.outputInfo:=$text
		Form.status:="Converted "+$result.value.input.format+" → "+$result.value.output.format

		$previous:=Method called on error(ek local)
		ON ERR CALL("Studio_TraceError"; ek local)
		READ PICTURE FILE($output.platformPath; $picture)
		ON ERR CALL($previous; ek local)
	End if
Else
	Form.savings:=0
	Form.outputPicture:=$blank
	Form.outputInfo:="FAILED\n"+$result.failureKind+"\n"+$result.error.code+"\n\n" \
		+"See the envelope below:\n"+$result.error.message
	Form.diagnostics:="failureKind: "+$result.failureKind+"\n" \
		+"code: "+$result.error.code+"\n" \
		+"message: "+$result.error.message+"\n\n" \
		+"status envelope:\n"+JSON Stringify($result; *)
	If ($result.error.code="invalid_protocol")
		Form.diagnostics:="[known webp 20.0.0 issue] The CLI wrote the output file and printed an " \
			+"informational diagnostic on stderr. The component treats any stderr output as a " \
			+"protocol violation, so this successful conversion is reported as failed. " \
			+"Field note: the same CLI command with --quiet succeeds.\n\n"+Form.diagnostics
		Form.status:="Blocked by component protocol check — see diagnostics"
	End if
	Form.status:="Rejected: "+$result.failureKind+" / "+$result.error.code
	$picture:=$blank
End if

Form.outputPicture:=$picture
