/* @pjs preload="bg.png","Angry_Bird_red_right.png","Angry_Bird_red_left.png","Angry_Bird_pig.png","Angry_Bird_pig2.png","Angry_Bird_pig3.png"; */

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

//vars for game
int playerScore = 0;
int compScore = 0;

// keep track of how much we should be 
// moving in each direction - we adjust these
// values in keyPressed below
int xMoveAmount = 0;
int yMoveAmount = 0;

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

void setup()
{
  size(500, 500);  
  
  //load images
  redBirdRight = loadImage("Angry_Bird_red_right.png");
  redBirdLeft = loadImage("Angry_Bird_red_left.png");
  pig = loadImage("Angry_Bird_pig.png");
  pig2 = loadImage("Angry_Bird_pig2.png");
  pig3 = loadImage("Angry_Bird_pig3.png");
  bg = loadImage("bg.png");
  
  //set default image
  redBirdCurrentDirection = redBirdRight;
  pigCurrent = pig;

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
  //background(200);
  //draw our bg
  image(bg, 0, 0);
  
  //get current time
  long currentTime = millis();
  
  //write out the score
  text("Number of pigs caught: " + playerScore, 20, 20);
  text("Number of pigs escaped: " + compScore, 20, 35);
  text("Time Played: " + (currentTime - startTime), 20, 50);

  // assume we aren't moving this frame
  xMoveAmount = 0;
  yMoveAmount = 0;

  // is a key currently pressed determine which direction to move
//  if (keyPressed)
//  {
    if (aDown) {
      xMoveAmount = -2;
    } 
    if (dDown) {
      xMoveAmount = 2;
    } 
    if (wDown) {
      yMoveAmount = -2;
    } 
    if (sDown) {
      yMoveAmount = 2;
    }
//  } 

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
  // values to the position of the player
  xPos += xMoveAmount;
  yPos += yMoveAmount;

  // continually add the move amount
  // values to the position of the computer
  xPos2 += xMoveAmount2;
  yPos2 += yMoveAmount2;


  // wrap around!
  if (xPos > width)
  {
    xPos = xPos - width;
  }
  if (xPos < 0)
  {
    xPos = width + xPos;
  }
  if (yPos > height)
  {
    yPos = yPos - height;
  }
  if (yPos < 0)
  {
    yPos = yPos + height;
  }
  
  //if computer escapes, reset the game;
  if(xPos2 > width || xPos2 < 0 || yPos2 > height || yPos2 < 0) {
    compScore++;
    reset();
  }

  // draw our player facing the correct way
  if(xMoveAmount > 0) {
    redBirdCurrentDirection = redBirdRight;
  }
  else if (xMoveAmount < 0) {
    redBirdCurrentDirection = redBirdLeft;
  }
  image(redBirdCurrentDirection, xPos, yPos, 50, 50);

  //draw the computer
  image(pigCurrent, xPos2, yPos2, 50, 50);
  
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


