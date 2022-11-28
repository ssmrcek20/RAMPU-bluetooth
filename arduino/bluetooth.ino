#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

const int ledPin =  2;

String poruka = "";
String on = "Led dioda je ukljucena\n";
String off = "Led dioda je iskljucena\n";

void setup() {
  pinMode(ledPin, OUTPUT);
  SerialBT.begin("RAMPU bluetooth");
}

void loop() {
  if (SerialBT.available()){
    char incomingChar = SerialBT.read();
    if (incomingChar != '\n'){
      poruka += String(incomingChar);
    }
    else{
      poruka = "";
    }
  }
  
  if (poruka =="on"){
    digitalWrite(ledPin, HIGH);
    for (int i = 0; i < on.length(); i++)
    SerialBT.write(on[i]);
  }
  else if (poruka =="off"){
    digitalWrite(ledPin, LOW);
    for (int i = 0; i < off.length(); i++)
    SerialBT.write(off[i]);
  }
  delay(20);
}