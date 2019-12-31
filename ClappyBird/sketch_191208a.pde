/* CS276 - Final Project
 FlappyBird, but it moves based on CLAPS!
 Eddie Chan & JuHoon Park */

import processing.video.*;
import ddf.minim.*;

Minim minim;
AudioInput in;

// GWindow Screen;
Capture video;
PImage face;

float clapLevel = 0.7;  // How loud is a clap
float threshold = 0.25; // How quiet is silence
boolean clapping = false;

bird b = new bird();
pillar[] p = new pillar[3];

boolean pictureTaken = false;
boolean end = false;
boolean start = false;
int score = 0;

PImage img;

void setup() {
  // Size for flappy bird canvas = 500, 800
  size(1140, 800);
  video = new Capture(this, 640, 480, 30);
  video.start();                                          
  for (int i = 0; i<3; i++) {
    p[i]=new pillar(i);
  }

  minim = new Minim(this);
  minim.debugOn();

  // connect to the builtin iMac microphone
  in = minim.getLineIn(Minim.MONO, 512);
}

void draw() {
  // Get the overall volume level (between 0 and 1.0)
  // scaled by 1000 (because volume isn't what it used to be!)
  float vol = in.mix.level() * 200;
  println(vol);

  if (video.available()) {
    video.read();
    println("Camera working");
    image(video, 500, 0);
    start = true;
  }
  
  if (pictureTaken == true) {
    fill(0);
    rect(500, 0, 640, 480);
    fill(255);
    text("Picture has been taken!",  660, 250);
  }

  // Draw the Sky
  fill(138, 210, 255);
  rect(0, 0, 500, 600);
  // Draw the Grass
  fill(124, 252, 0);
  rect(0, 600, 500, 200);
  // Draw the Menu
  fill(0);
  rect(500, 480, 640, 500);
  fill(255);
  text("Welcome to 'Clap'py Bird!", 620, 600);
  textSize(20);
  text("Get it? It's like Flappy Bird, but you clap!", 620, 700);

  // Graph the overall volume
  // First draw a background strip (a left bar)
  fill(200);
  rect(500, 0, 20, 800);

  // Then draw a rectangle size according to volume
  fill(100);
  rect(500, height-vol*800/2, 20, vol*800/2); 

  if (end) {
    b.move();
  } 
  b.drawBird();
  if (end) {
    b.drag();
  } 
  b.checkCollisions();

  if (vol > clapLevel) { 
    if (end == true) {
      b.jump();
      start=false;
    }
  }

  for (int i = 0; i<3; i++) {
    p[i].drawPillar();
    p[i].checkPosition();
  }

  fill(0);
  stroke(255);
  textSize(32);
  if (end) {
    rect(20, 20, 100, 50);
    fill(255);
    text(score, 30, 58);
  } else {
    rect(150, 100, 200, 50);
    rect(150, 200, 200, 50);
    fill(255); 
    if (start) {
      text("'Clap'py Bird", 155, 140);
      text("Click to Play", 155, 240);
    } else {
      text("Game Over", 170, 140);
      text("Score:", 180, 240);
      text(score, 280, 240);
    }
  }
}

class bird {
  float xPos, yPos, ySpeed;
  bird() {
    xPos = 250;
    yPos = 400;
  }

  void drawBird() {
    stroke(255);
    noFill();
    strokeWeight(2);
    img = loadImage("data/face.jpg");
    image(img, xPos, yPos, 20, 20);
    //rect(xPos, yPos, 20, 20);
  }

  void jump() {
    ySpeed=-10;
  }

  void drag() {
    ySpeed+=0.4;
  }

  void move() {
    yPos+=ySpeed; 
    for (int i = 0; i<3; i++) {
      p[i].xPos-=3;
    }
  }

  void checkCollisions() {
    if (yPos>600) {
      end=false;
    }

    for (int i = 0; i<3; i++) {
      if ((xPos<p[i].xPos+10&&xPos>p[i].xPos-10)&&(yPos<p[i].opening-100||yPos>p[i].opening+100)) {
        end=false;
      }
    }
  }
}

class pillar {
  float xPos, opening;
  boolean cashed = false;
  pillar(int i) {
    xPos = 100+(i*200);
    opening = random(400)+100;
  }

  void drawPillar() {
    line(xPos, 0, xPos, opening-100);  
    line(xPos, opening+100, xPos, 600);
  }

  void checkPosition() {
    if (xPos<0) {
      xPos+=(200*3);
      opening = random(400)+100;
      cashed=false;
    } 
    if (xPos<250&&cashed==false) {
      cashed=true;
      score++;
    }
  }
}

void reset() {
  end=true;
  score=0;
  b.yPos=400;
  for (int i = 0; i<3; i++) {
    p[i].xPos+=550;
    p[i].cashed = false;
  }
}

void mousePressed() {
  video.stop();
  video.read();
  PImage cp = video.get();
  cp.save("data/face.jpg"); 
  pictureTaken = true;
}

void keyPressed() {
  b.jump(); 
  start=false;
  if (end==false) {
    reset();
  }
}

void stop() {
  in.close();
  minim.stop();
  super.stop();
}
