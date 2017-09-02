// Luke Dickerson
// Sept. 1st, 2017



////////////// VARIABLES ////////////////////////////

// Player Variables
PlayerSegment head, tail;
ArrayList<PlayerSegment> player;
String playerDirection = "UP";
boolean dead = true;

// Food Variables
Food food;
int nextRainbowColor;

// Map Variables
int gridWidth = 20; // number of squares wide
int gridHeight = 20; // number of squares tall
int squareWidth, squareHeight;

// Miscellaneous Variables
boolean paused = false, allowedToChangeDirection = true;
int timer;
int startingFramerate = 400;
int framerate = startingFramerate; // in milliseconds
boolean won = false;
int winTime;
int winDisplayDuration = 2500; // milliseconds


/////////////////////////////////////////////////////

void setup() {
  size(400, 400);
  reset();
  squareWidth = width / gridWidth;
  squareHeight = height / gridHeight;
  timer = 0;
  food = new Food();
}


void draw() {
  if (!dead) {
    if (!paused) { 
      if (millis() - timer >= framerate) {
      
        allowedToChangeDirection = true;
        background(0);
        movePlayer();
        dead = hitWall() || hitSelf();
        if (!dead) {
          if (beatGame()) {
             dead = true;
             won = true;
             winTime = millis();
          } else {
            drawPlayer();
            eatFood();
            food.drawFood();     
          }
        } else {
          reset(); 
        }
        
        timer = millis();
        if (player.size() < 35) {
          framerate = startingFramerate - 10*player.size();          
        } else { framerate = startingFramerate - 350; }

        
      }
    } else {
      textSize(10);
      fill(255);
      text("Paused", 10, 30); 
    }
  } else {
    background(0);
    textSize(17);
    fill(255);
    if (won) {
      if (millis() - winTime < winDisplayDuration) {
        text("YOU WON!",20, 40);
      } else {
        won = false; 
      }
    } else {
      text("Press Spacebar to Play\n\nMove with Arrow Keys\nPause/Resume with Spacebar",
       20, 40); 
    }
  }
}

boolean beatGame() {
  return player.size() == width * height;
}

void drawPlayer() {
  for (PlayerSegment ps : player) {
    ps.drawSegment(); 
  }
}

class PlayerSegment {
 
  int x, y;
  PlayerSegment ahead; // the segment ahead of this one (head's ahead = null)
  int m = 1;
  color c;
  
  PlayerSegment(int psx, int psy, PlayerSegment ah, color pc) {
    x = psx;
    y = psy;
    ahead = ah;
    c = pc;
  }
  
  void drawSegment() {
    fill(c);
    rect(x + m, y + m, squareWidth - 2*m, squareHeight - 2*m);
  }
  
  void moveSegment(int nx, int ny) { x = nx; y = ny; }
  PlayerSegment getAhead() { return ahead; }
  void setAhead(PlayerSegment newAhead) { ahead = newAhead; }
  int getX() { return x; }
  int getY() { return y; }
  color getColor() { return c; }
  
}

// puts the last segment of the player at the front of the head of the player
void movePlayer() {
  
  int newHeadX = head.getX();
  int newHeadY = head.getY();
  
       if (playerDirection == "UP")    { newHeadY -= squareHeight; }
  else if (playerDirection == "DOWN")  { newHeadY += squareHeight; }
  else if (playerDirection == "LEFT")  { newHeadX -= squareWidth;  }
  else if (playerDirection == "RIGHT") { newHeadX += squareWidth;  }
  
  tail.moveSegment(newHeadX, newHeadY);
  
  if (player.size() > 1) {
    PlayerSegment newTail = tail.getAhead();
    tail.setAhead(null);
    head.setAhead(tail);
    head = tail;
    tail = newTail;
  }
}

boolean hitWall() { 
  return head.getX() < 0 || head.getX() >= width ||
         head.getY() < 0 || head.getY() >= height;
}

boolean hitSelf() {
  for (PlayerSegment ps : player) {
    if (ps != head) {
      if (ps.getX() == head.getX() && ps.getY() == head.getY()) {
        return true;
      }
    }
  }
  return false;
}

void reset() {
  nextRainbowColor = 0;
  head = new PlayerSegment(width / 2, height / 2, null, rainbowColor());
  tail = head;
  player = new ArrayList<PlayerSegment>();
  player.add(head);
}

boolean locationOccupied(int x, int y) {
  for (PlayerSegment ps : player) {
    if (ps.getX() == x && ps.getY() == y) {
      return true;
    }
  }
  return false;
}

class Food {
 
  int x, y, m;
  color c;
  
  Food() {
    x = 0;
    y = 0;
    m = 2;
    newPosition();
  }
  
