#DECLARE()

// Headless self-test: exercises every claim the UI makes, without a form.
// Run with:
//   tool4d --project Project/webp-demo.4DProject --startup-method=Studio_SelfTest \
//          --dataless --skip-onstartup --user-param <report.json>
// The report is written even when checks fail.

var $reportPath : Text
var $reportFile : 4D.File
var $work : 4D.Folder
var $converter : cs.WebP.Converter
var $checks : Collection
var $failures : Collection
var $capabilities; $inspection; $result; $options; $sample; $check : Object
var $input; $output : 4D.File
var $inBytes; $outBytes; $totalIn; $totalOut : Real
var $okCount; $failCount; $blockedCount : Integer
var $version; $json; $detail : Text

Get database parameter(User param value; $reportPath)
If ($reportPath="")
	$reportPath:=Get 4D folder(Database folder)+"selftest-report.json"
End if
// user param may be POSIX or a 4D system path
If (Match regex("^/"; $reportPath))
	$reportFile:=File($reportPath)
Else
	$reportFile:=File($reportPath; fk platform path)
End if

$checks:=New collection
$failures:=New collection
$work:=Studio_WorkFolder
$converter:=cs.WebP.Converter.new("macOS-universal")
$version:="?"

// ---------------------------------------------------------------- helpers
// $check is (re)used as the record builder.

// 1. the component and its verified asset are usable at all
$result:=$converter.version()
If ($result.ok)
	$version:=$result.value.version
