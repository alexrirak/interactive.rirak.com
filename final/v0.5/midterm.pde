/**
 * @author Alex Rirak <arirak@nyu.edu>
 * @since 10/26/2015
 * This is a remake of the first level of Super mario Bros. created as my midterm project for Interactive Computing at NYU
 */

import ddf.minim.*;
/* @pjs preload="marioleft.png", "marioright.png", "marioleft_super.png", "marioright_super.png", "goombaLeft.png", "goombaSquished.png", "goombaRight.png", "mushroom.png", "coin1.png", "coin2.png", "coin3.png", "coin4.png", "mainBG.png", "0.png","1.png","2.png","3.png","4.png","5.png","6.png","7.png","8.png","9.png","10.png","11.png","12.png","13.png","14.png","15.png","16.png","17.png","18.png","19.png","20.png","21.png","22.png","23.png","24.png","25.png","26.png","27.png","28.png","29.png","30.png","31.png","32.png","33.png","34.png","35.png","36.png","37.png","38.png","39.png","40.png","41.png","42.png","43.png","44.png","45.png","46.png","47.png","48.png","49.png","50.png","51.png","52.png","53.png","54.png","55.png","56.png","57.png","58.png"; */
// key flags
boolean keyA = false;
boolean keyS = false;
boolean keyD = false;
boolean keyW = false;

//Level creator menu flags
boolean creatorMenuOn = false;
boolean categoryMenu = true;
boolean backGroundSubMenu = false;
boolean collidableObjectsSubMenu = false;

//level creator data structures
int positionTracker = 1;
int selectedBlock = 0;
// an Array to hold all of our tiles
PImage[] tiles = new PImage[60];

// how big is each cell (pick a standard size)
int CELL_SIZE = 30;

// how far along in the world is the player? this will "shift" the map
// left and right
int X_OFFSET = 0;

// player object
Player mario;

// selected element object
selectedElement creatorFocus;

// main audio controller
Minim minim;

//levelDB object
levelDBClass levelDB = new levelDBClass();

//menuDB object
menuDBClass menuDB;

//soundDB object
SoundDBClass soundDB;

//state
//0 - main menu
//1 - in game
//2 - game over
//3 - died
//4 - time out
//5 - won game
//6 - level creator
int state = 0;

//debug
boolean debug = false;
boolean locationFinder = false;

//create array list of goombas to keep track of all of them
ArrayList<Goomba> goombas = new ArrayList<Goomba>();

//create array list of coins to keep track of all of them
ArrayList<Coin> coins = new ArrayList<Coin>();

//create array list of mushroom to keep track of all of them
ArrayList<Mushroom> mushrooms = new ArrayList<Mushroom>();

//create array list of breaking blocks to keep track of all of them
ArrayList<BreakingBlock> breakingBlocks = new ArrayList<BreakingBlock>();

int levelId = 1;
String levelName = "level1";
int[][] level;

void setup()
{
  // define our level using our tiles (note that the numbers here 
  // indicate which image file should appear at a particular spot on the grid)
  level = levelDB.getLevel(levelName);

  size(500, 500);

  // set up Minim  
  minim = new Minim(this);

  //soundDB object
  soundDB = new SoundDBClass();

  //menuDB object
  menuDB = new menuDBClass();

  // load in our tiles
  levelDB.loadTiles(tiles);

  // create our player
  mario = new Player(0, 390);

  //create creator marker
  creatorFocus = new selectedElement(0, 0);

  //create out goombas
  levelDB.getGoombas(levelName, goombas);
}



void draw()
{
  if (state == 0) {
    //show main menu
    menuDB.mainMenu();
  } else if (state == 1) {

    //increment the time
    levelDB.currLevelTimeElasped++;

    // draw the level
    levelDB.drawLevel(tiles);

    //draw the top menu
    menuDB.levelMenu();

    // move our player
    mario.move();

    // draw our player
    mario.display();

    //draw and display our goombas
    for (int i = 0; i < goombas.size (); i++) {
      //check for collisons with the player
      if (goombas.get(i).checkCollision()) {
        goombas.remove(i);
      } else {
        goombas.get(i).move();
        goombas.get(i).display();
      }
    }

    //draw and display our coins
    for (int i = 0; i < coins.size (); i++) {
      //check for collisons with the player
      if (coins.get(i).move()) {
        coins.remove(i);
        mario.coinsCollected++;
      } else {
        coins.get(i).display();
      }
    }

    //draw and display our mushrooms
    for (int i = 0; i < mushrooms.size (); i++) {
      //check for collisons with the player
      if (mushrooms.get(i).checkCollision()) {
        mushrooms.remove(i);
        mario.becomeSuper();
      } else {
        mushrooms.get(i).move();
        mushrooms.get(i).display();
      }
    }

    //draw and display our breakingBlocks
    for (int i = 0; i < breakingBlocks.size (); i++) {
      //check for collisons with the player
      if (breakingBlocks.get(i).move()) {
        //breakingBlocks.remove(i);
      } else {
        breakingBlocks.get(i).display();
      }
    }
  } else if (state == 2) {
    //show game over screen
    soundDB.playGameOver();
    menuDB.gameOver();
    if (menuDB.gameOverTimer > 0) {
      menuDB.gameOverTimer--;
    } else {
      menuDB.gameOverTimerReset();
      levelDB.resetGame();
      state  = 0;
      mario.score = 0;
      mario.coinsCollected = 0;
    }
  } else if (state == 3) {
    //show died screen
    soundDB.playMarioDies();
    menuDB.died();
    if (menuDB.diedTimer > 0) {
      menuDB.diedTimer--;
    } else {
      menuDB.diedTimerReset();
      state  = 1;
      soundDB.playLevelOneTheme();
    }
  } else if (state == 4) {
    //show time up screen
    menuDB.timeUp();
    if (menuDB.timeUpTimer > 0) {
      menuDB.timeUpTimer--;
    } else {
      menuDB.timeUpTimerReset();
      levelDB.resetGame();
      soundDB.playLevelOneTheme();
    }
  } else if (state == 5) {
    // draw the level
    levelDB.drawLevel(tiles);

    //draw the top menu
    menuDB.levelMenu();

    //animate player
    levelDB.gameEndAnimation();
  } else if (state == 6) {
    background(0);

    // draw the level
    levelDB.drawLevel(tiles, true);

    //move the selector
    creatorFocus.move();

    //display the selector
    creatorFocus.display();

    //draw the menu
    menuDB.creatorMenu();
  }
}


// compute the x position of the rightmost tile in the world
int getRightmostTileXLocation()
{
  int rightmostTileX = (level[0].length-1)*CELL_SIZE+X_OFFSET;
  return rightmostTileX;
}


// compute the x position of the leftmost tile in the world
int getLeftmostTileXLocation()
{
  int leftmostTileX = 0*CELL_SIZE+X_OFFSET;
  return leftmostTileX;
}


