PROGRAM_NAME='VirtualKeyPad'
					(***********************************************************)
					(*                                                         *)
					(*             AMX Virtual Keypad  (1.0.0)                 *)
					(*                                                         *)
					(***********************************************************)
//***********************                                         ***********************
//***********************                                         ***********************
//***********************                                         ***********************

//THE FOLLOWING NETLINX CODE IS TO BE USED ONLY AS SAMPLE CODE NOT AS A FINISHED PRODUCT.
//THE FOLLOWING NETLINX CODE IS TO BE USED ONLY AS SAMPLE CODE NOT AS A FINISHED PRODUCT.
//THE FOLLOWING NETLINX CODE IS TO BE USED ONLY AS SAMPLE CODE NOT AS A FINISHED PRODUCT.

//***********************                                         ***********************
//***********************                                         ***********************
//***********************                                         ***********************
//# Legal Notice :
//#    Copyright, AMX LLC, 2006-2011
//#    Private, proprietary information, the sole property of AMX LLC.  The
//#    contents, ideas, and concepts expressed herein are not to be disclosed
//#    except within the confines of a confidential relationship and only
//#    then on a need to know basis.
//#
//#    Any entity in possession of this AMX Software shall not, and shall not
//#    permit any other person to, disclose, display, loan, publish, transfer
//#    (whether by sale, assignment, exchange, gift, operation of law or
//#    otherwise), license, sublicense, copy, or otherwise disseminate this
//#    AMX Software.
//#
//#    This AMX Software is owned by AMX and is protected by United States
//#    copyright laws, patent laws, international treaty provisions, and/or
//#    state of Texas trade secret laws.
//#
//#    Portions of this AMX Software may, from time to time, include
//#    pre-release code and such code may not be at the level of performance,
//#    compatibility and functionality of the final code. The pre-release code
//#    may not operate correctly and may be substantially modified prior to
//#    final release or certain features may not be generally released. AMX is
//#    not obligated to make or support any pre-release code. All pre-release
//#    code is provided "as is" with no warranties.
//#
//#    This AMX Software is provided with restricted rights. Use, duplication,
//#    or disclosure by the Government is subject to restrictions as set forth
//#    in subparagraph (1)(ii) of The Rights in Technical Data and Computer
//#    Software clause at DFARS 252.227-7013 or subparagraphs (1) and (2) of
//#    the Commercial Computer Software Restricted Rights at 48 CFR 52.227-19,
//#    as applicable.
//####
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
VIRTUALKEYPAD = 				41001:1:0
dvVIRTUALKEYPAD = 				0:4:0
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
//The following Constants define the button label text which will
//appear on the Virtual Keypad
DEFINE_CONSTANT
BUTTON1 = 'Button 1'
BUTTON2 = 'Button 2'
BUTTON3 = 'Button 3'
BUTTON4 = 'Button 4'
BUTTON5 = 'Button 5'
BUTTON6 = 'Button 6'
BUTTON7 = 'Button 7'
BUTTON8 = 'Button 8'
BUTTON9 = 'Button 9'
BUTTON10 = 'Button 10'
BUTTON11 = 'Button 11'
BUTTON12 = 'Button 12'

//The following array hold the button numbers for each button
//on the Virtual Keypad
integer BTNS[] =
{
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12
}
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
//to prevent runaway ramping
integer ramp_timeout
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
DEFINE_MODULE 'VirtualKeypad_dr1_0_0' VKP(VIRTUALKEYPAD, dvVIRTUALKEYPAD)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT [VIRTUALKEYPAD]
{
    //The following online event updates the initial display on
		//the text window as well as the button text which are defined above.
		online:
    {
			send_command VIRTUALKEYPAD, "'LINETEXT1-'"
			send_command VIRTUALKEYPAD, "'LINETEXT2-AMX'"
			send_command VIRTUALKEYPAD, "'LINETEXT3-'"
			send_command VIRTUALKEYPAD, "'LABEL1-',BUTTON1"
			send_command VIRTUALKEYPAD, "'LABEL2-',BUTTON2"
			send_command VIRTUALKEYPAD, "'LABEL3-',BUTTON3"
			send_command VIRTUALKEYPAD, "'LABEL4-',BUTTON4"
			send_command VIRTUALKEYPAD, "'LABEL5-',BUTTON5"
			send_command VIRTUALKEYPAD, "'LABEL6-',BUTTON6"
			send_command VIRTUALKEYPAD, "'LABEL7-',BUTTON7"
			send_command VIRTUALKEYPAD, "'LABEL8-',BUTTON8"
			send_command VIRTUALKEYPAD, "'LABEL9-',BUTTON9"
			send_command VIRTUALKEYPAD, "'LABEL10-',BUTTON10"
			send_command VIRTUALKEYPAD, "'LABEL11-',BUTTON11"
			send_command VIRTUALKEYPAD, "'LABEL12-',BUTTON12"
    }
}

