use <wood.scad>
use <switch.scad>

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

module buttons_holes(buttons, button_size) {
  for (pos = buttons) {
    translate(pos) circle(d=button_size);
  }
}

module switch_plane_horizontal(buttons, offset, width, depth)
{
  difference() {
    translate([offset,0]) square([width, depth]);
    for (b=buttons)
      translate([b[0],0]) switch_holder(false, depth, wood);
  }
}

module switch_plane_vertical(buttons, offset, height, depth)
{
  translate([depth,0]) rotate(90,0) difference() {
    translate([offset,0]) square([height, depth]);
    for (b=buttons)
      translate([b[1],0]) switch_holder(false, depth, wood);
  }
}