// getTileCode - checks to see what tile is under the supplied x & y position
int getTileCode(float x, float y)
{
  // convert x & y coordinate to an array coordinate
  int col = int(int(x-X_OFFSET)/CELL_SIZE);
  int row = int(int(y)/CELL_SIZE);
  // off board test
  if (x >= width || x <= 0 || y >= height || y <= 0)
  {
    // off the board - return a solid tile
    return -1;
  }
  // otherwise return the tile value
  return level[row][col];
}

//overlaoded version of above
int getTileCode(float x, float y, boolean isEnemy)
{
  // convert x & y coordinate to an array coordinate
  int col = int(int(x-X_OFFSET)/CELL_SIZE);
  int row = int(int(y)/CELL_SIZE);


  // otherwise return the tile value
  return level[row][col];
}


// isSolid - returns true if the tile in question is solid, false if not
// you can update this function so you can support multiple solid tiles
boolean isSolid(int tileCode)
{
  ArrayList<Integer> nonSolidTiles = levelDB.getNonSolidList();
  if (nonSolidTiles.contains(tileCode))
    //if (tileCode in nonSolidTiles)
  {
    return false;
  } else
  {
    return true;
  }
}

//overlaoded version of above
boolean isSolid(int tileCode, boolean isEnemy)
{
  ArrayList<Integer> nonSolidTiles = levelDB.getNonSolidList(isEnemy);
  if (nonSolidTiles.contains(tileCode))
    //if (tileCode in nonSolidTiles)
  {
    return false;
  } else
  {
    return true;
  }
}

// handle multiple key presses
void keyPressed()
{
  if (key == 'a' || (key == CODED && keyCode == LEFT)) { 
    keyA = true;
  }  
  if (key == 's' || (key == CODED && keyCode == DOWN)) { 
    keyS = true;
  }  
  if (key == 'd' || (key == CODED && keyCode == RIGHT)) { 
    keyD = true;
  }  
  if (key == 'w' || (key == CODED && keyCode == UP)) { 
    keyW = true;
  }
}

void keyReleased()
{
  if (key == 'a' || (key == CODED && keyCode == LEFT)) { 
    keyA = false;
  }                                    
  if (key == 's' || (key == CODED && keyCode == DOWN)) { 
    keyS = false;
  }  
  if (key == 'd' || (key == CODED && keyCode == RIGHT)) { 
    keyD = false;
  }  
  if (key == 'w' || (key == CODED && keyCode == UP)) { 
    keyW = false;
  }

  //Handle menu actions
  if (key == ' ') {
    if (creatorMenuOn == false) {
      creatorMenuOn = true;
      positionTracker = 1;
    } else {
      creatorMenuOn = false;
    }
  } 

  if (creatorMenuOn == true) {
    if (key == CODED && keyCode == RIGHT) {
      if (collidableObjectsSubMenu == true) {
        if (positionTracker < 12) {
          positionTracker++;
        }
      } else if (backGroundSubMenu == true) {
        if (positionTracker < 14) {
          positionTracker++;
        }
      } else if (categoryMenu == true) {
        if (positionTracker < 2) {
          positionTracker++;
        }
      }
    } else if (key == CODED && keyCode == LEFT) {
      if (positionTracker > 1) {
        positionTracker--;
      }
    } else if (key == ENTER || key == RETURN) {
      if (categoryMenu == true) {
        if (positionTracker == 1) {
          backGroundSubMenu = true;
        } else if (positionTracker == 2) {
          collidableObjectsSubMenu = true;
        }
        categoryMenu = false;
        positionTracker = 1;
      } else if (backGroundSubMenu == true) {
        switch (positionTracker) {
        case 1: 
          selectedBlock = 12;
          break;
        case 2: 
          selectedBlock = 25;
          break;
        case 3: 
          selectedBlock = 14;
          break;
        case 4:
          selectedBlock = 16;
          break;
        case 5:
          selectedBlock = 50;
          break;
        case 6:
          selectedBlock = 24;
          break;
        case 7: 
          selectedBlock = 51;
          break;
        case 8: 
          selectedBlock = 32;
          break;
        case 9: 
          selectedBlock = 52;
          break;
        case 10: 
          selectedBlock = 1;
          break;
        case 11: 
          selectedBlock = 9;
          break;
        case 12: 
          selectedBlock = 17;
          break;
        case 13:
          selectedBlock = 33;
          break;
        case 14:
          selectedBlock = 15;
          break;
        }
        creatorMenuOn = false;
      } else if (collidableObjectsSubMenu == true) {
        switch (positionTracker) {
        case 1: 
          selectedBlock = 0;
          break;
        case 2: 
          selectedBlock = 6;
          break;
        case 3: 
          selectedBlock = 42;
          break;
        case 4:
          selectedBlock = 20;
          break;
        case 5:
          selectedBlock = 4;
          break;
        case 6:
          selectedBlock = 5;
          break;
        case 7: 
          selectedBlock = 13;
          break;
        case 8: 
          selectedBlock = 21;
          break;
        case 9: 
          selectedBlock = 34;
          break;
        case 10: 
          selectedBlock = 18;
          break;
        case 11: 
          selectedBlock = 43;
          break;
        case 12: 
          selectedBlock = 49;
          break;
        } 
        creatorMenuOn = false;
      }
    } else if (key == BACKSPACE) {
      if (categoryMenu == true) {
        creatorMenuOn = false;
      } else if (backGroundSubMenu == true) {
        backGroundSubMenu = false;
        categoryMenu = true; 
      } else if (collidableObjectsSubMenu == true) {
        collidableObjectsSubMenu = false;
        categoryMenu = true; 
      }
    }
  } else {
    if (key == ENTER) {
      level[creatorFocus.getRow()][creatorFocus.getCol()] = selectedBlock;
    } 
  }
}

//this class represents the peices of the block when a block breaks
class BreakingBlock
{
  
  // location
  float x, y;
  
  //image
  PImage artwork = tiles[58];

  // speed (constant)
  float speed = 3;
  
  //gravity
  float gravity = 5;
  
  //type
  String type = "rightTop";

  
  BreakingBlock(float _x, float _y, String _type)
  {
    // store position
    x = _x;
    y = _y;
    type= _type;
    
    //the top blocks fly a little farther
    if(type == "rightTop" || type == "leftTop") {
      gravity = 7;
      speed = 3.5;
    }

  }  
  
  //performs the movment of the block pieces
  boolean move() {
    if(type == "rightTop" || type == "leftBottom"){
      artwork = tiles[57];
    }
    else {
      artwork = tiles[58];
    }
    
    //sideways movement
    if(type == "leftTop" || type == "leftBottom"){ 
        // if we still have speed
        if ( speed > 0)
        {
          x -= speed;
          speed -= 0.05;
        }
    } else { 
        // if we still have speed
        if ( speed > 0)
        {
            //if it not solid we move
            x += speed;
            speed -= 0.05;    
        }
    }
    
    //gravity
      y -= gravity;
       
      //if the tile below the block pieces is not solid pull it down
      if (y > 450)
      {
        gravity = 0;
        return true;
      } else {
        gravity -= 0.2;
      }
      return false;
  }
  
  // draw the block
  void display() {
    image(artwork, x, y, CELL_SIZE, CELL_SIZE);
  }
}
//this class represents the coin which pops out of ? blocks
class Coin
{
  // artwork
  PImage artwork;
  PImage coin1;
  PImage coin2;
  PImage coin3;
  PImage coin4;
  
