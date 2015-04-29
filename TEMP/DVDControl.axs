MODULE_NAME='DVDControl'(DEV dvDVD, DEV dvTP_DVD, INTEGER nDVDStatus)

DEFINE_CONSTANT
    TL_DVDPoll = 1
    CDMode = 1
    DVDMode = 2
    NoMode = 3
    
    CR = $0D

DEFINE_TYPE
    
    STRUCTURE objDEV
    {
	CHAR strPowerOn[30]
	CHAR strPowerOff[30]
    }

DEFINE_VARIABLE
    
    VOLATILE LONG lDVDPoll [] = {1000}	//Poll status every 1s
    VOLATILE INTEGER nDiskType
    
    VOLATILE INTEGER dvdPlayButtons [] = {1,2,3,4,5,6,7}
    VOLATILE CHAR dvdPlayCodes [7][2]
    VOLATILE INTEGER dvdNavButtons [] = {44,45,46,47,48,49}
    VOLATILE CHAR dvdNavCodes [6][2]

DEFINE_LATCHING
    [dvTP_DVD, 1]..[dvTP_DVD, 3]
    [dvTP_DVD, 6]..[dvTP_DVD, 7]
    
DEFINE_MUTUALLY_EXCLUSIVE
    ([dvTP_DVD,1]..[dvTP_DVD,3],[dvTP_DVD,6],[dvTP_DVD,7])
    
DEFINE_START
{
    dvdNavCodes[1] = "$24,$2A"	//Menu
    dvdNavCodes[2] = "$24,$2C"	//Arrow UP
    dvdNavCodes[3] = "$24,$2D"	//Down
    dvdNavCodes[4] = "$24,$2F"	//Left
    dvdNavCodes[5] = "$24,$2E"	//Right
    dvdNavCodes[6] = "$24,$2B"	//Select
    
    dvdPlayCodes[1] = "$20,$21"		//Play
    dvdPlayCodes[2] = "$20,$20"		//Stop
    dvdPlayCodes[3] = "$20,$22"		//Pause
    dvdPlayCodes[4] = "$20,$34"		//Skip Fwd
    dvdPlayCodes[5] = "$20,$33"		//Skip Rev
    dvdPlayCodes[6] = "$20,$32"		//Search Fwd
    dvdPlayCodes[7] = "$20,$31"		//Search Rev
}                 

DEFINE_EVENT
    
    BUTTON_EVENT[dvTP_DVD, dvdPlayButtons]
    {
	PUSH:
	{
	    //TO[BUTTON.INPUT] //handle button visual state by checking status
	    SEND_STRING dvDVD, "dvdPlayCodes[GET_LAST(dvdPlayButtons)], CR"
	}
    }

    BUTTON_EVENT[dvTP_DVD, dvdNavButtons]
    {
	PUSH:
	{
	    IF(nDiskType == DVDMode)	//Navigation buttons should be disabled in CD mode
	    {
		TO[BUTTON.INPUT] 
		SEND_STRING dvDVD, "dvdNavCodes[GET_LAST(dvdNavButtons)], CR"
	    }
	    
	}
    }
    
    TIMELINE_EVENT[TL_DVDPoll]
    {
	SEND_STRING dvDVD, "$21,$12,CR"	//Status inquiry. response caught with data event
	SEND_STRING dvDVD, "$21,$11,CR" //Disk type inquiry
    }
    
    DATA_EVENT[dvDVD]
    {
    	ONLINE:
	{
	    SEND_COMMAND dvDVD, "'SET BAUD 9600,N,8,1'"
	    SEND_COMMAND dvDVD, "'HSOFF'"
	    TIMELINE_CREATE (TL_DVDPoll, lDVDPoll, LENGTH_ARRAY(lDVDPoll), TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
	}
	COMMAND:
	{
	    //popup selected
	}
	STRING:
	{
	    SEND_STRING 0, "'#1 -> ', DATA.TEXT" //diagnostic
	    IF(FIND_STRING(DATA.TEXT, "$05",1) <> 1) //if device is not off ($05)
	    {
		SEND_STRING 0, "'#2 -> ', DATA.TEXT" //diagnostic
		ON[nDVDStatus]
		SELECT
		{
		    ACTIVE(FIND_STRING(DATA.TEXT, "$11,$01",1) == 1): nDiskType = DVDMode 	//Disk Type inquiry response
		    ACTIVE(FIND_STRING(DATA.TEXT, "$11,$02",1) == 1): nDiskType = CDMode
		    ACTIVE(FIND_STRING(DATA.TEXT, "$11,$03",1) == 1): nDiskType = NoMode
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$01",1) == 1): ON[dvTP_DVD, dvdPlayButtons[1]] //Play
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$02",1) == 1): ON[dvTP_DVD, dvdPlayButtons[2]] //stop
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$03",1) == 1): ON[dvTP_DVD, dvdPlayButtons[3]] //pause
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$06",1) == 1): ON[dvTP_DVD, dvdPlayButtons[7]] //rev
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$07",1) == 1): ON[dvTP_DVD, dvdPlayButtons[6]] //ff
		    //ACTIVE(FIND_STRING(DATA.TEXT, "$06",1) == 1): PULSE[dvTP_DVD, GET_LAST(dvdPlayButtons)] //valid command received, but no response code
		}
	    }
	    ELSE
	    {
		OFF[nDVDStatus]
	    }
	}
    }
    

    
