import codeanticode.syphon.*;
import org.openkinect.processing.*;

//Kinect Library Object
Kinect2 kinect2;

PGraphics canvas;
SyphonServer server;


//Angle for rotation
float a = 0;

float minThresh = 1000; //900
float maxThresh = 1700; //1550

void setup() {
  //size(1280, 720, P3D);
  size(1280, 1080, P3D);
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  //Create Syphon server to send frames out
  server = new SyphonServer(this, "Processing Syphon");

  smooth(16);
}

void draw() {
  background(0,0,0);

  //Translate and rotate
  pushMatrix();
  translate(width/2, height/2, -2250);
  rotateY(a);

  //We're just going to calculate and draw every 2nd pixel
  int skip = 2;

  // Get the raw depth as array of integers
  int [] depth = kinect2.getRawDepth();

  stroke(255);
  strokeWeight(3);
  beginShape(POINTS);
  for (int x = 0; x < kinect2.depthWidth; x+=skip) {
    for (int y = 0; y < kinect2.depthHeight; y+=skip) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];


      if (d > minThresh && d < maxThresh) {
        //calculate the x, y, z, camera position based on 
        PVector point = depthToPointCloudPos(x, y, d);

        // Draw a point
        vertex(point.x, point.y, point.z);
      } else {
      }
    }
  }
  endShape();

  popMatrix();

  //fill(255);
  //text(frameRate, 50, 50);

  //Rotate
  //a += 0.0035;

  server.sendScreen(); //makes ready to send to madmapper
}

//calculate the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue); // / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}
