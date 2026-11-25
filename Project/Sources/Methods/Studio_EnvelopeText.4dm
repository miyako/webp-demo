#DECLARE($result : Object)->$text : Text

// One-line summary of a component envelope, safe for both outcomes.
// (Do not use Choose() for this: 4D evaluates all Choose arguments eagerly,
// so Choose(ok; "fine"; $result.failureKind) still throws when ok is true.)

If (Value type($result)#Is object)
	$text:="<not an object>"
Else
	If ($result.ok)
		$text:="ok"
	Else
		$text:=$result.failureKind+"/"+$result.error.code
		If ($result.error.message#"")
			$text:=$text+" · "+$result.error.message
		End if
	End if
End if
