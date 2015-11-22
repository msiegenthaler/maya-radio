height = 113;
width = 310;
grill_radius = 45;
depth = 60;

cutWidth = .4;

wood1 = 4;
wood2 = 4;


button_size = 10;
buttons_x = 4;
buttons_y = 3;
button_area = [height+5, 20, width-height-5, height-60];

buttons = concat(
  vector_flatten([for (y = button_rows()) button_row(y)]),
  vector_remove(button_row(height-29),1)
  );

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


use <utils.scad>
use <wood.scad>
use <switch.scad>


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

// ----------
// Components
// ----------

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

module buttons_holes(buttons, button_size) {
  for (pos = buttons) {
    translate(pos) circle(d=button_size);
  }
}