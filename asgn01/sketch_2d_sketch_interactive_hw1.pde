/*
Interactive Computing 2015 Assignment 1
Alex Rirak
ar3256@nyu.edu
*/

//set the size
size(400,400);

//set the bg color
background(0, 180, 200);

//draw shadow
fill(54, 158, 136);
noStroke();
ellipse(230,70,200,30);
triangle(130,70,330,70,230,370);

//draw crust
fill(194, 151, 52);
ellipse(200,50,200,30);
triangle(100,50,300,50,200,350);

//draw pizza
fill(247,204,106);
ellipse(200,70,184,30);
triangle(108,70,292,70,200,350);

//draw pepperonis
fill(140, 27, 1);
ellipse(150,90,50,50);
ellipse(200,130,50,50);
ellipse(195,245,50,50);

//bacon
fill(180, 27, 1);
beginShape();
vertex(150, 120);
vertex(165, 120);
vertex(160, 140);
vertex(165, 175);
vertex(150, 175);
vertex(155, 150);
endShape(CLOSE);
beginShape();
vertex(250, 90);
vertex(265, 90);
vertex(260, 110);
vertex(265, 145);
vertex(250, 145);
vertex(255, 120);
endShape(CLOSE);

//cheese
fill(255, 247, 8);
rect(200,170,50,15);
rect(200,70,50,15);

//olives
fill(0);
ellipse(200,300,20,20);
ellipse(170,200,20,20);
ellipse(230,220,20,20);
fill(180);
ellipse(200,300,10,10);
ellipse(170,200,10,10);
ellipse(230,220,10,10);

//text shadow
fill(54, 158, 136);
textSize(24);
text("Alex Rirak", 35, 390); 

//text
fill(0);
textSize(24);
text("Alex Rirak", 30, 380); 



