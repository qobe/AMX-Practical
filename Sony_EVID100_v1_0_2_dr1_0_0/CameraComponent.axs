MODULE_NAME='CameraComponent'(
								dev vdvDev[],
								dev dvTP,
								integer nButtons[],
								integer nOutputBtns[],
								integer nLevels[],
								integer nPresetBtns[],
								integer nFBArray[]
							 )
(***********************************************************)
(*  FILE CREATED ON: 12/21/2005  AT: 08:40:10              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/13/2006  AT: 16:03:18        *)
(***********************************************************)

DEFINE_DEVICE

DEFINE_CONSTANT

#include 'SNAPI.axi'

DEFINE_VARIABLE

volatile integer nPreset[2] = { 0, 0 }
volatile integer nPresetCount = 0
volatile integer nSet = 0
volatile integer nBlink = 0
volatile integer nDbg = 1
volatile integer nZoomValue[2] = { 0, 0 }
volatile integer nFocusValue[2] = { 0, 0 }
volatile integer nIrisValue[2] = { 0, 0 }
volatile integer nZoomSpeedValue[2] = { 0, 0 }
volatile integer nFocusSpeedValue[2] = { 0, 0 }
volatile integer nPanValue[2] = { 0, 0 }
volatile integer nTiltValue[2] = { 0, 0 }
volatile integer nPanSpeedValue[2] = { 0, 0 }
volatile integer nTiltSpeedValue[2] = { 0, 0 }
volatile integer nOutputCount = 1
volatile integer nCurrOut = 1

//*******************************************************************
// Function : fPrintf												*
// Purpose  : to print a line to the telnet session					*
// Params   : sTxt - the data to print to the telnet session		*
// Return   : none													*
//*******************************************************************
define_function fPrintf (char sTxt[])
{
	if (nDbg > 1)
	{
		send_string 0, "'** Message from CameraComponent.axs: ',sTxt"
	}
}

//*******************************************************************
// Function : fnFBLookup											*
// Purpose  : to look up whether this module is controlling 		*
//			  feedback for the button								*
// Params   : nChNo - the channel to test for feedback control		*
// Return   : integer - 1 for do feedback, 0 for do not do feedback	*
//*******************************************************************
define_function integer fnFBLookup (integer nChNo)
{
	stack_var integer z
	stack_var integer nFB
	nFB = 0
	z = 0
	for (z = 1; z <= length_array(nFBArray); z++)
	{
		if (nFBArray[z] == nChNo)
		{
			nFB = z
			break
		}
	}
/*	if (nFB)
	{
		fPrintf("'This component has feedback control over button #',itoa(nChNo)")
	}
	else
	{
		fPrintf("'This component does not have feedback control over button #',itoa(nChNo)")
	}
*/	return nFB
}

//*******************************************************************
// Function : dpstoa												*
// Purpose  : to convert a device's DPS to ascii for displaying		*
// Params   : dvIn - the device to be represented in ascii			*
// Return   : char[20] - the ascii representation of the dvIn's DPS	*
//*******************************************************************
define_function char[20] dpstoa (dev dvIn)
{
	return "itoa(dvIn.number),':',itoa(dvIn.port),':',itoa(dvIn.system)"
}

DEFINE_START

nPresetCount = length_array(nPresetBtns)
nOutputCount = length_array(nOutputBtns)

DEFINE_EVENT


button_event[dvTP, nOutputBtns]
{
	push:
	{
		stack_var integer x
		nCurrOut = get_last(nOutputBtns)
		
		for (x = 1; x <= nOutputCount; x++)
		{
			if (fnFBLookup(nOutputBtns[x]))
			{
				[dvTP, nOutputBtns[x]] = (nCurrOut == x)
			}
		}

		send_level dvTP, nLevels[1], nZoomValue[nCurrOut]
		send_level dvTP, nLevels[2], nFocusValue[nCurrOut]
		send_level dvTP, nLevels[3], nIrisValue[nCurrOut]
		send_level dvTP, nLevels[4], nZoomSpeedValue[nCurrOut]
		send_level dvTP, nLevels[5], nFocusSpeedValue[nCurrOut]
		send_level dvTP, nLevels[7], nPanValue[nCurrOut]
		send_level dvTP, nLevels[8], nTiltValue[nCurrOut]
		send_level dvTP, nLevels[9], nPanSpeedValue[nCurrOut]
		send_level dvTP, nLevels[10], nTiltSpeedValue[nCurrOut]
		for (x = 1; x <= nPresetCount; x++)
		{
			[dvTP, nPresetBtns[x]] = (nPreset[nCurrOut] == x)
		}
	}
}

