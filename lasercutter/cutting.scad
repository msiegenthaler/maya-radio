lasercut();
// 3d_body();

//Lasercuts for testing stuff
//switch_lasercut_test();
//grill_lasercut_test();

//Validations - the see if the finished product will look like imagined
//switch_3d_validation();



// Parameters
//------------
height = 128; //min: backpocket should fit battery+arduino (Warning will be echo'd)
width = 331;  //min: backpocket should fit the arduino (Warning will be echo'd)
depth = 70;

wood = 4;

speaker_front = 76.5;
speaker_screw_offset = 86/2/sqrt(2);

led_length = 9;
led_radius = 3;
led_count = 5;  //per side

grill_radius = 50;
grill_resolution = 1;
grill_offset = 4;

arduino_height = 28;
arduino_width = 54;
arduino_length = 103;
battery_width = 50;
battery_height = 20;
backpocket_height = arduino_height;
if (width-2*middle_offset < arduino_length)
  echo("WARNING: Arduino does not fit (in length)");
if (height < arduino_width+battery_width+6*wood)
  echo("WARNING: Arduino and battery do not fit (in width)");

battery_board_width = 58;
battery_board_width_low = 49; //where it meets the bottom
battery_board_height = 11;
battery_board_depth = 21;
battery_board_usb_height = 4;
battery_board_usb_offset = 1;
usb_width = 12; usb_height = 9;
woods_for_battery_board = ceil(battery_board_height/wood);

cutout_overlap = 15;

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

  col2 = max(
             len(button_xs)*(inner_depth+2*wood+gap) + button_size + button_holdback_diameter + 2*gap,
             len(button_ys)*(inner_depth+2*wood+gap) + button_size + button_holdback_diameter + 2*gap,
             width+gap);

  translate([col2+middle_offset/2,height/2]) rotate([0,0,180])
    p_speaker_holder_l();
  translate([col2+middle_offset/2,height/2+height+gap])
    p_speaker_holder_r();
  translate([col2+middle_offset/2,height/2+2*(height+gap)]) rotate([0,0,180])
    p_speaker_setback_l();
  translate([col2+middle_offset/2,height/2+3*(height+gap)])
    p_speaker_setback_r();

  translate([col2+2*wood, 4*(height+gap)])
    p_middle_pane();
  translate([col2+2*wood, 5*(height+gap)])
    p_sidewall_r();
  translate([col2+2*wood+inner_depth+gap, 5*(height+gap)])
    p_sidewall_l();

  translate([col2, 4*(height+gap)+button_holdback_diameter/2]) for (i=[0:len(buttons)-1]) {
    translate([-button_size/2,i*(button_size+gap)])
      circle(d=button_size);
    translate([-2*gap-button_size-button_holdback_diameter/2,i*(button_holdback_diameter+gap)])
      circle(d=button_holdback_diameter);
  }

  col3 = col2 + middle_offset + wood + gap;

  translate([col3, 0])
    p_back_screwholder();
  translate([col3, height+gap])
    p_back_screwholder2();

  for (i=[0:woods_for_battery_board]) {
    translate([col3+battery_board_width/2+20, 2*(height+gap)+i*(depth-5*wood)])
      p_battery_board_case(i);
  }
}