//The following are button events for each button on the Virtual Keypad
//This code is executed when the corresponding button is pushed
//Add the necessary code to a button case to implement your desired action
button_event [VIRTUALKEYPAD,BTNS]
{
//The current code samples below offer several methods of toggling the
//state of the buttons between ON and OFF.
    push:
    {
			switch (button.input.channel)
			{
				case 1:
				{//the following sample checks the status of button 1 and if the
				 //button status is ON the button is turned OFF and OFF if it is ON
					if ([virtualkeypad,1])
					{
						OFF[virtualkeypad,1]
					}
					else
					{
						ON[virtualkeypad,1]
					}
					break
				}
				case 2:
				{//the following sample checks the status of button 2 and if the
				 //button status is ON the button is turned OFF and OFF if it is ON
					if ([virtualkeypad,2])
					{
						OFF[virtualkeypad,2]
					}
					else
					{
						ON[virtualkeypad,2]
					}
					break
				}
				case 3:
				{//the following sample checks the status of the button.input.channel value
					//which in the section is 3 and if the button status is ON the button is
					//turned OFF and ON if it is OFF
					if ([virtualkeypad,button.input.channel])
					{
						OFF[virtualkeypad,button.input.channel]
					}
					else
					{
						ON[virtualkeypad,button.input.channel]
					}
					break
				}
				case 4:
				{//the following sample just toggles the status to the opposite of it current value
					[VIRTUALKEYPAD,button.input.channel] = ![virtualkeypad,button.input.channel]
					break
				}
				//The following is example code which shows how to
				//stack button events which have similar functionality
				case 5:
				case 6:
				case 7:
				{
					if ([virtualkeypad,button.input.channel])
					{
						OFF[virtualkeypad,button.input.channel]
					}
					else
					{
						ON[virtualkeypad,button.input.channel]
					}
					break
				}
				//The following is example code which shows how to
				//stack button events which have similar functionality
				case 8:
				case 9:
				case 10:
				{
					[VIRTUALKEYPAD,button.input.channel] = ![virtualkeypad,button.input.channel]
					break
				}
				case 11:
				{
					[VIRTUALKEYPAD,11] = ![virtualkeypad,11]
					break
				}
				case 12:
				{
					[VIRTUALKEYPAD,12] = ![virtualkeypad,12]
					break
				}
			}

			//The following shows examples of how to use the send_command to send updates to the text
			//window using the LINETEXT# command.  See user guide for more detail.
			send_command VIRTUALKEYPAD, "'LINETEXT1-Netlinx Push'"
			send_command VIRTUALKEYPAD, "'LINETEXT2-Button ',itoa(button.input.channel),' pushed'"

			if ([VIRTUALKEYPAD,button.input.channel])
			{
				send_command VIRTUALKEYPAD, "'LINETEXT3-Channel ',itoa(button.input.channel),' ON'"
			}
			else
			{
				send_command VIRTUALKEYPAD, "'LINETEXT3-Channel ',itoa(button.input.channel),' OFF'"
			}
		}

		//Button release section.  This code is executed when the corresponding button is released
		release:
		{
			ramp_timeout = 0
			send_command VIRTUALKEYPAD, 'LINETEXT1-Netlinx Release'
			send_command VIRTUALKEYPAD, "'LINETEXT2-Button ',itoa(button.input.channel),' released'"
		}

		//Button hold section.  This code is executed when the corresponding button is held for the
		hold[10,repeat]: //this code will facilitate ramping functionality
		{
			//some type of ramp timeout is recommended to prevent run away ramping in case the
			//panel is slammed with too many pushes in rapid fashion. This sample code forces the
			//ramping code to stop automatically after 5 seconds, even if the button is still pressed.
			//If more ramping is needed simply release and press the button again.
			ramp_timeout = ramp_timeout + 1
			if(ramp_timeout < 5)
			{
				send_command VIRTUALKEYPAD, 'LINETEXT1-Netlinx Ramping'
				send_command VIRTUALKEYPAD, "'LINETEXT2-Button ',itoa(button.input.channel),' ramping'"
			}
			else
			{
				ramp_timeout = 0
				//Put any force release code here
				//....
				send_command VIRTUALKEYPAD, 'LINETEXT1-Netlinx Release'
				send_command VIRTUALKEYPAD, "'LINETEXT2-Button ',itoa(button.input.channel),' released'"
			}
		}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)