/* @pjs preload="Angry_Bird_pig.png","Angry_Bird_pig3.png","Angry_Bird_red.png","hammer.png","hammerDown.png"; */

//set up image for "mole"
PImage pig;
PImage kingPig;
PImage bird;

//import the needed library for sund
import ddf.minim.*;

// main audio controller
Minim minim;

// audio file players
AudioPlayer hit;
AudioPlayer birdHit;

//create array of moles
Mole[] moles = new Mole[9];

//keep track of score
int score = 0;

//create a holder for the cursor
PImage hammer;
PImage hammerDown;

void setup()
{
  size(500,500);
  
  //load the images once
  pig = loadImage("Angry_Bird_pig3.png");
  kingPig = loadImage("Angry_Bird_pig.png");
  bird = loadImage("Angry_Bird_red.png");
  
  //set up sound
  // set up Minim  
  minim = new Minim(this);

  // load in our audio file once
  hit = minim.loadFile("oink.mp3");
  birdHit = minim.loadFile("birdHit.mp3");
  
  //create 9 "moles" in different locations
  moles[0] = new Mole(66, 196);
  moles[1] = new Mole(232, 196);
  moles[2] = new Mole(398, 196);
  moles[3] = new Mole(66, 312);
  moles[4] = new Mole(232, 312);
  moles[5] = new Mole(398, 312);
  moles[6] = new Mole(66, 428);
  moles[7] = new Mole(232, 428);
  moles[8] = new Mole(398, 428);
  
   //load in images for cursor
   hammer = loadImage("hammer.png");
   hammerDown = loadImage("hammerDown.png");
  
  //disable default cursoe
  noCursor();
}

void draw()
{
  //flood the bg
  background(0, 180, 0);
  
  //write title
  textSize(32);
  text("Whack-a-Pig", 20,40);
  
  //write out score
  text("Your Score:" + score, 20, 80);
  
  //write out directions
  textSize(14);
  text("Directions: Click on a pig to \nhit it. Hit the king pig for \nextra points but dont hit \nthe bird (or you'll lose points).", 280, 40);
  
  //display all our moles
  for(int i = 0; i < moles.length; i++) {
    moles[i].display();
  }
  
  //draw the cursor
  if(mousePressed){
    image(hammerDown, mouseX, mouseY, 100, 100);
  } else {
    image(hammer, mouseX, mouseY, 100, 100);
  }

}

void mousePressed() {
  //check hits for all our moles
  for(int i = 0; i < moles.length; i++) {
    int scoreToAdd;
    if((boolean(scoreToAdd = moles[i].checkHit())))
      //if a mole is hit increase the score
      score += scoreToAdd;
  }
}
class Mole {
  float xPos;
  float yPos;
  int state = 1;
  float timeForState = 0;
  float timeInState = 0;
  int isKing = 0;
  int isBird = 0;


  Mole(float x, float y) {
    xPos = x;
    yPos = y;
  } 

  // display function
  void display() {
    update();
    if (state == 0) {
      noFill();
      stroke(255);
      strokeWeight(4);
      ellipse(xPos, yPos, 100, 100);
    } else {
      imageMode(CENTER);
      if (boolean(isKing)) {
        image(kingPig, xPos, yPos);
      } else if (boolean(isBird)) {
        image(bird, xPos, yPos);
      } else {
        image(pig, xPos, yPos);
      }
    }
  }

  //update function
  void update() {
    //increase our counter
    timeInState++;

    //if we've been in this state for the time intended
    if (timeInState >= timeForState) {
      //switch state
      if (state == 0) {
        state = 1;
      } else {
        state = 0;
      }

      //generate a time to stay in this state
      generateTime();
    }
  }

  //generate a random amount of time for current state
  void generateTime() {
    //stay up for short amounts of time
    if (state == 1) {
      // pick a random amount of time to stay in this state
      timeForState = int(random(50, 150));
      int specialState  = int(random(1, 100));
      if (specialState < 5) {
        isKing = 1;
      } else if (specialState > 5 && specialState < 10) {
        isBird = 1;
      }
    }
    //stay down for longer amounts of time
    else {
      // pick a random amount of time to stay in this state
      timeForState = int(random(50, 700));
      isKing = 0;
      isBird = 0;
    }

    // reset our current counter
    timeInState = 0;
  }

  //checking if its hit
  int checkHit() {
    //if the mouse is clicked and is close to the mole
    if (dist(xPos, yPos, mouseX, mouseY) < 50 && mousePressed) {
      //the mole has been hit so reset it and play a sound
      if (state == 1) {
        //ckeck if it was a king
        boolean wasKing = boolean(isKing);

        //ckeck if it was a bird
        boolean wasBird = boolean(isBird);

        // sound if bird hit
        if (wasBird) {
          // first rewind the sound
          birdHit.rewind();

          //play the file
          birdHit.play();
        }
        //sound otherwise
        else {
          // first rewind the sound
          hit.rewind();

          //play the file
          hit.play();
        }

        //change the state back to down
        state = 0;

        //generate a time to stay in this state
        generateTime();

        //return the score to add only if it was up
        if (wasKing)
          return 5;
        else if (wasBird)
          return -5;
        else
          return 1;
      }
    }
    //if it wasnt hit or isnt up return false
    return 0;
  }
}


