PROGRAM_NAME='Sony EVI-D100 Main'
(***********************************************************)
(*  FILE CREATED ON: 02/01/2006  AT: 14:06:31              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 02/22/2006  AT: 15:59:11        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvCamOut = 5001:1:0
vdvCam1 = 41001:1:0
vdvCam2 = 41001:2:0

dvTP = 10001:17:0


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

integer NO_BTN = 9999

dev vdvCamArray[] =
{
	vdvCam1,
	vdvCam2
}

#include 'CameraComponent.axi'
#include 'ModuleComponent.axi'
#include 'PowerComponent.axi'

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
//DDD
//dynamic_application_device(vdvCam1,duet_dev_type_camera,'sony')
//dynamic_polled_port(dvCamOut)
//static_port_binding(vdvCam1,dvCamOut,duet_dev_type_camera,'sony',duet_dev_polled)


(* System Information Strings ******************************)
(* Use this section if there is a TP in the System!        *)
(*
    SEND_COMMAND TP,"'!F',250,'1'"
    SEND_COMMAND TP,"'TEXT250-',__NAME__"
    SEND_COMMAND TP,"'!F',251,'1'"
    SEND_COMMAND TP,"'TEXT251-',__FILE__,', ',S_DATE,', ',S_TIME"
    SEND_COMMAND TP,"'!F',252,'1'"
    SEND_COMMAND TP,"'TEXT252-',__VERSION__"
    SEND_COMMAND TP,"'!F',253,'1'"
    (* Must fill this (Master Ver) *)
    SEND_COMMAND TP,'TEXT253-'
    SEND_COMMAND TP,"'!F',254,'1'"
    (* Must fill this (Panel File) *)
    SEND_COMMAND TP,'TEXT254-'
    SEND_COMMAND TP,"'!F',255,'1'"
    (* Must fill this (Dealer Info) *)
    SEND_COMMAND TP,'TEXT255-'
*)

define_module 'CameraComponent' mCamCmp1(vdvCamArray, dvTP, nCameraButtons, nCameraOutputBtns, nCameraLevels, nCameraPresetBtns, nCameraFBBtns)
define_module 'ModuleComponent' mMdlCmp1(vdvCam1, dvTP, nModuleButtons, nModuleVTButtons)
define_module 'PowerComponent' mPwrCmp1(vdvCamArray, dvTP, nPowerButtons, nPowerOutputBtns, nPowerFBBtns)

define_module 'Sony_EVID100_Comm_dr1_0_0' mCamDev1(vdvCam1, dvCamOut)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

