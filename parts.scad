use <wood.scad>
use <switch.scad>
use <utils.scad>

module front_inner(width, height, grill_radius, buttons, button_size, button_outings, material, aroundMaterial, innerMaterial)
{
  module grill() circle(grill_radius);
  button_xs = vector_uniq(vector_extract(buttons, 0));
  button_ys = vector_uniq(vector_extract(buttons, 1));
  inner_offset = height/2 + grill_radius;
  difference() {
    side_inner(width, height, material, aroundMaterial);
    translate([height/2, height/2]) grill();
    translate([width - height/2, height/2]) grill();
    buttons_holes(buttons, button_size, button_outings, innerMaterial);
    for (x=button_xs) {
      translate([x-innerMaterial/2, aroundMaterial])
        square([innerMaterial, innerMaterial]);
      translate([x-innerMaterial/2, height-innerMaterial*2-aroundMaterial])
        square([innerMaterial, innerMaterial*2]);
    }
    for (y=button_ys) {
      translate([inner_offset,y-innerMaterial/2])
        square([innerMaterial, innerMaterial]);
      translate([width-inner_offset-innerMaterial,y-innerMaterial/2])
        square([innerMaterial, innerMaterial]);
    }
  }
}

module front_cover(width, height, grill_radius, grill_res, buttons, button_size)
{
  module grill() speakerGrill(grill_radius, grill_res/4, grill_res);
  difference() {
    side_cover(width, height);
    translate([height/2, height/2]) grill();
    translate([width - height/2, height/2]) grill();
    buttons_holes(buttons, button_size);
  }
}

module back_inner(width, height, cutout_overlap, buttons, inner_offset, material, aroundMaterial, innerMaterial)
{
  button_xs = vector_uniq(vector_extract(buttons, 0));
  button_ys = vector_uniq(vector_extract(buttons, 1));
  difference() {
    side_inner(width, height, material, aroundMaterial);
    //Cutout for access from outside
    back_cutout(2, cutout_overlap, width, height, inner_offset, innerMaterial);
    // horizontal inner tabs
    translate([inner_offset,aroundMaterial])
      rotate([0,0,90]) woodclick(height-2*aroundMaterial, innerMaterial);
    translate([width-inner_offset+innerMaterial,aroundMaterial])
      rotate([0,0,90]) woodclick(height-2*aroundMaterial, innerMaterial);
    // vertical inner tabs
    for (x = button_xs) {
      translate([x-innerMaterial/2,aroundMaterial])
        square([material,material*2]);
      translate([x-innerMaterial/2,height-2*material-aroundMaterial])
        square([material,material*2]);
      col_buttons = vector_filter(buttons, 0, x);
    }
  }
}

module back_cover(width, height, cutout_overlap, inner_offset, material)
{
  difference() {
    side_cover(width, height);
    back_cutout(1, cutout_overlap, width, height, inner_offset, material);
  }
}

module back_screwholder(width, height, cutout_overlap, inner_offset, material)
{
  back_cutout(3, cutout_overlap, width, height, inner_offset, material);
}

module back_screwholder2(width, height, cutout_overlap, inner_offset, material)
{
  back_cutout(4, cutout_overlap, width, height, inner_offset, material);
}

module back_cutout(layer, inset, width, height, middle_offset, material) {
  screw = 3.1;
  screw_s = 5.5 - 0.3; //to make it thight
  screw_head = 6.1;
  holder = 12;
  holders_holder = 30;
  leftover = material*2;
  module basic_form() {
    intersection() {
      union() {
        translate([height/2,height/2])
          circle(height/2-leftover);
        translate([height/2,height/2])
          square([height,height/2-leftover]);
      }
      basic_form_full();
    }
  }
  module basic_form_full() {
    intersection() {
      union() {
        translate([height/2,height/2])
          circle(height/2);
        translate([height/2,height/2])
          square([height,height/2]);
      }
      square([middle_offset-material,height]);
    }
  }
  module screw_positions() {
    b = middle_offset-height/2-material-screw*3;
    d = height/2 - leftover - inset/2;
    a = acos(b/d)+90;
    translate([height/2,height/2]) {
      translate([-d, 0]) children();
      translate([b, d]) children();
      translate([sin(a)*d, cos(a)*d]) children();
    }
  }
  module screws() screw_positions() circle(d=screw);
  module border() square([middle_offset-material, height]);

