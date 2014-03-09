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
       a = aInsideMargin ? moveToMarginSide(a, margin, transformed) : a;
       b = bInsideMargin ? moveToMarginSide(b, margin, transformed) : b;
       drawLine(a, b, margin, transformed);
     }
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
   
   
   Point moveToMarginSide(Point p, int margin, boolean transformed){
     int dX = transformed ? trans.x : 0;
     int dY = transformed ? trans.y : 0; 
     int x = min(max(p.x, left + margin + dX), right - margin + dX);
     int y = min(max(p.y, top + margin + dY), bottom - margin + dY);
     return new Point(x,y);  
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


class Point{
  int x;
  int y;
  Point(int x, int y){
    this.x = x;
    this.y = y;
  }
}
