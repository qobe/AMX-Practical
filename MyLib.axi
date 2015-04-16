PROGRAM_NAME='MyLib'

DEFINE_CONSTANT
    CR = $0D
    LF = $0A
    
    #INCLUDE 'SNAPI'

DEFINE_FUNCTION DO_PULSE_TIMED(DEV dv, INTEGER relay, INTEGER t)
{
    SET_PULSE_TIME(t)
    PULSE[dv, relay]
    SET_PULSE_TIME(5)
}

DEFINE_FUNCTION println(CHAR str [])
{
    SEND_STRING 0, "str"
}

DEFINE_FUNCTION fnOpenTCPConnect(DEV dvIP, CHAR IP4_ADDRESS[15], LONG IP_PORT) //do nothing is device is communicating. reconnect if not
{
    IF(![dvIP, DEVICE_COMMUNICATING])
    {
	IP_CLIENT_OPEN (dvIP.PORT, IP4_ADDRESS, IP_PORT, IP_TCP)
    }
}

DEFINE_FUNCTION LONG fnGenCKS(CHAR strCode[]) //generate checksum
{
    //($02, $00, $00, $00, $00, CKS) is calculated by adding all the bytes and taking the sum $02 + $00 + $00 + $00 + $00 = $02
    STACK_VAR INTEGER loop
    STACK_VAR LONG sum

    FOR(loop = 1; loop <= LENGTH_STRING(strCode); loop++)
    {
	sum = sum + strCode[loop]
    }
    RETURN (sum % $100)
}

DEFINE_FUNCTION INTEGER fnPowerValue(INTEGER base, INTEGER exp)
{
    STACK_VAR INTEGER total
    IF(exp)
    {
	FOR (total = base; exp > 1; exp--)
	{
	    total = total * base
	}
    }
    ELSE
    {
	total = 1
    }
    RETURN total
}