  // location
  float x, y;

  // speed (constant)
  float speed = 1;
  
  //gravity
  float gravity = 7;

  
  Coin(float _x, float _y)
  {
    // store position
    x = _x;
    y = _y;

    // load artwork
    coin1 = loadImage("coin1.png");
    coin2 = loadImage("coin2.png");
    coin3 = loadImage("coin3.png");
    coin4 = loadImage("coin4.png");
    artwork = coin1;

  }  
  
  //enables the coin to fly up and come back down
  boolean move() {
    //change artwork
    artwork = animateCoin();
    
    //gravity
      y -= gravity;
  
      // always pull down the coin (gravity) if we aren't on solid land
      int downTileCode = getTileCode(x + CELL_SIZE/2, y + CELL_SIZE+3, true);
      
      //if the tile below the coin is not solid pull it down
      if (isSolid( downTileCode))
      {
        gravity = 0;
        mario.score += 200;
        return true;
      } else {
        gravity -= 0.2;
      }
      return false;
  }
  
  // draw the coin
  void display() {
    if(gravity <= -5){
      text("200", x, y - CELL_SIZE/2);
    }
    image(artwork, x, y, CELL_SIZE, CELL_SIZE);
  }
  
  //creates the animation of the coin spinning
  PImage animateCoin() {
    int levelTimer = int(levelDB.currLevelTimeElasped/5);
    if(levelTimer % 4 == 0) {
        return coin1;
    } else if(levelTimer % 4 == 1) {
        return coin2;
    } else if(levelTimer % 4 == 2) {
        return coin3;
    } else {
        return coin4;
    } 
  }
}
//this class represents the goombas which walk around the level
class Goomba
{
  // artwork
  PImage artwork;
  PImage goombaRight;
  PImage goombaLeft;
  PImage goombaSquished;
  
  //squished info to show squished image
  boolean isSquished = false;
  int squishedTimer = 2;

  // location
  float x, y, origX, origY;

  // speed (constant)
  float speed = 1;
  
  //moveDirection
  String moveDirection = "left";
  
  //gravity
  float gravity = 0;

  
  Goomba(float _x, float _y)
  {
    // store position
    x = origX = _x;
    y = origY = _y;

    // load artwork
    goombaRight = loadImage("goombaRight.png");
    goombaLeft = loadImage("goombaLeft.png");
    goombaSquished = loadImage("goombaSquished.png");
    artwork = goombaLeft;
  }  
  
  //allows the goomba to walk around
    void move() {
    //only move if on screen and not squished
    if(x + CELL_SIZE > 0 && x < 500 && !isSquished) {
          
      if(int(levelDB.currLevelTimeElasped) % 10 == 0){
        //change the artwork to create walking effect
        if(artwork == goombaRight) {
          artwork = goombaLeft;
        } else {
          artwork = goombaRight;
        }
      }
      
      //right
      if (moveDirection == "right") 
      {
        
        // we need to check to see what tile is to our right (by 3 pixels or so)
        int tileCode = getTileCode(x + CELL_SIZE + 3, y + CELL_SIZE/2, true);
  
        if(debug){
          // debugging ellipse (to show the point that we are checking)
          ellipse(x + CELL_SIZE + 3, y+CELL_SIZE/2, 10, 10);
        }
  
        // is this a solid tile?  if so, don't allow us to move!
        if ( !isSolid(tileCode, true) )
        {
            //if it not solid we move
            x += speed;    
        } else
        {
          //if it is solid change moveDirection
          moveDirection = "left";
        }
      } //end right
      
      // left
      if (moveDirection == "left") 
      {
        // we need to check to see what tile is to our left (by 3 pixels or so)
        int tileCode = getTileCode(x - 3, y + CELL_SIZE/2, true);
  
        if(debug){
          // debugging ellipse
          ellipse(x-3, y+CELL_SIZE/2, 10, 10);
        }
  
        // is this a solid tile?  if so, don't allow us to move!
        if ( !isSolid(tileCode, true) )
        {
          x -= speed;
  
        } else
        {
          //otherwise switch moveDirection
          moveDirection = "right";
        }
      } //end left
      
      //gravity
      y -= gravity;
  
      // always pull down the character (gravity) if we aren't on solid land
      int downTileCode = getTileCode(x + CELL_SIZE/2, y + CELL_SIZE+3, true);
      
      //if the tile below the coin is not solid pull it down
      if (isSolid( downTileCode))
      {
        gravity = 0;
      } else {
        gravity -= 0.2;
      }
   }
   else {
     //if the goomba is squished
      artwork = goombaSquished;
      text("100", x, y-30);
   }
  }
  
  // draw the goomba
  void display() {
    image(artwork, x, y, CELL_SIZE, CELL_SIZE);
  }
  
  //reset goomba position
  void resetGoomba() {
    this.x = this.origX;
    this.y = this.origY;
  }
  
  //check for collision with the player
  //boolean returned indicates whether the goomba died
  boolean checkCollision() {
    //if a collision has occured
    if((dist(mario.x, mario.y, x, y) < 30 && !isSquished && !mario.isSuper) || (dist(mario.x, mario.y + CELL_SIZE, x, y) < 30 && !isSquished && mario.isSuper))  {
      //player jumped on top
      if(mario.jumpPower != 0) {
        artwork = goombaSquished;
        isSquished = true;
        soundDB.playStomp();
        return false;
      }
      else {
        //player ran into goomba
        if(mario.isSuper) {
          mario.isSuper = false;
        } else {
          mario.died();
        }
        return false;
      }
    }
    if(isSquished) {
      //timer of how long to stay in squshed state - this allows the player to see that it was squished
      squishedTimer--;
      if(squishedTimer <= 0){
        mario.score+= 100;
        return true;
      }
    }
    return false;
  }
}

//this class represents the mushroom which allows mario to turn super
class Mushroom
{
  // artwork
  PImage mushroom;
  
  // location
  float x, y;

  // speed (constant)
  float speed = 2;
  
  //caught info to show squished image
  boolean isCaught = false;
  int caughtTimer = 10;
  
  //moveDirection
  String moveDirection = "right";
  
