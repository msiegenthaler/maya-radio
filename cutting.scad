width = 300;
height = 100;
depth = 60;

cutWidth = .4;

front(width, height);
translate([0,height+5]) around(width, height, depth, 6);

module front(width, height)
{
  module grill() speakerGrill(height/2*.84, .75, 4);
  difference() {
    side(width, height);
    translate([height/2, height/2]) grill();
    translate([width - height/2, height/2]) grill();
  }
}

module side(width, height)
{
  translate([height/2, 0]) union()
  {
    basewidth = width - height;
    square([basewidth, height]);
    translate([basewidth, height/2]) circle(height/2);
    translate([0, height/2]) circle(height/2);
  };  
}

module speakerGrill(radius, holeSize, gap)
{
  module hole()
  {
    circle(holeSize);
  };

  count = round(radius*2*PI / gap);
  tick = 360 / count;
  for (a = [0:tick:360]) {
    translate([sin(a)*radius,cos(a)*radius])
    hole();
  };
  if (radius > gap) speakerGrill(radius-gap, holeSize, gap);
}

// Generates the wood that wraps around the box, forming the depth
module around(width, height, depth, materialThickness)
{
  basewidth = width - height;
  wrapside = height*PI/2;
  length = 2*(basewidth + wrapside);

  offset = basewidth/2;
  difference()
  {
    square([length, depth]);
    translate([offset, 0]) livingHinge(wrapside, depth, materialThickness);
    translate([offset+basewidth+wrapside, 0]) livingHinge(wrapside, depth, materialThickness);
  }
}

// hinge that allows bending along the x-axis (hinges are vertical)
module livingHinge(width, height, materialThickness)
{
  count = round(width / materialThickness);
  hingeWidth = width / count;

  maxHingeLength = 35;
  connectingLength = materialThickness / 2;
  hingesPerRow = ceil(height / maxHingeLength);
  echo("hinges per row", hingesPerRow);
  hingeLength = height / hingesPerRow;
  hingeLongCut = hingeLength - connectingLength;
  hingeShortCut = hingeLongCut/2;

  for (x = [0:count-1]) {
    translate([x*hingeWidth,0]) for (y = [0:hingesPerRow-1]) {
      translate([0,y*hingeLength]) {
        //line starting with short
        square([cutWidth, hingeShortCut]);
        translate([0,hingeShortCut+connectingLength]) square([cutWidth, hingeShortCut]);
        //line starting with long
        translate([hingeWidth/2, connectingLength/2]) square([cutWidth, hingeLongCut]);
      }
    }
  }
}