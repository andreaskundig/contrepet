int myWidth = 640;
int myHeight = int(myWidth*sqrt(2));
boolean pMousePressed = false;
Point offset = new Point( 10, 10 );
Point corner = new Point(myWidth - offset.x, myHeight / 2 - offset.y ); 
Point center = new Point (int(corner.x *.6), corner.y / 2);

int gutter = 10;
Point translation1 = new Point(corner.x-center.x, gutter+corner.y+center.y);
Point translation2 = new Point(corner.x-center.x, gutter+center.y);
Point translation3 = new Point(-center.x, gutter+corner.y);

Panel panel1 = new Panel(new Point(0,0), center, translation1, false);
Panel panel2 = new Panel(new Point(0,corner.y), center, translation2, true);
Panel panel3 = new Panel(new Point(center.x,0), corner, translation3, false);

void setup() {
  size(myWidth +10, myHeight +10);
  stroke(0);
  strokeWeight(3);
  clear();

}

void draw() {
  if (pMousePressed && mousePressed) {
    Point a = new Point(pmouseX, pmouseY);
    Point b = new Point(mouseX, mouseY);
    
    panel1.drawLines(a, b); 
    panel2.drawLines(a, b); 
    panel3.drawLines(a, b); 
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

  panel1.drawPanel();
  panel2.drawPanel();
  panel3.drawPanel();
  
  panel1.drawTransformedPanel();
  panel2.drawTransformedPanel();
  panel3.drawTransformedPanel();
}

class Point{
  int x;
  int y;
  Point(int x, int y){
    this.x = x;
    this.y = y;
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


