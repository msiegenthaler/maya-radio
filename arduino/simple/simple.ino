#include <RBD_Button.h>
#include <Adafruit_VS1053.h>

/**************** LED stuff ****************/
#define RED    0
#define GREEN  1
#define BLUE   2
#define RED_FACTOR   1
#define GREEN_FACTOR 0.5
#define BLUE_FACTOR  0.5
int LEDS[4][3] = {{2,3,4},{5,6,7},{8,9,10},{11,12,13}};
void setColor(int led, int r, int g, int b) {
  analogWrite(LEDS[led][RED],   r);
  analogWrite(LEDS[led][GREEN], g*0.5);
  analogWrite(LEDS[led][BLUE],  b*0.5);
}


/**************** Button stuff ****************/
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
//Volume buttons
RBD::Button button_up(35);
RBD::Button button_down(34);

#define OFF_PIN 36


/** Colors */
#define COLOR_COUNT 7
int COLORS[COLOR_COUNT][3] = {
  {200,   0,   0},
  {  0, 200,   0},
  {  0,   0, 200},
  {200, 120,   0},
  {200, 120, 120},
  {200,   0, 120},
  {  0, 200, 200},
};



/**************** Button stuff ****************/
#define SHIELD_CS     18      // VS1053 chip select pin (output)
#define SHIELD_DCS    19      // VS1053 Data/command select pin (output)
#define CARDCS 20     // Card chip select pin
#define DREQ 21       // VS1053 Data request, ideally an Interrupt pin
Adafruit_VS1053_FilePlayer musicPlayer = Adafruit_VS1053_FilePlayer(-1, SHIELD_CS, SHIELD_DCS, DREQ, CARDCS);


bool playing = false;

#define DELTA_VOLUME 10
#define MAX_VOLUME   0
#define MIN_VOLUME   250
uint8_t volume = 0;

#define INACTIVITY_TIMEOUT 300000 //ms
unsigned long lastAction;

int idleFadingPos = 0;

void setup() {
  Serial.begin(19200);
  Serial.println("Maya's radio - fading lights mode");

  //Initialize
  if (!musicPlayer.begin()) {
     Serial.println(F("Couldn't find VS1053, do you have the right pins defined?"));
     while (1);
  }
  SD.begin(CARDCS);
  musicPlayer.useInterrupt(VS1053_FILEPLAYER_PIN_INT);

  randomSeed(analogRead(0));

  initButtons();
  initialSettings();

  pinMode(OFF_PIN, OUTPUT);
  lastAction = millis();
}

/** Reset the button pressed state. */
void initButtons() {
  for (int i = 0; i < 12; i++)
    button[i].onReleased();
  button_up.onReleased();
  button_down.onReleased();
}

void initialSettings() {
  setColor(0, 30, 100, 100);
  setColor(1, 50, 30, 0);
  setColor(2, 30, 30, 100);
  setColor(3, 50, 30, 0);

  setVolume(40);
}


void setVolume(uint8_t vol) {
  Serial.print("Volume changed to ");
  Serial.println(vol);
  musicPlayer.setVolume(vol, vol);
  volume = vol;

  lastAction = millis();
}

void play(int number) {
  String track = "track";
  track += (number / 100) % 10;
  track += (number / 10) % 10;
  track += number % 10;
  track += ".mp3";
  Serial.print("Starting to play ");
  Serial.println(track);
  musicPlayer.startPlayingFile(track.c_str());

  lastAction = millis();
}

void loop() {
  // put your main code here, to run repeatedly:

  for (int i = 0; i < 12; i++) {
    if (button[i].onReleased()) {
      musicPlayer.stopPlaying();
      play(i+1);
      playing = true;

      for (int l = 0; l < 4; l++) {
        for (int c = 0; c < 3; c++) {
          int *color = COLORS[random(COLOR_COUNT)];
          setColor(l, color[0], color[1], color[2]);
        }
      }
    }
  }

  if (playing) {
    lastAction = millis();
    if (musicPlayer.stopped()) {
      Serial.println("Song ended.");
      playing = false;  
      setColor(0, 30, 100, 100);
      setColor(1, 50, 30, 0);
      setColor(2, 30, 30, 100);
      setColor(3, 50, 30, 0);
    }
  } else {
    idleFadingPos += 1;
    if (idleFadingPos > 20) idleFadingPos = -20;
    int factor = abs(idleFadingPos)/3;
    setColor(0, 15*factor, 50*factor, 50*factor);
    setColor(1, 25*factor, 15*factor, 0);
    setColor(2, 15*factor, 15*factor, 50*factor);
    setColor(3, 25*factor, 15*factor, 0);
  }

  if (button_up.onReleased()) {
    Serial.println("Louder");
    if (volume - DELTA_VOLUME >= MAX_VOLUME)
      setVolume(volume - DELTA_VOLUME);
  }
  if (button_down.onReleased()) {
    Serial.println("Softer");
    if (volume + DELTA_VOLUME <= MIN_VOLUME)
      setVolume(volume + DELTA_VOLUME);
  }

  unsigned long sinceLast = millis() - lastAction;
  if (sinceLast < 0) lastAction = millis();
  else if (sinceLast > INACTIVITY_TIMEOUT) {
    Serial.println("Turing off..");
    digitalWrite(OFF_PIN, HIGH);
    lastAction = millis();
  }

  delay(50);
}



