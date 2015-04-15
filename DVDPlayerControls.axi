PROGRAM_NAME='DVDPlayerControls'

DEFINE_DEVICE

#IF_NOT_DEFINED dvTP_DVD
    dvTP_DVD	=	10001:11:0
#END_IF
#IF_NOT_DEFINED dvDVD
    dvDVD	=	8003:1:0
#END_IF

DEFINE_CONSTANT

    TL_DVDPoll = 1

DEFINE_VARIABLE

    VOLATILE LONG lDVDPoll [] = {1000}
    VOLATILE INTEGER 
    
    VOLATILE INTEGER dvdPlayButtons [] = {1,2,3,4,5,6,7}
    VOLATILE CHAR dvdPlayCodes [7][2]
    VOLATILE INTEGER dvdControlButtons [] = {44,45,46,47,48,49}
    VOLATILE CHAR dvdControlCodes [6][2]

DEFINE_LATCHING
    [dvTP_DVD, 1]..[dvTP_DVD, 3]
    [dvTP_DVD, 6]..[dvTP_DVD, 7]
    
DEFINE_MUTUALLY_EXCLUSIVE
    ([dvTP_DVD,1]..[dvTP_DVD,3],[dvTP_DVD,6],[dvTP_DVD,7])
    
DEFINE_START
{
    dvdControlCodes[1] = "$24,$2A"	//Menu
    dvdControlCodes[2] = "$24,$2C"	//Arrow UP
    dvdControlCodes[3] = "$24,$2D"	//Down
    dvdControlCodes[4] = "$24,$2E"	//Right
    dvdControlCodes[5] = "$24,$2F"	//Left
    dvdControlCodes[6] = "$24,$2B"	//Select
    
    dvdPlayCodes[1] = "$20,$21"		//Play
    dvdPlayCodes[2] = "$20,$20"		//Stop
    dvdPlayCodes[3] = "$20,$22"		//Pause
    dvdPlayCodes[4] = "$20,$34"		//Skip Fwd
    dvdPlayCodes[5] = "$20,$33"		//Skip Rev
    dvdPlayCodes[6] = "$20,$32"		//Search Fwd
    dvdPlayCodes[7] = "$20,$31"		//Search Rev
}                 

DEFINE_EVENT
    
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
	    SELECT
	    {
		ACTIVE(FIND_STRING(DATA.TEXT, "$12,$05",1) == 1): PULSE[dvTP_DVD, dvdPlayButtons[4]] //Skip Fwd
		ACTIVE(FIND_STRING(DATA.TEXT, "$12,$04",1) == 1): PULSE[dvTP_DVD, dvdPlayButtons[5]] //Skip Rev
	    }
	}
    }
    BUTTON_EVENT[dvTP_DVD, dvdPlayButtons]
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	    SEND_STRING dvDVD, "dvdPlayCodes[GET_LAST(dvdPlayButtons)], CR"
	}
    }

    BUTTON_EVENT[dvTP_DVD, dvdControlButtons]
    {
	PUSH:
	{
	    SEND_STRING dvDVD, "dvdControlCodes[GET_LAST(dvdControlButtons)], CR"
	}
    }
    
    TIMELINE_EVENT[TL_DVDPoll]
    {
	//Poll DVD status
	SEND_STRING dvDVD, "$21,$12,CR"
    }
    