module 3d_body()
{
  add_show_around = 0;

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
  color("MediumVioletRed") translate([0,0,-depth+2*wood]) linear_extrude(wood)
    p_back_screwholder();
  color("DarkMagenta") translate([0,0,-depth+3*wood]) linear_extrude(wood)
    p_back_screwholder2();

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
  //Around sides (round)
  translate([height/2,0,-wood]) rotate([0,90,90]) color("Turquoise")
    cylindric_bend([around_depth,height*PI/2,wood], height/2)
      linear_extrude(wood) square([around_depth, height*PI/2*1.05]);
  translate([width-height/2,height,-wood]) rotate([0,90,-90]) color("Turquoise")
    cylindric_bend([around_depth,height*PI/2,wood], height/2)
      linear_extrude(wood) square([around_depth, height*PI/2*1.05]);

  //Inner structure
  color("Tan") for (button_x=button_xs) {
    translate([button_x+wood/2,0,-around_depth]) rotate([0,-90,0]) linear_extrude(wood)
      p_switch_plane_v(button_x);
  }
  color("Tan") for (button_y=button_ys) {
    translate([0,button_y-wood/2,-wood*2]) rotate([-90,0,0]) linear_extrude(wood)
      p_switch_plane_h(button_y);
  }

  //Backpocket
  color("Wheat") translate([middle_offset, 0, -depth+backpocket_height+2*wood])
    linear_extrude(wood) p_middle_pane();
  color("RosyBrown") translate([width-middle_offset,wood,-4*wood]) rotate([0,90,0])
   linear_extrude(wood) p_sidewall_r();
  color("RosyBrown") translate([middle_offset-wood,wood,-4*wood]) rotate([0,90,0])
   linear_extrude(wood) p_sidewall_l();

  //Electronics
  translate([width/2-35, wood*3, -depth+backpocket_height+2*wood-battery_height])
    battery();
  translate([width-middle_offset-arduino_length, height-54-wood*3, -depth+2*wood])
    translate([0,arduino_width,arduino_height]) rotate([180,0,0])
      arduino();

  //Battery Board
  for (i=[0:woods_for_battery_board]) {
    translate([width-middle_offset+i*wood+wood, height/2, -depth+2*wood])
      rotate([90,0,90]) linear_extrude(wood)
        p_battery_board_case(i);
  }
  translate([width-middle_offset+wood, height/2, -depth+wood]) rotate([90,0,90])
    battery_board();

  // Speakers and speaker holder
  color("LightGreen") translate([height/2,height/2, -wood*3]) linear_extrude(wood)
    p_speaker_setback_l();
  color("LightGreen") translate([width-height/2,height/2, -wood*3]) linear_extrude(wood)
    p_speaker_setback_r();
  color("PaleGreen") translate([height/2,height/2, -wood*4]) linear_extrude(wood)
    p_speaker_holder_l();
  color("PaleGreen") translate([width-height/2,height/2, -wood*4]) linear_extrude(wood)
    p_speaker_holder_r();
  color("Gray") translate([height/2,height/2,-3*wood])
    speaker();
  color("Gray") translate([width-height/2,height/2,-3*wood])
    speaker();
  translate([height/2,height/2]) leds(true);
  translate([width-height/2,height/2]) leds(false);

  //Buttons
  for (b=buttons) {
    color("OrangeRed") translate(b) {
      linear_extrude(wood) circle(d=button_size);
      translate([0,0,-wood])
        linear_extrude(wood) circle(d=button_size);
      translate([0,0,-2*wood])
        linear_extrude(wood) circle(d=button_holdback_diameter);
    }
  }
}


module p_front_inner()
  front_inner(width, height, grill_radius,
              buttons, button_holdback_diameter, button_holdback_outing,
              wood, wood, wood);
module p_back_inner() {
  difference() {
    back_inner(width, height, cutout_overlap, buttons, height/2+grill_radius, wood, wood, wood);
    translate([width-middle_offset+wood, (height-battery_board_width_low)/2])
      square([battery_board_height, battery_board_width_low]);
    translate([width-middle_offset+woods_for_battery_board*wood,height/2]) {
      translate([wood,-20]) square([wood,wood*2]);
      translate([wood,20-2*wood]) square([wood,wood*2]);
    }
  }
}
module p_front_cover()
  front_cover(width, height, grill_radius, grill_resolution, buttons, button_size);
module p_back_cover() {
  difference() {
    back_cover(width, height, cutout_overlap, middle_offset, wood);
    translate([
      width-middle_offset+wood+battery_board_usb_offset+battery_board_usb_height/2-usb_height/2, //-(usb_height-battery_board_usb_height)/2,
      (height-usb_width)/2])
      square([usb_height, usb_width]);
  }
}
module p_back_screwholder()
  back_screwholder(width, height, cutout_overlap, middle_offset, wood);
module p_back_screwholder2()
  back_screwholder2(width, height, cutout_overlap, middle_offset, wood);
module p_around()
  around(width, height, around_depth, wood, wood);
module p_switch_plane_h(y)
  switch_plane_horizontal(vector_filter(buttons, 1, y),
    middle_offset, backpocket_height+wood, width-2*middle_offset, inner_depth, wood,
    button_holdback_diameter, wood, button_holdback_outing);
module p_switch_plane_v(x)
  switch_plane_vertical(vector_filter(buttons, 0, x),
      wood, backpocket_height+wood, height-2*wood, inner_depth, wood,
      button_holdback_diameter, wood, button_holdback_outing);
module p_middle_pane()
  middle_pane(width, height, buttons, height/2+grill_radius, wood, wood, wood);
module p_speaker_holder_l()
  speaker_holder(width, height, speaker_front/2, speaker_screw_offset, grill_radius, led_count, led_radius, middle_offset, wood);
module p_speaker_holder_r() rotate([0,0,180])
    speaker_holder(width, height, speaker_front/2, speaker_screw_offset, grill_radius, led_count, led_radius, middle_offset, wood);
module p_speaker_setback_l()
  speaker_setback(width, height, grill_radius, led_count, led_radius, middle_offset, wood);
