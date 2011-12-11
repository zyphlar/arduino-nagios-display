/*
 * Arduino Nagios Display
 * Copyright Will Bradley, 2011
 * Licensed under Creative Commons Attribution-ShareAlike (CC BY-SA) license.
 *  based on Arduino SimpleClient example
 *  and shiftOutCode, Hello World example by Carlyn Maw, Tom Igoe, and David A. Mellis.
 *  (no license information found in examples)
 *
 * This program connects to a matching script on your Nagios server 
 *  (it must return a string like $00001000200002100000 -- see included php script.)
 *
 * YOU'LL NEED TO MODIFY the Local IP, Subnet, SSID, Security Type, 
 *  Passphrase or WEP key, and the IP, port, hostname, and URL of Nagios.
 *
 * Pins 5,7,8: Latch, Clock, and Data pins for five daisy chained 595 Shift Registers
 * Pins 8, 9, 10, 11, 12, 13: Normal WiShield or Diamondback pins
 *
 * If you want to change this script to something besides an 8x5 LED matrix, look at the magic numbers of 5, 7, and 8 in the printData function below.
 */

//Pin connected to ST_CP of 74HC595
int latchPin = 5;
//Pin connected to SH_CP of 74HC595
int clockPin = 7;
////Pin connected to DS of 74HC595
int dataPin = 6;

#include <WiServer.h>

#define WIRELESS_MODE_INFRA	1
#define WIRELESS_MODE_ADHOC	2

// Wireless configuration parameters ----------------------------------------
unsigned char local_ip[] = {192,168,1,3};	// IP address of WiShield
unsigned char gateway_ip[] = {192,168,1,1};	// router or gateway IP address
unsigned char subnet_mask[] = {255,255,255,0};	// subnet mask for the local network
const prog_char ssid[] PROGMEM = {"MyNetworkName"};		// max 32 bytes

unsigned char security_type = 0;	// 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2 -- edit WEP or WPA pass/keys below accordingly

// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"myWPApassword"};	// max 64 characters

// WEP 128-bit keys
// sample HEX keys
prog_uchar wep_keys[] PROGMEM = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d,	// Key 0
				  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Key 1
				  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,	// Key 2
				  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	// Key 3
				};

// setup the wireless mode
// infrastructure - connect to AP
// adhoc - connect to another WiFi device
unsigned char wireless_mode = WIRELESS_MODE_INFRA;

unsigned char ssid_len;
unsigned char security_passphrase_len;

// IP Address for your Nagios server
uint8 ip[] = {192,168,1,2};

// Create request object; put Nagios' port, hostname, and URL path here. See the attached nag.php script.
GETrequest getData(ip, 80, "my-nagios-server.com", "/nag.php?minimal=1");


// End of configuration parameters ----------------------------------------

void displayData(int numberToDisplay) {
        // take the latchPin low so 
        // the LEDs don't change while you're sending in bits:
        digitalWrite(latchPin, LOW);
        // shift out the bits:
        shiftOut(dataPin, clockPin, MSBFIRST, numberToDisplay);  
    
        //take the latch pin high so the LEDs will light up:
        digitalWrite(latchPin, HIGH);
        // pause before next value:
        delay(1); 
}

// Function that prints data from the server
void printData(char* data, int len) {
  String matrix;
  
  digitalWrite(latchPin, LOW); // start writing to LEDs
  
  // Print the data returned by the server
  // Note that the data is not null-terminated, may be broken up into smaller packets, and 
  // includes the HTTP header. 
  for(int i=0;i<len;i++) {
    if(data[i] == '$')
    {
      for(int rows=0;rows<5;rows++){
        int rowData = 0;
        for(int cols=0;cols<8;cols++){
          i++;
          char thisData = data[i];
          // a 0 in Nagios means the LED should be on
          if(thisData == '0') {
            // the absolute value of cols-7 is used so binary 10000000 shows up as 128 instead of 1 (left light on, not right)
            rowData += (1<<abs(cols-7));  
            Serial.print((1<<abs(cols-7)));
            Serial.print("+");
          }
          if(thisData == '1') {
            // any other value means the LED should be off
            Serial.print("0");
            Serial.print("+");
          }
          if(thisData == '2') {
            Serial.print("0"); 
            Serial.print("+");
          }

          matrix += thisData;
        }
        shiftOut(dataPin, clockPin, MSBFIRST, rowData);  // write to LEDs 
        Serial.print("=");
        Serial.println(rowData);
      }
      Serial.println('*');
      Serial.println(matrix);
      digitalWrite(latchPin, HIGH);  // stop writing to LEDs
    }
  } 
}

void setup() {
    // Initialize WiServer (we'll pass NULL for the page serving function since we don't need to serve web pages) 
  WiServer.init(NULL);
  
  // Enable Serial output and ask WiServer to generate log messages (optional)
  Serial.begin(57600);
  WiServer.enableVerboseMode(true);

  // Have the processData function called when data is returned by the server
  getData.setReturnFunc(printData);
  
  //set pins to output so you can control the shift register
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  
  // flash the display and clear everything upon startup
  displayData(0);
  displayData(0);
  displayData(0);
  displayData(0);
  displayData(0);
  delay(100);
  displayData(255);
  displayData(255);
  displayData(255);
  displayData(255);
  displayData(255);
  delay(100);  
  displayData(0);
  displayData(0);
  displayData(0);
  displayData(0);
  displayData(0);
}


// Time (in millis) when the data should be retrieved 
long updateTime = 0;

void loop(){

  // Check if it's time to get an update
  if (millis() >= updateTime) {
    getData.submit();    
    // Get an update every 30 seconds
    updateTime += 1000 * 30;
  }
  
  // Run WiServer
  WiServer.server_task();
 
  delay(10);
}
