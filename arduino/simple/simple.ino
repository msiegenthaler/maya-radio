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

  initButtons();
  initialSettings();
}

/** Reset the button pressed state. */
void initButtons() {
  for (int i = 0; i < 12; i++)
    button[i].onPressed();
  button_up.onPressed();
  button_down.onPressed();
}

void initialSettings() {
  setColor(0, 30, 100, 100);
  setColor(1, 50, 30, 0);
  setColor(2, 30, 30, 100);
  setColor(3, 50, 30, 0);

  setVolume(80);
}


void setVolume(uint8_t vol) {
  Serial.print("Volume changed to ");
  Serial.println(vol);
  musicPlayer.setVolume(vol, vol);
  volume = vol;
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
}

void loop() {
  // put your main code here, to run repeatedly:

  for (int i = 0; i < 12; i++) {
    if (button[i].onPressed()) {
      musicPlayer.stopPlaying();
      play(i+1);
      playing = true;
    }
  }

  if (playing) {
    if (musicPlayer.stopped()) {
      Serial.println("Song ended.");
      playing = false;  
      setColor(0, 30, 100, 100);
      setColor(1, 50, 30, 0);
      setColor(2, 30, 30, 100);
      setColor(3, 50, 30, 0);
    } else {
      setColor(0, 200, 100, 100);
      setColor(1, 200, 30, 0);
      setColor(2, 200, 10, 100);
      setColor(3, 200, 30, 200);
    }
  }


  if (button_up.onPressed()) {
    Serial.println("Louder");
    if (volume - DELTA_VOLUME >= MAX_VOLUME)
      setVolume(volume - DELTA_VOLUME);
  }
  if (button_down.onPressed()) {
    Serial.println("Softer");
    if (volume + DELTA_VOLUME <= MIN_VOLUME)
      setVolume(volume + DELTA_VOLUME);
  }

  delay(100);
}



