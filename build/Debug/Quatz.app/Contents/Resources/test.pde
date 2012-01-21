// Drawing by strange attractor
// Created with Processing 68 alpha on September 19 , 2004
// http://www.harukit.com/

int dNum=10;
Dot[] dot = new Dot[dNum];

float aa = random(-1.95,1.95);
float bb = random(0.7,0.96);
float an = random(360);

int frameNumber;

void setup(){
  frameNumber = 0;
  size(1280,900);
  noFill();
  background(0);
  for(int i=0;i<dNum;i++){
    dot[i]=new Dot(aa,bb);
  }
}

void draw(){
  //background(255);
  translate(width/2,height/2);
  rotate(radians(an));
  for(int i=0;i<dNum;i++){
    dot[i].update();
  }
  frameNumber++;
}

void mouseReleased(){
  background(255);
  aa = random(-1.95,1.95);
  bb = random(0.7,0.96);
  an = random(360);
  for(int i=0;i<dNum;i++){
    dot[i]=new Dot(aa,bb);
  }
}

void keyPressed(){
  save("sa4_" + frameNumber + ".tif");
}

class Dot{
  float a,b,c,d,nx,ny;
  int index;
  int indexRed, indexBlue, indexGreen;
  float ox[] = new float[4];
  float oy[] = new float[4];
  Dot(float aa,float bb){
    index=0;
    for(int i=0; i<4; i++)
    {
      ox[i]=random(width);
      oy[i]=random(height);
    }
    a=aa;
    b=bb;
    c=-4.0;
    d=10000.0;
  }
  void update(){
//    indexRed = 255 - int(sqrt(ox[0]*ox[0]+ox[1]*ox[1]+ox[2]*ox[2]+ox[3]*ox[3])) / 30;
//    indexBlue = 255 - int(sqrt(oy[0]*oy[0]+oy[1]*oy[1]+oy[2]*oy[2]+oy[3]*oy[3])) / 30;
    indexRed = 240 - min(int(sqrt(pow(ox[0]-ox[1], 2) + pow(oy[0]-oy[1], 2)) * 1.0), 200);
    indexBlue = 240 - min(int(sqrt(pow(ox[1]-ox[2], 2) + pow(oy[1]-oy[2], 2)) * 1.0), 200);
    indexGreen = 240 - min(int(sqrt(pow(ox[2]-ox[3], 2) + pow(oy[2]-oy[3], 2)) * 1.0), 200);

    nx=a*ox[(index+2)%4]+b*oy[(index+2)%4]+c+d/(1+sq(ox[3]));
    ny=-ox[(index+2)%4];
    ox[(index+3)%4] = nx;
    oy[(index+3)%4] = ny;
    stroke(indexRed, indexGreen, indexBlue, 10);
    //fill(indexRed, indexGreen, indexBlue, 10);
    //stroke(indexRed, indexGreen, indexBlue, 200);
    //fill(indexRed, indexGreen, indexBlue, 200);
    //ellipse(ox[0], oy[0], 5, 5);
    bezier(ox[index%4], oy[index%4],
           ox[(index+1)%4], oy[(index+1)%4],
           ox[(index+2)%4], oy[(index+2)%4],
           ox[(index+3)%4], oy[(index+3)%4]);
    index++;
//    println(""+ indexRed + " " + indexBlue + " " + indexGreen);
  }
}
