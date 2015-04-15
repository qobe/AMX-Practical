PROGRAM_NAME='CameraComponent'
(***********************************************************)
(*  FILE CREATED ON: 12/21/2005  AT: 08:18:10              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/14/2006  AT: 13:41:37        *)
(***********************************************************)

#if_not_defined __Camera_Component__
#define __Camera_Component__

DEFINE_DEVICE

DEFINE_CONSTANT

integer nCameraButtons[] =
{
	132,	//  1 - Tilt Up
	133,	//  2 - Tilt Down
	134,	//  3 - Pan Left
	135,	//  4 - Pan Right
	158,	//  5 - Zoom -
	159,	//  6 - Zoom +
	160,	//  7 - Focus -
	161,	//  8 - Focus +
	162,	//  9 - Auto Focus Cycle
	163,	// 10 - Auto Iris Cycle
	172,	// 11 - Auto Focus Off / On
	173,	// 12 - Auto Iris Off / On
	174,	// 13 - Iris - Close
	175,	// 14 - Iris + Open
	177,	// 15 - Camera Preset Cycle
	260,	// 16 - Save Preset
	1050,	// 17 - Query Camera Preset
	3015,	// 18 - Set Zoom (release)
	3016,	// 19 - Set Focus (release)
	3017,	// 20 - Set Iris (release)
	3018,	// 21 - Set Zoom Speed (release)
	3019,	// 22 - Set Focus Speed (release)
	3020,	// 23 - Set Iris Speed (release)
	3027,	// 24 - Set Pan (release)
	3028,	// 25 - Set Tilt (release)
	3029,	// 26 - Set Pan Speed (release)
	3030	// 27 - Set Tilt Speed (release)
}

integer nCameraPresetBtns[] =
{
	261,	// Preset 1
	262,	// Preset 2
	263,	// Preset 3
	264,	// Preset 4
	265,	// Preset 5
	266 	// Preset 6
}

integer nCameraLevels[] =
{
	15,		//  1 - Zoom
	16,		//  2 - Focus
	17,		//  3 - Iris
	18,		//  4 - Zoom Speed
	19,		//  5 - Focus Speed
	20,		//  6 - Iris Speed
	27,		//  7 - Pan
	28,		//  8 - Tilt
	29,		//  9 - Pan Speed
	30		// 10 - Tilt Speed
}

integer nCameraFBBtns[] =
{
	260,	// Save Preset
	261,	// Preset 1
	262,	// Preset 2
	263,	// Preset 3
	264,	// Preset 4
	265,	// Preset 5
	266		// Preset 6
}

integer nCameraOutputBtns[] =
{
	301,	// Output 1
	302 	// Output 2
}

DEFINE_VARIABLE

DEFINE_START

/* Copy / paste the data below, changing the variables if needed

define_module 'CameraComponent' mCamCmp1(vdvDevice, dvTP, nCameraButtons, nCameraOutputBtns,nCameraLevels, nCameraPresetBtns, nCameraFBBtns)

*/

DEFINE_EVENT

DEFINE_PROGRAM

#end_if
