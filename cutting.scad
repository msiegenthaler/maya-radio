width = 300;
height = 120;
grill_radius = 45;
depth = 60;

cutWidth = .4;

wood1 = 4;
wood2 = 4;


button_size = 10;
buttons_x = 4;
buttons_y = 3;
button_area = [height, 15, width-height, height-65];

buttons = vector_flatten([for (y = button_rows()) button_row(y)]);

function button_rows() =
  vector_distribute(buttons_y, button_area[3]-button_area[1]) +
            vector_of_length(buttons_x, button_area[1]);
function button_row(y) =
  vector_extend(
    vector_distribute(buttons_x, button_area[2]-button_area[0]) +
    vector_of_length(buttons_x, button_area[0])
  , [y]);


//Testing
difference() {
  front(width, height-wood2*2, grill_radius, wood1, wood2);
  buttons_holes(buttons, button_size);
}


//lasercut();

//Lasercut for testing stuff
//switch_lasercut_test();
//grill_lasercut_test();


//Validations - the see if the finished product will look like imagined
//3d_body();
//switch_3d_validation();


module grill_lasercut_test() {
  r = 40;
  difference() {
    square([r*2.2, r*2.2]);
    translate([r*1.1,r*1.1]) speakerGrill(r, .25, 1);
  }
}

module switch_lasercut_test() {
  width = 80;
  height = 70;
  wood = 4;
  gap = 5;
  lashOffset = 10;
  lashWidth = 2*wood;
  button_dia = 10;
  holdback_dia = 20;

  difference() {
    color("Plum") union() {
      square([width, height]);
      translate([lashOffset, -wood]) square([lashWidth,wood]);
      translate([width - lashOffset - lashWidth, -wood]) square([lashWidth,wood]);
      translate([lashOffset, height]) square([lashWidth,wood]);
      translate([width - lashOffset - lashWidth, height]) square([lashWidth,wood]);
    }
    translate([width/2,0]) switch_holder(true, height, wood);
  }

  translate([width+gap,0]) difference() {
    color("PaleTurquoise") union() {
      square([width,height]);
      translate([lashOffset, -wood]) square([lashWidth,wood]);
      translate([width - lashOffset - lashWidth, -wood]) square([lashWidth,wood]);
      translate([lashOffset, height]) square([lashWidth,wood]);
      translate([width - lashOffset - lashWidth, height]) square([lashWidth,wood]);
    }
    translate([width/2,0]) switch_holder(false, height, wood);
  }

  translate([0, height+wood+gap]) difference() {
    color("Gold") square([width, width]);
    translate([lashOffset, (width - wood)/2])
      square([lashWidth, wood]);
    translate([width - lashOffset - lashWidth, (width - wood)/2])
      square([lashWidth, wood]);
    translate([(width - wood)/2, lashOffset])
      square([wood, lashWidth]);
    translate([(width - wood)/2, width - lashOffset - lashWidth])
      square([wood, lashWidth]);
    translate([width/2,width/2])
      circle(d=button_dia);
  }

  translate([0, height+wood+width+2*gap]) difference() {
    color("DodgerBlue") square([width, width]);
    translate([lashOffset, (width - wood)/2])
      square([lashWidth, wood]);
    translate([width - lashOffset - lashWidth, (width - wood)/2])
      square([lashWidth, wood]);
    translate([(width - wood)/2, lashOffset])
      square([wood, lashWidth]);
    translate([(width - wood)/2, width - lashOffset - lashWidth])
      square([wood, lashWidth]);
  }

  translate([width+gap, height+wood+gap]) {
    color("IndianRed") union() {
      translate([button_dia/2, button_dia/2]) circle(d=button_dia);
      translate([button_dia/2*3+gap, button_dia/2]) circle(d=button_dia);
      translate([button_dia/2*5+gap*2, button_dia/2]) circle(d=button_dia-0.5);
      translate([button_dia/2*7+gap*3, button_dia/2]) circle(d=button_dia-0.5);
      translate([button_dia/2*9+gap*4, button_dia/2]) circle(d=button_dia-1);
      translate([button_dia/2*11+gap*5, button_dia/2]) circle(d=button_dia-1);
    }
    color("LightBlue") translate([0,button_dia+gap]) union() {
      translate([holdback_dia/2, holdback_dia/2]) circle(d=holdback_dia);
      translate([holdback_dia/2*3+gap, holdback_dia/2]) circle(d=holdback_dia-0.5);
      translate([holdback_dia/2*5+gap*2, holdback_dia/2]) circle(d=holdback_dia-1);
      translate([holdback_dia/2, holdback_dia/2*3+gap]) difference() {
        delta = 1;
        holdback_plus = holdback_dia/2+delta;
        circle(holdback_plus);
        translate([-holdback_plus,-wood/2]) square([delta, wood]);
        translate([holdback_plus-delta,-wood/2]) square([delta, wood]);
        translate([-wood/2,-holdback_plus]) square([wood,delta]);
        translate([-wood/2,holdback_plus-delta]) square([wood,delta]);
      }
      translate([holdback_dia*3/2+gap, holdback_dia/2*3+gap]) difference() {
        delta = 3;
        holdback_plus = holdback_dia/2+delta;
        circle(holdback_plus);
        translate([-holdback_plus,-wood/2]) square([delta, wood]);
        translate([holdback_plus-delta,-wood/2]) square([delta, wood]);
        translate([-wood/2,-holdback_plus]) square([wood,delta]);
        translate([-wood/2,holdback_plus-delta]) square([wood,delta]);
      }
      translate([holdback_dia*5/2+gap*2, holdback_dia/2*3+gap]) difference() {
        delta = 2;
        ep = 0.1;
        holdback_plus = holdback_dia/2+delta;
        woodp = wood+ep;
        circle(holdback_plus);
        translate([-holdback_plus,-woodp/2]) square([delta+ep, woodp]);
        translate([holdback_plus-delta-ep,-woodp/2]) square([delta+ep, woodp]);
        translate([-woodp/2,-holdback_plus]) square([woodp,delta]);
        translate([-woodp/2,holdback_plus-delta]) square([woodp,delta]);
      }
    }
  }
}

