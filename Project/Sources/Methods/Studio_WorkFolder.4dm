#DECLARE()->$folder : 4D.Folder

// All scratch output (previews and batch results) goes to one folder inside
// the project folder, so the files are easy to find from the Finder and also
// writable by tool4d during the self-test (writing outside the project scope
// can fail silently there).

var $path : Text
$path:=Get 4D folder(Database folder)+"webp-demo-work"
$folder:=Folder($path; fk platform path)
If (Not($folder.exists))
	$folder.create()
End if
