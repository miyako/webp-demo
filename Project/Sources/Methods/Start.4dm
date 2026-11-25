#DECLARE($params : Object)

// Entry point: called without parameters from On Startup and the application
// menu, and with an object parameter by itself through CALL WORKER.

var $title : Text
var $window : Integer
$title:="WebP Studio — miyako/webp 20.0.0"

If (Count parameters=0)

	// Reuse an already open window instead of stacking duplicates.
	ARRAY LONGINT($windows; 0)
	WINDOW LIST($windows)

	var $i : Integer
	For ($i; 1; Size of array($windows))
		$window:=$windows{$i}
		If ((Window process($window)=1) & (Get window title($window)=$title))
			var $left; $top; $right; $bottom : Integer
			GET WINDOW RECT($left; $top; $right; $bottom; $window)
			CALL FORM($window; Formula(SET WINDOW RECT($left; $top; $right; $bottom; $window)))
			return
		End if
	End for

	CALL WORKER(1; Current method name; {})

Else

	SET MENU BAR(1)
	$window:=Open form window("Studio"; Plain form window; Horizontally centered; Vertically centered)
	SET WINDOW TITLE($title; $window)
	DIALOG("Studio"; $params; *)

End if
