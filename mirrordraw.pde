int myWidth = 640;
int myHeight = int(myWidth*sqrt(2));
boolean pMousePressed = false;
color currentColor = color(0);
Point offset = new Point( 40, 10 );
Point corner = new Point(myWidth - offset.x, myHeight / 2 - offset.y ); 
Point center = new Point (int(corner.x *.6), corner.y / 2);

int gutter = 10;
Point translation1 = new Point(corner.x-center.x, gutter+corner.y+center.y);
Point translation2 = new Point(corner.x-center.x, gutter+center.y);
Point translation3 = new Point(-center.x, gutter+corner.y);
Panel [] panels = {
 new Panel(new Point(0,0), center, translation1, false),
 new Panel(new Point(0,corner.y), center, translation2, true),
 new Panel(new Point(center.x,0), corner, translation3, false)
};

ColorField [] colors = { new ColorField(10, 0, color(255, 0, 0)),
                         new ColorField(10+30, 0, color(0, 255, 0)),
                         new ColorField(10+2*30, 0, color(0, 0, 255)),
                         new ColorField(10+3*30, 0, color(255, 255, 255)),
                         new ColorField(10+4*30, 0, color(0, 0, 0)),
                       } ;

void setup() {
  size(myWidth +10, myHeight +10);
  clear();

}

void draw() {
  stroke(0);
  for(Panel panel: panels){
    panel.drawPanel();
    panel.drawTransformedPanel();
  }

  if (pMousePressed && mousePressed) {
    Point a = new Point(pmouseX, pmouseY);
    Point b = new Point(mouseX, mouseY);
    
    stroke(currentColor);
    for(Panel panel: panels){
      panel.drawLines(a, b); 
    } 
    for(ColorField col: colors){
      col.trigger(b);
    }
  }
  if (keyPressed) {
    if (key == 'c' ) {
      clear();
    }
  }
  pMousePressed = mousePressed;
}



void clear(){
  background(255);
  strokeWeight(3);


  for(ColorField col: colors){
    col.drawField();
  }
}

class Point{
  int x;
  int y;
  Point(int x, int y){
    this.x = x;
    this.y = y;
  }
}

class ColorField{
  color col;
  int top;
  int left;
  int size = 30;
  
  ColorField(int top, int left, color col){
    this.top = top;
    this.left = left ;
    this.col = col ;
  }
  
  boolean containsPoint(Point p){
     return p!=null && p.x >= left  && p.x <= left + size && p.y >= top  && p.y <= top + size ;
  }
  
  void trigger(Point p){
    if(containsPoint(p)){
      currentColor = col;
    }
  }
  
  void drawField(){
    fill(col);
    rect(left, top, size, size);
  }
  
  
}

class Panel{
   Point trans;
   int left, right, top, bottom;
   boolean rotate180 = false;

   Panel(Point cornerA, Point cornerB, Point translation, boolean rotate180){
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

   boolean containsPoint(Point p, boolean transformed){
     int dX = transformed ? trans.x : 0;
     int dY = transformed ? trans.y : 0; 
     return p!=null && 
            p.x >= left + dX && p.x <= right + dX && 
            p.y >= top + dY && p.y <= bottom + dY ;
   } 

   void drawLines(Point a, Point b){
     drawLine(a, b, false);
     drawLine(a, b, true);
   }
   
   void drawLine(Point a, Point b, boolean transformed){
     boolean aInside = containsPoint(a, transformed);
     boolean bInside = containsPoint(b, transformed);
     boolean insideNormal = aInside || bInside;
     
     Point start = a;
     Point end = b;
     if(!aInside && !bInside){
       return;
     }else if (!aInside || !bInside){
       Point inP = aInside? a : b;
       Point outP = aInside ? b : a;
       start = inP;
       end = findIntersection(inP, outP, transformed);
     }
     line(start.x, start.y, end.x, end.y);
     drawTransformedLine(start, end, transformed);
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
   
   Point findIntersection(Point inP, Point outP, boolean transformed){
       int dX = transformed ? trans.x : 0;
       int dY = transformed ? trans.y : 0;
       Point []points = {
        intersectionHorizontal(inP, outP, top + dY),
        intersectionHorizontal(inP, outP, bottom + dY ),
        intersectionVertical(inP, outP, left + dX),
        intersectionVertical(inP, outP, right + dX)
       };
       for(Point p: points){
         if(containsPoint(p, transformed)){
           return p;
         }
       }
       return null;

   }
   
 }
 
Point intersectionHorizontal(Point a, Point b, int yH){
  if(min(a.y, b.y) <= yH && yH <= max(a.y, b.y) ){
    int newX = a.x;
    if(b.y!=a.y){
      newX += (b.x - a.x) * (yH - a.y) / (b.y - a.y);
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


