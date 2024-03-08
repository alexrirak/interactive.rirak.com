////size our app
//size(800,600);
//
////draw single point
//point(100,300);


void setup() {
  size(500,500);
  
}

void draw() {
  fill(
    map(mouseX, 0, 500, 0, 255),
    map(mouseY, 0, 500, 0, 255),
    map(mouseY, 0, 500, 0, 255)
    );
//     ellipse(mouseX, mouseY, 50, 50); 

ellipse(mouseX, mouseY, 25, 25);
ellipse(500 - mouseX, mouseY, 25, 25);
ellipse(mouseX, 500 - mouseY, 25, 25);
ellipse(500 - mouseX, 500 - mouseY, 25, 25);
     
}

