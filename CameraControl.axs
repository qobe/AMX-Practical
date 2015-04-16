MODULE_NAME='CameraControl' (DEV vdvCamera, DEV dvTP_Camera, INTEGER nCAMStatus)

DEFINE_CONSTANT
    #INCLUDE 'SNAPI'

DEFINE_VARIABLE
    VOLATILE INTEGER tiltButtons [] = {TILT_UP,TILT_DN,PAN_LT,PAN_RT}		//Buttons map to SNAPI channels
    VOLATILE INTEGER zoomButtons [] = {ZOOM_OUT, ZOOM_IN}
    VOLATILE INTEGER presetButtons [] = {261, 262, 263}
    VOLATILE INTEGER focusBar = 3016
    VOLATILE INTEGER focusBarFlag = 0
    
DEFINE_LATCHING
    
DEFINE_MUTUALLY_EXCLUSIVE
   ([dvTP_Camera, 261]..[dvTP_Camera, 263])
    
DEFINE_START
    

DEFINE_EVENT

    BUTTON_EVENT[dvTP_Camera, tiltButtons]
    {
	PUSH:
	{
	    ON[vdvCamera, BUTTON.INPUT.CHANNEL]
	}
	RELEASE:
	{
	    OFF[vdvCamera, BUTTON.INPUT.CHANNEL]
	}
    }
    
    BUTTON_EVENT[dvTP_Camera, zoomButtons]
    {
	PUSH:
	{
	    ON[vdvCamera, BUTTON.INPUT.CHANNEL]
	}
	RELEASE:
	{
	    OFF[vdvCamera, BUTTON.INPUT.CHANNEL]
	}
    }
    
    BUTTON_EVENT[dvTP_Camera, presetButtons]
    {
	RELEASE:
	{
	    STACK_VAR INTEGER index
	    index = GET_LAST(presetButtons)
	    SEND_COMMAND vdvCamera, "'CAMERAPRESET-',ITOA(index)"
	    //SEND_COMMAND vdvCamera, "'?CAMERAPRESET'"
	}
	HOLD[20]:
	{
	    STACK_VAR INTEGER index
	    index = GET_LAST(presetButtons)
	    SEND_COMMAND vdvCamera, "'CAMERAPRESETSAVE-', ITOA(index)"
	}
    }
    
    BUTTON_EVENT[dvTP_Camera, focusBar]
    {
	PUSH:
	{
	    ON[focusBarFlag]
	}
	RELEASE:
	{
	    OFF[focusBarFlag]
	}
    }

    DATA_EVENT[vdvCamera]
    {
	ONLINE:
	{
	    // SEND_COMMAND vdvCamera, "'?CAMERAPRESET'"
	}
	COMMAND:
	{
	    SEND_STRING 0, "'Data.txt camera A ', DATA.TEXT"
	    IF(LENGTH_STRING(REMOVE_STRING(DATA.TEXT, 'CAMERAPRESET-',1)) > 0)
	    {
		SEND_STRING 0, "'Data.txt camera B', DATA.TEXT"
		ON[dvTP_Camera, presetButtons[ATOI(DATA.TEXT)]]
	    }
	}
    }
    
    LEVEL_EVENT[dvTP_Camera, FOCUS_LVL]
    {
	IF(focusBarFlag)
	{
	    SEND_LEVEL vdvCamera, FOCUS_LVL, LEVEL.VALUE
	}
    }
    
    LEVEL_EVENT[vdvCamera, FOCUS_LVL]
    {
	SEND_LEVEL dvTP_Camera, FOCUS_LVL, LEVEL.VALUE
    }
    
DEFINE_PROGRAM

[dvTP_Camera, tiltButtons[1]] = [vdvCamera, TILT_UP_FB]
[dvTP_Camera, tiltButtons[2]] = [vdvCamera, TILT_DN_FB]
[dvTP_Camera, tiltButtons[3]] = [vdvCamera, PAN_LT_FB]
[dvTP_Camera, tiltButtons[4]] = [vdvCamera, PAN_RT_FB]
[dvTP_Camera, zoomButtons[1]] = [vdvCamera, ZOOM_OUT_FB]
[dvTP_Camera, zoomButtons[2]] = [vdvCamera, ZOOM_IN_FB]
