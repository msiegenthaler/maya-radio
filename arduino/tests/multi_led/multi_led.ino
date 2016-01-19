#define RED    0
#define GREEN  1
#define BLUE   2
#define RED_FACTOR   1
#define GREEN_FACTOR 0.5
#define BLUE_FACTOR  0.5

int LEDS[4][3] = {{2,3,4},{5,6,7},{8,9,10},{11,12,13}};


void setup() {
  Serial.begin(19200);
  setColor(0, 100, 100, 100);
  setColor(1, 100, 100, 100);
  setColor(2, 100, 100, 100);
  setColor(3, 100, 100, 100);
  Serial.println("Hello");
}

void loop() {
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
}


void setColor(int led, int r, int g, int b) {
  analogWrite(LEDS[led][RED],   r);
  analogWrite(LEDS[led][GREEN], g*0.5);
  analogWrite(LEDS[led][BLUE],  b*0.5);
}

