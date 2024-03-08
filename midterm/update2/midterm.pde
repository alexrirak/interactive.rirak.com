/* @pjs preload="marioleft.png", "marioright.png", "goombaLeft.png", "goombaRight.png", "0.png","1.png","2.png","3.png","4.png","5.png","6.png","7.png","8.png","9.png","10.png","11.png","12.png","13.png","14.png","15.png","16.png","17.png","18.png","19.png","20.png","21.png","22.png","23.png","24.png","25.png","26.png","27.png","28.png","29.png","30.png","31.png","32.png","33.png","34.png","35.png","36.png","37.png","38.png","39.png","40.png","41.png","42.png","43.png","44.png","45.png","46.png","47.png","48.png","49.png","50.png","51.png","52.png","53.png","54.png","55.png"; */
// key flags
boolean keyA = false;
boolean keyS = false;
boolean keyD = false;
boolean keyW = false;

// an Array to hold all of our tiles
PImage[] tiles = new PImage[56];

// how big is each cell (pick a standard size)
int CELL_SIZE = 30;

// how far along in the world is the player? this will "shift" the map
// left and right
int X_OFFSET = 0;

// player object
Player mario;

//levelDB object
levelDB levelDB = new levelDB();

//levelDB object
menuDB menuDB = new menuDB();

//state
//0 - main menu
//1 - in game
//2 - game over
//3 - died
//4 - time out
int state = 1;

//debug
boolean debug = true;
boolean locationFinder = true;

Goomba[] goombas = new Goomba[4];

// define our level using our tiles (note that the numbers here 
// indicate which image file should appear at a particular spot on the grid)
int levelId = 1;
int[][] level = levelDB.getLevel(levelId);

void setup()
{
  size(500, 500);

  // load in our tiles
  levelDB.loadTiles(tiles);

  // create our player
  mario = new Player(0, 390);
  
  //create out goombas
  goombas[0] = new Goomba(640, 400);
  goombas[1] = new Goomba(1345, 400);
  goombas[2] = new Goomba(1640, 400);
  goombas[3] = new Goomba(1670, 400);
}



