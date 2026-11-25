#DECLARE($case : Integer)

// Each case drives the component into one specific failure. The result rows
// keep the whole envelope, not just the message, because the interesting
// contract is (failureKind × code × exit semantics), not the prose.

var $converter : cs.WebP.Converter
var $result : Object
var $scenario : Text
var $input; $output : 4D.File
var $work : 4D.Folder

$converter:=cs.WebP.Converter.new("macOS-universal")
$work:=Studio_WorkFolder
$input:=Studio_SampleFile("aurora.png")
$output:=$work.file("error-lab.webp")

Case of
	: ($case=1)
		$scenario:="Unknown convert option (rejected before launch)"
		$result:=$converter.convert($input; $output; New object("auto_orient"; True))

	: ($case=2)
		$scenario:="Corrupt input (truncated PNG)"
		$result:=$converter.convert(Studio_SampleFile("corrupt.png"); $output; New object("quality"; 80; "overwrite"; True))

	: ($case=3)
		$scenario:="Unsupported input (plain text file)"
		$result:=$converter.convert(Studio_SampleFile("notes.txt"); $output; New object("overwrite"; True))

	: ($case=4)
		$scenario:="Missing input file"
		$result:=$converter.inspect(Folder("/RESOURCES/samples").file("absent.png"))

	: ($case=5)
		$scenario:="Resource limit (max-input-bytes: 10)"
		$result:=$converter.convert($input; $output; New object("max-input-bytes"; 10; "overwrite"; True))

	: ($case=6)
		$scenario:="Multi-page TIFF without an explicit page"
		$result:=$converter.convert(Studio_SampleFile("layers.tiff"); $output; New object("overwrite"; True))

	: ($case=7)
		$scenario:="Alpha image to JPEG without a background"
		$result:=$converter.convert($input; $work.file("error-lab.jpg"); New object("to"; "jpeg"; "quality"; 80; "overwrite"; True))

	: ($case=8)
		// On macOS the only accepted target is macOS-universal; asking for
		// another platform fails before any process starts.
		$scenario:="Wrong platform target (Windows-x64 on macOS)"
		$result:=cs.WebP.Converter.new("Windows-x64").version()

	: ($case=9)
		// The CLI writes info diagnostics to stderr even with --json; the
		// component treats non-empty stderr as a protocol violation, so a
		// successful conversion is reported as failed.
		$scenario:="Info diagnostic on a successful conversion"
		$result:=$converter.convert(Studio_SampleFile("garden.jpg"); $work.file("error-lab-meta.webp"); \
			New object("to"; "webp"; "quality"; 80; "metadata"; "all"; "overwrite"; True))

	Else
		return
End case

Studio_AddErrorRow($scenario; $result)