  if (layer == 1) {
    difference() {
      intersection() {
        basic_form();
        border();
      }
      screw_positions() circle(d=screw_head);
    }
  } else if (layer == 2) {
    difference() {
      union() {
        intersection() {
          offset(-inset) basic_form();
          border();
        }
        screw_positions() circle(d=holder);
      }
      screws();
    }
  } else if (layer == 3) {
    intersection() {
      difference() {
        basic_form_full();
        offset(-inset) basic_form();
        screws();
      }
      screw_positions() circle(d=holders_holder);
    }
  } else if (layer == 4) {
    intersection() {
      difference() {
        basic_form_full();
        offset(-inset) basic_form();
        screw_positions() hexagon(screw_s);
      }
      screw_positions() circle(d=holders_holder);
    }
  }
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
  wrapside = (height-2*materialThickness)*PI/2 * 0.99; // remove 1% (experimental)
  length = 2*(basewidth + wrapside);

  offset = basewidth/2;
  translate([-wrapside-basewidth/2,0]) difference()
  {
    square([length, depth]);
    translate([offset, 0])
      livingHinge(wrapside, depth, materialThickness);
    translate([offset+basewidth+wrapside, 0])
      livingHinge(wrapside, depth, materialThickness);
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

module buttons_holes(buttons, button_size, outing, outing_material) {
  for (pos = buttons) {
    translate(pos) union() {
      circle(d=button_size);
      translate([-button_size/2-outing,-outing_material/2])
        square([outing*2+button_size, outing_material]);
      translate([-outing_material/2, -button_size/2-outing])
        square([outing_material, button_size+outing*2]);
    }
  }
}

module switch_plane_horizontal(buttons, offset, backpocket_height, width, depth, material, holdback_diameter, holdback_inset, holdback_outing)
{
  canal = 2;
  top_depth = depth - backpocket_height;
  union() {
    difference() {
      translate([offset,0]) square([width, top_depth]);
      for (b=buttons)
        translate([b[0],0]) switch_holder(false, depth, material, holdback_diameter, holdback_inset);
      //cable canals
      xs = vector_sort(vector_extract(buttons, 0));
      for (i=[1:len(xs)-1]) {
        middle = (xs[i-1] + xs[i]) / 2;
        translate([middle, top_depth-5]) circle(canal);
      }
      translate([(offset+buttons[0][0])/2, top_depth-5]) circle(canal);
      translate([(offset+width+buttons[len(buttons)-1][0])/2, top_depth-5]) circle(canal);
    }
    // outings at buttons
    for (b=buttons) {
      translate([b[0]-holdback_diameter/2-holdback_outing,-material])
        square([holdback_outing,material]);
      translate([b[0]+holdback_diameter/2,-material])
        square([holdback_outing,material]);
    }
    //top/bottom outing
    translate([offset,-material]) square([material, material]);
    translate([width+offset-material,-material]) square([material, material]);
    //back tabs
    translate([0, top_depth]) {
      for (b=buttons) {
        translate([b[0]-1.5*material,0]) square([3*material,material]);
      }
    }
  }
}

module switch_plane_vertical(buttons, offset, backpocket_height, height, depth, material, holdback_diameter, holdback_inset, holdback_outing)
{
  top_depth = depth - backpocket_height;
  union() {
    translate([depth,0]) rotate(90,0) difference() {
      translate([offset,0]) square([height, top_depth]);
      for (b=buttons)
        translate([b[1],0]) switch_holder(true, depth+material, material, holdback_diameter, holdback_inset);
    }
    // outings at buttons
    for (b=buttons) {
      translate([depth,b[1]-holdback_diameter/2-holdback_outing])
        square([material,holdback_outing]);
      translate([depth,b[1]+holdback_diameter/2])
        square([material,holdback_outing]);
    }
    //top/bottom outing
    translate([depth,offset]) square([material, material]);
    translate([depth,height-offset]) square([material, material*2]);
    //back tabs
    for (i=[1:len(buttons)-1]) {
      middle = (buttons[i-1][1]+buttons[i][1]) / 2;
      translate([backpocket_height-material,middle-material]) square([material,material*2]);
    }
    translate([-material,offset])
      square([backpocket_height+material,material*2]);
    translate([-material,offset+height-2*material])
      square([backpocket_height+material,material*2]);
  }
}

module middle_pane(width, height, buttons, inner_offset, material, aroundMaterial, innerMaterial)
{
  button_xs = vector_uniq(vector_extract(buttons, 0));
  button_ys = vector_uniq(vector_extract(buttons, 1));
  translate([-inner_offset, 0]) difference() {
    translate([inner_offset, 0]) union() {
      translate([0, aroundMaterial])
        square([width-2*inner_offset, height-2*aroundMaterial]);
      translate([-innerMaterial,0])
        middle_pane_hclick(height, button_ys, innerMaterial, aroundMaterial);
      translate([width-2*inner_offset,0])
        middle_pane_hclick(height, button_ys, innerMaterial, aroundMaterial);
    }
    // horizontal inner tabs
    for (y = vector_sort(vector_uniq(vector_extract(buttons, 1)))) {
      for (b = vector_filter(buttons, 1, y)) {
        translate([b[0]-1.5*material,b[1]-innerMaterial/2]) square([3*material,material]);
      }
    }
    // vertical inner tabs
    button_xs = vector_sort(vector_uniq(vector_extract(buttons, 0)));
    for (x = button_xs) {
      col_buttons = vector_extract(vector_filter(buttons, 0, x), 1);
      translate([x-innerMaterial/2,0])
        middle_pane_hclick(height, col_buttons, innerMaterial, aroundMaterial);
    }
    //cable canals
    canal = 3;
    for (i = [1:len(button_xs)-1]) {
      middle = (button_xs[i-1] + button_xs[i]) / 2;
      translate([middle, (height-2*aroundMaterial)*0.75]) circle(canal);
    }
    translate([(inner_offset+button_xs[0])/2, (height-2*aroundMaterial)*0.75]) circle(canal);
    translate([(width-inner_offset+button_xs[len(button_xs)-1])/2, (height-2*aroundMaterial)*0.75]) circle(canal);
  }
}

module middle_pane_hclick(height, button_ys, innerMaterial, aroundMaterial) {
  translate([0,aroundMaterial])
    square([innerMaterial,innerMaterial*2]);
  translate([0/2,aroundMaterial])
    square([innerMaterial,innerMaterial*2]);
  translate([0,height-2*innerMaterial-aroundMaterial])
    square([innerMaterial,innerMaterial*2]);
  for (i=[1:len(button_ys)-1]) {
    middle = (button_ys[i-1]+button_ys[i]) / 2;
    translate([0,middle-aroundMaterial])
      square([innerMaterial,innerMaterial*2]);
  }
}

module sidewall(height, depth, backpocket_height, buttons, material) {
  d = depth-6*material;
  h = height-2*material;
  button_ys = vector_uniq(vector_extract(buttons, 1));
  difference() {
    union() {
      square([d, h]);
      //front/back tabs
      rotate([0,0,90])
        woodclick(h, material);
      translate([d+material,0]) rotate([0,0,90])
        woodclick(h, material);
    }
    //middle pane tabs
    translate([d-backpocket_height-material, -material])
      middle_pane_hclick(height, button_ys, material, material);
  }
}

module speaker_setback(width, height, grill_radius, led_count, led_radius, middle_offset, material) {
  border = material;
  led_offset = grill_radius+led_radius;
  led_angle_offset = 90 - (360/led_count/2);
  intersection() {
    union() {
      circle(height/2-material);
      translate([0,-height/2+border])
        square([middle_offset-height/2,height-2*border]);
    }
    difference() {
      translate([-height/2,-height/2+border])
        square([middle_offset,height-2*border]);
      circle(grill_radius);
      for (i=[0:led_count]) {
          a = (360/led_count*i + led_angle_offset) % 360;
          translate([sin(a)*led_offset, cos(a)*led_offset])
            rotate([0,0,225-a])
            union() {
              circle(led_radius);
              translate([-led_radius/1.4,-led_radius/1.4])
                square([grill_radius, grill_radius]);
            }
      }
    }
  }
}

module speaker_holder(width, height, speaker_radius, screw_offset, grill_radius, led_count, led_radius, middle_offset, material) {
  border = material;
  screw = 3.2;
  led_offset = grill_radius+led_radius;
  led_angle_offset = 90 - (360/led_count/2);
  intersection() {
    union() {
      circle(height/2-material);
      translate([0,-height/2+border])
        square([middle_offset-height/2,height-2*border]);
    }
    difference() {
      translate([-height/2,-height/2+border])
        square([middle_offset,height-2*border]);
      circle(speaker_radius);
      translate([screw_offset,  screw_offset]) circle(d=screw);
      translate([screw_offset, -screw_offset]) circle(d=screw);
      translate([-screw_offset, screw_offset]) circle(d=screw);
      translate([-screw_offset,-screw_offset]) circle(d=screw);
      for (i=[0:led_count]) {
          a = (360/led_count*i + led_angle_offset) % 360;
          translate([sin(a)*led_offset, cos(a)*led_offset]) circle(led_radius);
      }
      translate([middle_offset-height/2,-height/2+material]) rotate([0,0,90])
        woodclick(height-2*material, material);
    }
  }
}

module battery_board_case(width, height) {
  difference() {
    translate([-width/2,0]) square([width, height]);
    children();
  }
}