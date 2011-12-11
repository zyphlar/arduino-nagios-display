Arduino Nagios Display

For creating an WiFi-enabled, Arduino-powered 8x5 LED matrix that displays Nagios status information
Intentionally kept hackable, with lots of commented-out sections and debugging information available, because everyone's environment is slightly different.

Included in distribution:
- ArduinoNagiosDisplay.pde, based on Arduino SimpleClient and shiftOutCode Hello World examples
- nag.php, based on GPL-licensed code by Jason Antman
- ShiftOutExample images, copyright Arduino

This program connects to a matching script on your Nagios server 
 (it must return a string like $00001000200002100000 -- see included php script.)

To assemble the hardware, I recommend an Arduino Diamondback, which is essentially an Arduino + WiShield.
Look at the included ShiftOutExample images which are taken from the Shift Out Arduino tutorial at http://arduino.cc/en/Tutorial/ShiftOut
The only difference is that the Diamondback/WiShield uses pins 14, 11, and 12 so I'm using pins 5,7, and 8 instead.

To get the microcontroller software working, look at the ArduinoNagiosDisplay.pde comments.

Also, put the nag.php script on your Nagios server outside of any authentication requirements. I put it at /var/www/nag.php . See the comment in the file and modify settings as needed.