data_event[vdvDev]
{
	online:
	{
		stack_var integer x
		for (x = 1; x <= nOutputCount; x++)
		{
			[dvTP, nOutputBtns[x]] = (nCurrOut == x)
		}
	}
	command:
	{
		if (find_string(data.text, '-', 1))
		{
			stack_var integer x
			stack_var integer nTempDev
			stack_var char sCmd[15]
			
			sCmd = remove_string(data.text, '-', 1)
			
			for (x = 1; x <= nOutputCount; x++)
			{
				if (vdvDev[x] == data.device)
				{
					nTempDev = x
					break
				}
			}
			switch (sCmd)
			{
				case 'CAMERAPRESET-' :
				{
					nPreset[nTempDev] = atoi(data.text)
					for (x = 1; x <= nPresetCount; x++)
					{
						if (fnFBLookup(nPresetBtns[x]))
						{
							[dvTP, nPresetBtns[x]] = (nPreset[nTempDev] == x)
						}
					}
				}
				case 'DEBUG-' :
				{
					nDbg = atoi(data.text)
				}
			}
		}
	}
}

button_event[dvTP, nPresetBtns]
{
	push:
	{
		stack_var integer x
		stack_var integer nPresetValue
		
		nPresetValue = get_last(nPresetBtns)
		if (nSet)
		{
			send_command vdvDev[nCurrOut], "'CAMERAPRESETSAVE-',itoa(nPresetValue)"
			fPrintf("'send_command ',dpstoa(vdvDev[nCurrOut]),', ',39,'CAMERAPRESETSAVE-',itoa(nPresetValue),39")
		}
		else
		{
			send_command vdvDev[nCurrOut], "'CAMERAPRESET-',itoa(nPresetValue)"
			fPrintf("'send_command ',dpstoa(vdvDev[nCurrOut]),', ',39,'CAMERAPRESET-',itoa(nPresetValue),39")
		}
		nSet = 0
	}
}

