MODULE_NAME='LightingControl' (DEV dvLighting, DEV dvTP_Lighting)

DEFINE_CONSTANT
    LIGHTING_IP_ADDRESS = '157.182.14.219'	// '192.168.1.112'
    LIGHTING_PORT	= 24
    #INCLUDE 'SNAPI'
    
DEFINE_TYPE
    STRUCTURE _Lighting
    {
	INTEGER lightIntensity
	INTEGER fadeTimer
    }
    
    STRUCTURE _LightScene
    {
	CHAR sceneName [20]
	_Lighting zone[4]
    }
    

DEFINE_VARIABLE
    VOLATILE INTEGER lowerDimButtons[] = {36,38,40,42}	// buttons to lower dim in each zone
    VOLATILE INTEGER raiseDimButtons[] = {35,37,39,41}	// buttons to raise dim in each zone
    VOLATILE INTEGER zoneLevels[] = {10,11,12,13}
    VOLATILE INTEGER sceneButtons [] = {30,31,32}
    NON_VOLATILE _LightScene lightingScenes [3]
    
#INCLUDE 'MyLib'



DEFINE_EVENT

    DATA_EVENT[0]
    {
	ONLINE:
	{
	    fnOpenTCPConnect(dvLighting, LIGHTING_IP_ADDRESS, LIGHTING_PORT)
	    lightingScenes[1].sceneName = 'Scene 1'
	    lightingScenes[1].zone[1].fadeTimer = 1
	    lightingScenes[1].zone[1].lightIntensity = 50
	    lightingScenes[1].zone[2].fadeTimer = 1
	    lightingScenes[1].zone[2].lightIntensity = 25
	    lightingScenes[1].zone[3].fadeTimer = 1
	    lightingScenes[1].zone[3].lightIntensity = 10
	    lightingScenes[1].zone[4].fadeTimer = 1
	    lightingScenes[1].zone[4].lightIntensity = 90
	    lightingScenes[2].sceneName = 'Scene 2'
	    lightingScenes[2].zone[1].fadeTimer = 3
	    lightingScenes[2].zone[1].lightIntensity = 0
	    lightingScenes[2].zone[2].fadeTimer = 3
	    lightingScenes[2].zone[2].lightIntensity = 0
	    lightingScenes[2].zone[3].fadeTimer = 3
	    lightingScenes[2].zone[3].lightIntensity = 0
	    lightingScenes[2].zone[4].fadeTimer = 3
	    lightingScenes[2].zone[4].lightIntensity = 20
	    lightingScenes[3].sceneName = 'Scene 3'
	    lightingScenes[3].zone[1].fadeTimer = 1
	    lightingScenes[3].zone[1].lightIntensity = 30
	    lightingScenes[3].zone[2].fadeTimer = 1
	    lightingScenes[3].zone[2].lightIntensity = 30
	    lightingScenes[3].zone[3].fadeTimer = 1
	    lightingScenes[3].zone[3].lightIntensity = 30
	    lightingScenes[3].zone[4].fadeTimer = 1
	    lightingScenes[3].zone[4].lightIntensity = 0
	}
    }
    
    CHANNEL_EVENT[dvLighting, DEVICE_COMMUNICATING]
    {
	ON:
	{
	    println('Kill-a-Watt Dimmer is communicating')
	}
	OFF:
	{
	    println('Kill-a-Watt Dimmer is not communicating')
	    fnOpenTCPConnect(dvLighting, LIGHTING_IP_ADDRESS, LIGHTING_PORT)
	}
    }
    
    DATA_EVENT[dvLighting]
    {
	ONERROR:
	{
	    println("'error: server=',ITOA(DATA.NUMBER)")
	    fnOpenTCPConnect(dvLighting, LIGHTING_IP_ADDRESS, LIGHTING_PORT)
	}
	ONLINE:
	{
	    //When connection is established
	    println('Kill-a-Watt Dimmer is online')
	    ON[dvLighting, DEVICE_COMMUNICATING]
	}
	OFFLINE:
	{
	    println('Kill-a-Watt Dimmer is offline')
	    OFF[dvLighting, DEVICE_COMMUNICATING]
	}
	STRING:	//Provide feedback, issues updating TP levels 12.12 and 12.13 when selecting presets (feedback too fast for system?)
	{
	    STACK_VAR INTEGER zone
	    STACK_VAR INTEGER lvl
	    
	    IF(FIND_STRING(REMOVE_STRING(DATA.TEXT,':',1), 'DL',1)) 	//Example "DL,[1:4],50,CR,LF"
	    {
		zone = ATOI(LEFT_STRING(REMOVE_STRING(DATA.TEXT, ',', 1), LENGTH_STRING(DATA.TEXT) - 2))
		lvl = ATOI(LEFT_STRING(DATA.TEXT, LENGTH_STRING(DATA.TEXT) - 2))
		SEND_LEVEL dvTP_Lighting, zoneLevels[zone], ((lvl * 255) / 100)
	    }
	}
    }

    BUTTON_EVENT[dvTP_Lighting, lowerDimButtons]
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	    SEND_STRING dvLighting, "'LOWERDIM,[1:',ITOA(GET_LAST(lowerDimButtons)),']',CR"
	}
	RELEASE:
	{
	    SEND_STRING dvLighting, "'STOPDIM,[1:',ITOA(GET_LAST(lowerDimButtons)),']',CR"
	    SEND_COMMAND dvTP_Lighting, "'^TXT-10,0,'"
	}
    }
    BUTTON_EVENT[dvTP_Lighting, raiseDimButtons]
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	    SEND_STRING dvLighting, "'RAISEDIM,[1:',ITOA(GET_LAST(raiseDimButtons)),']',CR"
	}
	RELEASE:
	{
	    SEND_STRING dvLighting, "'STOPDIM,[1:',ITOA(GET_LAST(raiseDimButtons)),']',CR"
	    SEND_COMMAND dvTP_Lighting, "'^TXT-10,0,'"
	}
    }
    
    BUTTON_EVENT[dvTP_Lighting, sceneButtons]
    {
	PUSH:
	{
	    STACK_VAR INTEGER loop, index
	    index = GET_LAST(sceneButtons)
	    
	    SEND_COMMAND dvTP_Lighting, "'^TXT-10,0,',lightingScenes[index].sceneName"
	    
	    FOR(loop = 1; loop <= 4; loop++)
	    {
		SEND_STRING dvLighting, "'FADEDIM,',ITOA(lightingScenes[index].zone[loop].lightIntensity),',',ITOA(lightingScenes[index].zone[loop].fadeTimer),',0,[1:',ITOA(loop),']',CR"
	    }
	    
	}
    }