void draw()
{
  if(state == 0) {
      //show main menu
  
  } else if(state == 1) {
    
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
    for(int i = 0; i < goombas.length; i++) {
      goombas[i].move();
      goombas[i].display();
    }
    
  } else if(state == 2) {
    //show game over screen
    menuDB.gameOver();
    if(menuDB.gameOverTimer > 0){
      menuDB.gameOverTimer--;
    }
    else {
      menuDB.gameOverTimerReset();
      levelDB.resetGame();
    }
  } else if(state == 3) {
    //show died screen
    menuDB.died();
    if(menuDB.diedTimer > 0){
      menuDB.diedTimer--;
    }
    else {
      menuDB.diedTimerReset();
      state  = 1;
    }
  } else if(state == 4) {
    //show died screen
    menuDB.timeUp();
    if(menuDB.timeUpTimer > 0){
      menuDB.timeUpTimer--;
    } else {
      menuDB.timeUpTimerReset();
      levelDB.resetGame();
    }
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
  if(nonSolidTiles.contains(tileCode))
  //if (tileCode in nonSolidTiles)
  {
    return false;
  } 
  
  else
  {
    return true;
  }
}

boolean isSolid(int tileCode, boolean isEnemy)
{
  ArrayList<Integer> nonSolidTiles = levelDB.getNonSolidList(isEnemy);
  if(nonSolidTiles.contains(tileCode))
  //if (tileCode in nonSolidTiles)
  {
    return false;
  } 
  
  else
  {
    return true;
  }
}



// handle multiple key presses
void keyPressed()
{
  if (key == 'a') { keyA = true; }  
  if (key == 's') { keyS = true; }  
  if (key == 'd') { keyD = true; }  
  if (key == 'w') { keyW = true; }    
}

void keyReleased()
{
  if (key == 'a') { keyA = false; }  
  if (key == 's') { keyS = false; }  
  if (key == 'd') { keyD = false; }  
  if (key == 'w') { keyW = false; }    
}

class Goomba
{
  // artwork
  PImage artwork;
  PImage goombaRight;
  PImage goombaLeft;

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
    artwork = goombaLeft;
  }  
  
    void move() {
    //only move if on screen
    if(x + CELL_SIZE > 0 && x < 500) {
      if (moveDirection == "right") 
      {
        //change the artwork
        artwork = goombaRight;
        
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
        //change the artwork
        artwork = goombaLeft;
        
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
      
      //if the tile below the goomba is not solid pull it down
      if (isSolid( downTileCode))
      {
        gravity = 0;
      } else {
        gravity -= 0.2;
      }
   }
   else {

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
}
class Player
{
  // artwork
  PImage artwork;
  PImage marioRight;
  PImage marioLeft;

  // location
  float x, y, origX, origY;

  // speed (constant)
  float speed = 3;

  // jump power
  float jumpPower = 0;
  
  //lives
  int livesOrig = 3;
  int lives = livesOrig;
  
  //check if moving
  boolean isMoving = false;

  Player(float _x, float _y)
  {
    // store position
    x = origX = _x;
    y = origY = _y;

    // load artwork
    marioRight = loadImage("marioright.png");
    marioLeft = loadImage("marioleft.png");
    artwork = marioRight;
  }  

  void move()
  {
    // move right
    if (keyD) 
    {
      //change the artwork
      artwork = marioRight;
      
      // we need to check to see what tile is to our right (by 3 pixels or so)
      int tileCode = getTileCode(x + CELL_SIZE + 3, y + CELL_SIZE/2);

      if(debug){
        // debugging ellipse (to show the point that we are checking)
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
            //also adjust the locatoin of our goombas so they remain where they were relative to the bg
            for(int i = 0; i < goombas.length; i++) {
              goombas[i].x -= speed;
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
    }

    // left
    if (keyA) 
    { 
      //change the artwork
      artwork = marioLeft;
      
      // we need to check to see what tile is to our left (by 3 pixels or so)
      int tileCode = getTileCode(x - 3, y + CELL_SIZE/2);

      if(debug){
        // debugging ellipse
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
            
            //also adjust the locatoin of our goombas so they remain where they were relative to the bg
            for(int i = 0; i < goombas.length; i++) {
              goombas[i].x += speed;
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
          jumpPower = 7;
        }
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

    if(debug){
      // debugging ellipse
      ellipse(x+CELL_SIZE/2, y+CELL_SIZE+3, 10, 10);
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
      if(y > 450) {
        lives--;
        if (lives > 0) {
          //died but still have lives
          resetPlayer();
          levelDB.resetGoombas();
          state = 3;
        } else if (lives <= 0) {
          //game over
          state = 2;
        }
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
  }

  // draw the player
  void display() {
    image(artwork, x, y, CELL_SIZE, CELL_SIZE);
    //for debug purposes
    if(locationFinder) {
      text("x:" + x + " y:" + y + " x - offset:" + (x - X_OFFSET),20,80);
    }
  }
  
  //reset lives
  void resetLives() {
    this.lives = livesOrig;
  }
  
}

class levelDB {
  
  int currLevelTimeElasped;
  
  int[][] getLevel(int levelId) {
    int[][] level = {
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 26, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 19, 27, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 28, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 49, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 40, 40, 40, 40, 40, 40, 40, 40, 12, 12, 12, 40, 40, 40, 49, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 49, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 40, 40, 40, 12, 12, 12, 12, 40, 49, 49, 40, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 12, 12, 12, 12, 12, 12, 12, 12, 28, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 12, 12, 12, 12, 12, 12, 12, 12, 28, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 18, 12, 12, 12, 12, 12, 12, 12, 12, 28, 12, 12, 12, 12, 12, 12, 12, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 18, 18, 12, 12, 12, 12, 12, 12, 12, 12, 28, 12, 12, 12, 12, 04, 04, 04, 12 },
                  { 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 49, 12, 12, 12, 40, 49, 40, 49, 40, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 02, 10, 12, 12, 12, 12, 12, 12, 12, 12, 12, 02, 10, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 40, 49, 40, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 40, 12, 12, 12, 12, 12, 40, 40, 12, 12, 12, 12, 49, 12, 12, 49, 12, 12, 49, 12, 12, 12, 12, 12, 40, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 40, 40, 12, 12, 12, 12, 12, 12, 18, 12, 12, 18, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 12, 12, 18, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 40, 40, 49, 40, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 18, 18, 18, 12, 12, 12, 12, 12, 12, 12, 12, 28, 12, 12, 12, 12, 05, 20, 21, 12 },
                  { 12, 12, 15, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 02, 10, 12, 12, 12, 12, 12, 12, 03, 11, 12, 12, 15, 12, 12, 12, 12, 12, 12, 03, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 15, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 12, 12, 18, 18, 12, 12, 12, 12, 15, 12, 12, 12, 18, 18, 18, 12, 12, 18, 18, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 18, 18, 18, 18, 12, 12, 12, 12, 15, 12, 12, 12, 28, 12, 12, 12, 04, 22, 22, 22, 04 },
                  { 12, 01,  9, 17, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 15, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 02, 10, 12, 12, 12, 12, 12, 12, 12, 12, 03, 11, 12, 12, 12, 12, 12, 12, 03, 11, 12, 01,  9, 17, 12, 12, 12, 12, 12, 03, 11, 12, 12, 12, 12, 12, 12, 15, 12, 12, 12, 12, 12, 12, 15, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 01,  9, 17, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 15, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 12, 12, 18, 18, 18, 12, 12, 01,  9, 17, 12, 18, 18, 18, 18, 12, 12, 18, 18, 18, 12, 12, 12, 15, 12, 02, 10, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 02, 10, 12, 18, 18, 18, 18, 18, 18, 18, 18, 12, 12, 12, 01,  9, 17, 12, 12, 28, 12, 12, 12, 20, 20, 13, 20, 20 },
                  { 01,  9, 53,  9, 17, 12, 12, 12, 12, 12, 12, 50, 51, 51, 51, 52, 01,  9, 17, 12, 12, 12, 12, 50, 51, 52, 12, 12, 03, 11, 12, 12, 12, 12, 12, 12, 12, 12, 03, 11, 12, 12, 12, 12, 12, 12, 03, 11, 01,  9, 53,  9, 17, 12, 12, 12, 12, 03, 11, 50, 51, 51, 51, 52, 01,  9, 17, 12, 12, 12, 12, 01,  9, 17, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 50, 51, 51, 52, 12, 12, 12, 01,  9, 53,  9, 17, 12, 12, 12, 12, 12, 12, 50, 51, 51, 51, 52, 01,  9, 17, 12, 12, 12, 12, 50, 51, 52, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 18, 18, 18, 18, 51, 51, 18, 18, 18, 18, 01,  9, 53,  9, 18, 18, 18, 18, 18, 12, 12, 18, 18, 18, 18, 52, 01,  9, 17, 03, 11, 12, 12, 50, 51, 52, 12, 12, 12, 12, 12, 12, 12, 12, 12, 03, 11, 18, 18, 18, 18, 18, 18, 18, 18, 18, 12, 12, 01,  9, 53,  9, 17, 12, 18, 12, 12, 12, 20, 20, 14, 20, 20 },
                  { 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 12, 12, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 12, 12, 12, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 12, 12, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00 },
                  { 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 12, 12, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 12, 12, 12, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 12, 12, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00 }
                };
      return level;
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
  
  //resets the level
  void resetGame() {
    levelId = 1;
    state  = 1;
    levelDB.currLevelTimeElasped = 0;
    mario.resetLives();
    mario.resetPlayer();
    resetGoombas();
    
  }
  
  //resets all the goombas to their original positions
  void resetGoombas() {
     //reset all the goombas
    for(int i = 0; i < goombas.length; i++) {
      goombas[i].resetGoomba();
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
  
  PImage animate49() {
    int levelTimer = levelDB.currLevelTimeElasped/5;
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
}
class menuDB {
  
  int gameOverTimerOrig = 120;
  int gameOverTimer = gameOverTimerOrig;
  
  int diedTimerOrig = 120;
  int diedTimer = gameOverTimerOrig;
  
  int timeUpTimerOrig = 120;
  int timeUpTimer = timeUpTimerOrig;
    
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
    
    text("000000", 40, 55);
    text(levelId + "-1", 350, 55);
    text(levelDB.getTime(levelId) - (levelDB.currLevelTimeElasped/60), 440, 55);
    
    if(levelDB.getTime(levelId) - (levelDB.currLevelTimeElasped/60) <= 0) {
      state = 4;
    }
  }
  
  
  
}

