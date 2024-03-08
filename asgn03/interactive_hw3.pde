/* @pjs preload="bg.png","bg2.png","easy.png","hard.png","Angry_Bird_red_right.png","Angry_Bird_red_left.png","Angry_Bird_pig.png","Angry_Bird_pig2.png","Angry_Bird_pig3.png"; */

//import the needed library
import ddf.minim.*;

// main audio controller
Minim minim;

// audio file player
AudioPlayer hit;
AudioPlayer bgMusic;

// keep track of where our character is
float xPos;
float yPos;
float xPos_prev;

//keep track of where the computer is
float xPos2;
float yPos2;

//vars for images
PImage redBirdRight;
PImage redBirdLeft;
PImage redBirdCurrentDirection;
PImage pig;
PImage pig2;
PImage pig3;
PImage pigCurrent;
PImage bg;
PImage bg2;
PImage easy;
PImage hard;

//vars for game
int playerScore = 0;
int compScore = 0;

// keep track of how much we should be 
// moving in each direction - we adjust these
// values in keyPressed below
float xMoveAmount = 0;
float yMoveAmount = 0;

//keep track of computer movemnt
float xMoveAmount2 = 0;
float yMoveAmount2 = 0;

// threshold for a collision (in pixels)
int thresh = 50;

//record start time
long startTime = millis();

//allow pushing multiple keys
boolean wDown = false;
boolean sDown = false;
boolean aDown = false;
boolean dDown = false;

//keep track of state
int state = 0;

//keep track of dificulty
String difficulty = "hard";

//for developemnt
boolean debug = false;

//keep track of player speed
float playerSpeed = 2;

void setup()
{
  
  //set up size
  size(500, 500);  
  
  //set up sound
  // set up Minim  
  minim = new Minim(this);

  // load in our audio files
  hit = minim.loadFile("boing.mp3");
  bgMusic = minim.loadFile("Angry_Birds_Theme_Song.mp3");
  
  //play bg music in a loop
  bgMusic.loop();
  
  //set up images
  setupImages();
  
  //set player start randomly
  setPlayerStart();
  
  //set random pig
  randomPig();
  
  //set computer start at the center
  xPos2 = width/2 -25;
  yPos2 = height/2 -25;
}

void draw()
{
  //if we are on the pause screen
  if(state == 0 && !debug) {
    //display pause menu
    pauseMenu();
  }
  //otherwise play the game
  else {
    //draw our bg
    image(bg, 0, 0);
    
    //write out time and score
    scoreTime();
    
    //draw barriers
    drawBarriers();
  
    //move the player
    movePlayer();
    
    //move the computer
    moveComp();
   
   //check for collision
   checkCollision();
  }
}

//use random value to set player start position
void setPlayerStart() {
  switch((int)floor(random(4))) {
  case 0:
    xPos = width/2 - 25;
    yPos = 10;
    break;
  case 1:
    xPos = width/2 - 25;
    yPos = 450;
    break;
  case 2:
    xPos = 10;
    yPos = height/2 - 25;
    break;
  case 3:
    xPos = 450;
    yPos = height/2 - 25;
    redBirdCurrentDirection = redBirdLeft;
    break;
  }
}

//reset function
void reset() {
  setPlayerStart();
  randomPig();
  xPos2 = width/2;
  yPos2 = height/2;
}

void keyPressed() {
  //set booleans based on keys pressed to allow diagonal movment
  if (key == 'a'  || key == 'A') {
      aDown = true;
    } else if (key == 'd' || key == 'D') {
      dDown = true;
    } else if (key == 'w' || key == 'W') {
      wDown = true;
    } else if (key == 's' || key == 'S') {
      sDown = true;
    }
}

void keyReleased() {
  //unset booleans based on keys pressed to allow diagonal movment
    if (key == 'a'  || key == 'A') {
      aDown = false;
    } else if (key == 'd' || key == 'D') {
      dDown = false;
    } else if (key == 'w' || key == 'W') {
      wDown = false;
    } else if (key == 's' || key == 'S') {
      sDown = false;
    }
}