module p_speaker_setback_r() rotate([0,0,180])
    speaker_setback(width, height, grill_radius, led_count, led_radius, middle_offset, wood);
module p_sidewall_l() {
  holdback_l = 2;
  holdback_r = 6;
  ear_upper = 25;
  difference() {
    sidewall(height, depth, backpocket_height, buttons, wood);
    translate([depth-6*wood-backpocket_height,height-4*wood-arduino_width+holdback_r])
      square([ear_upper, arduino_width-holdback_l-holdback_r]);
    //cable canal for usb
    translate([depth-6*wood-backpocket_height+2.5,3*wood+2.5]) circle(2.5);
  }
}
module p_sidewall_r() {
  difference() {
    sidewall(height, depth, backpocket_height, buttons, wood);
    //cable canals
    echo(battery_board_height);
    translate([depth-backpocket_height+wood-3, (height-2*wood)*.88]) circle(3);
    translate([depth-5*wood-battery_board_depth+2, (height-2*wood)*.4]) circle(2);
  }
}
module p_battery_board_case(i) {
  w = battery_board_width + 2*10;
  h = battery_board_depth-wood + 10;
  tw = 50;
  battery_board_case(w, h) {
    if (i<woods_for_battery_board)
      translate([0,-wood]) battery_board_base();
  }
  if (middle_offset+wood-i*wood >= height/2+grill_radius) {
    translate([-tw/2,h])
      square([50,depth-h-6*wood]);
  }
  if (i==woods_for_battery_board) {
    translate([-20,-wood]) square([2*wood,wood]);
    translate([20-2*wood,-wood]) square([2*wood,wood]);
  }
}


//Other parts (for fitting)
module speaker() {
  speaker_back=34;
  speaker_depth=33;
  speaker_back_depth=15;
  speaker_front_depth=speaker_depth-speaker_back_depth;
  speaker_front_plate_s=72;
  speaker_front_plate_o=96;
  speaker_front_plate_thickness = 0.2;
  speaker_screw = 4.7;

  rotate([0,-180,0]) union() {
    linear_extrude(height=speaker_front_depth, scale=speaker_back/speaker_front)
      circle(d=speaker_front);
    translate([0,0,speaker_front_depth])
      cylinder(d=speaker_back, h=speaker_back_depth);
    translate([0,0,-speaker_front_plate_thickness])
      linear_extrude(speaker_front_plate_thickness)
      difference() {
        intersection() {
          union() {
            translate([-speaker_front_plate_s/2, -speaker_front_plate_s/2])
              square([speaker_front_plate_s, speaker_front_plate_s]);
            circle(d=speaker_front+3);
          }
          circle(d=speaker_front_plate_o);
        }
        translate([speaker_screw_offset,  speaker_screw_offset]) circle(d=speaker_screw);
        translate([speaker_screw_offset, -speaker_screw_offset]) circle(d=speaker_screw);
        translate([-speaker_screw_offset, speaker_screw_offset]) circle(d=speaker_screw);
        translate([-speaker_screw_offset,-speaker_screw_offset]) circle(d=speaker_screw);
      }
  }
}
module battery() {
  color("SteelBlue") cube([70, battery_width, battery_height]);
}
module battery_board() {
  uw = 9; protude = 2;
  color("LightSteelBlue") union() {
    linear_extrude(battery_board_height) battery_board_base();
    translate([-uw/2,-protude,battery_board_usb_offset])
      cube([uw,protude,battery_board_usb_height]);
  }
}
module battery_board_base() {
  h = battery_board_depth;
  module half()
    polygon([[0,0], [0,12],[4,16],[8,h],[23,h],
      [battery_board_width/2,h],[battery_board_width/2,0]]);
  translate([-battery_board_width/2,h]) mirror([0,1]) union() {
    half();
    translate([battery_board_width,0]) mirror([1,0]) half();
  }
}
module arduino() {
  base_offset_1 = 5;
  base_offset_2 = 8;
  base_height = arduino_height - base_offset_2;
  color("DeepSkyBlue") union() {
    cube([arduino_length, arduino_width, base_height]);
    translate([0,0,base_height]) cube([8, 21, base_offset_2]);
    translate([0,54-33,base_height]) cube([25, 33, base_offset_1]);
  }
}
module led() {
  color("FireBrick") cylinder(led_length, r=led_radius);
}
module leds(alignRight) {
  led_offset = grill_radius+led_radius;
  led_angle_offset = (alignRight?90:270) - (360/led_count/2);
  union() for (i=[0:led_count]) {
    a = (360/led_count*i + led_angle_offset) % 360;
    translate([sin(a)*led_offset, cos(a)*led_offset, -wood*2-led_length]) led();
  }
}
