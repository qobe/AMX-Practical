MODULE_NAME='ProjectorControl' (DEV dvProj, DEV dvTP_Proj, INTEGER nProjStatus)

DEFINE_CONSTANT

    TL_ProjStatusPoll = 1
    TL_ProjLampPoll = 2
    WARMING_UP = 3
    COOLING_OFF = 4

DEFINE_TYPE

    STRUCTURE _Projector
    {
	INTEGER nCoolDownTime
	INTEGER nWarmUpTime
	CHAR strPowerOn[10]
	CHAR strPowerOff[10]
	CHAR strSources[4][10]
	CHAR strLampInfo[10]
	CHAR strStatusRequest[10]
    }

DEFINE_VARIABLE
    VOLATILE LONG lProjStatusPoll [] = {1000}
    VOLATILE LONG lProjLampPoll [] = {30000}	//poll for lamp hours every 30s
    VOLATILE INTEGER sourceButtons[] = {31,32,33,34}
    VOLATILE _Projector objProj
    
    #INCLUDE 'MyLib'

DEFINE_MUTUALLY_EXCLUSIVE
    ([dvTP_Proj, 31]..[dvTP_Proj, 34])
    
////////////////////////DEFINE FUNCTION////////////////////////////////////////
DEFINE_FUNCTION fnConfirmSource(INTEGER i)
{
    SWITCH (i)   
    {
	CASE $01: 	//HDMI
	{
	    ON[dvTP_Proj, sourceButtons[1]]
	    SEND_COMMAND dvTP_Proj, "'^TXT-15,0,','HDMI'"
	}
	CASE 11: 	//S-Video
	{
	    ON[dvTP_Proj, sourceButtons[2]]
	    SEND_COMMAND dvTP_Proj, "'^TXT-15,0,','S-Video'"
	}
	CASE $06: 	//Video
	{
	    ON[dvTP_Proj, sourceButtons[3]]
	    SEND_COMMAND dvTP_Proj, "'^TXT-15,0,','Video'"
	}
	CASE 17: 	//Component
	{
	    ON[dvTP_Proj, sourceButtons[4]]
	    SEND_COMMAND dvTP_Proj, "'^TXT-15,0,','Component'"
	}
    }
}
//////////////////////DEFINE EVENT/////////////////////////////////////////////
DEFINE_EVENT

    DATA_EVENT[dvProj]
    {
	ONLINE:
	{
	    SEND_COMMAND dvProj, "'SET BAUD 38400,N,8,1'"
	    SEND_COMMAND dvProj, "'HSOFF'"
	    
	    objProj.nCoolDownTime = 75
	    objProj.nWarmUpTime = 30
	    objProj.strPowerOn = "$02,$00,$00,$00,$00"
	    objProj.strPowerOff = "$02,$01,$00,$00,$00"
	    objProj.strSources[1] = "$02,$03,$00,$00,$02,$01,$01"	//HDMI
	    objProj.strSources[2] = "$02,$03,$00,$00,$02,$01,$0B"	//S-Video
	    objProj.strSources[3] = "$02,$03,$00,$00,$02,$01,$06"	//Video
	    objProj.strSources[4] = "$02,$03,$00,$00,$02,$01,$11"	//Component
	    objProj.strLampInfo = "$03,$8C,$00,$00,$00"
	    objProj.strStatusRequest = "$00,$85,$00,$D0,$01,$01"
	}
	STRING:
	{
	    //println("'Proj Return String: DATA.TEXT  CKS ',DATA.TEXT[LENGTH_STRING(DATA.TEXT)],' ', fnGenCKS(LEFT_STRING(DATA.TEXT, LENGTH_STRING(DATA.TEXT) - 1))")
	
	    IF(fnGenCKS(LEFT_STRING(DATA.TEXT, LENGTH_STRING(DATA.TEXT) - 1)) == DATA.TEXT[LENGTH_STRING(DATA.TEXT)]) //Confirm checksum
	    {
		IF(FIND_STRING(DATA.TEXT, "$22,$00,$00,$D0,$00",1)) //Power On response
		{
		    TIMELINE_CREATE (TL_ProjLampPoll, lProjLampPoll, LENGTH_ARRAY(lProjLampPoll), TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
		    ON[nProjStatus]
		    TIMELINE_CREATE (TL_ProjStatusPoll, lProjStatusPoll, LENGTH_ARRAY(lProjStatusPoll), TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
		}
		IF(FIND_STRING(DATA.TEXT, "$22,$01,$00,$D0,$00",1)) //Power Off response
		{
		    TIMELINE_KILL (TL_ProjLampPoll)
		    OFF[nProjStatus]
		    TOTAL_OFF[sourceButtons]
		    TIMELINE_CREATE (TL_ProjStatusPoll, lProjStatusPoll, LENGTH_ARRAY(lProjStatusPoll), TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
		}
		IF(FIND_STRING(DATA.TEXT, "$20,$85,$00,$D0,$01",1)) //Running status response
		{
		    SWITCH (DATA.TEXT[6])
		    {
			CASE $03: {nProjStatus = WARMING_UP}
			CASE $05: {nProjStatus = COOLING_OFF}
		    }
		    fnConfirmSource(DATA.TEXT[7])
		}		
		IF(FIND_STRING(DATA.TEXT, "$22,$03,$00,$D0,$01",1)) //Source select response
		{
		    fnConfirmSource(DATA.TEXT[6])
		}
		IF(FIND_STRING(DATA.TEXT, "$23,$8C,$00,$04", 1))	//Lamp Poll response
		{
		    //REMOVE_STRING(DATA.TEXT, "$23,$8C,$00,$04", 1)
		    STACK_VAR CHAR temp [4]
		    STACK_VAR LONG total
		    STACK_VAR INTEGER loop, index, exp, exp2
		    index = 1
		    total = 0
		    exp = 7

		    FOR(loop = LENGTH_STRING(DATA.TEXT) - 1; loop > 4; loop--,index++)
		    {
			temp[index] = DATA.TEXT[loop]
			total = total + ((DATA.TEXT[loop] / $0F) * fnPowerValue(16, exp)) + (($0F BAND DATA.TEXT[loop]) * fnPowerValue(16, exp - 1))
			exp = exp - 2
		    }
		    
		    total = total / 3600 //convert from seconds to hours
		    SEND_COMMAND dvTP_Proj, "'^TXT-14,0,', ITOA(total)"
		}
	    }
	}
    }
    
    TIMELINE_EVENT[TL_ProjLampPoll]
    TIMELINE_EVENT[TL_ProjStatusPoll]
    {
	SWITCH (TIMELINE.ID)
	{
	    CASE TL_ProjStatusPoll:
	    {
		SELECT
		{
		    ACTIVE(nProjStatus && TIMELINE.REPETITION < objProj.nWarmUpTime):
		    {
			SEND_COMMAND dvTP_Proj, "'^TXT-13,0,', ITOA(objProj.nWarmUpTime - TIMELINE.REPETITION)"
		    }
		    ACTIVE(!(nProjStatus) && TIMELINE.REPETITION < objProj.nCoolDownTime):
		    {
			SEND_COMMAND dvTP_Proj, "'^TXT-12,0,', ITOA(objProj.nCoolDownTime - TIMELINE.REPETITION)"
		    }
		    ACTIVE(1):
		    {
			TIMELINE_KILL(TL_ProjStatusPoll)
			SEND_COMMAND dvTP_Proj, "'^TXT-12,0,'"
			SEND_COMMAND dvTP_Proj, "'^TXT-13,0,'"
		    }
		}
	    }
	    CASE TL_ProjLampPoll:
	    {
		SEND_STRING dvProj, "objProj.strLampInfo, fnGenCKS(objProj.strLampInfo)"
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Proj, 255] //Projector power button
    {
	PUSH:
	{
	    IF(nProjStatus)	//IF on turn off
	    {
		SEND_STRING dvProj, "objProj.strPowerOff, fnGenCKS(objProj.strPowerOff)"
	    }
	    ELSE
	    {
		SEND_STRING dvProj, "objProj.strPowerOn, fnGenCKS(objProj.strPowerOn)"
		TOTAL_OFF[dvTP_Proj, 31]
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Proj, sourceButtons]	//Source select buttons
    {
	PUSH:
	{
	    STACK_VAR INTEGER index
	    index = GET_LAST(sourceButtons)
	    
	    SEND_STRING dvProj, "objProj.strSources[index], fnGenCKS(objProj.strSources[index])"
	}
    }
    
DEFINE_PROGRAM

    [dvTP_Proj, 255] = (nProjStatus > 0)
