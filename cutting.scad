// lasercut();
3d_body();

//Lasercuts for testing stuff
//switch_lasercut_test();
//grill_lasercut_test();

//Validations - the see if the finished product will look like imagined
//switch_3d_validation();



// Parameters
//------------
height = 123;
width = 330;
depth = 60;

wood = 4;

grill_radius = 45;
grill_offset = 4;

// Buttons
use <utils.scad>
button_size = 10;
buttons_x = 4;
buttons_y = 3;
button_grill_offset = 5;
button_area = [height+button_grill_offset,       20,
               width-height-button_grill_offset, height-60];
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



// Compositions
//--------------
use <parts.scad>

around_side_length = height*PI/2 * 1.05;
basewidth = width-height;
middle_offset = height/2+grill_radius;
button_xs = vector_uniq(vector_extract(buttons, 0));
button_ys = vector_uniq(vector_extract(buttons, 1));
around_depth = depth - 2*wood;
inner_depth = depth - 4*wood;

module lasercut() {
  gap = 2;

  translate()
    front_inner(width, height, grill_radius, buttons, button_size, wood, wood);
  translate([0, height+gap])
    back_inner(width, height, wood, wood);
  translate([0, 2*(height+gap)])
    front_cover(width, height, grill_radius, buttons, button_size);
  translate([0, 3*(height+gap)])
    back_cover(width, height);
  translate([-gap, around_side_length+basewidth/2]) rotate(90)
    around(width, height, around_depth, wood, wood);

  for (i=[0:len(button_xs)-1]) {
    translate([i*(inner_depth+gap), 4*(height+gap)])
      switch_plane_vertical(vector_filter(buttons, 0, button_xs[i]),
        wood, height-2*wood, inner_depth, wood);
  }
  for (i=[0:len(button_ys)-1]) {
    translate([i*(inner_depth+gap), 5*(height+gap)])
      rotate(90,0) translate([-middle_offset, -inner_depth])
        switch_plane_horizontal(vector_filter(buttons, 1, button_ys[i]),
          middle_offset, width-2*middle_offset, inner_depth, wood);
  }
}

module 3d_body()
{
  add_show_around = 0.4 * basewidth;

  //Front
  color("GreenYellow") translate([0,0,-wood*2]) linear_extrude(wood)
    front_inner(width, height, grill_radius, buttons, button_size, wood, wood);
  color("SpringGreen") translate([0,0,-wood]) linear_extrude(wood)
    front_cover(width, height, grill_radius, buttons, button_size);

  //Back
  color("Violet") translate([0,0,-depth+wood]) linear_extrude(wood)
    back_inner(width, height, wood, wood);
  color("Fuchsia") translate([0,0,-depth]) linear_extrude(wood)
    back_cover(width, height);

  //Around
  //top around
  translate([height/2, height, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      around(width, height, around_depth, wood, wood);
      translate([-add_show_around,0])
        square([basewidth+add_show_around*2, around_depth]);
    }
  //bottom around
  translate([height/2+basewidth/2, wood, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      translate([around_side_length+basewidth/2,0])
        around(width, height, around_depth, wood, wood);
      square([basewidth/2+add_show_around, around_depth]);
    }
  translate([-add_show_around+height/2, wood, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      translate([-basewidth-around_side_length+add_show_around,0])
        around(width, height, around_depth, wood, wood);
      square([basewidth/2+add_show_around, around_depth]);
    }

  //Inner structure
  for (button_x=button_xs) {
    translate([button_x+wood/2,0,-around_depth]) rotate([0,-90,0]) linear_extrude(wood)
      switch_plane_vertical(vector_filter(buttons, 0, button_x),
        wood, height-2*wood, inner_depth, wood);
  }
  for (button_y=button_ys) {
    translate([0,button_y-wood/2,-wood*2]) rotate([-90,0,0]) linear_extrude(wood)
      switch_plane_horizontal(vector_filter(buttons, 1, button_y),
        middle_offset, width-2*middle_offset, inner_depth, wood);
  }
}