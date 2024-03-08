/* @pjs preload="marioleft.png", "marioright.png", "0.png","1.png","2.png","3.png","4.png","5.png","6.png","7.png","8.png","9.png","10.png","11.png","12.png","13.png","14.png","15.png","16.png","17.png","18.png","19.png","20.png","21.png","22.png","23.png","24.png","25.png","26.png","27.png","28.png","29.png","30.png","31.png","32.png","33.png","34.png","35.png","36.png","37.png","38.png","39.png","40.png","41.png","42.png","43.png","44.png","45.png","46.png","47.png","48.png","49.png","50.png","51.png","52.png","53.png"; */
// key flags
boolean keyA = false;
boolean keyS = false;
boolean keyD = false;
boolean keyW = false;

// an Array to hold all of our tiles
PImage[] tiles = new PImage[54];

// how big is each cell (pick a standard size)
int CELL_SIZE = 30;

// how far along in the world is the player? this will "shift" the map
// left and right
int X_OFFSET = 0;

// player object
Player mario;

//levelDB object
levelDB levelDB = new levelDB();

// define our level using our tiles (note that the numbers here 
// indicate which image file should appear at a particular spot on the grid)
int[][] level = levelDB.getLevel1();

void setup()
{
  size(500, 500);

  // load in our tiles
  levelDB.loadTiles(tiles);

  // create our player
  mario = new Player(0, 390);
}



void draw()
{
  // draw the level
  levelDB.drawLevel(tiles);

  // move our player
  mario.move();

  // draw our player
  mario.display();
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
    return 0;
  }
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

      // debugging ellipse (to show the point that we are checking)
      ellipse(x + CELL_SIZE + 3, y+CELL_SIZE/2, 10, 10);

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
        
        fill(255);
        text("Tile to the right of mario is NOT SOLID.", 20, 60);
      } else
      {
        fill(255);
        text("Tile to the right of mario is SOLID.", 20, 60);
      }
    }

    // left
    if (keyA) 
    { 
      //change the artwork
      artwork = marioLeft;
      
      // we need to check to see what tile is to our left (by 3 pixels or so)
      int tileCode = getTileCode(x - 3, y + CELL_SIZE/2);

      // debugging ellipse
      ellipse(x-3, y+CELL_SIZE/2, 10, 10);

      // is this a solid tile?  if so, don't allow us to move!
      if ( !isSolid(tileCode) )
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

        fill(255);
        text("Tile to the left of mario is NOT SOLID.", 20, 40);
      } else
      {
        fill(255);
        text("Tile to the left of mario is SOLID.", 20, 40);
      }
    }


    // jump
    if (keyW) { 
      
      // we need to check to see what tile is to our top (by 3 pixels or so)
      int tileCode = getTileCode(x + CELL_SIZE/2, y-3);
      
      // debugging ellipse
      ellipse(x+CELL_SIZE/2, y-3, 10, 10);

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
    
    // debugging ellipse
    ellipse(x+CELL_SIZE/2, y-3, 10, 10);

    // is this a solid tile?  if so, stop the jump and enable gravity!
    if ( isSolid(tileCodeUP) ) {
      // apply jump power (bring us back down)
      jumpPower = -0.5;
    }
    
    y -= jumpPower;

    // always pull down the character (gravity) if we aren't on solid land
    int downTileCode = getTileCode(x + CELL_SIZE/2, y + CELL_SIZE+3);

    // debugging ellipse
    ellipse(x+CELL_SIZE/2, y+CELL_SIZE+3, 10, 10);

    if (isSolid( downTileCode))
    {
      jumpPower = 0;
      fill(255);
      text("Tile below mario is SOLID. jumpPower=" + jumpPower, 20, 20);
    } else {
      
      //if character has fell off the level, restart at the beginning
      if(y > 450) {
        x = origX;
        y = origY;
        X_OFFSET = 0;
      }
      jumpPower -= 0.2;
      fill(255);
      text("Tile below mario is NOT SOLID. jumpPower=" + jumpPower, 20, 20);
    }
  }


  // draw the player
  void display()
  {
    image(artwork, x, y, CELL_SIZE, CELL_SIZE);
  }
  
}

class levelDB {
  int[][] getLevel1() {
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
        image( tiles[ level[row][col] ], col*CELL_SIZE+X_OFFSET, row*CELL_SIZE, CELL_SIZE, CELL_SIZE);
      }
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
}

