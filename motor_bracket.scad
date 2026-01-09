$fn=360;

expansion_factor = 1.01;  // Allowance for model contraction
motor_size=42;            // Width of the motor
base_size=90;
hole_pitch=31;            // Distance between mounting holes
hole_size=3.1;            // Diameter of mounting holes
thickness=6;              // Thickness of bracket
spigot_diameter=22.2;       // Diameter of the motor spigot
pulley_diameter=30;       // Diameter of the pulley spigot
motor_height=40;          // Height of the motor above the mount
flange_width=10;          // Width of the mountng flange
mounting_hole=5;          // Diameter of mounting holes
wall_external=false;       // Walls external or internal

// Bracket parameters

bracket();

module bracket() {
    difference() {
        top();
        translate([0,0,2])
            cylinder(h=thickness,d=pulley_diameter+2);
        translate([0,0,-1])
            cylinder(h=thickness,d=spigot_diameter);
    }
    
    translate([0,-base_size/2,0])
        wall();
    translate([0,base_size/2,0])
            rotate([0,0,180]) wall();
    translate([base_size/2,0,0])
        rotate([0,0,90]) wall();
}

module top() {
    hole_offset=hole_pitch/2;
    linear_extrude(thickness)
        difference() {
            square([base_size,base_size], true);

            translate([hole_offset,hole_offset,0]) circle(d=hole_size);
            translate([-hole_offset,hole_offset,0]) circle(d=hole_size);
            translate([-hole_offset,-hole_offset,0]) circle(d=hole_size);
            translate([hole_offset,-hole_offset,0]) circle(d=hole_size);
        }
}

module wall() {
    if (wall_external)
        wall_external();
    else
        wall_internal();
}

module wall_internal() {
    difference() {
        translate([-base_size/2,0,0]) {
            cube([base_size,thickness,motor_height]);
            translate([0,0,motor_height-thickness])
                cube([base_size,flange_width+thickness,thickness]);
        }
        translate([0,thickness+flange_width/2,0])
            cylinder(h=motor_height+thickness,d=mounting_hole);
    }
}


module wall_external() {
    difference() {
        translate([-base_size/2,0,0]) {
            cube([base_size,thickness,motor_height]);
            translate([-thickness,-flange_width,motor_height-thickness])
                cube([base_size+2*thickness,flange_width,thickness]);
        }
        translate([0,-flange_width/2,0])
            cylinder(h=motor_height+thickness,d=mounting_hole);
    }
}