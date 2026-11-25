#DECLARE($format : Text)->$extension : Text

Case of
	: ($format="JPEG")
		$extension:="jpg"
	: ($format="TIFF")
		$extension:="tif"
	Else
		$extension:=Lowercase($format)
End case
