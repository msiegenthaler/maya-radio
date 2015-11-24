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

speaker_front=78;
speaker_back=34;
speaker_depth=33;
speaker_back_depth=15;
speaker_front_depth=speaker_depth-speaker_back_depth;

grill_radius = speaker_front/2 * 1.25;
grill_resolution = 4;
grill_offset = 4;

// Buttons
use <utils.scad>
button_size = 10;
buttons_x = 4;
buttons_y = 3;
button_grill_offset = 5;
button_holdback_diameter = 16;
button_holdback_outing = 2;
button_area = [height+button_grill_offset, 20,
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
    p_front_inner();
  translate([0, height+gap])
    p_back_inner();
  translate([0, 2*(height+gap)])
    p_front_cover();
  translate([0, 3*(height+gap)])
    p_back_cover();
  translate([-gap, around_side_length+basewidth/2]) rotate(90)
    p_around();

  for (i=[0:len(button_xs)-1]) {
    translate([i*(inner_depth+2*wood+gap)+wood, 4*(height+gap)])
      p_switch_plane_v(button_xs[i]);
  }
  for (i=[0:len(button_ys)-1]) {
    translate([i*(inner_depth+2*wood+gap)+wood, 5*(height+gap)])
      rotate(90,0) translate([-middle_offset, -inner_depth])
        p_switch_plane_h(button_ys[i]);
  }
}

module 3d_body()
{
  add_show_around = 0.4 * basewidth;

  //Front
  color("GreenYellow") translate([0,0,-wood*2]) linear_extrude(wood)
    p_front_inner();
  color("SpringGreen") translate([0,0,-wood]) linear_extrude(wood)
    p_front_cover();

  //Back
  color("Violet") translate([0,0,-depth+wood]) linear_extrude(wood)
    p_back_inner();
  color("Fuchsia") translate([0,0,-depth]) linear_extrude(wood)
    p_back_cover();

  // Speakers
  module speaker() {
    rotate([0,-180,0]) union() {
      linear_extrude(height=speaker_front_depth, scale=speaker_back/speaker_front)
        circle(d=speaker_front);
      translate([0,0,speaker_front_depth])
        cylinder(d=speaker_back, h=speaker_back_depth);
    }
  }
  color("Gray") translate([height/2,height/2,-depth+speaker_depth+2*wood])
    speaker();
  color("Gray") translate([width-height/2,height/2,-depth+speaker_depth+2*wood])
    speaker();

  //Around
  //top around
  translate([height/2, height, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      p_around();
      translate([-add_show_around,0])
        square([basewidth+add_show_around*2, around_depth]);
    }
  //bottom around
  translate([height/2+basewidth/2, wood, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      translate([around_side_length+basewidth/2,0]) p_around();
      square([basewidth/2+add_show_around, around_depth]);
    }
  translate([-add_show_around+height/2, wood, -depth+wood]) rotate([90,0]) color("Turquoise")
    linear_extrude(wood) intersection() {
      translate([-basewidth-around_side_length+add_show_around,0]) p_around();
      square([basewidth/2+add_show_around, around_depth]);
    }

  //Inner structure
  for (button_x=button_xs) {
    translate([button_x+wood/2,0,-around_depth]) rotate([0,-90,0]) linear_extrude(wood)
      p_switch_plane_v(button_x);
  }
  for (button_y=button_ys) {
    translate([0,button_y-wood/2,-wood*2]) rotate([-90,0,0]) linear_extrude(wood)
      p_switch_plane_h(button_y);
  }
}


module p_front_inner()
  front_inner(width, height, grill_radius,
              buttons, button_holdback_diameter, button_holdback_outing,
              wood, wood, wood);
module p_back_inner()
  back_inner(width, height, buttons, height/2+grill_radius, wood, wood, wood);
module p_front_cover()
  front_cover(width, height, grill_radius, grill_resolution, buttons, button_size);
module p_back_cover()
  back_cover(width, height);
module p_around()
  around(width, height, around_depth, wood, wood);
module p_switch_plane_h(y)
  switch_plane_horizontal(vector_filter(buttons, 1, y),
    middle_offset, width-2*middle_offset, inner_depth, wood,
    button_holdback_diameter, wood, button_holdback_outing);
module p_switch_plane_v(x)
  switch_plane_vertical(vector_filter(buttons, 0, x),
      wood, height-2*wood, inner_depth, wood,
      button_holdback_diameter, wood, button_holdback_outing);
