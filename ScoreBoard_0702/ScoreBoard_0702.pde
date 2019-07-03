import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import processing.serial.*;
import java.util.*;

Serial port;
Serial buttonPort;
PFont teamNamefont;
PFont timeFont;
PImage backgroundImg;
PImage soccerBall;
String portval;
char buttonPortval;
//DataRead
int datalength;
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
boolean pauseCheck = true;
boolean endCheck = false;

//
boolean secTimerCheck = true;
boolean tenTimerCheck = true;
boolean minTimerCheck = true;


//Time Counter 
Timer timer;

//XBox Controller 
ControlIO control;
ControlDevice device;
ControlButton button;


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
        println("timerStop");
        break;
      }
    }
  }
}

void setup() {
  fullScreen();
  backgroundImg = loadImage("Backgroundimg.jpg");
  soccerBall= loadImage("soccerBall2.png");
  timeFont = createFont("EHSMB.TTF", 32);
  fill(255);
  //  buttonPort = new Serial(this,"COM5",9600);
}


void draw() {  
  image(backgroundImg, 0, 0, width, height); // backgroundimg
  noStroke();
  fill(0, 0, 0, 200);
  rect(200, 100, 1280, 710, 30); // background box

  drawScoreBoard(250, 150, "Red Team");
  drawScoreBoard(1030, 150, "Blue Team");
  drawSoccerBall();
  drawTimeBox();
  drawSettingButton();
  drawTime(250, 150);
  dataReader();
  drawScore();
  terminate();
  //buttonReader();
}

void terminate() {
  if (min == 0 && tenSec == 0 && sec==0 && startAction==true) {
    timer.interrupt();
    pauseCheck = true;
    port.stop();
    endCheck = true;
  }
}


void drawScoreBoard(int x, int y, String teamName) {
  teamNamefont = loadFont("Impact-48.vlw");
  textFont(teamNamefont, 85);

  if (teamName=="Red Team") { 
    fill(211, 35, 25);

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
  if (mouseX >= 770 && mouseX <= 900 && mouseY >=120 && mouseY <= 300) {
    image(soccerBall, 735, 90, 200, 200);
    textSize(47);
    text("Start", 785, 320);
  } else {
    image(soccerBall, 755, 100, 170, 170);
    text("Start", 790, 300);
  }
}

void drawSettingButton() {
  // Pause Button
  if (mouseX >= 670 && mouseX <= 830 && mouseY >=700 && mouseY <= 750) {
    fill(242, 116, 19);
    noStroke();
    //quad(665, 690, 835, 690, 835, 760, 665, 760);
    rect(660, 695, 180, 60, 7); 
    textSize(47);
    fill(255, 255, 255);
    text("Pause", 693, 742);
  } else {
    fill(242, 116, 19);
    noStroke();
    rect(670, 700, 160, 50, 7); 
    textSize(42);
    fill(255, 255, 255);
    text("Pause", 695, 740);
  }

  //ReSect Button
  if (mouseX >= 850 && mouseX <= 1010 && mouseY >=700 && mouseY <= 750) {
    fill(242, 116, 19);
    noStroke();
    rect(840, 695, 180, 60, 7);
    textSize(47);
    fill(255, 255, 255);
    text("Reset", 875, 742); 
    stroke(0);
  } else { 
    fill(242, 116, 19);
    noStroke();
    rect(850, 700, 160, 50, 7);
    textSize(42);
    fill(255, 255, 255);
    text("Reset", 878, 740); 
    stroke(0);
  }
}

void dataReader() {
  if (pauseCheck==false) {
    portval = port.readString();
    if (portval != null) {
      datalength = portval.length();
      println("Datalength : ", datalength);
      println("Data : ", portval);

      teamCheck = portval.charAt(0);
      if (teamCheck == '1') { 
        pauseCheck=true;
        startAction=false;
        redScore=redScore+1;
        port.stop();
        timer.interrupt();
      } else if (teamCheck == '2') {
        pauseCheck=true;
        startAction=false;
        blueScore=blueScore+1;
        timer.interrupt();
        port.stop();
      }
    }
  } else {
    //println("didn't Read Data");
  }
}

void drawTime(int x, int y) {
  if (endCheck==false) {
    fill(78, 252, 237);
    smooth();
    textFont(timeFont, 170);
    text(min, 670, 500);
    textSize(150);
    text(":", 750, 500);
    textSize(170);
    text(tenSec, 805, 500);
    text(sec, 905, 500);
  } else {
    smooth();
    textFont(timeFont, 50);
    if (redScore > blueScore) {
      textSize(60);
      text("RED Team ", 692, 400);
      textSize(70);
      text("Win", 780, 500);
    } else if (redScore < blueScore) {
      textSize(60);
      fill(68,158,227);
      text("Blue Team ", 675, 400);
      textSize(70);
      fill(255);
      text("Win", 780, 500);
    } else {
      textSize(70);
      text("Draw", 750, 460);
    }
  }
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

void buttonReader() {
  buttonPortval=buttonPort.readChar();
  if (buttonPortval=='q') {
    if (pauseCheck == false) {
      pauseCheck = true;
      timer.interrupt();
      port.stop();
    } else {
      pauseCheck = false;
      port = new Serial(this, "COM6", 9600);
      timer = new Timer();
      timer.start();
    }
  }
}

void mouseClicked() {
  //StartButton Action
  if (mouseX >= 770 && mouseX <= 900 && mouseY >=120 && mouseY <= 300) {  

    if ((startAction==false && (resetAction == true || pauseCheck == true))) {
      if (resetAction ==true) {
        resetAction = false;
        pauseCheck=false;
        println("startButton Clicked");
      } else if (pauseCheck == true) {
        pauseCheck = false;
        println("startButton Clicked");
      }
      startAction=true;
      port = new Serial(this, "COM6", 9600);
      timer = new Timer();
      timer.start();
    }
  }

  //ResetButton Action
  if (mouseX >= 850 && mouseX <= 1010 && mouseY >=700 && mouseY <= 750) {    
    if (startAction==true) {
      timer.interrupt();
      port.stop();
    }
    resetAction = true;
    pauseCheck=true;
    startAction = false;
    endCheck = false;

    redScore=0;
    blueScore=0;
    min=5;
    tenSec=0;
    sec=0;
  }
  //PauseButton Action
  if (mouseX >= 670 && mouseX <= 830 && mouseY >=700 && mouseY <= 750) {
    if (startAction == true) {
      pauseCheck = true;
      startAction = false;
      timer.interrupt();
      port.stop();
    }
  }
}

void keyPressed() {
  if (key=='q') {
    if (pauseCheck == false) {
      pauseCheck = true;
      startAction = false;
      timer.interrupt();
      port.stop();
    } else {
      pauseCheck = false;
      startAction = true;
      port = new Serial(this, "COM6", 9600);
      timer = new Timer();
      timer.start();
    }
  }

  if (key=='u') {
    min--;
    if (min == -1) {
      min = 5;
    }
  }

  if (key=='i') {
    tenSec--;
    if (tenSec == -1) {
      tenSec=5;
    }
  }
}