  //gravity
  float gravity = 0;

  
  Mushroom(float _x, float _y)
  {
    // store position
    x = _x;
    y = _y;

    // load artwork
    mushroom = loadImage("mushroom.png");

  }  
  
//allows the mushroom to move
void move() {     
    
    if(!isCaught) {
      if (moveDirection == "right") 
      {
        
        // we need to check to see what tile is to our right (by 3 pixels or so)
        int tileCode = getTileCode(x + CELL_SIZE + 3, y + CELL_SIZE/2);
    
        if(debug){
          // debugging ellipse (to show the point that we are checking)
          ellipse(x + CELL_SIZE + 3, y+CELL_SIZE/2, 10, 10);
        }
    
        // is this a solid tile?  if so, don't allow us to move!
        if ( !isSolid(tileCode, true) )
        {
            //if it not solid we move
            x += speed;    
        } else
        {
          //if it is solid change moveDirection
          moveDirection = "left";
        }
      } //end right
      
      // left
      if (moveDirection == "left") 
      {
        
        // we need to check to see what tile is to our left (by 3 pixels or so)
        int tileCode = getTileCode(x - 3, y + CELL_SIZE/2);
    
        if(debug){
          // debugging ellipse
          ellipse(x-3, y+CELL_SIZE/2, 10, 10);
        }
    
        // is this a solid tile?  if so, don't allow us to move!
        if ( !isSolid(tileCode, true) )
        {
          x -= speed;
    
        } else
        {
          //otherwise switch moveDirection
          moveDirection = "right";
        }
      } //end left
      
      //gravity
      y -= gravity;
    
      // always pull down the mushroom (gravity) if we aren't on solid land
      int downTileCode = getTileCode(x + CELL_SIZE/2, y + CELL_SIZE+3);
      
      //if the tile below the mushroom is not solid pull it down
      if (isSolid( downTileCode))
      {
        gravity = 0;
      } else {
        gravity -= 0.2;
      }
    }
    else {
      //give points for catching the mushroom
      text("1000", x-CELL_SIZE, y-CELL_SIZE);
    }
  }
  
  // draw the mushroom
  void display() {
    if(!isCaught) {
      image(mushroom, x, y, CELL_SIZE, CELL_SIZE);
    }
  }
  
  //check for collision with the player
  boolean checkCollision() {
    //if a collision has occured
    if(dist(mario.x, mario.y, x, y) < 30 && !isCaught)  {
      isCaught = true;
      soundDB.playPowerUp();
      return false;
    }
    if(isCaught) {
      //timer of how long to display points gained - this allows the player to see what he/she earned
      caughtTimer--;
      if(caughtTimer <= 0){
        mario.score+= 1000;
        return true;
      }
    }
     return false;
  }
  

}
//this class represents the player (in this case mario)
class Player
{
  // artwork
  PImage artwork;
  PImage marioRight;
  PImage marioLeft;
  PImage marioRightSuper;
  PImage marioLeftSuper;

  // location
  float x, y, origX, origY;

  // speed (constant)
  float speed = 3;

  // jump power
  float jumpPower = 0;
  
  //lives
  int livesOrig = 3;
  int lives = livesOrig;
  
  //score
  int score = 000000;
  
  //coins
  int coinsCollected = 0;
  
  //check if moving
  boolean isMoving = false;
  
  //check if super
  boolean isSuper = false;

  Player(float _x, float _y)
  {
    // store position
    x = origX = _x;
    y = origY = _y;

    // load artwork
    marioRight = loadImage("marioright.png");
    marioLeft = loadImage("marioleft.png");
    marioRightSuper = loadImage("marioright_super.png");
    marioLeftSuper = loadImage("marioleft_super.png");
    artwork = marioRight;
  }  

  void move()
  {
    // move right
    if (keyD) 
    {
      //change the artwork
      if(isSuper) {
        artwork = marioRightSuper;
      } else {
        artwork = marioRight;
      }
      
      // we need to check to see what tile is to our right (by 3 pixels or so)
      int tileCode = getTileCode(x + CELL_SIZE + 3, y + CELL_SIZE/2);
      if(isSuper && !isSolid(tileCode)) {
        tileCode = getTileCode(x + CELL_SIZE + 3, y + CELL_SIZE/2 + CELL_SIZE);
      }

      if(debug){
        // debugging ellipse (to show the point that we are checking)
        if(isSuper) {
          ellipse(x + CELL_SIZE + 3, y+CELL_SIZE/2 + CELL_SIZE, 10, 10);
        }
        ellipse(x + CELL_SIZE + 3, y+CELL_SIZE/2, 10, 10);
      }

      // is this a solid tile?  if so, don't allow us to move!
      if ( !isSolid(tileCode) )
      {
        // are we at >= 50% of the width of the screen?
        if (x >= width/2)
        {
          // is there more level to the right of the character?
          int rt = getRightmostTileXLocation();  
          
          // move level to the right - just adjust the X_OFFSET and leave the character
          // where they are on the screen
          if (rt > width)
          {
            X_OFFSET -= speed;
            //also adjust the location of our goombas so they remain where they were relative to the bg
            for(int i = 0; i < goombas.size(); i++) {
              goombas.get(i).x -= speed;
            }
            //also adjust the location of our coins so they remain where they were relative to the bg
            for(int i = 0; i < coins.size(); i++) {
              coins.get(i).x -= speed;
            }
            //also adjust the location of our mushrooms so they remain where they were relative to the bg
            for(int i = 0; i < mushrooms.size(); i++) {
              mushrooms.get(i).x -= speed;
            }
            //also adjust the location of our breaking blocks so they remain where they were relative to the bg
            for(int i = 0; i < breakingBlocks.size(); i++) {
              breakingBlocks.get(i).x -= speed;
            }
          }
          
          // otherwise just move the character's x position
          else
          {
            x += speed;
          }
        }
        
        // character is to the left of the midpoint of the screen - just move their x position
        else
        {
          x += speed;
        }
        
        isMoving = true;
        fill(255);
        if(debug){
          text("Tile to the right of mario is NOT SOLID.", 20, 60);
        }
      } else
      {
        isMoving = false;
        fill(255);
        if(debug){
          text("Tile to the right of mario is SOLID.", 20, 60);
        }
      }
      //if the player reaches this far they win the game
      if(x - X_OFFSET >= 5930){
        state = 5;
      }
    }

    // left
    if (keyA) 
    { 
      //change the artwork
      if(isSuper) {
        artwork = marioLeftSuper;
      } else {
        artwork = marioLeft;
      }
      
      // we need to check to see what tile is to our left (by 3 pixels or so)
      int tileCode = getTileCode(x - 3, y + CELL_SIZE/2);
      if(isSuper && !isSolid(tileCode)) {
        tileCode = getTileCode(x - 3, y + CELL_SIZE/2 + CELL_SIZE);
      }

      if(debug){
        // debugging ellipse
        if(isSuper) {
          ellipse(x-3, y+CELL_SIZE/2 + CELL_SIZE, 10, 10);
        }
        ellipse(x-3, y+CELL_SIZE/2, 10, 10);
      }

      // is this a solid tile?  if so, don't allow us to move!
      if ( !isSolid(tileCode) )
      {
        // are we at <= 50% of the width of the screen?
        if (debug && x <= width/2)
        {
          // is there more level to the left of the character?
          int rt = getLeftmostTileXLocation();  
          
          // move level to the left - just adjust the X_OFFSET and leave the character
          // where they are on the screen
          if (rt < 0)
          {
            X_OFFSET += speed;
            
            //also adjust the location of our goombas so they remain where they were relative to the bg
            for(int i = 0; i < goombas.size(); i++) {
              goombas.get(i).x += speed;
            }
            //also adjust the location of our coins so they remain where they were relative to the bg
            for(int i = 0; i < coins.size(); i++) {
              coins.get(i).x += speed;
            }
            //also adjust the location of our mushrooms so they remain where they were relative to the bg
            for(int i = 0; i < mushrooms.size(); i++) {
              mushrooms.get(i).x += speed;
            }
            //also adjust the location of our breaking blocks so they remain where they were relative to the bg
            for(int i = 0; i < breakingBlocks.size(); i++) {
              breakingBlocks.get(i).x += speed;
            }
          }
          
          // otherwise just move the character's x position
          else
          {
            x -= speed;
          }
        }
        
        // character is to the right of the midpoint of the screen - just move their x position
        else
        {
          x -= speed;
        }
        
        isMoving = true;
        fill(255);
        if(debug){
          text("Tile to the left of mario is NOT SOLID.", 20, 40);
        }
      } else
      {
        isMoving = false;
        fill(255);
        if(debug){
          text("Tile to the left of mario is SOLID.", 20, 40);
        }
      }
    }


    // jump
    if (keyW) { 
      
      // we need to check to see what tile is to our top (by 3 pixels or so)
      int tileCode = getTileCode(x + CELL_SIZE/2, y-3);
      
      if(debug){
        // debugging ellipse
        ellipse(x+CELL_SIZE/2, y-3, 10, 10);
      }

      // is this a solid tile?  if so, don't allow us to move!
      if ( !isSolid(tileCode) ) {
        // only jump if we are on solid ground (not falling, not jumping)
        if (jumpPower == 0)
        {
          soundDB.playJump();
          jumpPower = 7;
        }
      }
      else {
        levelDB.tileIsSpecial(tileCode, x + CELL_SIZE/2, y-3 );
      }
    }

    //Stop the character from jumping through solid tiles
    // we need to check to see what tile is to our top (by 3 pixels or so)
    int tileCodeUP = getTileCode(x + CELL_SIZE/2, y-3);
    
    if(debug){
      // debugging ellipse
      ellipse(x+CELL_SIZE/2, y-3, 10, 10);
    }

    // is this a solid tile?  if so, stop the jump and enable gravity!
    if ( isSolid(tileCodeUP) ) {
      // apply jump power (bring us back down)
      jumpPower = -0.5;
    }
    
    y -= jumpPower;

    // always pull down the character (gravity) if we aren't on solid land
    int downTileCode = getTileCode(x + CELL_SIZE/2, y + CELL_SIZE+3);
    
    if(isSuper) {
      downTileCode = getTileCode(x + CELL_SIZE/2, y + (CELL_SIZE* 2)+3);
    }

    if(debug){
      // debugging ellipse
      if(isSuper) {
        ellipse(x+CELL_SIZE/2, y+(CELL_SIZE* 2)+3, 10, 10);
      } else {
        ellipse(x+CELL_SIZE/2, y+CELL_SIZE+3, 10, 10);
      }
    }

    if (isSolid( downTileCode))
    {
      jumpPower = 0;
      fill(255);
      if(debug){
        text("Tile below mario is SOLID. jumpPower=" + jumpPower, 20, 20);
      }
    } else {
      
      //if character has fell off the level, restart at the beginning
      if((y > 450 && !isSuper) || (y > 430 && isSuper)) {
        died();
      }
      jumpPower -= 0.2;
      fill(255);
      if(debug){
        text("Tile below mario is NOT SOLID. jumpPower=" + jumpPower, 20, 20);
      }
    }
  }

