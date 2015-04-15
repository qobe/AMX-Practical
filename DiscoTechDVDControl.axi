PROGRAM_NAME='DiscoTechDVDControl'

DEFINE_DEVICE

    #IF_NOT_DEFINED dvTP_DVD
	dvTP_DVD	=	10001:11:0
    #END_IF
    #IF_NOT_DEFINED dvDVD
	dvDVD		=	8003:1:0
    #END_IF

DEFINE_CONSTANT
    TL_DVDPoll = 1
    CDMode = 1
    DVDMode = 2
    NoMode = 3
    
    CR = $0D
    
DEFINE_VARIABLE
    #IF_NOT_DEFINED nDVDStatus		//define in Main
	VOLATILE INTEGER nDVDStatus = 0
    #END_IF
    
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
    dvdNavCodes[4] = "$24,$2E"	//Right
    dvdNavCodes[5] = "$24,$2F"	//Left
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
	    TO[BUTTON.INPUT]
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
	STRING:
	{
	    IF((FIND_STRING(DATA.TEXT, "$05",1) <> 1) && nDVDStatus)
	    {
		ON[nDVDStatus]
		SELECT
		{
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$05",1) == 1): PULSE[dvTP_DVD, dvdPlayButtons[4]] //Skip Fwd
		    ACTIVE(FIND_STRING(DATA.TEXT, "$12,$04",1) == 1): PULSE[dvTP_DVD, dvdPlayButtons[5]] //Skip Rev
		    ACTIVE(FIND_STRING(DATA.TEXT, "$11,$01",1) == 1): nDiskType = DVDMode 	//Disk Type inquiry response
		    ACTIVE(FIND_STRING(DATA.TEXT, "$11,$02",1) == 1): nDiskType = CDMode
		    ACTIVE(FIND_STRING(DATA.TEXT, "$11,$03",1) == 1): nDiskType = NoMode
		}
	    }
	    ELSE
	    {
		OFF[nDVDStatus]
	    }
	}
    }
    