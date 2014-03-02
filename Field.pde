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
