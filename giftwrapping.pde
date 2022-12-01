
float angle = 0;
final int nPoints = 2500;
PVector[] points = new PVector[nPoints];
ArrayList<PVector> path = new ArrayList<PVector>();
int border = 100;


PVector a;

void setup() {
  size(800, 800);

  randomPoints();
  addLeftMost();
  
  a = new PVector(0, -1, 0);
  frameRate(4);
}

void randomPoints(){
  for (int i = 0; i < nPoints; i++) {
    //Random within a box
    //PVector randomPosition = new PVector(random(border, width - border), random(border, height - border));
    
    //Random within a  circle
    PVector randomPosition = PVector.fromAngle(random(TWO_PI)).mult(random((width - border) / 2));
    
    randomPosition.y *= (float)height / width;
    randomPosition.add(new PVector(width / 2, height / 2));
    points[i] = randomPosition;
  }
}

void addLeftMost(){
  int leftMostIndex = 0;
  for (int i = 1; i < nPoints; i++) {
    if (points[leftMostIndex].x > points[i].x) {
      leftMostIndex = i;
    }
  }
  path.add(points[leftMostIndex]);
}

void draw() {
  background(30);
  
  currentPoint = path.get(0);
  while(!calculate());
  
  stroke(220, 30, 120);
  line(path.get(0).x, path.get(0).y, path.get(path.size() - 1).x, path.get(path.size() - 1).y);
  drawPoints();
}


//Returns true when calculations are done

int index = -1;
//Set before calling calculate();
PVector currentPoint;
float closest = -1;
int closestIndex = 0;
boolean calculate(){
  index++;
  if(index >= nPoints){
    if (pathContains(closestIndex))
      return true;
      
    updateVariables();
  }
  PVector nextPoint = points[index];
  PVector b = nextPoint.copy().sub(currentPoint);

  if (a.normalize().cross(b.normalize()).z > 0 && a.normalize().dot(b.normalize()) > closest) {
    closest = a.dot(b);
    closestIndex = index;
  }
  
  return false;
}

void updateVariables(){
  path.add(points[closestIndex]);
  a = path.get(path.size() - 1).copy().sub(path.get(path.size() - 2));
  drawPoints();
  
  currentPoint = path.get(path.size() - 1);
  closest = -1;
  closestIndex = 0;
  index = 0;
}

void drawPoints() {
  stroke(220, 30, 120);
  for (int i = 1; i < path.size(); i++) {
    line(path.get(i).x, path.get(i).y, path.get(i - 1).x, path.get(i - 1).y);
  }
  noStroke();

  for (int i = 0; i < nPoints; i++) {
    fill(255);
    if (pathContains(i)) {
      fill(255, 0, 0);
      if (path.get(path.size() - 1) == points[i]) {
        fill(0, 255, 0);
      }
    }

    circle(points[i].x, points[i].y, 5);
  }
}

boolean pathContains(int index) {
  for (PVector point : path)
    if (point == points[index])
      return true;

  return false;
}
boolean pathContains(PVector index) {
  for (PVector point : path)
    if (point == index)
      return true;

  return false;
}
