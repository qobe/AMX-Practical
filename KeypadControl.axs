MODULE_NAME='KeypadControl' (DEV dvKeypad)

DEFINE_EVENT

    DATA_EVENT[dvKeypad]
    {
	ONLINE:
	{
	
	}
    }

    BUTTON_EVENT[dvKeypad, 0]
    {
	PUSH:
	{
	    SELECT(BUTTON.INPUT)
	    {
		ACTIVE(5):
		ACTIVE(6):
		ACTIVE(7):
		ACTIVE(8):
		ACTIVE(12):
	    }
	}
    }

