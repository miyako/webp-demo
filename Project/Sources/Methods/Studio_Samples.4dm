#DECLARE()->$samples : Collection

// The fixture set shipped in /RESOURCES/samples. Every sample is a real
// conversion input; two of them are deliberately unreadable so the UI can
// show the failure envelopes as part of the demo.
// The collection is the single source of truth for both the dropdown and
// the batch page.

$samples:=New collection
$samples.push(New object( \
	"label"; "Aurora · PNG · alpha"; \
	"sample"; "aurora.png"; \
	"note"; "640×400 RGBA: gradient with a transparent ellipse"))
$samples.push(New object( \
	"label"; "Garden · JPEG · EXIF"; \
	"sample"; "garden.jpg"; \
	"note"; "640×400 RGB with an EXIF block (Artist tag)"))
$samples.push(New object( \
	"label"; "Orbit · WebP · re-encode"; \
	"sample"; "orbit.webp"; \
	"note"; "640×400, itself produced by webp-convert"))
$samples.push(New object( \
	"label"; "Spinner · GIF · 12 frames"; \
	"sample"; "spinner.gif"; \
	"note"; "640×400 animated; converts to animated WebP"))
$samples.push(New object( \
	"label"; "Layers · TIFF · 2 pages"; \
	"sample"; "layers.tiff"; \
	"note"; "640×400; needs an explicit page to convert"))
$samples.push(New object( \
	"label"; "Briefing · BMP"; \
	"sample"; "briefing.bmp"; \
	"note"; "640×400 uncompressed; the batch page shows it shrinking"))
$samples.push(New object( \
	"label"; "Truncated PNG · corrupt"; \
	"sample"; "corrupt.png"; \
	"note"; "inspect() reports the header, convert() rejects the pixels"))
$samples.push(New object( \
	"label"; "notes.txt · not an image"; \
	"sample"; "notes.txt"; \
	"note"; "unsupported_input; proves there is no silent passthrough"))
