// carbon fiber nano-quadcopter frame
// Author: Raiford Storey (raiford@gmail.com)

use <fillets.scad>

// Thickness of the carbon fiber sheet.
thickness = 1;

// Diameter of reliefs for inside corners.
relief_d = 0.52;

// Center Body dimensions
body_width = 30;
body_length = 30;

//Thickness of the flat vertical supports.
vert_thick = 1.5;
arm_vert_width = 5;

screw_dia = 3;
screw_inset = 1.4;

// Motor mount parameters.
motor_d = 7;
motor_mount_d = motor_d + 2.5;
motor_fillet_angle = 55; 
// Arm Dimensions
front_arm_w = 3;
front_arm_l = 24;
rear_arm_w = 3;
rear_arm_l = 24;
// Angle between arms.
front_arm_angle = 90;
rear_arm_angle = 90;

// Resolution for various components.
cylinder_res = 100;

//Body holes width and length and spacing
body_hole_w = body_width*0.36;
body_hole_l = body_length*0.36;
body_hole_r = 1.5;

// Foot and layer spacing related parameters.
layer_spacing = 9;
spacer_w = 5;
spacer_l = layer_spacing + 4*thickness;
foot_l = 14;
foot_w = spacer_w + motor_d;
foot_tip = 2; // The width of the foot tips


module frame_screw_positions(x, y)
  for(corner = [[1, 1], [-1, 1], [1, -1], [-1, -1]])
    translate([corner[0] * x/2, corner[1] * y/2, 0])
      child();

module screw_hole(diameter, depth)
  cylinder(r=diameter/2, h=depth, $fn=cylinder_res, center=true);

module arm(angle, length, width) {
  translate([length/2, 0])
    square([length, width], center=true);
  // Motor Mount
  translate([motor_d/2 + length, 0])
    motor_mount(width);
  // Arm to body fillets
  for(angle_orr = [[angle, 0], [90-angle, 1]]) {
    mirror([0, angle_orr[1], 0])
      translate([-(tan(90-angle_orr[0])*(width/2)), width/2, 0])
        edge_fil_2d_i(e=length/3, overlap=width/2+1, angle=angle_orr[0], $fn=200);
  }
}

module arm_with_hole(angle, length, width) {
  hole_r = screw_dia/2;
  difference() {
    arm(angle, length, width);
    translate([length - hole_r - screw_inset, 0, 0])
      circle(r=hole_r, center=true);
  }
}

module arm_with_slot(angle, length, width) {
  difference() {
    arm(angle, length, width);
    translate([length - spacer_w/4, 0, 0])
      square([spacer_w/2, thickness], center=true);
    // Second square is necessary to get clean cut on circle.
    translate([length, 0, 0])
      square([spacer_w/2, thickness], center=true);
    // Reliefs for inside corners.
    translate([length - spacer_w/2 + relief_d/2, (thickness/2), 0])
      relief();
    translate([length - spacer_w/2 + relief_d/2, -(thickness/2), 0])
      relief();
  }
}

module arms() {
  roll = body_width;
  pitch = body_length;
  for(arm = [[90-(front_arm_angle/2), roll/2, pitch/2, front_arm_w, front_arm_l], //Front right
             [90+(front_arm_angle/2), -roll/2, pitch/2, front_arm_w, front_arm_l], //Front left
             [270+(rear_arm_angle/2), roll/2, -pitch/2, rear_arm_w, rear_arm_l], //Rear right
             [270-(rear_arm_angle/2), -roll/2, -pitch/2, rear_arm_w, rear_arm_l]]) //Rear left
    translate([arm[1], arm[2], 0])
      rotate([0, 0, arm[0]])
        //arm_with_hole(angle=abs(arm[0]%90), length=arm[4], width=arm[3]);
        arm_with_slot(angle=abs(arm[0]%90), length=arm[4], width=arm[3]);
}

module motor_mount(arm_width) {
  difference() {
    circle(r=motor_mount_d/2, center=true);
    circle(r=motor_d/2, center=true);
    // Half circle motor mounts
    //translate([motor_mount_d/4, 0])
    //  square([motor_mount_d/2, motor_mount_d], center=true);

  }
  // Fillets to arm.
  fillet_angle = motor_fillet_angle;
  edge = (tan(fillet_angle) * (motor_mount_d/2)) - (arm_width/2)/sin(90-fillet_angle);
  x_pos = (arm_width/2)/tan(fillet_angle - atan(edge/(motor_mount_d/2)));
  for(orr = [0, 1]) {
    mirror([0, orr, 0])
      translate([-x_pos, arm_width/2, 0])
        mirror([1, 0, 0])
          edge_fil_2d_i(e=edge, overlap=(motor_mount_d-motor_d)/2, angle=90-fillet_angle, $fn=200);
  }
  // Pair of squares to fill in possible hole between fillet and arm.
  //for(orr = [0, 1]) {
  // mirror([0, orr, 0])
  //  translate([-motor_mount_d/2, arm_width/2])
  //    square(arm_width/2, center=true);
  //}
}

module center_body() {
  square(size=[body_width, body_length], center=true);
}

module rounded_square(dim, corner_r=1) {
  off_w=dim[0]/2 - corner_r;
  off_l=dim[1]/2 - corner_r;

  hull() {
    for(trans = [[off_w, off_l],
                 [-off_w, off_l],
                 [off_w, -off_l],
                 [-off_w, -off_l]])
      translate(trans)
        circle(r=corner_r, center=true);
  }
}

module body_with_holes() {
  w_trans = (body_width + body_hole_w)/6;
  l_trans = (body_length + body_hole_l)/6;
  difference() {
    union() {
      arms();
      center_body();
    }
    for(trans = [[w_trans, l_trans, 0],
                 [w_trans, -l_trans, 0],
                 [-w_trans, l_trans, 0],
                 [-w_trans, -l_trans, 0]]) {
      translate(trans)
        rounded_square([body_hole_w, body_hole_l], corner_r=body_hole_r);
    }
  }
}

module relief() {
  circle(r=relief_d/2, center=true, $fn=20);
}

module body() {
  arms();
  center_body();
}

module foot() {
  // The spacer between the sheets.
  difference() {
    union() {
      square([spacer_w, spacer_l], center=true);
      // The foot.
      translate([foot_w/2-spacer_w/2, -(spacer_l/2 + foot_l/2 - thickness)]) {
        difference() {
            square([foot_w, foot_l], center=true);
            translate([foot_tip + foot_w/2, -(foot_tip + foot_l/2)])
              rounded_square([foot_w*2, foot_l*2], corner_r=4);
        }
      }
    }
    // Relief between foot and spacer.
    translate([spacer_w/2 + relief_d/4, -(spacer_l/2 - thickness - relief_d/4)])
      relief();
    // The two slots to hold the frame layers.
    for(x = [1, -1])
      translate([-(spacer_w/4), x*(layer_spacing/2 + thickness/2)]) {
        square([spacer_w/2, thickness], center=true);
        // Two relief circles
        translate([spacer_w/4 - relief_d/2, (thickness/2)])
          relief();
        translate([spacer_w/4 - relief_d/2, -(thickness/2)])
          relief();
      }
  }
}

$fn=50;
//body_with_holes(); 
//for(rot = [0:90:270])
//  rotate([0, 0, rot]) translate([body_width/2 + 10, 5]) foot();

linear_extrude(2) {
  body_with_holes(); 
  for(rot = [0:90:270])
    rotate([0, 0, rot]) translate([body_width/2 + 10, 5]) foot();
}

