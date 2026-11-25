#DECLARE()

// Initialise the form model. Called from the form method on load.
// Every value the UI binds to lives in Form.* so the object methods only
// read and update one object.

var $labels : Collection
var $converter : cs.WebP.Converter
var $version : Object

Form.samples:=Studio_Samples()
$labels:=Form.samples.extract("label")

Form.sourceChoice:=New object( \
	"values"; $labels; \
	"index"; 0)
Form.formatChoice:=New object( \
	"values"; New collection("WebP"; "PNG"; "JPEG"; "GIF"; "TIFF"; "BMP"); \
	"index"; 0; \
	"currentValue"; "WebP")
Form.inspectChoice:=New object( \
	"values"; $labels; \
	"index"; 0)

Form.lossless:=False
Form.quality:=80
Form.carryMetadata:=False
Form.background:=""
Form.dryRun:=False

var $blank : Picture
Form.sourcePicture:=$blank
Form.outputPicture:=$blank
Form.sourceInfo:=""
Form.sourceMeta:=Null
Form.outputInfo:="Not converted yet."
Form.diagnostics:=""
Form.savings:=0
Form.status:="Starting…"

Form.batchRows:=New collection
Form.batchSummary:="Batch not run yet."
Form.batchDetail:=""

Form.capRows:=New collection
Form.capSummary:=""
Form.capDetail:=""

Form.errorsRows:=New collection
Form.errorDetail:="Select a row to see the full envelope."

Form.inspectText:=""
Form.inspectPicture:=$blank
Form.inspectNotes:=""

$version:=cs.WebP.Converter.new("macOS-universal").version()
If ($version.ok)
	Form.cliVersion:=$version.value.version
	Form.status:="Component ready — CLI "+Form.cliVersion
Else
	Form.cliVersion:="?"
	Form.status:="Component unavailable — "+$version.failureKind+": "+$version.error.message
End if

Studio_LoadCapabilities
Studio_LoadSource
Studio_LoadInspect
