Arduino Nagios Display
by Will Bradley, www.zyphon.com/arduino-nagios, twitter @willbradley

For creating an WiFi-enabled, Arduino-powered 8x5 LED matrix that displays Nagios status information.
Intentionally kept hackable, with lots of commented-out sections and debugging information available, because everyone's environment is slightly different.

Included in distribution:
- ArduinoNagiosDisplay.pde, based on Arduino SimpleClient and shiftOutCode Hello World examples
- nag.php, based on GPL-licensed code by Jason Antman
- ShiftOutExample images, copyright Arduino
- display images, by me

To assemble the hardware, I recommend an Arduino Diamondback, which is essentially an Arduino + WiShield.
Look at the included ShiftOutExample images which are taken from the Shift Out Arduino tutorial at http://arduino.cc/en/Tutorial/ShiftOut
The only difference is that the Diamondback/WiShield uses pins 14, 11, and 12 so I'm using pins 5,7, and 8 instead.

To get the microcontroller software working, look at the ArduinoNagiosDisplay.pde comments.

Also, put the nag.php script on your Nagios server outside of any authentication requirements. I put it at /var/www/nag.php . See the comment in the file and modify settings as needed.

Overview: Nagios keeps its status info in a status.dat file somewhere, which nag.php parses and outputs in a simplified way. ArduinoNagiosDisplay.pde gets loaded onto a WiFi-equipped Arduino, connects to nag.php, parses that simple data, and lights up LEDs corresponding to each server. You'll need to edit some settings in both files to make them work, but if you're halfway familiar with your Nagios installation, Arduino programming (especially the ShiftOut and SimpleClient examples), and networking (what's a subnet mask?) you should be fine. I'd love to see other people use this code and ask questions, too.