void randomPig() {
  //choose an image of the enemy based on a radndom number
  switch((int)floor(random(3))) {
  case 0:
    pigCurrent = pig;
    break;
  case 1:
    pigCurrent = pig2;
    break;
  case 2:
    pigCurrent = pig3;
    break;
  }
}

void setupImages() {
  //load images
  redBirdRight = loadImage("Angry_Bird_red_right.png");
  redBirdLeft = loadImage("Angry_Bird_red_left.png");
  pig = loadImage("Angry_Bird_pig.png");
  pig2 = loadImage("Angry_Bird_pig2.png");
  pig3 = loadImage("Angry_Bird_pig3.png");
  bg = loadImage("bg.png");
  bg2 = loadImage("bg2.png");
  easy = loadImage("easy.png");
  hard = loadImage("hard.png");
  
  //set default image
  redBirdCurrentDirection = redBirdRight;
  pigCurrent = pig;
}

void scoreTime() {
  //get current time
  long currentTime = millis();
  
  //write out the score
  text("Number of pigs caught: " + playerScore, 20, 20);
  text("Number of pigs escaped: " + compScore, 20, 35);
  text("Time Played: " + (currentTime - startTime), 20, 50);
}

void movePlayer() {
  // assume we aren't moving this frame
  xMoveAmount = 0;
  yMoveAmount = 0;
  
  // is a key currently pressed determine which direction to move
  if (aDown) {
    xMoveAmount = -1*playerSpeed;
  } 
  if (dDown) {
    xMoveAmount = playerSpeed;
  } 
  if (wDown) {
    yMoveAmount = -1*playerSpeed;
  } 
  if (sDown) {
    yMoveAmount = playerSpeed;
  }
  
       
   //check if barrier will be hit by movement in x direction
   if(!checkBarrierHit(xPos + xMoveAmount, yPos)){
     //if not make the move
     xPos += xMoveAmount;
   }
   //check if barrier will be hit by movement in y direction
   if(!checkBarrierHit(xPos, yPos + yMoveAmount)){
     //if not make the move
     yPos += yMoveAmount;
   }
  
  // wrap around!
  if (xPos > width) {
    xPos = xPos - width;
  }
  if (xPos < 0) {
    xPos = width + xPos;
  }
  if (yPos > height) {
    yPos = yPos - height;
  }
  if (yPos < 0) {
    yPos = yPos + height;
  }
  
  // draw our player facing the correct way
  if(xMoveAmount > 0) {
    redBirdCurrentDirection = redBirdRight;
  }
  else if (xMoveAmount < 0) {
    redBirdCurrentDirection = redBirdLeft;
  }
  image(redBirdCurrentDirection, xPos, yPos, 50, 50);

}

void moveComp() {
  //the computer moves away from the player
  if (xPos > xPos2) {
    xMoveAmount2 = -0.5;
  } else if (xPos < xPos2) {
    xMoveAmount2 = 0.5;
  }
  if (yPos > yPos2) {
    yMoveAmount2 = -0.5;
  } else if (yPos < yPos2) {
    yMoveAmount2 = 0.5;
  }

  // continually add the move amount
  // values to the position of the computer
  xPos2 += xMoveAmount2;
  yPos2 += yMoveAmount2;
  
  //if computer escapes, reset the game;
  if(xPos2 > width || xPos2 < 0 || yPos2 > height || yPos2 < 0) {
    compScore++;
    if(!debug){
      reset();
    }
  }
  
  //draw the computer
  image(pigCurrent, xPos2, yPos2, 50, 50);
}

void checkCollision() {
  // first, compute distance
  float distance = dist(xPos+25, yPos+25, xPos2+25, yPos2+25);
  
  // are we close enough to consider this a collision?
  if (distance < thresh)
  {
    reset(); 
    
    // update score
    playerScore++;
  }
}

