// Holder for a push button switch. Cross pair with mode=true and mode=false.
//  7x7 no-lock switch: http://www.dx.com/p/7-x-7mm-no-lock-switch-blue-white-black-20-piece-pack-120311
module switch_holder(mode, height, wood) {
  holdback_diameter = 18;
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


// ----
// Test
// ----


// Lasercut plan for a single switch
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