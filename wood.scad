// Generic operations to treat woods (hinges, connections).
//----------------------------------------------------------


// Cuts out tabs, so it can be 'docked in' in a 90deg angle with another piece (with inverted mode)
module woodjoint(length, mode, below, myMaterialThickness, otherMaterialThickness)
{
  w = max(myMaterialThickness, otherMaterialThickness);
  w2 = (length/w > 14) ? w*2 : w;
  count = floor(length / w2 / 2) * 2 + 1;
  tabwidth = length / count;
  tabheight = otherMaterialThickness;
  start = mode ? 0 : 1;
  translate([0,(below?-tabheight:0)]) for (i = [start:2:count-1]) {
    translate([i*tabwidth,0]) square([tabwidth,tabheight]);
  }
}

// Hinge that allows bending along the x-axis (hinges are vertical).
module livingHinge(width, height, materialThickness)
{
  count = round(width / materialThickness);
  hingeWidth = width / count;

  cutWidth = .01;
  maxHingeLength = 35;
  connectingLength = materialThickness / 2;
  hingesPerRow = ceil(height / maxHingeLength);
  hingeLength = height / hingesPerRow;
  hingeLongCut = hingeLength - connectingLength;
  hingeShortCut = hingeLongCut / 2;
  for (x = [0:count-1]) {
    translate([x*hingeWidth,0]) for (y = [0:hingesPerRow-1]) {
      translate([0,y*hingeLength]) {
        //line starting with short
        square([cutWidth, hingeShortCut]);
        translate([0,hingeShortCut+connectingLength])
          square([cutWidth, hingeShortCut]);
        //line starting with long
        translate([hingeWidth/2, connectingLength/2])
          square([cutWidth, hingeLongCut]);
      }
    }
  }
}

// Circle filled with little holes to allow the sound to pass though.
//  For a really dense, see-though pattern use holeSize=0.25, gap=1
module speakerGrill(radius, holeSize, gap)
{
  r = radius - holeSize;
  count = round(r*2*PI / gap);
  tick = 360 / count;
  for (a = [0:tick:360])
    translate([sin(a)*r,cos(a)*r]) circle(holeSize);
  if (r > gap) speakerGrill(r-gap, holeSize, gap);
}








// Tests
module grill_lasercut_test() {
  r = 40;
  difference() {
    square([r*2.2, r*2.2]);
    translate([r*1.1,r*1.1]) speakerGrill(r, .25, 1);
  }
}