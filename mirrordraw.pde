boolean pMousePressed = false;
color currentColor = color(0);
int currentStrokeWeight = 3;

Panel [] panels ;
Field [] fields;

void setup() {
  // 640;//540;//min(displayWidth, 640);
  // 905;//764;//int(totalWidth*sqrt(2)); //min(displayHeight, int(totalWidth*sqrt(2)));
  size(640, 905);
  int totalWidth = width;
  int totalHeight = height;
  
  int myWidth = totalWidth - 10;
  int myHeight = totalHeight -10;
  
  Point offset = new Point( 60, 10 );
  Point corner = new Point(myWidth - offset.x, myHeight / 2 - offset.y ); 
  Point center = new Point (int(corner.x *.6), corner.y / 2);

  int gutter = 10;
  Point translation1 = new Point(corner.x-center.x, gutter+corner.y+center.y);
  Point translation2 = new Point(corner.x-center.x, gutter+center.y);
  Point translation3 = new Point(-center.x, gutter+corner.y);
  panels = new Panel [] {
     new Panel(new Point(0,0), center, translation1, false, offset),
     new Panel(new Point(0,corner.y), center, translation2, true, offset),
     new Panel(new Point(center.x,0), corner, translation3, false, offset)
  };
  
  int fieldSize = 50; 
  int fSizeWithStroke = fieldSize + 3;
  fields = new Field []{ 
    new ColorField(10, 0, fieldSize, color(255, 0, 0)),
    new ColorField(10 +   fSizeWithStroke, 0, fieldSize, color(0, 255, 0)),
    new ColorField(10 + 2*fSizeWithStroke, 0, fieldSize, color(0, 0, 255)),
    new ColorField(10 + 3*fSizeWithStroke, 0, fieldSize, color(255, 255, 255)),
    new ColorField(10 + 4*fSizeWithStroke, 0, fieldSize, color(0, 0, 0)),
    new BrushField(10 + 5*fSizeWithStroke + 5, 0, fieldSize, 3),
    new BrushField(10 + 6*fSizeWithStroke + 5, 0, fieldSize, 10),
    new BrushField(10 + 7*fSizeWithStroke + 5, 0, fieldSize, 20),
    new BrushField(10 + 8*fSizeWithStroke + 5, 0, fieldSize, 40),
  } ;
  
  clear();

}

void draw() {

  if (pMousePressed && mousePressed) {
    Point a = new Point(pmouseX, pmouseY);
    Point b = new Point(mouseX, mouseY);
    
    stroke(currentColor);
    strokeWeight(currentStrokeWeight);
    for(Panel panel: panels){
      panel.drawLines(a, b, currentStrokeWeight/2 ); 
    } 

  }
  stroke(0);
  strokeWeight(3);
  for(Panel panel: panels){
    panel.drawPanel();
    panel.drawTransformedPanel();
  }
  if (keyPressed) {
    if (key == 'c' ) {
      clear();
    }
  }
  
  for(Field field: fields){
    field.drawField();
  }
  pMousePressed = mousePressed;
}

void mouseClicked() {
  Point b = new Point(mouseX, mouseY);
  for(Field field: fields){
    field.select(b);
  }
}

void clear(){
  background(255);
}





 



