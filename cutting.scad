height = 113;
width = 310;
grill_radius = 45;
depth = 60;

cutWidth = .4;

wood = 4;


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
// color("red")
 // translate([0, height+10])
 // translate([0,0,-2])
  // front_cover(width, height, grill_radius, buttons, button_size);

// color("blue")
  // side_inner(width, height, wood, wood);
  // front_inner(width, height, grill_radius, buttons, button_size, wood, wood);



//lasercut();


//Lasercut for testing stuff
//switch_lasercut_test();
//grill_lasercut_test();

//Validations - the see if the finished product will look like imagined
3d_body();
//switch_3d_validation();


use <utils.scad>
use <wood.scad>
use <switch.scad>


module lasercut() {
  gap = 2;
  front(width, height, grill_radius, wood, wood);
  translate([0, height+gap+wood*2]) back(width, height, wood, wood);

  around_side_length = height*PI/2 * 1.05;
  basewidth = width-height;
  translate([-gap, around_side_length+basewidth/2]) rotate(90) around(width, height, depth, wood, wood);
}

module 3d_body()
{
  //Front
  color("GreenYellow") linear_extrude(wood)
    front_inner(width, height, grill_radius, buttons, button_size, wood, wood);
  color("SpringGreen") translate([0,0,wood]) linear_extrude(wood)
    front_cover(width, height, grill_radius, buttons, button_size);

  //Back
  color("Violet") translate([0,0,-depth+wood]) linear_extrude(wood)
    back_inner(width, height, wood, wood);
  color("Fuchsia") translate([0,0,-depth]) linear_extrude(wood)
    back_cover(width, height);

  //Around
  around_side_length = height*PI/2 * 1.05;
  basewidth = width-height;
  add_show_around = 0.4 * basewidth;
  //top around
  translate([height/2, height, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      around(width, height, depth, wood, wood);
      translate([-add_show_around,0])
        square([basewidth+add_show_around*2, depth]);
    }
  //bottom around
  translate([height/2+basewidth/2, wood, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      translate([around_side_length+basewidth/2,0]) around(width, height, depth, wood, wood);
      square([basewidth/2+add_show_around, depth]);
    }
  translate([-add_show_around+height/2, wood, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      translate([-basewidth-around_side_length+add_show_around,0]) around(width, height, depth, wood, wood);
      square([basewidth/2+add_show_around, depth]);
    }
}

// ----------
// Components
// ----------

module front_inner(width, height, grill_radius, buttons, button_size, material, aroundMaterial)
{
  module grill() circle(grill_radius);
  difference() {
    side_inner(width, height, material, aroundMaterial);
    translate([height/2, height/2]) grill();
    translate([width - height/2, height/2]) grill();
    buttons_holes(buttons, button_size);
  }
}

module front_cover(width, height, grill_radius, buttons, button_size)
{
  module grill() speakerGrill(grill_radius, .75, 4);
  difference() {
    side_cover(width, height);
    translate([height/2, height/2]) grill();
    translate([width - height/2, height/2]) grill();
    buttons_holes(buttons, button_size);
  }
}

module back_inner(width, height, material, aroundMaterial)
{
  side_inner(width, height, material, aroundMaterial);
}

module back_cover(width, height)
{
  side_cover(width, height);
}


module side_inner(width, height, material, aroundMaterial)
{
  h = height - 2*aroundMaterial;
  basewidth = width - height;
  baseoffset = (width-basewidth)/2;
  union() {
    translate([aroundMaterial,aroundMaterial]) union() {
      translate([h/2,0]) square([basewidth, h]);
      translate([h/2,h/2]) circle(d=h);
      translate([width-height/2-aroundMaterial,h/2]) circle(d=h);
    }
    //will join long side of around
    translate([(width-basewidth)/2, height-aroundMaterial])
      woodjoint(basewidth, false, false, material, aroundMaterial);
    //will join short, left side of around
    translate([baseoffset,aroundMaterial])
      woodjoint(basewidth/2, false, true, material, aroundMaterial);
    //will join short, right side of around
    translate([baseoffset+basewidth/2,aroundMaterial])
      woodjoint(basewidth/2, false, true, material, aroundMaterial);
  }
}

module side_cover(width, height)
{
  union() {
    translate([height/2,0]) {
      translate([0, height/2]) {
        circle(d=height);
        translate([width-height, 0]) circle(d=height);
      }
      square([width-height,height]);
    }
  }
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