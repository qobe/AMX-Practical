PROGRAM_NAME='Main'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/05/2006  AT: 09:00:25        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
    
    dvTP_Main		=	10001:1:0
    dvTP_Camera		=	10001:10:0	// Camera Control Page
    dvTP_DVD		=	10001:11:0	// DVD player control page
    dvTP_Lighting	=	10001:12:0	// Lighting control Page
    dvTP_Proj		=	10001:13:0	// Room control page
    dvTP_Satellite	=	10001:14:0	// Satellite receiveer control page
    dvTP_Switcher	=	10001:15:0	// Security camera control page
    
    
    dvSwitcher		=	8001:1:0	// 5001:1:0	//Switchback 12x4 Composite Video Switcher
    dvProj		=	8002:1:0	// 5001:2:0	//LightThrower 3000
    dvDVD		=	8003:1:0	// 5001:3:0	//Disco Tech DVD player
    dvCamera		=	5001:4:0	//Sony EVI-D100
    vdvCamera		=	41001:1:0
    vdvKeypad		=	42001:1:0	//Virtual Keypad
    dvSatellite		=	8005:1:0	// 5001:9:0	//DirectTV HR-20 DSS Receiver
    dvLighting		=	0:3:0		//Kill-a-Watt Lighting Controller
    dvRelays		=	5001:8:0	//All relays, Light Catcher, rack power

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

    #WARN 'I spent _hrs on this progam'
    #WARN 'System Requ ver: Thursday,January 27,2011,3:29:14 PM Device Specs ver: 2.2 VideoFlow ver: 2.2 ConnectorDetail ver: 2.2 ControlSingleLines ver: 2.2'
    #WARN 'CHANGE EMULATED DEVICE NUMBERS BACK!!!'

    ScreenRelayUP = 1
    ScreenRelayDN = 2
    ScreenRelaySP = 3
    DevicePowerRelay = 5
    AmpRelay = 6
    
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
    
    VOLATILE INTEGER nSystemStatus = 0
    VOLATILE INTEGER nDVDStatus = 0
    VOLATILE INTEGER nSATStatus = 0
    VOLATILE INTEGER nCAMStatus = 0
    VOLATILE INTEGER nProjStatus = 0
    VOLATILE INTEGER screenButtons[3] = {101,102,103}
    VOLATILE INTEGER keypadButtons[5] = {5,6,7,8,12}
    
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING
    [dvTP_Main,11]..[dvTP_Main,14]

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

    ([dvTP_Main,11]..[dvTP_Main, 14])
    ([dvRelays, ScreenRelayDN],[dvRelays, ScreenRelayUp],[dvRelays, ScreenRelaySP])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
#INCLUDE 'MyLib'

DEFINE_FUNCTION INTEGER fnPowerSystemOn(INTEGER input)
{
    (*	
	a. 00 seconds – Turn on device power relay **, lower the screen & turn on Video
	Projector
	b. 01 seconds – Turn on amplifier power relay **
	c. 31 seconds – If a source button initiated the macro then turn on the source and
	switch Video Projector to the appropriate input.
    *)
    PULSE[dvRelays, DevicePowerRelay]
    DO_PULSE_TIMED(dvRelays, ScreenRelayDN, 25)
    DO_PUSH(dvTP_Proj, 255) //Turn projector on
    WAIT 10
    {
	PULSE[dvRelays, AmpRelay]
	WAIT 300
	{
	   //switch to source
	   SWITCH (input)
	   {
		CASE 1:	//DVD player
		{
		    SEND_STRING dvDVD, "$22,$00,CR"
		    ON[nDVDStatus]
		    DO_PUSH(dvTP_Proj, 34) //switch to component
		}
		CASE 2: //Camera
		{
		    PULSE[vdvCamera, 27] //Turn camera on
		    ON[nCAMStatus]
		    DO_PUSH(dvTP_Proj, 32) //Switch to s-video
		}
		CASE 3: //Satellite
		{
		    PULSE[dvSatellite, 9] //Turn on sat receiver
		    ON[nSATStatus]
		    DO_PUSH(dvTP_Proj, 31)
		}
		CASE 4: //Security cameras
		{
		    DO_PUSH(dvTP_Proj, 33)
		}
	   }
	}
    }
    
    ON[nSystemStatus]
}

