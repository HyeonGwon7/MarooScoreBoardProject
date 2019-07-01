import processing.serial.*;
import java.util.*;

Serial port;
PFont teamNamefont;
PFont timeFont;
PImage backgroundImg;
PImage soccerBall;
String portval;

//DataRead
int datalength;
char goalCheck = '0';
char teamCheck = '0';

//GoalRecord
int redScore = 0;
int blueScore = 0;

//Timer
int min = 5;
int tenSec = 0;
int sec = 0;

boolean startAction = false;
boolean resetAction = false;
//
boolean secTimerCheck = true;
boolean tenTimerCheck = true;
boolean minTimerCheck = true;

//PauseCheck
boolean pauseCheck = false;

//Time Counter 
MinTimer minCounter; 
TenSecTimer tenSecCounter;
SecTimer secCounter;
Timer timer;

//DataReader datareader; 
int s;
int t;
int m;

int secUp = 0;
int tenUp = 0;

class Timer extends Thread {
  public void run() {
    while (true) {
      try {
        sleep(1000);
        sec= sec-1;

        if (sec==-1) {
          sec = 9;
          secUp = 1;
        }


        if (secUp==1) {
          tenSec--;
          secUp =0;
          if (tenSec == -1) {
            tenSec=5;
            tenUp = 1;
          }
        }

        if (tenUp == 1) {
          min--;
          tenUp = 0;
        }
      }
      catch(InterruptedException e) {
        print("timerStop");
        break;
      }
    }
  }
}


class MinTimer extends Thread {
  public void run() {
    while (true) {
      println(this.getState());
      try {
        if (min == 5 ) {
          sleep(1000);
          min=4;
        } else {
          sleep(60000);
          min--;
        }
      }
      catch(InterruptedException e) {
        print("Thread Error Min");     
        e.printStackTrace(); 
        break;
      }
    }
    println(this.getState());
  }
}

class TenSecTimer extends Thread {
  public void run() {
    while (true) {
      try {
        if (min == 5 ) {
          sleep(1000);
          tenSec =5;
        }
        sleep(10000);
        if (tenSec == 0) 
          tenSec = 5;
        else
          tenSec--;
      }
      catch(InterruptedException e) {
        print("Thread Error TenSec");
        break;
        //e.printStackTrace();
      }
    }
  }
}

class SecTimer extends Thread {
  public void run() {
    while (true) { 
      try { 
        sleep(1000);
        if (sec == 0) 
          sec = 9;
        else
          sec--;
      }
      catch(InterruptedException e) {
        print("Thread Error");
        break;
        //e.printStackTrace();
      }
    }
  }
}


void setup() {
  fullScreen();
  backgroundImg = loadImage("Backgroundimg.jpg");
  soccerBall= loadImage("soccerBall2.png");

  timeFont = createFont("EHSMB.TTF", 32);

  minCounter = new MinTimer();
  tenSecCounter = new TenSecTimer();
  secCounter = new SecTimer();
  timer = new Timer();

  fill(255);
  port = new Serial(this, "COM6", 9600);
}


void draw() {  
  image(backgroundImg, 0, 0, width, height); // backgroundimg
  noStroke();
  fill(0, 0, 0, 200);
  rect(200, 100, 1280, 710, 30); // background box

  dataReader();

  drawScoreBoard(250, 150, "Red Team");
  drawScoreBoard(1030, 150, "Blue Team");
  drawSoccerBall();
  drawTimeBox();
  drawSettingButton();
  drawTime(250, 150);
  drawScore();
}