void pauseMenu() {
  //draw our bg
  image(bg2, 0, 0);
  
  //choose difficulty text
  textSize(32);
  text("Choose Your Dificulty", 43, 50);
  textSize(12);
  
  //draw easy selection
  fill(0);
  image(easy, 33, 95);
  text(" Easier barriers \n Player moves fast", 35, 205);
  
  //draw hard selection
  image(hard, 266, 95);
  text(" Harder barriers \n Player moves slow", 270, 205);
  
  //instructions
  text("Instructions:\n Use the W,A,S,D keys to control your character \n Catch the pig before he escapes to get a point \n Be careful of the barriers. The pig can pass through them but you cannot.", 35, 325);
  fill(255);
  
  //process easy button clicking
  if (mouseX > 33 && mouseX < 233 && mouseY > 95 && mouseY < 295) {
      // set fill to white
      noFill();
      stroke(255);
      rect(32,94, 201, 205);
      
      // is the mouse pressed? if so, we have a hit!
      if (mousePressed) {
        difficulty = "easy";
        state = 1;
        playerSpeed = 2;
      }
   }
   
  //process hard button clicking
  if (mouseX > 266 && mouseX < 466 && mouseY > 95 && mouseY < 295) {
      // set fill to white
      noFill();
      stroke(255);
      rect(265,94, 201, 205);
      
      // is the mouse pressed? if so, we have a hit!
      if (mousePressed) {
        difficulty = "hard";
        state = 1;
        playerSpeed = 1;
      }
   }
}

//funciton to draw barriers
void drawBarriers(){
  if(difficulty == "easy") {
     fill(255,0,0);
     rect(100,100, 50, 50); 
     rect(400,100, 50, 50);
     rect(100,400, 50, 50); 
     rect(400,400, 50, 50);
     fill(255);
  }
  else {
    fill(255,0,0);
    noStroke();
    rect(100,100, 25, 75);
    rect(100,100, 75, 25); 
    rect(400,100, 25, 75);
    rect(350,100, 75, 25); 
    rect(100,350, 25, 75);
    rect(100,400, 75, 25);
    rect(400,350, 25, 75);
    rect(350,400, 75, 25);
    stroke(0);
    fill(255);
  }
}

//function to check barrier collisions
boolean checkBarrierHit(float x, float y) {
  if(difficulty == "easy") {
    if (((x > 100 || x+50 > 100) && (x < 150 || x + 50 < 150) && (y+50 > 100 || y > 100) && (y+50 < 150 || y < 150))
          || ((x > 400 || x+50 > 400) && (x < 450 || x + 50 < 450) && (y+50 > 100 || y > 100) && (y+50 < 150 || y < 150))
          || ((x > 100 || x+50 > 100) && (x < 150 || x + 50 < 150) && (y+50 > 400 || y > 400) && (y+50 < 450 || y < 450))
          || ((x > 400 || x+50 > 400) && (x < 450 || x + 50 < 450) && (y+50 > 400 || y > 400) && (y+50 < 450 || y < 450))) {
      
      // first rewind the sound
      hit.rewind();
  
      // play the file
      hit.play();
      
      return true;
    }  
  }
  else {
    if (((x > 100 || x+50 > 100) && (x < 125 || x + 50 < 125) && (y+50 > 100 || y > 100) && (y+50 < 175 || y < 175))
     || ((x > 100 || x+50 > 100) && (x < 175 || x + 50 < 175) && (y+50 > 100 || y > 100) && (y+50 < 125 || y < 125))
     || ((x > 400 || x+50 > 400) && (x < 425 || x + 50 < 425) && (y+50 > 100 || y > 100) && (y+50 < 175 || y < 175))
     || ((x > 350 || x+50 > 350) && (x < 425 || x + 50 < 425) && (y+50 > 100 || y > 100) && (y+50 < 125 || y < 125))
     || ((x > 100 || x+50 > 100) && (x < 125 || x + 50 < 125) && (y+50 > 350 || y > 350) && (y+50 < 425 || y < 425))
     || ((x > 100 || x+50 > 100) && (x < 175 || x + 50 < 175) && (y+50 > 400 || y > 400) && (y+50 < 425 || y < 425))
     || ((x > 400 || x+50 > 400) && (x < 425 || x + 50 < 425) && (y+50 > 350 || y > 350) && (y+50 < 425 || y < 425))
     || ((x > 350 || x+50 > 350) && (x < 425 || x + 50 < 425) && (y+50 > 400 || y > 400) && (y+50 < 425 || y < 425))) {
      
      // first rewind the sound
      hit.rewind();
  
      // play the file
      hit.play();
      
      return true;
    } 
  }
  return false;
}


