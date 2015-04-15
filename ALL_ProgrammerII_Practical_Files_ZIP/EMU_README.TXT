*** If using Windows 8+, it may require the use of: http://johann.loefflmann.net/en/software/jarfix/index.html  ***


The testing emulator is meant to provide a means to test and troubleshoot the AMX Programmer Practical exam in the absence of controlled equipment.  The program connects to the NetLinx master and responds as if it were a device connected to the controller.

You will still need a NetLinx master and a G4 touchpanel.  The version of master is unimportant, although to fully test the practical you will need Duet firmware.  Recommended NetLinx masters are therefore any NI-series integrated controller or an NXC-ME260/64.


Using the AMX Programmer Practical testing emulator:


You will need a relatively current JVM on the PC you intend to run the emulator.  Go to java.sun.com if you do not have the Java Runtime Environment.  This program was written against J2SE v1.6.0_07.  Older versions may work, but nothing older than 1.5.

Double-click the jar file to get started.

When the application opens, you will be presented with a launcher for the individual connected devices specified in the test.

First, type the IP address of the NetLinx master you will load the program to.  This will populate a similar field in all the device emulators you launch.  This will make it convenient to connect.

Pressing Connect will cause the individual device simulator to attempt a connection with the NetLinx master.


NOTE:  Due to a limitation of the process I used to connect, you will need to edit your DEFINE_DEVICE section.  The devices are configurable, but the defaults are as follows:

The SwitchBack 12x4 matrix switcher 	--- 8001:1:0

The LightThrower 3000 projector		--- 8002:1:0

The DiscoTech DVD player		--- 8003:1:0

The DirecTV satellite receiver		--- 8005:1:0


The lighting emulator does not attempt to connect as it is a server application and is waiting for the NetLinx master to connect on TCP port 24.


If the connection has been successful, the connect button will turn yellow.  The commands and strings to and from the NetLinx master will appear in the console window.  The device should visibly react to the correct strings.



Notes on the emulator's behavior:

Each of the devices will appear as two windows.  Selecting one brings the other to the front.  Closing one closes the other.

Closing the Emu Launcher closes all the device emulators.  Pressing 'Bring All to Front' on the Emu Launcher is a handy way to call the devices to attention without clicking on a dozen Start Menu items.

The device's behavior has been coded to the Device Specification 2.1.  Certain elements of the protocols have been altered in a way that is not backwards compatible with previous specifications.  Emulators for the previous versions are available upon request.



Known issues:

The lighting section will not display any characters received until a line ending is encountered.  This is natural behavior for the PrintStream upon which it is based.  Other solutions will be explored.

There are some bizarre resize/redraw behaviors.  These are cosmetic and will be dealt with in later releases.

Occasionally, the command window will be blank, even though commands have been received.  This is a threading/concurrency issue between the application thread and Swing.  Sending another command will cause the display to show the entire history.

If an invalid IP address is provided that does not immediately get denied, the device emulators may have trouble letting go and accepting the new address.  Closing the emulator and starting over is the workaround.



Please submit any questions/comments/concerns to nczapla@amx.com