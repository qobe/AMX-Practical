MODULE_NAME='PowerComponent'(
								dev vdvDev[],
								dev dvTP,
								integer nButtons[],
								integer nOutputBtns[],
								integer nFBArray[]
							)
(***********************************************************)
(*  FILE CREATED ON: 12/09/2005  AT: 08:49:16              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/13/2006  AT: 09:38:23        *)
(***********************************************************)

DEFINE_DEVICE

DEFINE_CONSTANT

#include 'SNAPI.axi'

DEFINE_VARIABLE

volatile integer nCurrZone = 1
volatile integer nDbg = 1
volatile integer nOutputCount = 1

//*******************************************************************
// Function : fPrintf												*
// Purpose  : to print a line to the telnet session					*
// Params   : sTxt - the data to print to the telnet session		*
// Return   : none													*
//*******************************************************************
define_function fPrintf (char sTxt[])
{
	if (nDbg > 1)
	{
		send_string 0, "'** Message from PowerComponent.axs: ',sTxt"
	}
}

//*******************************************************************
// Function : fnFBLookup											*
// Purpose  : to look up whether this module is controlling 		*
//			  feedback for the button								*
// Params   : nChNo - the channel to test for feedback control		*
// Return   : integer - 1 for do feedback, 0 for do not do feedback	*
//*******************************************************************
define_function integer fnFBLookup (integer nChNo)
{
	stack_var integer z
	stack_var integer nFB
	nFB = 0
	z = 0
	for (z = 1; z <= length_array(nFBArray); z++)
	{
		if (nFBArray[z] == nChNo)
		{
			nFB = z
			break
		}
	}
/*	if (nFB)
	{
		fPrintf("'This component has feedback control over button #',itoa(nChNo)")
	}
	else
	{
		fPrintf("'This component does not have feedback control over button #',itoa(nChNo)")
	}
*/	return nFB
}

//*******************************************************************
// Function : dpstoa												*
// Purpose  : to convert a device's DPS to ascii for displaying		*
// Params   : dvIn - the device to be represented in ascii			*
// Return   : char[20] - the ascii representation of the dvIn's DPS	*
//*******************************************************************
define_function char[20] dpstoa (dev dvIn)
{
	return "itoa(dvIn.number),':',itoa(dvIn.port),':',itoa(dvIn.system)"
}

DEFINE_START

nOutputCount = length_array(nOutputBtns)

DEFINE_EVENT

data_event[vdvDev]
{
	command:
	{
		if (find_string(data.text, 'DEBUG-', 1))
		{
			remove_string(data.text, '-', 1)
			nDbg = atoi(data.text)
		}
	}
}

button_event[dvTP, nOutputBtns]
{
	push:
	{
		stack_var integer x
		nCurrZone = get_last(nOutputBtns)
		
		for (x = 1; x <= nOutputCount; x++)
		{
			if (fnFBLookup(nOutputBtns[x]))
			{
				[dvTP, nOutputBtns[x]] = (nCurrZone == x)
			}
		}
	}
}

button_event[dvTP, nButtons]
{
	push:
	{
		stack_var integer nBtn
		nBtn = get_last(nButtons)
		
		switch (nBtn)
		{
			case 1 :	// Set Power
			{
				[vdvDev[nCurrZone], POWER_ON] = ![vdvDev[nCurrZone], POWER_ON]
				fPrintf("'[',dpstoa(vdvDev[nCurrZone]),', ',itoa(POWER_ON),'] = ![',dpstoa(vdvDev[nCurrZone]),', ',itoa(POWER_ON),']'")
			}
			case 2 :	// Cycle Power
			{
				pulse[vdvDev[nCurrZone], POWER]
				fPrintf("'pulse[',dpstoa(vdvDev[nCurrZone]),', ',itoa(POWER),']'")
			}
			case 3 :	// Set Power On
			{
				pulse[vdvDev[nCurrZone], PWR_ON]
				fPrintf("'pulse[',dpstoa(vdvDev[nCurrZone]),', ',itoa(PWR_ON),']'")
			}
			case 4 :	// Set Power Off
			{
				pulse[vdvDev[nCurrZone], PWR_OFF]
				fPrintf("'pulse[',dpstoa(vdvDev[nCurrZone]),', ',itoa(PWR_OFF),']'")
			}
		}
	}
}

DEFINE_PROGRAM
[dvTP, nButtons[1]] = [vdvDev[nCurrZone], POWER_FB]
[dvTP, nButtons[3]] = [vdvDev[nCurrZone], POWER_FB]
[dvTP, nButtons[4]] = ![vdvDev[nCurrZone], POWER_FB]
