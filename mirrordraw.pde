boolean pMousePressed = false;
color currentColor = color(0);
int currentStrokeWeight = 3;

Panel [] panels ;
Field [] fields;

void setup() {
  int totalWidth = min(displayWidth, 640);
  int totalHeight = min(displayHeight, int(totalWidth*sqrt(2)));
  int myWidth = totalWidth - 10;
  int myHeight = totalHeight -10;
  size(totalWidth, totalHeight);
  
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
    new BrushField(10 + 7*fSizeWithStroke + 5, 0, fieldSize, 40),
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

class Point{
  int x;
  int y;
  Point(int x, int y){
    this.x = x;
    this.y = y;
  }
}

class Field{
  int top;
  int left;
  int size = 30;
  
  Field(int top, int left, int size){
    this.top = top;
    this.left = left ;
    this.size = size;
  }
  
  boolean containsPoint(Point p){
     return p!=null && p.x >= left  && p.x <= left + size && p.y >= top  && p.y <= top + size ;
  }
  
  void select(Point p){}
  
  void drawField(){}
}

class ColorField extends Field{
  color col;
  
  ColorField(int top, int left, int size, color col){
    super(top, left, size);
    this.col = col ;
  }
  
  void select(Point p){
    if(containsPoint(p)){
      currentColor = col;
    }
  }
   boolean isSelected(){
    return this.col == currentColor;
  }
 
  void drawField(){
    stroke(isSelected()? 0 : 255);
    strokeWeight(3);

    fill(col);
    rect(left, top, size, size);
  }
}

class BrushField extends Field{
  int sWeight;
  
  BrushField(int top, int left, int size, int sWeight){
    super(top, left, size);
    this.sWeight = sWeight ;
  }
  
  void select(Point p){
    if(containsPoint(p)){
      currentStrokeWeight = sWeight;
    }
  }
  
  boolean isSelected(){
    return this.sWeight == currentStrokeWeight;
  }
  
  void drawField(){
    stroke(isSelected()? 0 : 255);
    strokeWeight(3);
    noFill();
    rect(left, top, size, size);

    stroke(0);
    strokeWeight(sWeight);
    int x = left+size/2;
    int y = top+size/2;
    line(x , y, x, y);
  }
}

class Panel{
   Point trans;
   int left, right, top, bottom;
   boolean rotate180 = false;

   Panel(Point cornerA, Point cornerB, Point translation, boolean rotate180, Point offset){
     left = min(cornerA.x, cornerB.x) + offset.x;
     right = max(cornerA.x, cornerB.x) + offset.x;
     top = min(cornerA.y, cornerB.y) + offset.y;
     bottom = max(cornerA.y, cornerB.y) + offset.y;
     this.trans = translation;
     this.rotate180 = rotate180;
     //println("l"+left+" r"+right+" t"+top+" b"+bottom+" tx"+translation[0]+" ty"+translation[1]);
   }

   void drawPanel(){
     line(left, top, right, top); 
     line(right, top, right, bottom); 
     line(right, bottom, left, bottom); 
     line(left, bottom, left, top);
   }
   
   void drawTransformedPanel(){
    pushMatrix();  
    translate(trans.x, trans.y);
    drawPanel();
    popMatrix();
   }

   boolean containsPoint(Point p, boolean transformed, int margin){
     int dX = transformed ? trans.x : 0;
     int dY = transformed ? trans.y : 0; 
     return p!=null && 
            p.x >= left + dX + margin && p.x <= right + dX - margin && 
            p.y >= top + dY + margin && p.y <= bottom + dY - margin ;
   } 

   void drawLines(Point a, Point b, int margin){
     drawLine(a, b, margin, false);
     drawLine(a, b, margin, true);
   }
   
   void drawLine(Point a, Point b, int margin, boolean transformed){
     boolean aInside = containsPoint(a, transformed, margin);
     boolean bInside = containsPoint(b, transformed, margin);
     boolean aInsideMargin = containsPoint(a, transformed, 0);
     boolean bInsideMargin = containsPoint(b, transformed, 0);
     
     if(aInside || bInside){
       Point start = a;
       Point end = b;
       if (aInside != bInside){
         Point inP = aInside? a : b;
         Point outP = aInside ? b : a;
         start = inP;
         end = findIntersection(inP, outP, transformed, margin);
       }
       line(start.x, start.y, end.x, end.y);
       drawTransformedLine(start, end, transformed);
     }else if(aInsideMargin || bInsideMargin){
       a = aInsideMargin ? moveToMarginSide(a, margin) : a;
       b = bInsideMargin ? moveToMarginSide(b, margin) : b;
       drawLine(a, b, margin, transformed);
     }
   }
   
   Point moveToMarginSide(Point p, int margin){
     int x = min(max(p.x, left + margin), right - margin);
     int y = min(max(p.y, top + margin), bottom - margin);
     return new Point(x,y);  
   }
   
   void drawTransformedLine(Point start, Point end, boolean transformed){
     pushMatrix(); 
     if(rotate180) {
       int axisX = (trans.x + right + left) /2;
       int axisY = (trans.y + bottom + top) /2;
       translate(axisX, axisY);
       rotate(PI);
       translate(-axisX, -axisY);
     }else{
       int sign = transformed ? -1 : 1;
       translate(sign * trans.x, sign * trans.y);
     }
     line(start.x, start.y, end.x, end.y);
     popMatrix();     
  }
   
   Point findIntersection(Point inP, Point outP, boolean transformed, int margin){
       int dX = transformed ? trans.x : 0;
       int dY = transformed ? trans.y : 0;
       Point []points = {
        intersectionHorizontal(inP, outP, top + dY + margin),
        intersectionHorizontal(inP, outP, bottom + dY - margin),
        intersectionVertical(inP, outP, left + dX + margin),
        intersectionVertical(inP, outP, right + dX - margin)
       };
       for(Point p: points){
         if(containsPoint(p, transformed, margin)){
           return p;
         }
       }
       return null;

   }
   
 }
 
Point intersectionHorizontal(Point inP, Point outP, int yH){
  if(min(inP.y, outP.y) <= yH && yH <= max(inP.y, outP.y) ){
    int newX = inP.x;
    if(outP.y!=inP.y){
      newX += (outP.x - inP.x) * (yH - inP.y) / (outP.y - inP.y);
    }
    return  new Point(newX , yH);
  }
  return null;
}

Point  intersectionVertical(Point a, Point b, int xV){
  if(min(a.x, b.x) <= xV && xV <= max(a.x, b.x) ){
    int newY =  a.y ;
    if(b.x != a.x){
      newY +=  (b.y-a.y) * (xV - a.x) / (b.x-a.x);
    }
    return new Point(xV, newY );
  }
  return null;
}


