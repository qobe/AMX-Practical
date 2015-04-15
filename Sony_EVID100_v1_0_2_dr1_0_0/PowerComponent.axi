PROGRAM_NAME='PowerComponent'
(***********************************************************)
(*  FILE CREATED ON: 12/09/2005  AT: 09:00:38              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/13/2006  AT: 09:39:24        *)
(***********************************************************)

#if_not_defined __Power_Component__
#define __Power_Component__

DEFINE_DEVICE

DEFINE_CONSTANT

integer nPowerButtons[] = 
{
	9,		//  1 - Set Power
	255,	//  2 - Cycle Power
	27,		//  3 - Set Power On
	28		//  4 - Set Power Off
}

integer nPowerOutputBtns[] =
{
	301,	// Output 1
	302 	// Output 2
}

integer nPowerFBBtns[] =
{
	301,	// Output 1
	302	// Output 2
}

DEFINE_VARIABLE

DEFINE_START

/* Copy / paste the data below, changing the variables if needed

define_module 'PowerComponent' mPwrCmp1(vdvDeviceArray, dvTP, nPowerButtons, nPowerOutputBtns, nPowerFBBtns)

*/

DEFINE_EVENT

DEFINE_PROGRAM

#end_if