// To see if the switch actually fits into the enclosure..
module switch_3d_validation() {
  width = 80;
  height = 70;
  wood = 4;

  color("Plum") linear_extrude(wood) {
    difference() {
      square([width, height]);
      translate([width/2,0]) switch_holder(true, height, wood);
    }
  }

  translate([width/2-wood/2,0,width/2+wood/2]) rotate([0,90])
    color("PaleTurquoise") linear_extrude(wood) {
      difference() {
        square([width, height]);
        translate([width/2,0]) switch_holder(false, height, wood);
      }
    }
}


module buttons_holes(buttons, button_size) {
  for (pos = buttons) {
    translate(pos) circle(d=button_size);
  }
}

module switch_holder(mode, height, wood) {
  holdback_diameter = 20;
  holdback_thickness = 4;
  switch_travel = 2;
  switch_neck_width = 4;
  switch_neck_height = 5;
  switch_body_width = 7;
  switch_body_height = 7;
  pin_length = 4;
  pin_width = 1;
  pin_offset = 0.5;
  switch_height = switch_neck_height + switch_body_width;
  cutout_height = height - switch_height - holdback_thickness;

  module cutout1() {
    union() {
      square([holdback_diameter, holdback_thickness + switch_travel]);
      translate([(holdback_diameter - switch_neck_width)/2, holdback_thickness + switch_travel])
        square([switch_neck_width, switch_neck_height - switch_travel]);
      translate([(holdback_diameter - switch_body_width)/2, holdback_thickness + switch_neck_height])
        square([switch_body_width, switch_body_height]);
      translate([(holdback_diameter - switch_body_width)/2, holdback_thickness + switch_height]) {
        translate([pin_offset,0])
          square([pin_width, pin_length]);
        translate([switch_body_width - pin_offset - pin_width,0])
          square([pin_width, pin_length]);
      }
      translate([(holdback_diameter - wood)/2, height - cutout_height/2])
        square([wood,cutout_height/2]);
    }
  }
  module cutout2() {
    union() {
      square([holdback_diameter, holdback_thickness+switch_travel]);
      translate([(holdback_diameter - switch_body_width)/2, holdback_thickness + switch_travel])
        square([switch_body_width,switch_body_height + switch_neck_height - switch_travel]);
      translate([(holdback_diameter - wood)/2, switch_height + holdback_thickness])
        square([wood,cutout_height/2]);
    }
  }

  if (mode) translate([-holdback_diameter/2, 0]) cutout1();
  else translate([-holdback_diameter/2, 0]) cutout2();
}


module lasercut() {
  gap = 2;
  front(width, height, grill_radius, wood1, wood2);
  translate([0, height+gap+wood2*2]) back(width, height, wood1, wood2);

  around_side_length = height*PI/2 * 1.05;
  basewidth = width-height;
  translate([-gap, around_side_length+basewidth/2]) rotate(90) around(width, height, depth, wood2, wood1);
}

module 3d_body()
{
  //Front
  linear_extrude(wood1) front(width, height, grill_radius, wood1, wood2);

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


module front(width, height, grill_radius, materialThickness, aroundMaterialThickness)
{
  module grill() speakerGrill(grill_radius, .75, 4);
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



// Vector Utilities
function vector_of_length(count, v=0) = [for (i = [1:count]) v];
function vector_of_length_index(count) = [for (i = [0:count-1]) i];
function vector_distribute(count, width) =
  vector_of_length_index(count, 0) * (width/(count-1));
function vector_extend(vector, e) = [for (v = vector) concat([v],e)];
function vector_flatten(vector) = [for (a=vector) for (b=a) b];
