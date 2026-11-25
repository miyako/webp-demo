If (FORM Event.code=On Clicked)
	If (Form.selectedError#Null)
		Form.errorDetail:=Form.selectedError.envelope
	End if
End if