  //reset player position
  void resetPlayer() {
    this.x = this.origX;
    this.y = this.origY;
    X_OFFSET = 0;
    this.isSuper = false;
  }

  // draw the player
  void display() {
    if(isSuper){
      image(artwork, x, y, CELL_SIZE, CELL_SIZE * 2);
    } else {
      image(artwork, x, y, CELL_SIZE, CELL_SIZE);
    }
    //for debug purposes
    if(locationFinder) {
      text("x:" + x + " y:" + y + " x - offset:" + (x - X_OFFSET),20,80);
    }
  }
  
  //reset lives
  void resetLives() {
    this.lives = livesOrig;
  }
  
  //function called when player dies
  void died() {
    //subtract a life
    lives--;
    //if the player died but still has lives
    if (lives > 0) {
      //reset the level and continue playing
      resetPlayer();
      levelDB.resetGoombas();
      levelDB.currLevelTimeElasped = 0;
      level = levelDB.getLevel(levelName);
      state = 3;
      //otherwise the game is over
    } else if (lives <= 0) {
      state = 2;
    }
  }
  
  //function called when player turns super
  void becomeSuper() {
    isSuper = true;
    y = y - CELL_SIZE;
    if(artwork == marioRight) {
      artwork = marioRightSuper;
    } else {
      artwork = marioLeftSuper;
    }
  }
  
}

//this class controlls all the sounds for the game
class SoundDBClass {
   
  // audio file players
  AudioPlayer gameOver;
  AudioPlayer marioDies;
  AudioPlayer bump;
  AudioPlayer coin;
  AudioPlayer powerUpAppears;
  AudioPlayer powerUp;
  AudioPlayer stomp;
  AudioPlayer jump;
  AudioPlayer levelOneTheme;
  AudioPlayer stageClear;
  
  //set up all the sounds
  SoundDBClass() {      
    // load in our audio files
    gameOver = minim.loadFile("smb_gameover.mp3");
    marioDies = minim.loadFile("smb_mariodie.mp3");
    bump = minim.loadFile("smb_bump.mp3");
    coin = minim.loadFile("smb_coin.mp3");
    powerUpAppears = minim.loadFile("smb_powerup_appears.mp3");
    powerUp = minim.loadFile("smb_powerup.mp3");
    stomp = minim.loadFile("smb_stomp.mp3");
    jump = minim.loadFile("smb_jump.mp3");
    levelOneTheme = minim.loadFile("smb_level1_theme.mp3");
    stageClear = minim.loadFile("smb_stage_clear.mp3");
  }
  
  //play the game over sound
  void playGameOver() { 
    
    //stop theme music
    pauseLevelOneTheme();
    rewindLevelOneTheme();
    
    //rewind if not playing
    if(!gameOver.isPlaying()) {
      gameOver.rewind();
    }
    
    //play the file
    gameOver.play();
    
  }
  
  //play the mario dies sound
  void playMarioDies() { 
    
    //stop theme music
    pauseLevelOneTheme();
    
    //rewind if not playing
    if(!marioDies.isPlaying()) {
      marioDies.rewind();
    }
    
    //play the file
    marioDies.play();
    
  }
  
  //play the bump sound
  void playBump() { 
    
    //rewind if not playing
    if(!bump.isPlaying()) {
      bump.rewind();
    }
    
    //play the file
    bump.play();
    
  }
  
  //play the coin sound
  void playCoin() { 
    
    //rewind if not playing
    if(!coin.isPlaying()) {
      coin.rewind();
    }
    
    //play the file
    coin.play();
    
  }
  
  //play the powerup appears sound
  void playPowerUpAppears() { 
    
    //rewind if not playing
    if(!powerUpAppears.isPlaying()) {
      powerUpAppears.rewind();
    }
    
    //play the file
    powerUpAppears.play();
    
  }
  
