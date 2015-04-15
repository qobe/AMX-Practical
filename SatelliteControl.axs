MODULE_NAME='SatelliteControl' (DEV dvSatellite, DEV dvTP_Satellite, INTEGER nSATStatus)


DEFINE_VARIABLE
    VOLATILE INTEGER satPresetButtons[] = {1041,1042,1043,1044,1045,1046}
    VOLATILE INTEGER satPresets	[6]
    VOLATILE INTEGER updnButtons[] = {225,226}

DEFINE_EVENT

    DATA_EVENT[dvSatellite]
    {
	ONLINE:
	{
	    satPresets[1] = 123
	    satPresets[2] = 65
	    satPresets[3] = 634
	    satPresets[4] = 98
	    satPresets[5] = 3
	    satPresets[6] = 53
	    
	    SEND_COMMAND DATA.DEVICE, "'CARON'"
	    SEND_COMMAND DATA.DEVICE, "'SET MODE IR'"
	    SEND_COMMAND DATA.DEVICE, "'XCHM-1'"
	    SEND_COMMAND DATA.DEVICE, "'CTON',3"
	    SEND_COMMAND DATA.DEVICE, "'CTOF',2"
	}             
    }
    
    BUTTON_EVENT[dvTP_Satellite, satPresetButtons]
    {
	PUSH:
	{
	    TO[BUTTON.INPUT]
	    SEND_COMMAND dvSatellite, "'XCH ',ITOA(satPresets[GET_LAST(satPresetButtons)])"
	}
    }
    
    BUTTON_EVENT[dvTP_Satellite, updnButtons]
    {
	PUSH:
	{
	    PULSE[dvSatellite, BUTTON.INPUT.CHANNEL - 203]
	}
    }
    
    CHANNEL_EVENT[dvSatellite, 22]
    CHANNEL_EVENT[dvSatellite, 23]
    {
	ON:
	{
	    ON[dvTP_Satellite, CHANNEL.CHANNEL + 203]
	}
	OFF:
	{
	    OFF[dvTP_Satellite, CHANNEL.CHANNEL + 203]
	}
    }