  void newPosition() {
    int oldX = x, oldY = y;
    int newX, newY, rx, ry;
    boolean squareOccupied;
    
    // change position
    while (x == oldX && y == oldY) {
       rx = (int)random(width);      ry = (int)random(height);
       newX = rx - rx % squareWidth; newY = ry - ry % squareHeight;
       
       squareOccupied = false;
       for (PlayerSegment ps : player) {
         if (newX == ps.getX() && newY == ps.getY()) {
           squareOccupied = true;
           break;
         }
       }
       if (!squareOccupied) {
         x = newX;
         y = newY;
       }
       
    }
    // change color
    c = rainbowColor();
  }
  
  void drawFood() {
    fill(c);
    ellipse(x + squareWidth/2, y + squareHeight/2, squareWidth - 2*m, squareHeight - 2*m); 
  }
  
  int getX() { return x; }
  int getY() { return y; }
  color getColor() {return c; }
}

void eatFood() {
  if (head.getX() == food.getX() && head.getY() == food.getY()) {
    
    // add a playerSegment to the player's tail
    int tx = tail.getX(), ty = tail.getY();
    int ntx = 0, nty = 0;
    if (player.size() > 1) {
    
      int ahx = tail.getAhead().getX(), ahy = tail.getAhead().getY();
      
      // if tail's ahead is above the tail, put the new tail under the current tail
           if (tx == ahx && ty > ahy) { ntx = tx;               nty = ty + squareHeight; }
      // if tail's ahead is below the tail, put the new tail above the current tail
      else if (tx == ahx && ty < ahy) { ntx = tx;               nty = ty - squareHeight; }
      // if tail's ahead is to the left of the tail, put the new tail to the right of the current tail
      else if (tx < ahx && ty == ahy) { ntx = tx + squareWidth; nty = ty;                }
      // if tail's ahead is to the right of the tail, put the new tail to the left of the current tail
      else if (tx > ahx && ty == ahy) { ntx = tx - squareWidth; nty = ty;                }
      
      // if the location of the newTail is occupied
      if (locationOccupied(ntx, nty)) {
        // find a position that is unoccupied, and put it there instead
             if (!locationOccupied(tx, ty + squareHeight)) { ntx = tx;               nty = ty + squareHeight; }
        else if (!locationOccupied(tx, ty - squareHeight)) { ntx = tx;               nty = ty - squareHeight; }
        else if (!locationOccupied(tx + squareWidth, ty))  { ntx = tx + squareWidth; nty = ty;                }
        else if (!locationOccupied(tx - squareWidth, ty))  { ntx = tx - squareWidth; nty = ty;                }
      }
    
    } else {
      
           if (playerDirection == "UP")    { ntx = tx;               nty = ty + squareHeight; }
      else if (playerDirection == "DOWN")  { ntx = tx;               nty = ty - squareHeight; }
      else if (playerDirection == "LEFT")  { ntx = tx + squareWidth; nty = ty;                }
      else if (playerDirection == "RIGHT") { ntx = tx - squareWidth; nty = ty;                }
      
    }
    
    PlayerSegment newTail = new PlayerSegment(ntx, nty, tail, food.getColor());
    player.add(newTail);
    tail = newTail;
  
    food.newPosition();
  }
}

color randomColor() {
   int numColors = 6, rc = (int)random(numColors);
   switch (rc) {
     case 0:  return color(255, 0,   0  ); // red
     case 1:  return color(255, 127, 0  ); // orange
     case 2:  return color(255, 255, 0  ); // yellow
     case 3:  return color(0,   255, 0  ); // green
     case 4:  return color(0,   0,   255); // blue
     case 5:  return color(148, 0,   211); // violet
     default: return color(255, 255, 255); // white
   }
}

color rainbowColor() {
  nextRainbowColor++;
  if (nextRainbowColor > 5) { nextRainbowColor = 0; }
  switch (nextRainbowColor) {
     case 0:  return color(255, 0,   0  ); // red
     case 1:  return color(255, 127, 0  ); // orange
     case 2:  return color(255, 255, 0  ); // yellow
     case 3:  return color(0,   255, 0  ); // green
     case 4:  return color(0,   0,   255); // blue
     case 5:  return color(148, 0,   211); // violet
     default: return color(255, 255, 255); // white
   }
}


void keyPressed() {
  if (key == CODED) {
         if (keyCode == UP    && playerDirection != "DOWN"  && allowedToChangeDirection) { playerDirection = "UP";    allowedToChangeDirection = false; }
    else if (keyCode == DOWN  && playerDirection != "UP"    && allowedToChangeDirection) { playerDirection = "DOWN";  allowedToChangeDirection = false; }
    else if (keyCode == LEFT  && playerDirection != "RIGHT" && allowedToChangeDirection) { playerDirection = "LEFT";  allowedToChangeDirection = false; }
    else if (keyCode == RIGHT && playerDirection != "LEFT"  && allowedToChangeDirection) { playerDirection = "RIGHT"; allowedToChangeDirection = false; }
  
  } else {
    if (key == ' ') {
      if (dead) {
        dead = false;
      } else { 
        paused = !paused;
      }
    }
  }
}