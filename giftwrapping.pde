
float angle = 0;
final int nPoints = 50;
PVector[] points = new PVector[nPoints];
ArrayList<PVector> path = new ArrayList<PVector>();
int border = 100;
PVector center;


//How many pixels on the circle before a point appears
float pointEvery = 24;

PVector a = new PVector(0, -1, 0);

int index = -1;
//Set before calling calculate();
PVector currentPoint;
float closest = -1;
int closestIndex = 0;

ArrayList<PVector> unitPath = new ArrayList<PVector>();
ArrayList<PVector> completePath = new ArrayList<PVector>();


void setup() {
  size(800, 800);
  background(30);

  center = new PVector(width / 2, height / 2);
  randomPoints();
  addLeftMost();
}

void randomPoints() {
  for (int i = 0; i < nPoints; i++) {
    //Random within a box
    PVector randomPosition = new PVector(random(border, width - border), random(border, height - border));

    //Random within a  circle
    /*PVector randomPosition = PVector.fromAngle(random(TWO_PI)).mult(random((width - border) / 2));
    randomPosition.y *= (float)height / width;
    randomPosition.add(new PVector(width / 2, height / 2));*/
    
    points[i] = randomPosition;
  }
}

void addLeftMost() {
  int leftMostIndex = 0;
  for (int i = 1; i < nPoints; i++) {
    if (points[leftMostIndex].x > points[i].x) {
      leftMostIndex = i;
    }
  }
  path.add(points[leftMostIndex]);

  currentPoint = path.get(0);
  while (!calculate());
  for (int i = 0; i < path.size(); i++) {
    PVector thisPath = path.get(i);
    PVector nextPath = path.get((i + 1) % path.size());
    PVector thisUnitPath = convertToUnit(thisPath, center);
    PVector nextUnitPath = convertToUnit(nextPath, center);
    float distanceBetween = dist(thisUnitPath.x, thisUnitPath.y, nextUnitPath.x, nextUnitPath.y);

    int totalPoints = ceil(distanceBetween / pointEvery);
    completePath.add(thisPath);
    unitPath.add(thisUnitPath);
    for (int p = 0; p < distanceBetween / pointEvery; p++) {
      PVector position = thisPath.copy().add((nextPath.copy().sub(thisPath)).mult((float)p / totalPoints));
      PVector unitPosition = convertToUnit(position, center);
      completePath.add(position);
      unitPath.add(unitPosition);
    }
  }
}

void draw() {
  background(30);
  stroke(220, 30, 120);
  //drawOutline();
  drawPoints();
  drawAnimation();
}

void drawAnimation() {
  for (int i = 0; i < unitPath.size(); i++) {
    int nextIndex = (i + 1) % unitPath.size();
    float time = max(millis() - 1000, 0) / 5.0;
    float t1 = sin(max(min(time / dist(completePath.get(i).x, completePath.get(i).y, 
      unitPath.get(i).x, unitPath.get(i).y), HALF_PI), 0));
    float t2 = sin(max(min(time / 5.0 / dist(completePath.get(nextIndex).x, completePath.get(nextIndex).y, 
      unitPath.get(nextIndex).x, unitPath.get(nextIndex).y), HALF_PI), 0));
      
    PVector thisPoint = unitPath.get(i);
    PVector nextPoint = unitPath.get(nextIndex);
    PVector thisInterpolatedPoint = thisPoint.copy().add(completePath.get(i).copy().sub(thisPoint).mult(t1));
    PVector nextInterpolatedPoint = nextPoint.copy().add(completePath.get((i + 1) % unitPath.size()).copy().sub(nextPoint).mult(t2));
    stroke(255);
    line(thisInterpolatedPoint.x, thisInterpolatedPoint.y, nextInterpolatedPoint.x, nextInterpolatedPoint.y);
  }
}

PVector convertToUnit(PVector v, PVector c) {
  return v.copy().sub(c).normalize().mult((width - border) / 2 + 100).add(c);
}

//Returns true when calculations are done
boolean calculate() {
  index++;
  if (index >= nPoints) {
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

void updateVariables() {
  path.add(points[closestIndex]);
  a = path.get(path.size() - 1).copy().sub(path.get(path.size() - 2));

  currentPoint = path.get(path.size() - 1);
  closest = -1;
  closestIndex = 0;
  index = 0;
}

void drawOutline() {
  stroke(220, 30, 120);  
  line(path.get(0).x, path.get(0).y, path.get(path.size() - 1).x, path.get(path.size() - 1).y);
  for (int i = 1; i < path.size(); i++) {
    line(path.get(i).x, path.get(i).y, path.get(i - 1).x, path.get(i - 1).y);
  }
}

void drawPoints() {
  fill(255);
  noStroke();
  for (int i = 0; i < nPoints; i++) {
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