  //play the powerup sound
  void playPowerUp() { 
    
    //rewind if not playing
    if(!powerUp.isPlaying()) {
      powerUp.rewind();
    }
    
    //play the file
    powerUp.play();
    
  }
  
  //play the stomp sound
  void playStomp() { 
    
    //rewind if not playing
    if(!stomp.isPlaying()) {
      stomp.rewind();
    }
    
    //play the file
    stomp.play();
    
  }
  
  //play the jump sound
  void playJump() { 
    
    //rewind if not playing
    if(!jump.isPlaying()) {
      jump.rewind();
    }
    
    //play the file
    jump.play();
    
  }
  
  //play the level one theme sound
  void playLevelOneTheme() { 
       
    //play the file
    levelOneTheme.loop();
    
  }
  
  //pause the level one theme sound
  void pauseLevelOneTheme() { 
       
    //pause the file
    levelOneTheme.pause();
        
  }
  
    //stop the level one theme sound
  void rewindLevelOneTheme() { 
       
    //rewind the file
    levelOneTheme.rewind();
        
  }
  
  //play the stage clear sound
  void playStageClear() { 
    
    //rewind if not playing
    if(!stageClear.isPlaying()) {
      stageClear.rewind();
    }
    
    //play the file
    stageClear.play();
    
  }


}
//this class contains all the level information
class levelDBClass {
  
  int currLevelTimeElasped;
  int endAnimationTimer = 0;
  
  //function which returns the mapping for the level
  int[][] getLevel(String levelName) {
   
  //load the text file
  String[] lines = loadStrings(levelName + ".txt");
  int[] data = int(split(lines[0],','));
  int[][] level = new int[lines.length][data.length];

  for(int x = 0; x < level.length; x++) {
    data = int(split(lines[x],','));
    
    for(int y = 0; y < level[0].length - 1; y++) {
      level[x][y] = data[y];
    }  
  }
      return level;
  }
  
  //funciton which creates all the goombas for a level
  void getGoombas(String levelName, ArrayList<Goomba> theList) {
    
  //load the text file
  String[] lines = loadStrings(levelName + "_goombas.txt");
  int[] data = int(split(lines[0],','));
  int[][] level = new int[lines.length][data.length];

    for(int x = 0; x < level.length; x++) {
      data = int(split(lines[x],','));
      theList.add(new Goomba(data[0], data[1]));
    }
  }
  
  //get the allotted time for a level
  int getTime(int levelId) {
    return 400;
  }
  
  // load our tiles into memory
  void loadTiles(PImage[] tiles) {
    for (int i = 0; i < tiles.length; i++)
    {
      tiles[i] = loadImage(i + ".png");
    }
  }
  
  // iterate over the level array and draw the correct tile to the screen
  void drawLevel(PImage[] tiles){
    for (int row = 0; row < level.length; row++)
    {
      for (int col = 0; col < level[row].length; col++)
      {
        image( animateTile(tiles[ level[row][col] ]), col*CELL_SIZE+X_OFFSET, row*CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }
    }
  }
  
    // iterate over the level array and draw the correct tile to the screen
  void drawLevel(PImage[] tiles, boolean creator){
    for (int row = 0; row < level.length; row++)
    {
      for (int col = 0; col < level[row].length; col++)
      {
        image( animateTile(tiles[ level[row][col] ]), col*CELL_SIZE+X_OFFSET, row*CELL_SIZE, CELL_SIZE, CELL_SIZE);
        if(creator) {
          noFill();
          rect(col*CELL_SIZE+X_OFFSET, row*CELL_SIZE, CELL_SIZE, CELL_SIZE);
        }
      }
    }
  }
  
  //resets the level
  void resetGame() {
    levelId = 1;
    state  = 1;
    currLevelTimeElasped = 0;
    mario.resetLives();
    mario.resetPlayer();
    resetGoombas();
    level = levelDB.getLevel(levelName);
    
  }
  
  //resets all the goombas to their original positions
  void resetGoombas() {
     //reset all the goombas
     levelDB.getGoombas(levelName, goombas);
    for(int i = 0; i < goombas.size(); i++) {
      goombas.get(i).resetGoomba();
    }
  }
  
  //function to check if tile is animated
  PImage animateTile(PImage img) {
    if(img == tiles[49]) {
      return animate49();
    }
    else {
      return img;
    }
  }
  
  //make the ? mark tile change colors
  PImage animate49() {
    int levelTimer = int(currLevelTimeElasped/5);
    if(levelTimer % 7 == 0) {
        return tiles[54];
    } else if(levelTimer % 7 == 1) {
        return tiles[55];
    } else {
        return tiles[49];
    }
  }
  
  //get a list of non solid tiles
  ArrayList<Integer> getNonSolidList() {
    ArrayList<Integer> nonSolidTiles = new ArrayList<Integer>();
    nonSolidTiles.add(12);
    nonSolidTiles.add(15);
    nonSolidTiles.add(01);
    nonSolidTiles.add(9);
    nonSolidTiles.add(17);
    nonSolidTiles.add(50);
    nonSolidTiles.add(51);
    nonSolidTiles.add(52);
    nonSolidTiles.add(53);
    
    return nonSolidTiles;
  }
  
  //overloaded version of getNonSolidList
  ArrayList<Integer> getNonSolidList(boolean isEnemy) {
    ArrayList<Integer> nonSolidTiles = getNonSolidList();
    if(isEnemy) {
      nonSolidTiles.add(-1);
    }
    
    return nonSolidTiles;
  }
  
  //check to see if tile is special
  void tileIsSpecial(int code, float x, float y) {
    //get row and column
      int col = int(int(x-X_OFFSET)/CELL_SIZE);
      int row = int(int(y)/CELL_SIZE);
    
    //if this is a "?" tile
    if(code == 49) {
      
      //if its a mushroom
      if(col == 21 && row == 11 || col == 110 && row == 7) {
        mushrooms.add(new Mushroom(x - CELL_SIZE/2,y - (CELL_SIZE*2)));
        level[row][col] = 48;
        soundDB.playPowerUpAppears();
        
      } else { //otherwise its a coin
        coins.add(new Coin(x - CELL_SIZE/2,y - (CELL_SIZE*2)));
      
        level[row][col] = 48;
        soundDB.playCoin();
      }
    }
    
    //if this is a brick block and mario is super
    else if(code == 40 && mario.isSuper) {
      level[row][col] = 12;
      soundDB.playBump();
      breakingBlocks.add(new BreakingBlock(x-CELL_SIZE, y - CELL_SIZE, "leftTop" ));
      breakingBlocks.add(new BreakingBlock(x-CELL_SIZE, y - CELL_SIZE/4, "leftBottom" ));
      breakingBlocks.add(new BreakingBlock(x+CELL_SIZE/3, y - CELL_SIZE, "rightTop" ));
      breakingBlocks.add(new BreakingBlock(x+CELL_SIZE/3, y - CELL_SIZE/4, "rightBottom" ));
    }
    else {
      soundDB.playBump();
    }
  }
  
  //end game animation
  void gameEndAnimation() {
    endAnimationTimer++;
    soundDB.pauseLevelOneTheme();
    soundDB.playStageClear();
    
    //first lower the flag
    if(endAnimationTimer < 6) {
      mario.y = 390;
      level[6][198] = 19;
      level[5][198] = 12;
      level[6][199] = 27;
      level[5][199] = 28;
    } else if(endAnimationTimer < 12) {
      level[7][198] = 19;
      level[6][198] = 12;
      level[7][199] = 27;
      level[6][199] = 28;
    } else if(endAnimationTimer < 18) {
      level[8][198] = 19;
      level[7][198] = 12;
      level[8][199] = 27;
      level[7][199] = 28;
    } else if(endAnimationTimer < 24) {
      level[9][198] = 19;
      level[8][198] = 12;
      level[9][199] = 27;
      level[8][199] = 28;
    } else if(endAnimationTimer < 30) {
      level[10][198] = 19;
      level[9][198] = 12;
      level[10][199] = 27;
      level[9][199] = 28;
    } else if(endAnimationTimer < 36) {
      level[11][198] = 19;
      level[10][198] = 12;
      level[11][199] = 27;
      level[10][199] = 28;
    } else if(endAnimationTimer < 42) {
      level[12][198] = 19;
      level[11][198] = 12;
      level[12][199] = 27;
      level[11][199] = 28;
    } else if(endAnimationTimer < 48) {
      level[13][198] = 19;
      level[12][198] = 12;
      level[13][199] = 27;
      level[12][199] = 28;
    } else if(endAnimationTimer < 54) {
      level[13][198] = 12;
      level[13][199] = 28;
    }     
    //then move forward to castle
    else if(endAnimationTimer < 92) {
      //move him forward
      mario.x += mario.speed;
      X_OFFSET -= mario.speed;
    }
    //then raise the flag on the castle
    else if(endAnimationTimer < 105){
      level[9][205] = 59;
    }
    //show you win screen and reset game
    else {
      menuDB.youWin();
      if(menuDB.youWinTimer > 0){
        menuDB.youWinTimer--;
      }
      else {
        menuDB.youWinTimerReset();
        levelDB.resetGame();
        soundDB.rewindLevelOneTheme();
        state  = 0;
      }
    }
    
    //display the player
    if(endAnimationTimer < 92){
      mario.display();
    }
  }
}
//this class contains all the menus/transtion scrrens used in the game
class menuDBClass {

