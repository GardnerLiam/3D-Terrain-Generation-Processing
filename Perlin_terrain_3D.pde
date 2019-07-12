int w = 4650;
int h = 3200;
int scl = 10;

float scale = 25f;

float heightScale = 420f;

int rows;
int cols;

int octaves = 5;
float lacunarity = 2;
float persistence = 0.5;

float[][] perlin;
PVector[] octaveOffsets;

PVector pos = new PVector(0, 0); 

float zoomscl = 0.5;

float maxPossibleHeight;

float maxHeight = Float.MIN_VALUE;
float minHeight = Float.MAX_VALUE;

float speed = 25;

float rotVal = 0;

float threshold = 0.015;

boolean hasUpdated = false;

int counter = 0;

float[] values;

boolean inc = true;

boolean useQuads = false;

void setup() {
  //size(800, 600, P3D);
  fullScreen(P3D);
  noStroke();
  noFill();
  noCursor();

  values = new float[] {-0.7078, -0.6518, -0.5057, -0.27, -0.07, 0.1765, 0.3725, 0.5686, 0.9608};

  cols = w/scl;
  rows = h/scl;
  octaveOffsets = new PVector[octaves];
  maxPossibleHeight = 0;
  float amplitude = 1;
  for (int i = 0; i < octaves; i++) {
    octaveOffsets[i] = new PVector(random(-100000, 100000)+pos.x, random(-100000, 100000)+pos.y);
    maxPossibleHeight += amplitude;
    amplitude *= persistence;
  }
  perlin = new float[cols][rows];
  calculatePerlinValues();
}

void calculatePerlinValues() {
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float amplitude = 1;
      float frequency = 1;

      float noiseHeight = 0;

      for (int i = 0; i < octaves; i++) {
        float sampleX = frequency * (pos.x + x + octaveOffsets[i].x) / scale; 
        float sampleY = frequency * (pos.y + y + octaveOffsets[i].y) / scale;

        float perlinValue = 2 * noise(sampleX, sampleY) - 1;
        noiseHeight += perlinValue * amplitude;
        amplitude *= persistence;
        frequency *= lacunarity;
      }

      if (noiseHeight > maxHeight) {
        maxHeight = noiseHeight;
      }
      if (noiseHeight < minHeight) {
        minHeight = noiseHeight;
      }
      perlin[x][y] = noiseHeight;
    }
  }

  println("Refreshed array");
}

void createBackground() {

  for (int i = 0; i < 49; i++) {
    float iter = map(i, 0, 49, 0, 1);
    color c = lerpColor(color(213, 242, 245), color(107, 134, 176), iter);
    stroke(c);
    line(0, i, width, i);
  }
}

void draw() {
  frameRate(30);
  counter++;
  //createBackground();
  if (counter%60 == 0) {
    calculatePerlinValues();
  }
  translate(width/2, height/2);
  rotateX(PI/3);
  translate(-w/2, -h/2);
  background(213, 242, 245);

  for (int y = 0; y < rows-1; y++) {
    beginShape(useQuads?QUAD_STRIP:TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      setColors(x, y);

      if (perlin[x][y] < threshold) {
        vertex(x*scl, y*scl, 0);
        vertex(x*scl, (y+1)*scl, 0);
      } else {
        vertex(x*scl, y*scl, (heightScale*perlin[x][y]*zoomscl));
        vertex(x*scl, (y+1)*scl, (heightScale*perlin[x][y+1]*zoomscl));
      }
    }
    endShape();
  }

  if (keyPressed) {
    calculatePerlinValues();
    if (key == 'w' || key == 'W') {
      pos.y-=speed;
    } else if (key == 's' || key == 'S') {
      pos.y+=speed;
    } else if (key == 'a' || key == 'A') {
      pos.x-=speed;
    } else if (key == 'd' || key== 'D') {
      pos.x+=speed;
    } else if (key == 'q' || key == 'Q') {
      pos.y -= speed;
      pos.x -= speed;
    } else if (key == 'e' || key == 'E') {
      pos.y -= speed;
      pos.x += speed;
    } else if (key == 'z' || key == 'Z') {
      pos.y += speed;
      pos.x -= speed;
    } else if (key == 'c' || key == 'C') {
      pos.y += speed;
      pos.x += speed;
    } else if (key == 'g' || key == 'G') {
      speed += 0.25;
    } else if (key == 'h' || key == 'H') {
      speed -= 0.25;
    } else if (key == 'l' || key == 'L') {
      heightScale += 10;
      println(heightScale);
    } else if (key == 'm' || key == 'M') {
      heightScale -= 10;
      println(heightScale);
    } else if (key == 'b' || key == 'B') {
      threshold -= 0.01;
      println(threshold);
    } else if (key == 'n' || key == 'N') {
      threshold += 0.01;
      println(threshold);
    }
  }
}

void setColors(int x, int y) {
  float lerpable = map(perlin[x][y], minHeight, maxHeight, 0, 1);

  if (between(perlin[x][y], -1, values[0]) ) {
    fill(42, 93, 186);
  } else if (between(perlin[x][y], values[0], values[1])) {
    fill(lerpColor(color(42, 93, 186), color(51, 102, 195), lerpable));
  } else if (between(perlin[x][y], values[1], values[2]) ) {
    fill(lerpColor(color(51, 102, 195), color(207, 215, 127), lerpable));
  } else if (between(perlin[x][y], values[2], values[3])) {
    fill(207, 215, 127);
  } else if (between(perlin[x][y], values[3], values[4])) {
    fill(91, 169, 24);
  } else if (between(perlin[x][y], values[4], values[5]) ) {
    fill(63, 119, 17);
  } else if (between(perlin[x][y], values[5], values[6])) {
    fill(89, 68, 61);
  } else if (between(perlin[x][y], values[6], values[7])) {
    fill (74, 59, 55);
  } else if (between(perlin[x][y], values[7], values[8])) {
    fill(250, 250, 250);
  } else if (perlin[x][y] > values[8]) {
    fill(255, 255, 255);
  }
}

boolean between(float k, float x, float y) {
  return (k > x && k < y);
}

void keyPressed() {
  if (keyCode == DOWN) {

    if (scl > 6) {
      scl -= 1;
      zoomscl -= 0.1;
    }
  } else if (keyCode == UP) {
    if (scl < 16) {
      scl += 1;
      zoomscl +=0.1;
    }
  } else if (keyCode == 61) {
    inc = true;
  } else if (keyCode == 173 || keyCode == 45) {
    inc = false;
  } else if (keyCode == 49) {
    values[0] = inc?values[0]+0.01:values[0]-0.01;
  } else if (keyCode == 50) {
    values[1] = inc?values[1]+0.01:values[1]-0.01;
  } else if (keyCode == 51) {
    values[2] = inc?values[2]+0.01:values[2]-0.01;
  } else if (keyCode == 52) {
    values[3] = inc?values[3]+0.01:values[3]-0.01;
  } else if (keyCode == 53) {
    values[4] = inc?values[4]+0.01:values[4]-0.01;
  } else if (keyCode == 55) {
    values[5] = inc?values[5]+0.01:values[5]-0.01;
  } else if (keyCode == 56) {
    values[6] = inc?values[6]+0.01:values[6]-0.01;
  } else if (keyCode == 57) {
    values[7] = inc?values[7]+0.01:values[7]-0.01;
  } else if (keyCode == 48) {
    values[8] = inc?values[8]+0.01:values[8]-0.01;
  }
}