void drawScoreBoard(int x, int y, String teamName) {
  teamNamefont = loadFont("Impact-48.vlw");
  textFont(teamNamefont, 85);
  //textSize(40);

  if (teamName=="Red Team") { 
    fill(211, 35, 25);
    //noStroke();
    stroke(255);
    strokeWeight(5);
    //   rect(x,y,400,150); // teamName Box
    quad(x, y, x+400, y, x+400, y+150, x, y+150);

    fill(255, 255, 255); // teamName color
    text(teamName, x+25, y+110); // teamName Text
  } else { 
    fill(32, 62, 244);
    //noStroke();
    stroke(255);
    strokeWeight(5);
    //rect(x,y,400,150); // teamName Box

    quad(x, y, x+400, y, x+400, y+150, x, y+150);
    fill(255, 255, 255); // teamName color
    text(teamName, x+13, y+110); // teamName Text
  }


  fill(47, 47, 47); // scorebox color
  stroke(255); // strokecolor
  strokeWeight(5);
  //quad(x,y+150,x+400,y+150,x+400,y+550,x,y+550);
  rect(x, y+150, 400, 400); // Score Box

  fill(189, 189, 189); // Score setting color
  rect(x, y+550, 400, 50); // Score setting Box

  strokeWeight(3);
  stroke(255);
  line(x+200, y+550, x+200, y+600); // ScoreButton Spliter

  noStroke();
  fill(0, 255, 0); // ScoreButton Color
  triangle(x+100, y+560, x+70, y+590, x+130, y+590); // Score Up Button
  triangle(x+300, y+590, x+270, y+560, x+330, y+560); // Score Down Button
}

void drawTimeBox() {
  fill(0);
  stroke(255);
  strokeWeight(4);
  rect(670, 330, 340, 200, 3);
}

void drawSoccerBall() {
  textSize(45);
  fill(255, 255, 255);
  image(soccerBall, 755, 100, 170, 170);
  text("Start", 790, 300);
  //stroke(255);
  // line(770,300,780+120,300); buttonWidthRange Check code
  // line(770,300,770,120); buttonHeightRange Check code
}

void drawSettingButton() {
  // Pause Button
  fill(242, 116, 19);
  noStroke();
  rect(670, 700, 160, 50, 7); 
  textSize(42);
  fill(255, 255, 255);
  text("Pause", 695, 740);

  //ReSect Button 
  fill(242, 116, 19);
  noStroke();
  rect(850, 700, 160, 50, 7);
  textSize(42);
  fill(255, 255, 255);
  text("Reset", 880, 740); 
  stroke(0);
  //line(850,700,1020,700);
}

void dataReader() {
  if (pauseCheck==false) {
    portval = port.readString();
    if (portval != null) {
      datalength = portval.length();
      println("Datalength : ", datalength);
      if (datalength == 11) {
        println("Data : ", portval);
        goalCheck = portval.charAt(datalength-4);
        println("goal : ", goalCheck);

        if (goalCheck == '1') {
          teamCheck = portval.charAt(datalength-6);

          if (teamCheck == '1') {
            timer.interrupt();
            pauseCheck=true;
            redScore=redScore+1;
          } else if (teamCheck == '2') {
            timer.interrupt();
            pauseCheck=true;
            blueScore=blueScore+1;
          }
        }
      }
    }
  }
  else{
   //println("didn't Read Data"); 
  }
}

void drawTime(int x, int y) {
  fill(78, 252, 237);
  smooth();
  textFont(timeFont, 170);
  text(min, 670, 500);
  textSize(150);
  text(":", 750, 500);
  textSize(170);
  text(tenSec, 805, 500);
  text(sec, 905, 500);
}

void drawScore() {
  fill(244, 171, 68);
  textFont(timeFont, 300);
  if (redScore < 10) {
    text(redScore, 355, 630);
  } else {
    text(redScore, 265, 630);
  }

  if (blueScore < 10) {
    text(blueScore, 1135, 630);
  } else {
    text(blueScore, 1045, 630);
  }
}

void mouseClicked() {

  //StartButton Action
  if (mouseX >= 770 && mouseX <= 900 && mouseY >=120 && mouseY <= 300) {  
    if (startAction==false) {    
      timer.start();
      startAction = true;
    }

    if ((resetAction == true || pauseCheck == true)) {
      if (resetAction ==true)
        resetAction = false;
      if (pauseCheck == true)
        pauseCheck = false;

      timer = new Timer();
      timer.start();
    }
  }

  //ResetButton Action
  if (mouseX >= 850 && mouseX <= 1010 && mouseY >=700 && mouseY <= 750) {
    if (startAction==true) {
      resetAction = true;
      //startAction = false;

      redScore=0;
      blueScore=0;
      min=5;
      tenSec=0;
      sec=0;

      timer.interrupt();
    }
  }
  //PauseButton Action
  if (mouseX >= 670 && mouseX <= 830 && mouseY >=700 && mouseY <= 750) {
    pauseCheck = true;
    timer.interrupt();
  }
}


void printSec() {
  println("min sec : ", min, " TenSec : ", tenSec, " Sec : ", sec);
}
