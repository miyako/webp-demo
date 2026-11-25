//%attributes = {"invisible":true}
// Called via CALL FORM: run the action, then select the page.
// Rendering completes at the end of this cycle, so CaptureShot captures in the
// next one.

Case of
	: (Form.__action="convert")
		Studio_RunConvert
	: (Form.__action="inspect")
		Studio_LoadInspect
	: (Form.__action="batch")
		Studio_RunBatch
	: (Form.__action="capabilities")
		Studio_LoadCapabilities
	: (Form.__action="errors")
		Studio_RunErrorCase(9)
		Studio_RunErrorCase(2)
		Studio_RunErrorCase(3)
		Studio_RunErrorCase(5)
		Studio_RunErrorCase(6)
		Studio_RunErrorCase(7)
End case

FORM GOTO PAGE(Form.__page)
CALL FORM(Current form window; Formula(CaptureShot))
