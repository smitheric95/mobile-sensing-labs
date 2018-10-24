/*

Copyright (c) 2012-2014 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

/*
 *    Chat
 *
 *    Simple chat sketch, work with the Chat iOS/Android App.
 *    Type something from the Arduino serial monitor to send
 *    to the Chat App or vice verse.
 *
 */

//"RBL_nRF8001.h/spi.h/boards.h" is needed in every new project
#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>

int LED = 2;
int PHOTO = A0;
int BUTTON = 3;

String set_led_prefix = "SET LED:";

void set_led(String val)
{
  int update_val = val.toInt();
  Serial.print(update_val);
  analogWrite(LED, update_val);
}

void rx_handle()
{
  String received = "";
  while ( ble_available() ) {
    received += String((char)ble_read());
  }

  if (received.substring(0, set_led_prefix.length()) == set_led_prefix) {
    set_led(received.substring(set_led_prefix.length()+1, received.length()));
  }
}

void tx_handle()
{
  int photo = analogRead(PHOTO);
  String send_str = "PHOTO VAL: " + String(photo);
  for (int i = 0; i < send_str.length(); i++) {
    Serial.print(send_str[i]);
    ble_write(send_str[i]);
  }
  Serial.println();
}

void setup()
{  
  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(3, 2);
  
  // Set your BLE Shield name here, max. length 10
  //ble_set_name("My Name");
  
  // Init. and start BLE library.
  ble_begin();
  
  // Enable serial debug
  Serial.begin(57600);

  pinMode(LED, OUTPUT);
  pinMode(BUTTON, INPUT);

  analogWrite(LED, 255);
}

unsigned char buf[16] = {0};
unsigned char len = 0;

void loop()
{
  if ( ble_available() )
  {
      rx_handle();
  }

  tx_handle();
  
  ble_do_events();

  Serial.println(analogRead(PHOTO));
  Serial.println(digitalRead(BUTTON));
  delay(1000);
}

