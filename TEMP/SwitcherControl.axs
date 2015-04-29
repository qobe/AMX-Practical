MODULE_NAME='SwitcherControl' (DEV dvSwitcher, DEV dvTP_Switcher)

DEFINE_VARIABLE
    VOLATILE INTEGER outputs [4]

DEFINE_EVENT

    DATA_EVENT[dvSwitcher]
    {
	ONLINE:
	{
	    SEND_COMMAND dvSwitcher, "'SET BAUD 9600,N,8,1'" //configure serial port
	    SEND_COMMAND dvSwitcher, "'HSOFF'" //turn off handshaking
	}
	
	STRING:
	{
	    IF(FIND_STRING(DATA.TEXT, 'OUT',1))
	    {
		STACK_VAR INTEGER in
		STACK_VAR INTEGER out
		
		REMOVE_STRING(DATA.TEXT, 'OUT',1)
		out = ATOI(LEFT_STRING(REMOVE_STRING(DATA.TEXT, 'IN',1), 1))
		in = 10 * ATOI(LEFT_STRING(DATA.TEXT, LENGTH_STRING(DATA.TEXT) - 1))
		IF(in) //If input "0" was selected on SwitchBack go to Else
		{
		    OFF[dvTP_Switcher, outputs[out]]
		    outputs[out]= (in + out)
		    ON[dvTP_Switcher, outputs[out]]
		}
		ELSE
		{
		    OFF[dvTP_Switcher, outputs[out]]
		}
	    }
	}
    }
    
    BUTTON_EVENT[dvTP_Switcher, 0]
    {
	PUSH:
	{
	    STACK_VAR CHAR in[2]
	    STACK_VAR CHAR out[1]
	    STACK_VAR CHAR temp [3]
	    
	    temp = ITOA(BUTTON.INPUT.CHANNEL)
	    out = RIGHT_STRING(temp, 1)
	    in = LEFT_STRING(temp, LENGTH_STRING(temp) - 1)
	    
	    SEND_STRING dvSwitcher, "in, '*', out, 'S'"
	}
    }