End if
$check:=New object("check"; "version() resolves the verified CLI"; "ok"; ($result.ok & ($version#"?")))
$check.detail:=Choose($result.ok; "cli "+$version; Studio_EnvelopeText($result))
$checks.push($check)
If (Not($check.ok))
	$failures.push("version")
End if

$capabilities:=$converter.capabilities()
$check:=New object("check"; "capabilities() lists the format registry"; "ok"; ($capabilities.ok & ($capabilities.value.capabilities.length>0)))
If ($capabilities.ok)
	$check.detail:=String($capabilities.value.capabilities.length)+" entries, protocol "+String($capabilities.value.protocol)
Else
	$check.detail:=Studio_EnvelopeText($capabilities)
End if
$checks.push($check)
If (Not($check.ok))
	$failures.push("capabilities")
End if

// 2. every fixture is classified correctly, and bad ones fail one by one
For each ($sample; Studio_Samples())

	$input:=Studio_SampleFile($sample.sample)
	$inBytes:=BLOB size($input.getContent())
	$totalIn:=$totalIn+$inBytes
	$inspection:=$converter.inspect($input)
	$options:=New object("to"; "webp"; "quality"; 80; "overwrite"; True)

	$check:=New object("check"; "convert handles "+$sample.sample; "ok"; False; "detail"; "")

	If (($sample.sample="corrupt.png") | ($sample.sample="notes.txt"))
		$result:=$converter.convert($input; $work.file(Replace string($sample.sample; "."; "_")+".webp"); $options)
		$check.ok:=Not($result.ok)
		$check.detail:=Choose($result.ok; "unexpected success"; Studio_EnvelopeText($result))
		If ($result.ok)
			$failures.push("convert:"+$sample.sample)
		Else
			$failCount:=$failCount+1
		End if
	Else
		If ($inspection.ok & ($inspection.value.input.format="tiff") & ($inspection.value.input.frames>1))
			$options["page"]:=1
		End if
		$output:=$work.file(Replace string($sample.sample; "."; "_")+".webp")
		$result:=$converter.convert($input; $output; $options)
		If ($result.ok)
			$okCount:=$okCount+1
			$outBytes:=$result.value.output.bytes
			$totalOut:=$totalOut+$outBytes
			$check.detail:=Studio_Bytes($inBytes)+" → "+Studio_Bytes($outBytes)+" ("+$result.value.output.format+")"
			$check.ok:=$inspection.ok
		Else
			$check.detail:=Studio_EnvelopeText($result)
			If ($result.error.code="invalid_protocol")
				// documented 20.0.0 defect: CLI success with an info
				// diagnostic on stderr is reported as a protocol violation
				$blockedCount:=$blockedCount+1
				$check.ok:=($inspection.ok & ($sample.sample="garden.jpg"))
			Else
				$check.ok:=False
				$failures.push("convert:"+$sample.sample)
			End if
		End if
	End if

	$checks.push($check)

End for each

$check:=New object("check"; "batch: 5 convert, 1 protocol-blocked, 2 rejected"; \
	"ok"; (($okCount=5) & ($blockedCount=1) & ($failCount=2)))
$check.detail:=String($okCount)+" ok, "+String($blockedCount)+" blocked, "+String($failCount)+" rejected"
$checks.push($check)
If (Not($check.ok))
	$failures.push("batch-count")
End if

// 3. structural probe vs decode (the inspect finding)
$inspection:=$converter.inspect(Studio_SampleFile("corrupt.png"))
$result:=$converter.convert(Studio_SampleFile("corrupt.png"); $work.file("probe.webp"); New object("overwrite"; True))
$check:=New object("check"; "inspect() accepts truncated PNG while convert() rejects it"; \
	"ok"; ($inspection.ok & (Not($result.ok)) & ($result.error.code="corrupt_input")))
$detail:="inspect ok="+String($inspection.ok)+" · convert "
If ($result.ok)
	$check.detail:=$detail+"ok (unexpected)"
Else
	$check.detail:=$detail+$result.error.code
End if
$checks.push($check)
If (Not($check.ok))
	$failures.push("inspect-probe")
End if

// 4. multi-page TIFF: refused without page, converted with page 1
$result:=$converter.convert(Studio_SampleFile("layers.tiff"); $work.file("tiff-none.webp"); New object("to"; "webp"; "overwrite"; True))
$check:=New object("check"; "multi-page TIFF without page is refused"; \
	"ok"; ((Not($result.ok)) & (Not($result.ok) & ($result.error.code="unsupported_input"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("tiff-page-missing")
End if

$result:=$converter.convert(Studio_SampleFile("layers.tiff"); $work.file("tiff-page1.webp"); New object("to"; "webp"; "page"; 1; "overwrite"; True))
$check:=New object("check"; "multi-page TIFF with page 1 converts"; "ok"; $result.ok)
If ($result.ok)
	$check.detail:=Studio_Bytes($result.value.output.bytes)
Else
	$check.detail:=Studio_EnvelopeText($result)
End if
$checks.push($check)
If (Not($result.ok))
	$failures.push("tiff-page1")
End if

// 5. alpha flattening needs an explicit background
$result:=$converter.convert(Studio_SampleFile("aurora.png"); $work.file("alpha-none.jpg"); New object("to"; "jpeg"; "quality"; 80; "overwrite"; True))
$check:=New object("check"; "alpha PNG → JPEG without background is refused"; \
	"ok"; ((Not($result.ok)) & (Not($result.ok) & ($result.error.code="missing_option"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("alpha-background")
End if

$result:=$converter.convert(Studio_SampleFile("aurora.png"); $work.file("alpha-bg.jpg"); New object("to"; "jpeg"; "quality"; 80; "background"; "#FFFFFF"; "overwrite"; True))
$check:=New object("check"; "alpha PNG → JPEG with background is blocked by the protocol check (20.0.0)"; "ok"; \
	((Not($result.ok)) & (Not($result.ok) & ($result.error.code="invalid_protocol"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("alpha-background-protocol")
End if

// 6. argument contract: unknown option is rejected before launch
$result:=$converter.convert(Studio_SampleFile("aurora.png"); $work.file("bad-option.webp"); New object("auto_orient"; True))
$check:=New object("check"; "unknown option is argument/invalid_argument"; \
	"ok"; ((Not($result.ok)) & (Not($result.ok) & ($result.failureKind="argument") & ($result.error.code="invalid_argument"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("unknown-option")
End if

// 7. resource limits are enforced by the CLI
$result:=$converter.convert(Studio_SampleFile("aurora.png"); $work.file("limit.webp"); New object("max-input-bytes"; 10; "overwrite"; True))
$check:=New object("check"; "max-input-bytes is a resource_limit_exceeded"; \
	"ok"; ((Not($result.ok)) & (Not($result.ok) & ($result.error.code="resource_limit_exceeded"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("resource-limit")
End if

// 8. platform targeting is asset-driven
$result:=cs.WebP.Converter.new("Windows-x64").version()
$check:=New object("check"; "Windows-x64 target fails with unsupported_architecture"; \
	"ok"; ((Not($result.ok)) & (Not($result.ok) & ($result.error.code="unsupported_architecture"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("platform")
End if

// 9. animation survives GIF → animated WebP
$result:=$converter.convert(Studio_SampleFile("spinner.gif"); $work.file("spinner.webp"); New object("to"; "webp"; "quality"; 80; "overwrite"; True))
$check:=New object("check"; "animated GIF converts to WebP"; "ok"; ($result.ok & ($result.ok & ($result.value.output.bytes>0))))
If ($result.ok)
	$check.detail:=Studio_Bytes($result.value.output.bytes)
Else
	$check.detail:=Studio_EnvelopeText($result)
End if
$checks.push($check)
If (Not($result.ok))
	$failures.push("animated-gif")
End if

// 10. known defect: a successful CLI run that prints an info diagnostic on
// stderr is reported as protocol/invalid_protocol by webp 20.0.0.
$result:=$converter.convert(Studio_SampleFile("garden.jpg"); $work.file("meta.webp"); \
	New object("to"; "webp"; "quality"; 80; "metadata"; "all"; "overwrite"; True))
$check:=New object("check"; "success + info diagnostic → protocol/invalid_protocol (20.0.0 defect)"; \
	"ok"; ((Not($result.ok)) & (Not($result.ok) & ($result.error.code="invalid_protocol"))))
$check.detail:=Studio_EnvelopeText($result)
$checks.push($check)
If (Not($check.ok))
	$failures.push("stderr-diagnostic-defect")
End if

// ---------------------------------------------------------------- report
$json:=JSON Stringify(New object( \
	"component"; "webp 20.0.0"; \
	"cli"; $version; \
	"workFolder"; $work.platformPath; \
	"checks"; $checks; \
	"failures"; $failures; \
	"inputBytes"; $totalIn; \
	"outputBytes"; $totalOut; \
	"passed"; ($failures.length=0); \
	"ranAt"; Timestamp); *)

$reportFile.setText($json)
LOG EVENT(Into system standard outputs; "selftest: "+String($checks.length)+" checks, "+String($failures.length)+" failure(s), report "+$reportFile.platformPath)
If ($failures.length>0)
	LOG EVENT(Into system standard outputs; "FAILED: "+$failures.join(", "))
End if