button_event[dvTP, nButtons]
{
	push:
	{
		stack_var integer nBtn
		nBtn = get_last(nButtons)
		
		switch (nBtn)
		{
			case 1 :	// Tilt Up
			{
				on[vdvDev[nCurrOut], TILT_UP]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(TILT_UP),']'")
			}
			case 2 :	// Tilt Down
			{
				on[vdvDev[nCurrOut], TILT_DN]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(TILT_DN),']'")
			}
			case 3 :	// Pan Left
			{
				on[vdvDev[nCurrOut], PAN_LT]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(PAN_LT),']'")
			}
			case 4 :	// Pan Right
			{
				on[vdvDev[nCurrOut], PAN_RT]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(PAN_RT),']'")
			}
			case 5 :	// Zoom -
			{
				on[vdvDev[nCurrOut], ZOOM_OUT]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(ZOOM_OUT),']'")
			}
			case 6 :	// Zoom +
			{
				on[vdvDev[nCurrOut], ZOOM_IN]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(ZOOM_IN),']'")
			}
			case 7 :	// Focus -
			{
				on[vdvDev[nCurrOut], FOCUS_NEAR]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(FOCUS_NEAR),']'")
			}
			case 8 :	// Focus +
			{
				on[vdvDev[nCurrOut], FOCUS_FAR]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(FOCUS_FAR),']'")
			}
			case 9 :	// Auto Focus Cycle
			{
				pulse[vdvDev[nCurrOut], AUTO_FOCUS]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(AUTO_FOCUS),']'")
			}
			case 10 :	// Auto Iris Cycle
			{
				pulse[vdvDev[nCurrOut], AUTO_IRIS]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(AUTO_IRIS),']'")
			}
			case 11 :	// Auto Focus Off / On
			{
				[vdvDev[nCurrOut], AUTO_FOCUS_ON] = ![vdvDev[nCurrOut], AUTO_FOCUS_ON]
				fPrintf("'[',dpstoa(vdvDev[nCurrOut]),', ',itoa(AUTO_FOCUS_ON),'] = ![',dpstoa(vdvDev[nCurrOut]),', ',itoa(AUTO_FOCUS_ON),']'")
			}
			case 12 :	// Auto Iris Off / On
			{
				[vdvDev[nCurrOut], AUTO_IRIS_ON] = ![vdvDev[nCurrOut], AUTO_IRIS_ON]
				fPrintf("'[',dpstoa(vdvDev[nCurrOut]),', ',itoa(AUTO_IRIS_ON),'] = ![',dpstoa(vdvDev[nCurrOut]),', ',itoa(AUTO_IRIS_ON),']'")
			}
			case 13 :	// Iris -
			{
				on[vdvDev[nCurrOut], IRIS_CLOSE]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(IRIS_CLOSE),']'")
			}
			case 14 :	// Iris +
			{
				on[vdvDev[nCurrOut], IRIS_OPEN]
				fPrintf("'on[',dpstoa(vdvDev[nCurrOut]),', ',itoa(IRIS_OPEN),']'")
			}
			case 15 :	// Camera Preset Cycle
			{
				pulse[vdvDev[nCurrOut], CAM_PRESET]
				fPrintf("'pulse[',dpstoa(vdvDev[nCurrOut]),', ',itoa(CAM_PRESET),']'")
			}
			case 16 :	// Save Preset
			{
				nSet = !(nSet)
				nBlink = fnFBLookup(nButtons[nBtn])
			}
			
			case 17 :	// Query Camera Preset
			{
				send_command vdvDev[nCurrOut], "'?CAMERAPRESET'"
				fPrintf("'send_command ',dpstoa(vdvDev[nCurrOut]),', ',39,'?CAMERAPRESET',39")
			}
		}
	}
	release:
	{
		stack_var integer nBtn
		nBtn = get_last(nButtons)
		
		switch (nBtn)
		{
			case 1 :	// Tilt Up
			{
				off[vdvDev[nCurrOut], TILT_UP]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(TILT_UP),']'")
			}
			case 2 :	// Tilt Down
			{
				off[vdvDev[nCurrOut], TILT_DN]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(TILT_DN),']'")
			}
			case 3 :	// Pan Left
			{
				off[vdvDev[nCurrOut], PAN_LT]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(PAN_LT),']'")
			}
			case 4 :	// Pan Right
			{
				off[vdvDev[nCurrOut], PAN_RT]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(PAN_RT),']'")
			}
			case 5 :	// Zoom -
			{
				off[vdvDev[nCurrOut], ZOOM_OUT]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(ZOOM_OUT),']'")
			}
			case 6 :	// Zoom +
			{
				off[vdvDev[nCurrOut], ZOOM_IN]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(ZOOM_IN),']'")
			}
			case 7 :	// Focus -
			{
				off[vdvDev[nCurrOut], FOCUS_NEAR]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(FOCUS_NEAR),']'")
			}
			case 8 :	// Focus +
			{
				off[vdvDev[nCurrOut], FOCUS_FAR]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(FOCUS_FAR),']'")
			}
			case 13 :	// Iris -
			{
				off[vdvDev[nCurrOut], IRIS_CLOSE]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(IRIS_CLOSE),']'")
			}
			case 14 :	// Iris +
			{
				off[vdvDev[nCurrOut], IRIS_OPEN]
				fPrintf("'off[',dpstoa(vdvDev[nCurrOut]),', ',itoa(IRIS_OPEN),']'")
			}
			case 18 :	// Set Zoom (release)
			{
				send_level vdvDev[nCurrOut], ZOOM_LVL, nZoomValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(ZOOM_LVL),', ',itoa(nZoomValue[nCurrOut]),39")
			}
			case 19 :	// Set Focus (release)
			{
				send_level vdvDev[nCurrOut], FOCUS_LVL, nFocusValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(FOCUS_LVL),', ',itoa(nFocusValue[nCurrOut]),39")
			}
			case 20 :	// Set Iris (release)
			{
				send_level vdvDev[nCurrOut], IRIS_LVL, nIrisValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(IRIS_LVL),', ',itoa(nIrisValue[nCurrOut]),39")
			}
			case 21 :	// Set Zoom Speed (release)
			{
				send_level vdvDev[nCurrOut], ZOOM_SPEED_LVL, nZoomSpeedValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(ZOOM_SPEED_LVL),', ',itoa(nZoomSpeedValue[nCurrOut]),39")
			}
			case 22 :	// Set Focus Speed (release)
			{
				send_level vdvDev[nCurrOut], FOCUS_SPEED_LVL, nFocusSpeedValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(FOCUS_SPEED_LVL),', ',itoa(nFocusSpeedValue[nCurrOut]),39")
			}
			case 24 :	// Set Pan (release)
			{
				send_level vdvDev[nCurrOut], PAN_LVL, nPanValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(PAN_LVL),', ',itoa(nPanValue[nCurrOut]),39")
			}
			case 25 :	// Set Tilt (release)
			{
				send_level vdvDev[nCurrOut], TILT_LVL, nTiltValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(TILT_LVL),', ',itoa(nTiltValue[nCurrOut]),39")
			}
			case 26 :	// Set Pan Speed (release)
			{
				send_level vdvDev[nCurrOut], PAN_SPEED_LVL, nPanSpeedValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(PAN_SPEED_LVL),', ',itoa(nPanSpeedValue[nCurrOut]),39")
			}
			case 27 :	// Set Tilt Speed (release)
			{
				send_level vdvDev[nCurrOut], TILT_SPEED_LVL, nTiltSpeedValue[nCurrOut]
				fPrintf("'send_level ',dpstoa(vdvDev[nCurrOut]),', ',itoa(TILT_SPEED_LVL),', ',itoa(nTiltSpeedValue[nCurrOut]),39")
			}
		}
	}
}