DEFINE_FUNCTION INTEGER fnPowerSystemOff()
{
    (*
	a. 0 Seconds – Turn off Satellite Receiver & DVD/CD Player. Turn off Video
	Projector & Local Camera as well.
	b. 2 seconds – Raise the screen
	c. 6 seconds – Turn off amplifier power**
	d. 10 seconds – Turn off device power**
    *)
    DO_PUSH(dvTP_Proj, 255) //Turn proj off
    IF(nDVDStatus){ SEND_STRING dvDVD, "$22,$00,CR" } //turn off dvd
    IF(nSATStatus){ PULSE[dvSatellite, 9]}	//turn off sat
    IF(nCAMStatus){ PULSE[vdvCamera, 28] }	//turn Camera off
    WAIT 20
    {
	DO_PULSE_TIMED(dvRelays, ScreenRelayUP, 25)
	WAIT 40
	{
	    PULSE[dvRelays, AmpRelay]
	    WAIT 40
	    {
		PULSE[dvRelays, DevicePowerRelay]
	    }
	}
    }
    OFF[nSystemStatus]
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

DEFINE_MODULE 'DVDControl' mdvd(dvDVD, dvTP_DVD, nDVDStatus)
DEFINE_MODULE 'CameraControl' mCam(vdvCamera, dvTP_Camera, nCAMStatus)
DEFINE_MODULE 'SatelliteControl' mSat(dvSatellite, dvTP_Satellite, nSATStatus)
DEFINE_MODULE 'SwitcherControl' mSwitch(dvSwitcher, dvTP_Switcher)
DEFINE_MODULE 'LightingControl' mLighting(dvLighting, dvTP_Lighting)
DEFINE_MODULE 'ProjectorControl' mProj(dvProj, dvTP_Proj, nProjStatus)
DEFINE_MODULE 'Sony_EVID100_Comm_dr1_0_0' mCamDev1(vdvCamera, dvCamera)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
    
    BUTTON_EVENT[dvTP_Main, 105]	//System on Button
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	    IF(nSystemStatus)
	    {
		SEND_COMMAND dvTP_Main, "'@PPN-Confirm'"
	    }
	    ELSE
	    {
		fnPowerSystemOn(0)
	    }
	}
    }
    BUTTON_EVENT[dvTP_Main, 106]	//Confirm shutdown
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	    fnPowerSystemOff()
	}
    }

    BUTTON_EVENT[dvTP_Main, 11]		//DVD/CD player select
    {
	PUSH:
	{
	    IF(nSystemStatus == 0)
	    {
		fnPowerSystemOn(1)
	    }
	    ELSE
	    {
		DO_PUSH(dvTP_Proj, 34)
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Main, 12]		//Camera Control
    {
	PUSH:
	{
	    IF(nSystemStatus == 0)
	    {
		fnPowerSystemOn(2)
	    }
	    ELSE
	    {
		DO_PUSH(dvTP_Proj, 32)
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Main, 13]		//Satellite reciever
    {
	PUSH:
	{
	    IF(nSystemStatus == 0)
	    {
		fnPowerSystemOn(3)
	    }
	    ELSE
	    {
		DO_PUSH(dvTP_Proj, 31)
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Main, 14]	//Security Cameras
    {
	PUSH:
	{
	    IF(nSystemStatus == 0)
	    {
		fnPowerSystemOn(4)
	    }
	    ELSE
	    {
		DO_PUSH(dvTP_Proj, 33)
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Main, 10]	//Lighting Control
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	}
    }
    
    BUTTON_EVENT[dvTP_Main, screenButtons]
    {
	PUSH:
	{
	    STACK_VAR INTEGER index
	    index = GET_LAST(screenButtons)
	    
	    SWITCH (index)
	    {
		CASE 1:
		{
		    //UP
		    DO_PULSE_TIMED(dvRelays, ScreenRelayUp, 25)
		}
		CASE 2:
		{
		    //DOWN
		    DO_PULSE_TIMED(dvRelays, ScreenRelayDN, 25)
		}
		CASE 3:
		{
		    //STOP
		    DO_PULSE_TIMED(dvRelays, ScreenRelaySP, 5)
		}
	    }
	}
    }
    CHANNEL_EVENT[dvRelays, ScreenRelaySP]
    CHANNEL_EVENT[dvRelays, ScreenRelayDN]
    CHANNEL_EVENT[dvRelays, ScreenRelayUP]
    {
	ON:
	{
	    ON[dvTP_Main, CHANNEL.CHANNEL + 100]
	}
	OFF:
	{
	    OFF[dvTP_Main, CHANNEL.CHANNEL + 100]
	}
    }

    ////////////////////////////////////////////////////////
    ///Virtual Keypad Controls
    ////////////////////////////////////////////////////////
    BUTTON_EVENT[vdvKeypad, keypadButtons]
    {
	PUSH:
	{
	    STACK_VAR INTEGER index
	    index = GET_LAST(keypadButtons)
	    IF(index == 5)	//System power selected
	    {
		IF(nSystemStatus)	//IF system is on
		{
		    PULSE[AmpRelay]
		    WAIT 10
		    {
			PULSE[DevicePowerRelay]
			OFF[nSystemStatus]
		    }
		}
		ELSE
		{
		    PULSE[DevicePowerRelay]
		    WAIT 10
		    {
			PULSE[AmpRelay]
			ON[nSystemStatus]
		    }
		}
	    }
	    ELSE
	    {
		DO_PUSH(dvTP_Main, 10 + index)
	    }
	}
    }

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

    [dvTP_Main, 105] = nSystemStatus
    [dvTP_Main, 11] = [dvTP_Proj, 34] //Link control buttons to source selection
    [dvTP_Main, 12] = [dvTP_Proj, 32]
    [dvTP_Main, 13] = [dvTP_Proj, 31]
    [dvTP_Main, 14] = [dvTP_Proj, 33]
    
    [vdvKeypad, 5] = [dvTP_Main, 11]
    [vdvKeypad, 6] = [dvTP_Main, 12]
    [vdvKeypad, 7] = [dvTP_Main, 13]
    [vdvKeypad, 8] = [dvTP_Main, 14]
    [vdvKeypad, 12] = nSystemStatus
                                
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

