#DECLARE($bytes : Real)->$text : Text

// Compact human-readable byte size without relying on localised separators.

var $value : Real

Case of
	: ($bytes<1024)
		$text:=String($bytes)+" B"
	: ($bytes<(1024*1024))
		$value:=$bytes/1024
		$text:=String($value; "###,##0.0")+" KB"
	Else
		$value:=$bytes/(1024*1024)
		$text:=String($value; "###,##0.0")+" MB"
End case
