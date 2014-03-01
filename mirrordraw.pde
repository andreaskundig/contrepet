int myWidth = 640;
int myHeight = int(myWidth*sqrt(2));
boolean pMousePressed = false;
Point offset = new Point( 10, 10 );
Point corner = new Point(myWidth - offset.x, myHeight / 2 - offset.y ); 
Point center = new Point (int(corner.x *.6), corner.y / 2);

Point translation1 = new Point(corner.x-center.x, 10 +corner.y+center.y);
Point translation2 = new Point(corner.x-center.x, 10+ center.y);
Point translation3 = new Point(-center.x, 10+ corner.y);

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
    
    panel1.drawLine(a, b); 
    panel2.drawLine(a, b); 
    panel3.drawLine(a, b); 
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
   Point translation;
   int left, right, top, bottom;
   boolean rotate180 = false;

   Panel(Point cornerA, Point cornerB, Point translation, boolean rotate180){
     left = min(cornerA.x, cornerB.x) + offset.x;
     right = max(cornerA.x, cornerB.x) + offset.x;
     top = min(cornerA.y, cornerB.y) + offset.y;
     bottom = max(cornerA.y, cornerB.y) + offset.y;
     this.translation = translation;
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
    translate(translation.x, translation.y);
    drawPanel();
    popMatrix();
   }

   boolean containsPoint(Point p){
     return p!=null && p.x >= left && p.x <= right && p.y >= top && p.y <= bottom;
   } 
   
   void drawLine(Point a, Point b){
     boolean aInside = containsPoint(a);
     boolean bInside = containsPoint(b);
     Point start = a;
     Point end = b;
     if(!aInside && !bInside){
       return;
     }else if (!aInside || !bInside){
       Point inP = aInside? a : b;
       Point outP = aInside ? b : a;
       start = inP;
       end = findIntersection(inP, outP);
     }
     line(start.x, start.y, end.x, end.y);
     drawTransformedLine(start,end);
   }
   
   void drawTransformedLine(Point start, Point end){
     pushMatrix(); 
     if(rotate180) {
       int axisX = (translation.x + right + left) /2;
       int axisY = (translation.y + bottom + top) /2;
       translate(axisX, axisY);
       rotate(PI);
       translate(-axisX, -axisY);
     }else{
        translate(translation.x, translation.y);
     }
     line(start.x, start.y, end.x, end.y);
     popMatrix();     
  }
   
   Point findIntersection(Point inP, Point outP){
       Point []points = {
        intersectionHorizontal(inP, outP, top),
        intersectionHorizontal(inP, outP, bottom),
        intersectionVertical(inP, outP, left),
        intersectionVertical(inP, outP, right)
       };
       for(Point p: points){
         if(containsPoint(p)){
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