  //these are all the timers for how long a screen is shown
  int gameOverTimerOrig = 120;
  int gameOverTimer = gameOverTimerOrig;

  int diedTimerOrig = 120;
  int diedTimer = gameOverTimerOrig;

  int timeUpTimerOrig = 120;
  int timeUpTimer = timeUpTimerOrig;

  int youWinTimerOrig = 220;
  int youWinTimer = youWinTimerOrig;

  //main menu image
  PImage mainMenuBG;

  //coin image
  PImage coinArt;

  //images for the creatorMenu
  PImage sky;
  PImage black;
  PImage green;
  PImage bushFragment1;
  PImage bushFragment2;
  PImage bushFragment3;
  PImage bushFragment4;
  PImage bushFragment5;
  PImage bushFragment6;
  PImage hillFragment1;
  PImage hillFragment2;
  PImage hillFragment3;
  PImage hillFragment4;
  PImage hillFragment5;



  PImage groundBlockBrown;
  PImage groundBlockWhite;
  PImage groundBlockBlue;
  PImage brickWallBrown1;
  PImage brickWallBrown2;
  PImage brickWallBrown3;
  PImage brickWallBrown4;
  PImage brickWallBrown5;
  PImage brickWallBlue;
  PImage obstacleBlockBrown;
  PImage obstacleBlockBlue;
  PImage questionBlock;

  PImage pipeFragment1;
  PImage pipeFragment2;
  PImage pipeFragment3;
  PImage pipeFragment4;
  PImage pipeFragment5;
  PImage pipeFragment6;
  PImage pipeFragment7;
  PImage pipeFragment8;

  menuDBClass() {
    mainMenuBG = loadImage("mainBG.png");
    coinArt = loadImage("coin2.png");

    sky = loadImage("12.png");
    black = loadImage("14.png");
    green = loadImage("25.png");
    bushFragment1 = loadImage("16.png");
    bushFragment2 = loadImage("50.png");
    bushFragment3 = loadImage("24.png");
    bushFragment4 = loadImage("51.png");
    bushFragment5 = loadImage("32.png");
    bushFragment6 = loadImage("52.png");
    hillFragment1 = loadImage("1.png");
    hillFragment2 = loadImage("9.png");
    hillFragment3 = loadImage("17.png");
    hillFragment4 = loadImage("33.png");
    hillFragment5 = loadImage("8.png");

    groundBlockBrown = loadImage("0.png");
    groundBlockWhite = loadImage("6.png");
    groundBlockBlue = loadImage("42.png");
    brickWallBrown1 = loadImage("20.png");
    brickWallBrown2 = loadImage("4.png");
    brickWallBrown3 = loadImage("5.png");
    brickWallBrown4 = loadImage("13.png");
    brickWallBrown5 = loadImage("21.png");
    brickWallBlue = loadImage("34.png");
    obstacleBlockBrown = loadImage("18.png");
    obstacleBlockBlue = loadImage("43.png");
    questionBlock = loadImage("49.png");
  }

  //display the game over screen
  void gameOver() {
    background(0);
    fill(255);
    textSize(32);
    text("Game Over", 151, 239);
    textSize(14);
  }

  //reset the game over timer
  void gameOverTimerReset() {
    this.gameOverTimer = gameOverTimerOrig;
  }

  //display the game over screen
  void timeUp() {
    background(0);
    fill(255);
    textSize(32);
    text("Time Up", 151, 239);
    textSize(14);
  }

  //reset the game over timer
  void timeUpTimerReset() {
    this.timeUpTimer = timeUpTimerOrig;
  }

  //reset the died timer
  void diedTimerReset() {
    this.diedTimer = diedTimerOrig;
  }

  //show this when the player dies but still has lives
  void died() {
    background(0);
    fill(255);
    textSize(32);
    text("Level: " + levelId + "-1", 148, 185);
    text(mario.lives + " x", 168, 235);
    image(mario.marioRight, 225, 200, 50, 50);
    textSize(14);
  }

  //this menu is displayed during game play - it gives HUD info
  void levelMenu() {
    fill(225);
    text("MARIO", 40, 40);
    text("WORLD", 350, 40);
    text("TIME", 440, 40);

    text(nf(mario.score, 6, 0), 40, 55);
    image(coinArt, 235, 42);
    text("x" + nf(mario.coinsCollected, 2, 0), 250, 55);
    text(levelId + "-1", 350, 55);
    text(levelDB.getTime(levelId) - (levelDB.currLevelTimeElasped/60), 440, 55);

    if (levelDB.getTime(levelId) - (levelDB.currLevelTimeElasped/60) <= 0) {
      state = 4;
    }
  }


