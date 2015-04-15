MODULE_NAME='ModuleComponent'(
								dev vdvDev,
								dev dvTP,
								integer nButtons[],
								integer nVTButtons[]
							 )
(***********************************************************)
(*  FILE CREATED ON: 12/09/2005  AT: 10:19:02              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 03/06/2006  AT: 14:25:13        *)
(***********************************************************)

DEFINE_DEVICE

DEFINE_CONSTANT

#include 'SNAPI.axi'

DEFINE_VARIABLE

volatile integer nDbg = 1
volatile integer nSet = 0
volatile char sMonth[2] = '01'
volatile char sDay[2]   = '01'
volatile char sYear[4]  = '2001'
volatile char sHour[2]  = '01'
volatile char sMinute[2]= '01'
volatile char sSecond[2]= '01'
volatile char sNewSet[4]= ''

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
		send_string 0, "'** Message from ModuleComponent.axs: ',sTxt"
	}
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

DEFINE_EVENT

data_event[vdvDev]
{
	command:
	{
		
		if (find_string(data.text, '-', 1))
		{
			stack_var char sCmd[20]
			sCmd = remove_string(data.text, '-', 1)
			
			switch (sCmd)
			{
				case 'FWVERSION-' :
				{
					send_command dvTP, "'^TXT-',itoa(nVTButtons[1]),',0,',data.text"
				}
				case 'VERSION-' :
				{
					send_command dvTP, "'^TXT-',itoa(nVTButtons[2]),',0,',data.text"
				}
				case 'DEBUG-' :
				{
					nDbg = atoi(data.text)
					fPrintf("'Debug Level - ', data.text")
				}
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
			case 3 :	// Reinitialize
			{
				send_command vdvDev, 'REINIT'
				fPrintf("'send_command ',dpstoa(vdvDev),', ',39,'REINIT',39")
			}
			case 4 :	// Debug state 1 (ERROR)
			case 5 :	// Debug state 2 (WARNING)
			case 6 :	// Debug state 3 (INFO)
			case 7 :	// Debug state 4 (DEBUG)
			{
				send_command vdvDev, "'DEBUG-',itoa(nBtn - 3)"
				fPrintf("'send_command ',dpstoa(vdvDev),', ',39,'DEBUG-',itoa(nBtn - 3),39")
			}
			case 8 :	// Query for debug state
			{
				send_command vdvDev, "'?DEBUG'"
				fPrintf("'send_command ',dpstoa(vdvDev),', ',39,'?DEBUG',39")
			}
			case 9 :	// Query for device firmware version
			{
				send_command vdvDev, "'?FWVERSION'"
				fPrintf("'send_command ',dpstoa(vdvDev),', ',39,'?FWVERSION',39")
			}
			case 10 :	// Query for module version
			{
				send_command vdvDev, "'?VERSION'"
				fPrintf("'send_command ',dpstoa(vdvDev),', ',39,'?VERSION',39")
			}
			case 11 :	// Set Month
			case 12 :	// Set Day
			case 13 :	// Set Year
			case 14 :	// Set Hour
			case 15 :	// Set Minute
			case 16 :	// Set Seconds
			{
				nSet = nBtn
				send_command dvTP, "'@PPN-Module Numeric'"
			}
			case 17 :	// 0
			case 18 :	// 1
			case 19 :	// 2
			case 20 :	// 3
			case 21 :	// 4
			case 22 :	// 5
			case 23 :	// 6
			case 24 :	// 7
			case 25 :	// 8
			case 26 :	// 9
			{
				if (nSet == 13)
				{
					if (length_string(sNewSet) >= 4)
					{
						get_buffer_char(sNewSet)
					}
				}
				else
				{
					if (length_string(sNewSet) >= 2)
					{
						get_buffer_char(sNewSet)
					}
				}
				sNewSet = "sNewSet, itoa(nBtn - 17)"
				send_command dvTP, "'^TXT-',itoa(nVTButtons[9]),',0,',sNewSet"
			}
			case 27 :	// Accept
			{
				switch (nSet)
				{
					case 11 :	// Set Month
					{
						sMonth = sNewSet
						send_command dvTP, "'^TXT-',itoa(nVTButtons[3]),',0,',sMonth"
					}
					case 12 :	// Set Day
					{
						sDay = sNewSet
						send_command dvTP, "'^TXT-',itoa(nVTButtons[4]),',0,',sDay"
					}
					case 13 :	// Set Year
					{
						sYear = sNewSet
						send_command dvTP, "'^TXT-',itoa(nVTButtons[5]),',0,',sYear"
					}
					case 14 :	// Set Hour
					{
						sHour = sNewSet
						send_command dvTP, "'^TXT-',itoa(nVTButtons[6]),',0,',sHour"
					}
					case 15 :	// Set Minute
					{
						sMinute = sNewSet
						send_command dvTP, "'^TXT-',itoa(nVTButtons[7]),',0,',sMinute"
					}
					case 16 :	// Set Seconds
					{
						sSecond = sNewSet
						send_command dvTP, "'^TXT-',itoa(nVTButtons[8]),',0,',sSecond"
					}
				}
				nSet = 0
				set_length_string(sNewSet, 0)
				send_command dvTP, "'^TXT-',itoa(nVTButtons[9]),',0,',sNewSet"
				send_command dvTP, "'@PPK-Module Numeric'"
			}
			case 28 :	// Cancel
			{
				nSet = 0
				set_length_string(sNewSet, 0)
				send_command dvTP, "'^TXT-',itoa(nVTButtons[9]),',0,',sNewSet"
				send_command dvTP, "'@PPK-Module Numeric'"
			}
			case 29 :	// Clear
			{
				set_length_string(sNewSet, 0)
				send_command dvTP, "'^TXT-',itoa(nVTButtons[9]),',0,',sNewSet"
			}
			case 30 :	// Set Date/Time
			{
				send_command vdvDev, "'CLOCK-',sMonth,'/',sDay,'/',sYear,' ',sHour,':',sMinute,':',sSecond"
				fPrintf("'send_command ',dpstoa(vdvDev),', ',39,'CLOCK-',sMonth,'/',sDay,'/',sYear,' ',sHour,':',sMinute,':',sSecond,39")
			}
		}
	}
}

DEFINE_PROGRAM
[dvTP, nButtons[1]] = [vdvDev, DEVICE_COMMUNICATING]
[dvTP, nButtons[2]] = [vdvDev, DATA_INITIALIZED]
[dvTP, nButtons[4]] = (nDbg == 1)
[dvTP, nButtons[5]] = (nDbg == 2)
[dvTP, nButtons[6]] = (nDbg == 3)
[dvTP, nButtons[7]] = (nDbg == 4)
