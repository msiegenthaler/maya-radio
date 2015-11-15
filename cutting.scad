width = 270;
height = 100;
depth = 60;

cutWidth = .4;

wood1 = 6;
wood2 = 6;

// 3d_body();
lasercut();


module lasercut() {
  gap = 2;
  front(width, height, wood1, wood2);
  translate([0, height+gap+wood2*2]) back(width, height, wood1, wood2);

  around_side_length = height*PI/2 * 1.05;
  basewidth = width-height;
  translate([-gap, around_side_length+basewidth/2]) rotate(90) around(width, height, depth, wood2, wood1);
}

module 3d_body()
{
  //Front
  linear_extrude(wood1) front(width, height, wood1, wood2);

  //Back
  translate([0,0,depth-wood2]) linear_extrude(wood1) back(width, height, wood1, wood2);

  //Around
  around_side_length = height*PI/2 * 1.05;
  basewidth = width-height;
  add_show_around = 0.4 * basewidth;
  //top around
  translate([height/2, height+wood2]) rotate([90,0])
    linear_extrude(wood2) intersection() {
      around(width, height, depth, wood2, wood1);
      translate([-add_show_around,0])
        square([basewidth+add_show_around*2, depth]);
    }
  //bottom around
  translate([height/2+basewidth/2, 0]) rotate([90,0])
    linear_extrude(wood2) intersection() {
      translate([around_side_length+basewidth/2,0]) around(width, height, depth, wood2, wood1);
      square([basewidth/2+add_show_around, depth]);
    }
  translate([-add_show_around+height/2, 0]) rotate([90,0])
    linear_extrude(wood2) intersection() {
      translate([-basewidth-around_side_length+add_show_around,0]) around(width, height, depth, wood2, wood1);
      square([basewidth/2+add_show_around, depth]);
    }

}


module front(width, height, materialThickness, aroundMaterialThickness)
{
  module grill() speakerGrill(height/2*.84, .75, 4);
  difference() {
    side(width, height, materialThickness, aroundMaterialThickness);
    translate([height/2, height/2]) grill();
    translate([width - height/2, height/2]) grill();
  }
}

module back(width, height, materialThickness, aroundMaterialThickness)
{
  side(width, height, materialThickness, aroundMaterialThickness);
}

module side(width, height, materialThickness, aroundMaterialThickness)
{
  basewidth = width - height;
  translate([height/2, 0]) {
    union() {
      square([basewidth, height]);
      translate([basewidth, height/2]) circle(height/2);
      translate([0, height/2]) circle(height/2);
      //will join long side of around
      translate([0,height])
        woodjoint(basewidth, false, false, materialThickness, aroundMaterialThickness);
      //will join short, left side of around
      translate([0,0])
        woodjoint(basewidth/2, false, true, materialThickness, aroundMaterialThickness);
      //will join short, right side of around
      translate([basewidth/2,0])
        woodjoint(basewidth/2, false, true, materialThickness, aroundMaterialThickness);
    }
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
module around(width, height, depth, materialThickness, sideMaterialThickness)
{
  basewidth = width - height;
  wrapside = height*PI/2 * 1.05; // add 5% to reduce the stress on the material
  length = 2*(basewidth + wrapside);

  offset = basewidth/2;
  translate([-wrapside-basewidth/2,0]) difference()
  {
    square([length, depth]);
    translate([offset, 0]) livingHinge(wrapside, depth, materialThickness);
    translate([offset+basewidth+wrapside, 0]) livingHinge(wrapside, depth, materialThickness);
    translate([wrapside+basewidth/2,0])
    //long side joints
    woodjoint(basewidth, false, false, materialThickness, sideMaterialThickness);
    translate([wrapside+basewidth/2,depth])
      woodjoint(basewidth, false, true, materialThickness, sideMaterialThickness);
    // short, left joints
    translate([0,0])
      woodjoint(basewidth/2, false, false, materialThickness, sideMaterialThickness);
    translate([0, depth])
      woodjoint(basewidth/2, false, true, materialThickness, sideMaterialThickness);
    // short, right joints
    translate([length-basewidth/2,0]) {
      woodjoint(basewidth/2, false, false, materialThickness, sideMaterialThickness);
      translate([0, depth])
        woodjoint(basewidth/2, false, true, materialThickness, sideMaterialThickness);
    }
  }
}

//cuts out tabs, so it can be 'docked in' in a 90deg angle with another piece (with inverted mode)
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

// hinge that allows bending along the x-axis (hinges are vertical)
module livingHinge(width, height, materialThickness)
{
  count = round(width / materialThickness);
  hingeWidth = width / count;

  maxHingeLength = 35;
  connectingLength = materialThickness / 2;
  hingesPerRow = ceil(height / maxHingeLength);
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