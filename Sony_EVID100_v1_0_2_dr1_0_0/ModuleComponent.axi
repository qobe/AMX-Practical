PROGRAM_NAME='ModuleComponent'
(***********************************************************)
(*  FILE CREATED ON: 12/09/2005  AT: 10:31:06              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/18/2006  AT: 10:37:43        *)
(***********************************************************)

#if_not_defined __Module_Component__
#define __Module_Component__

DEFINE_DEVICE

DEFINE_CONSTANT

integer nModuleButtons[] = 
{
	1001,	//  1 - Device Online
	1002,	//  2 - Data Initialized
	1003,	//  3 - Reinitialize
	1004,	//  4 - Debug state 1 (ERROR)
	1005,	//  5 - Debug state 2 (WARNING)
	1006,	//  6 - Debug state 3 (INFO)
	1007,	//  7 - Debug state 4 (DEBUG)
	1540,	//  8 - Query for debugging state
	1541,	//  9 - Query for device firmware version
	1542,	// 10 - Query for module version
	1543,	// 11 - Set Month
	1544,	// 12 - Set Day
	1545,	// 13 - Set Year
	1546,	// 14 - Set Hour
	1547,	// 15 - Set Minute
	1548,	// 16 - Set Seconds
	2000,	// 17 - 0
	2001,	// 18 - 1
	2002,	// 19 - 2
	2003,	// 20 - 3
	2004,	// 21 - 4
	2005,	// 22 - 5
	2006,	// 23 - 6
	2007,	// 24 - 7
	2008,	// 25 - 8
	2009,	// 26 - 9
	2010,	// 27 - Accept
	2011,	// 28 - Cancel
	2012,	// 29 - Clear
	1549	// 30 - Set Date/Time
}

integer nModuleVTButtons[] = 
{
	1001,	//  1 - FW Version
	1002,	//  2 - Module Version
	1543,	//  3 - Month
	1544,	//  4 - Day
	1545,	//  5 - Year
	1546,	//  6 - Hour
	1547,	//  7 - Minute
	1548,	//  8 - Second
	2000	//  9 - Numpad display
}

DEFINE_VARIABLE

DEFINE_START

/* Copy / paste the data below, changing the variables if needed

define_module 'ModuleComponent' mMdlCmp1(vdvDevice, dvTP, nModuleButtons, nModuleVTButtons)

*/

DEFINE_EVENT

DEFINE_PROGRAM

#end_if
