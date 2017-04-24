import processing.video.*;
import gab.opencv.OpenCV;
import processing.video.Capture;
import java.awt.Rectangle;

// Drag an image file into this window. Replace Mona_Lisa.jpg with the name of that file.
String paintingFilename = "img1.jpg";

PImage painting, mask, maskedFace;
Capture cam;
OpenCV faceCascade;
Rectangle paintingFace, liveFace;

void setup() {  

  // Load PImage of the painting
  painting = loadImage(paintingFilename);

  // Set the size of the canvas according to the dimensions of `painting`
  surface.setSize(painting.width, painting.height);

  // Select and initialize the webcam
  cam = new Capture(this, 640, 480);
  try {
    cam.start();
  } 
  catch (NullPointerException e) {
    cam = new Capture(this, 640, 480);
    //Capture.list();
    cam.start();
  }

  // Detect the largest face in the painting and store Rectangle of it in `paintingFace`
  faceCascade = new OpenCV(this, painting.width, painting.height);
  faceCascade.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  faceCascade.loadImage(painting);
  paintingFace = findLargestFace(faceCascade.detect());

  // Setup the face detection object
  faceCascade = new OpenCV(this, cam.width, cam.height);
  faceCascade.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  mask = loadImage("mask.png");
}

void draw() {

  // Read image from webcam
  if (cam.available()) {
    cam.read();
  }

  // Detect the faces in the live image
  faceCascade.loadImage(cam);
  liveFace = findLargestFace(faceCascade.detect());

  // Display the painting
  image(painting, 0, 0, width, height);

  // Crop the face according to the oval mask
  if (liveFace.width > 0 && liveFace.height > 0) {
    mask.resize(liveFace.width, liveFace.height);
    maskedFace = createImage(liveFace.width, liveFace.height, RGB);
    maskedFace.copy(cam, liveFace.x, liveFace.y, liveFace.width, liveFace.height, 
      0, 0, liveFace.width, liveFace.height);
    maskedFace.mask(mask);

    // Insert `liveFace` on top of the `paintingFace`
    blend(maskedFace, 0, 0, maskedFace.width, maskedFace.height, 
      paintingFace.x, paintingFace.y, paintingFace.width, paintingFace.height, MULTIPLY);
  }
}

// Save the outputted picture when the mouse is pressed
void mousePressed() {
  // Save current canvas to sketch folder
  saveFrame();
  // "Flash" animation 
  background(255);
}


Rectangle findLargestFace(Rectangle[] faces) {
  Rectangle largestFace = new Rectangle();
  float maxArea = -1;
  float area;

  for (Rectangle face : faces) {
    area = face.width * face.height;
    if (area > maxArea) {
      largestFace = face;
      maxArea = area;
    }
  }

  return largestFace;
}