  //this is the initial menu we see
  void mainMenu() {
    image(mainMenuBG, 0, 0, 500, 500);
    text("Remade by: Alex Rirak!", 250, 285);
    textSize(24);
    text("Press Enter to Begin!", 150, 400);
    text("Press C to enter level creator", 150, 430);
    textSize(14);
    if (keyPressed && key == ENTER) {
      state = 1;
      soundDB.playLevelOneTheme();
    } else if (keyPressed && key == 'c') {
      state = 6;

      //set the level to blank
      levelName = "creator";
      level = levelDB.getLevel(levelName);
    }
  }

  //the level creator menu
  void creatorMenu() {
    if (creatorMenuOn == true) {
      fill(0);
      rect(0, 0, width, 100);
      if (categoryMenu == true) {
        fill(208, 237, 247);
        switch (positionTracker) {
        case 1:
          rect(5, 5, 110, 80);
          break;
        case 2:
          rect(115, 5, 110, 80);
          break;
        }
        fill(255);
        rect(10, 10, 100, 70);
        rect(120, 10, 100, 70);
        fill(0);
        text("Background", 17, 40);
        text("Blocks", 35, 60);
        text("Collidable", 135, 40);
        text("Blocks", 145, 60);
      } else if (backGroundSubMenu == true) {
        fill(208, 237, 247);
        switch (positionTracker) {
        case 1: 
          rect(5, 5, 25, 25);
          break;
        case 2: 
          rect(35, 5, 25, 25);
          break;
        case 3: 
          rect(65, 5, 25, 25);
          break;
        case 4:
          rect(95, 5, 25, 25);
          break;
        case 5:
          rect(125, 5, 25, 25);
          break;
        case 6:
          rect(155, 5, 25, 25);
          break;
        case 7: 
          rect(185, 5, 25, 25);
          break;
        case 8: 
          rect(215, 5, 25, 25);
          break;
        case 9: 
          rect(245, 5, 25, 25);
          break;
        case 10: 
          rect(275, 5, 25, 25);
          break;
        case 11: 
          rect(305, 5, 25, 25);
          break;
        case 12: 
          rect(335, 5, 25, 25);
          break;
        case 13:
          rect(365, 5, 25, 25);
          break;
        case 14:
          rect(395, 5, 25, 25);
          break;
        }
        image(sky, 10, 10);
        image(green, 40, 10);
        image(black, 70, 10);
        image(bushFragment1, 100, 10);
        image(bushFragment2, 130, 10);
        image(bushFragment3, 160, 10);
        image(bushFragment4, 190, 10);
        image(bushFragment5, 220, 10);
        image(bushFragment6, 250, 10);
        image(hillFragment1, 280, 10);
        image(hillFragment2, 310, 10);
        image(hillFragment3, 340, 10);
        image(hillFragment4, 370, 10);
        image(hillFragment5, 400, 10);
      } else if (collidableObjectsSubMenu == true) {
        fill(208, 237, 247);
        switch (positionTracker) {
        case 1: 
          rect(5, 5, 25, 25);
          break;
        case 2: 
          rect(35, 5, 25, 25);
          break;
        case 3: 
          rect(65, 5, 25, 25);
          break;
        case 4:
          rect(95, 5, 25, 25);
          break;
        case 5:
          rect(125, 5, 25, 25);
          break;
        case 6:
          rect(155, 5, 25, 25);
          break;
        case 7: 
          rect(185, 5, 25, 25);
          break;
        case 8: 
          rect(215, 5, 25, 25);
          break;
        case 9: 
          rect(245, 5, 25, 25);
          break;
        case 10: 
          rect(275, 5, 25, 25);
          break;
        case 11: 
          rect(305, 5, 25, 25);
          break;
        case 12: 
          rect(335, 5, 25, 25);
          break;
        }
        image(groundBlockBrown, 10, 10);
        image(groundBlockWhite, 40, 10);
        image(groundBlockBlue, 70, 10);
        image(brickWallBrown1, 100, 10);
        image(brickWallBrown2, 130, 10);
        image(brickWallBrown3, 160, 10);
        image(brickWallBrown4, 190, 10);
        image(brickWallBrown5, 220, 10);
        image(brickWallBlue, 250, 10);
        image(obstacleBlockBrown, 280, 10);
        image(obstacleBlockBlue, 310, 10);
        image(questionBlock, 340, 10);
      }
    }
  }

  //display the you win screen
  void youWin() {
    background(0);
    fill(255);
    textSize(32);
    text("You Win!", 151, 239);
    textSize(14);
  }

  //reset the game over timer
  void youWinTimerReset() {
    this.youWinTimer = youWinTimerOrig;
  }
}

//this class represents the selectedElement
class selectedElement
{
// location
  float x, y;
  float speed = 3;
  
  selectedElement(float _x, float _y) {
    // store position
    x = _x;
    y = _y;
  }  
  
  void display() {
    int col = getCol();
    int row = getRow();
    noFill();
    stroke(0, 255, 0);
    rect(col*CELL_SIZE+X_OFFSET, row*CELL_SIZE, CELL_SIZE, CELL_SIZE);
    stroke(0, 0, 0);
    
    //for debug purposes
    if(locationFinder) {
      text("x:" + x + " y:" + y + " x - offset:" + (x - X_OFFSET),20,80);
    }
  }
  
  int getRow() {
    return int(int(y)/CELL_SIZE);
  }
  
  int getCol() {
    return int(int(x-X_OFFSET)/CELL_SIZE);
  }

  void move() {
    //only move when the creator menu is not displayed
    if(!creatorMenuOn) {
      // move right
      if (keyD) 
      {
        // are we at >= 50% of the width of the screen?
        if (x >= width/2)
        {
          // is there more level to the right of the character?
          int rt = getRightmostTileXLocation();  
    
          // move level to the right - just adjust the X_OFFSET and leave the selector
          if (rt > width)
          {
            X_OFFSET -= speed;
          }
    
          // otherwise just move the selector's x position
          else
          {
            x += speed;
          }
        }
      
        //selector is to the left of the midpoint of the screen - just move their x position
        else
        {
          x += speed;
        }
        
         //make sure we dont go too far
        if(getCol() + 3 > level[0].length) {
          x = 480;
        }
      }
      
      // left
      if (keyA) 
      { 
        // are we at <= 50% of the width of the screen?
        if (x <= width/2)
        {
          // is there more level to the left of the character?
          int rt = getLeftmostTileXLocation();  
          
          // move level to the left - just adjust the X_OFFSET and leave the character
          // where they are on the screen
          if (rt < 0)
          {
          X_OFFSET += speed;
          }
          
          // otherwise just move the character's x position
          else
          {
          x -= speed;
          }
        }
        
        // character is to the right of the midpoint of the screen - just move their x position
        else
        {
          x -= speed;
        }
        
        //make sure we dont go too far
        if(x < 0) {
          x = 0;
        }
      }
      
      // move up
      if (keyW) 
      {
          //simply move the selector up
          y -= speed;
          
          //if we go past 0 reset to 0
          if(y < 0) {
            y = 0;
          }
      }
      
      // move down
      if (keyS) 
      {
          //simply move the selector up
          y += speed;
          
          //if we go past 500 reset to 500
          if(y > 500) {
            y = 500;
          }
      }
    } 
  }

}