level_event[dvTP, nLevels[1]]	// Zoom
{
	nZoomValue[nCurrOut] = level.value
}

level_event[vdvDev, ZOOM_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nZoomValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[1], nZoomValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[1]),', ',itoa(nZoomValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[2]]	// Focus
{
	nFocusValue[nCurrOut] = level.value
}
level_event[vdvDev, FOCUS_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nFocusValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[2], nFocusValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[2]),', ',itoa(nFocusValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[3]]	// Iris
{
	nIrisValue[nCurrOut] = level.value
}
level_event[vdvDev, IRIS_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nIrisValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[3], nIrisValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[3]),', ',itoa(nIrisValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[4]]	// Zoom Speed
{
	nZoomSpeedValue[nCurrOut] = level.value
}
level_event[vdvDev, ZOOM_SPEED_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nZoomSpeedValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[4], nZoomSpeedValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[4]),', ',itoa(nZoomSpeedValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[5]]	// Focus Speed
{
	nFocusSpeedValue[nCurrOut] = level.value
}
level_event[vdvDev, FOCUS_SPEED_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nFocusSpeedValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[5], nFocusSpeedValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[5]),', ',itoa(nFocusSpeedValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[7]]	// Pan
{
	nPanValue[nCurrOut] = level.value
}
level_event[vdvDev, PAN_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nPanValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[7], nPanValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[7]),', ',itoa(nPanValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[8]]	// Tilt
{
	nTiltValue[nCurrOut] = level.value
}
level_event[vdvDev, TILT_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nTiltValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[8], nTiltValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[8]),', ',itoa(nTiltValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[9]]	// Pan Speed
{
	nPanSpeedValue[nCurrOut] = level.value
}
level_event[vdvDev, PAN_SPEED_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nPanSpeedValue[x] = level.value
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[9], nPanSpeedValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[9]),', ',itoa(nPanSpeedValue[nCurrOut]),39")
	}
}

level_event[dvTP, nLevels[10]]	// Tilt Speed
{
	nTiltSpeedValue[nCurrOut] = level.value
}
level_event[vdvDev, TILT_SPEED_LVL]
{
	stack_var integer x
	for (x = 1; x <= nOutputCount; x++)
	{
		if (vdvDev[x] == level.input.device)
		{
			break
		}
	}
	nTiltSpeedValue[x] = level.value
	
	if (x == nCurrOut) 
	{
		send_level dvTP, nLevels[10], nTiltSpeedValue[nCurrOut]
		fPrintf("'send_level ',dpstoa(dvTP),', ',itoa(nLevels[10]),', ',itoa(nTiltSpeedValue[nCurrOut]),39")
	}
}

DEFINE_PROGRAM
[dvTP, nButtons[1]] = [vdvDev[nCurrOut], TILT_UP_FB]
[dvTP, nButtons[2]] = [vdvDev[nCurrOut], TILT_DN_FB]
[dvTP, nButtons[3]] = [vdvDev[nCurrOut], PAN_LT_FB]
[dvTP, nButtons[4]] = [vdvDev[nCurrOut], PAN_RT_FB]
[dvTP, nButtons[5]] = [vdvDev[nCurrOut], ZOOM_OUT_FB]
[dvTP, nButtons[6]] = [vdvDev[nCurrOut], ZOOM_IN_FB]
[dvTP, nButtons[7]] = [vdvDev[nCurrOut], FOCUS_NEAR_FB]
[dvTP, nButtons[8]] = [vdvDev[nCurrOut], FOCUS_FAR_FB]
[dvTP, nButtons[11]] = [vdvDev[nCurrOut], AUTO_FOCUS_FB]
[dvTP, nButtons[12]] = [vdvDev[nCurrOut], AUTO_IRIS_FB]
[dvTP, nButtons[13]] = [vdvDev[nCurrOut], IRIS_CLOSE_FB]
[dvTP, nButtons[14]] = [vdvDev[nCurrOut], IRIS_OPEN_FB]

wait 10
{
	if (nBlink)
	{
		if (nSet)
		{
			[dvTP, nButtons[16]] = ![dvTP, nButtons[16]]
		}
		else
		{
			[dvTP, nButtons[16]] = 0
		}
	}
}
