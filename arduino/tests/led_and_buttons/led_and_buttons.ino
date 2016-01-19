#include <RBD_Timer.h>
#include <RBD_Button.h>

#define RED    0
#define GREEN  1
#define BLUE   2
#define RED_FACTOR   1
#define GREEN_FACTOR 0.5
#define BLUE_FACTOR  0.5

int LEDS[4][3] = {{2,3,4},{5,6,7},{8,9,10},{11,12,13}};

//row 1
RBD::Button button_0(48);
RBD::Button button_1(49);
RBD::Button button_2(46);
RBD::Button button_3(47);
//row 2
RBD::Button button_4(44);
RBD::Button button_5(45);
RBD::Button button_6(42);
RBD::Button button_7(43);
//row 3
RBD::Button button_8(40);
RBD::Button button_9(41);
RBD::Button button_10(38);
RBD::Button button_11(39);
// array of song-selects
RBD::Button button[12] = {button_0, button_1, button_2, button_3, button_4, button_5, button_6, button_7,
  button_8, button_9, button_10, button_11};
  
RBD::Button button_up(35);
RBD::Button button_down(34);


void setup() {
  Serial.begin(19200);
  setColor(0, 100, 100, 100);
  setColor(1, 100, 100, 100);
  setColor(2, 100, 100, 100);
  setColor(3, 100, 100, 100);
  Serial.println("Hello");
}

void loop() {
  /*
  if (Serial.available() > 0) {
    String v = Serial.readStringUntil('\n');
    Serial.print("Setting color to ");
    Serial.println(v);

    long number = strtol(&v[0], NULL, 16);
    long r = number >> 16;
    long g = number >> 8 & 0xFF;
    long b = number & 0xFF;
    Serial.println(r);
    setColor(0, r, g, b);
    setColor(1, r, g, b);
    setColor(2, r, g, b);
    setColor(3, r, g, b);
  }
  */

  for (int i = 0; i < 12; i++) {
    if (button[i].onPressed()) {
      int led = i % 4;
      Serial.print("Pressed button ");
      Serial.print(i);
      Serial.print(" -> will turn led ");
      Serial.print(led);
      Serial.print(" to color ");
      Serial.println(i / 4);
      switch (i / 4) {
        case 0:
          setColor(led, 100, 0, 0);
          break;
        case 1:
          setColor(led, 0, 100, 0);
          break;
        case 2:
          setColor(led, 0, 0, 100);
          break;
      }
    }
  }

  if (button_up.onPressed()) {
    Serial.println("Presses up-button, changing color to yellow");
    for (int i=0; i<4; i++) setColor(i, 100, 100, 0);    
  }
  if (button_down.onPressed()) {
    Serial.println("Presses down-button, changing color to cyan");
    for (int i=0; i<4; i++) setColor(i, 0, 100, 100);    
  }
}


void setColor(int led, int r, int g, int b) {
  analogWrite(LEDS[led][RED],   r);
  analogWrite(LEDS[led][GREEN], g*0.5);
  analogWrite(LEDS[led][BLUE],  b*0.5);
}

