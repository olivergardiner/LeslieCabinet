$fn=360;

expansion_factor = 1.01;  // Allowance for model contraction
drum_diameter = 200;      // Main drum diameter
drum_height = 191;        // Height of drum
wall_thickness = 3;       // Wall thickness
port_width = 120;         // Width of sound port opening
balance_cavity_diameter = 29; // Diameter of balance cavities
balance_cavity_x = -50;   // X position of balance cavities
balance_cavity_y = 30;    // Y offset of balance cavities from center
horn_length = 150;        // Length of each horn
horn_width = 80;          // Width of horn opening
horn_depth = 60;          // Depth of horn
center_hub_diameter = 100; // Central hub diameter
center_hub_height = 100;   // Central hub height

// Build the complete drum assembly
leslie_drum();
//drum_base();
//drive_pulley();

module leslie_drum() {
    difference() {
        union() {
            // Main cylindrical drum housing
            drum_housing();
            
            // Wall around balance cavity - clipped by baffle
            clip_height = drum_height/2-balance_cavity_x-44;
            difference() {
                balance_cavity();
                // Clip using angled baffle cutter at each cavity position
                translate([balance_cavity_x, -balance_cavity_y, clip_height])
                    angled_baffle_cutter();
                translate([balance_cavity_x, balance_cavity_y, clip_height])
                    angled_baffle_cutter();
            }
            
            // Central spindle bearing housing
            spindle_housing();           
        }
        
        // Single sound exit port
        sound_port();
        
        // Trim any remaining artefacts at drum height
        translate([0,0,drum_height-3])
            cylinder(10,drum_diameter/1.8,drum_diameter/1.8);
    }
    
    // 45-degree baffle inside the port, clipped to drum interior
    intersection() {
        difference() {
            union() {
                sound_baffle();
                side_walls();
                side_cavity_caps();
            }
            // Cut spindle hole through baffle and walls
            translate([0, 0, -20])
                cylinder(h=drum_height + 40, d=22, center=false);
        }
        // Clip to inner cylinder of drum
        translate([0, 0, wall_thickness])
            cylinder(h=drum_height, d=drum_diameter, center=false);
    }
}

module drum_housing() {
    difference() {
        // Outer cylinder
        cylinder(h=drum_height, d=drum_diameter, center=false);
        
        // Inner hollow - starts at wall_thickness (floor is separate part)
        translate([0, 0, wall_thickness])
            cylinder(h=drum_height, d=drum_diameter - 2*wall_thickness, center=false);
        
        // Top opening
        translate([0, 0, drum_height - wall_thickness])
            cylinder(h=wall_thickness + 1, d=drum_diameter, center=false);
        
        // Remove bottom (floor is in drum_base module)
        translate([0, 0, -1])
            cylinder(h=wall_thickness + 1, d=drum_diameter + 1, center=false);
    }
}

module center_hub() {
    translate([0, 0, drum_height]) {
        // Main hub cylinder
        cylinder(h=center_hub_height, d=center_hub_diameter, center=false);
        
        // Motor mounting plate
        translate([0, 0, center_hub_height])
            cylinder(h=10, d=center_hub_diameter + 20, center=false);
        
        // Shaft
        cylinder(h=center_hub_height + 30, d=20, center=false);
    }
}

module horn_assembly() {
    translate([0, 0, drum_height + center_hub_height/2]) {
        rotate([0, 90, 0]) {
            // Horn flare shape
            hull() {
                // Inner throat
                translate([0, 0, center_hub_diameter/2])
                    cube([horn_depth/3, horn_width/3, 1], center=true);
                
                // Outer opening
                translate([0, 0, center_hub_diameter/2 + horn_length])
                    cube([horn_depth, horn_width, 1], center=true);
            }
            
            // Horn walls
            difference() {
                hull() {
                    translate([0, 0, center_hub_diameter/2])
                        cube([horn_depth/3 + wall_thickness*2, 
                              horn_width/3 + wall_thickness*2, 1], center=true);
                    
                    translate([0, 0, center_hub_diameter/2 + horn_length])
                        cube([horn_depth + wall_thickness*2, 
                              horn_width + wall_thickness*2, 1], center=true);
                }
                
                // Hollow interior
                hull() {
                    translate([0, 0, center_hub_diameter/2 - 0.5])
                        cube([horn_depth/3, horn_width/3, 1], center=true);
                    
                    translate([0, 0, center_hub_diameter/2 + horn_length + 0.5])
                        cube([horn_depth, horn_width, 1], center=true);
                }
            }
        }
    }
}

module sound_port() {
    translate([drum_diameter/2 - wall_thickness, 0, drum_height/2+wall_thickness]) {
        rotate([0, 90, 0])
            cube([drum_height, port_width, drum_diameter/2], center=true);
    }
}

module angled_baffle_cutter() {
    cutter_size = balance_cavity_diameter +2*wall_thickness + 1;
        rotate([0,0,-90]) translate([-(cutter_size/2),-(cutter_size/2),0]) difference() {
            cube([cutter_size, cutter_size, drum_height]);
        translate([-1,0,-cutter_size*1.4]) rotate([45, 0, 0])
            cube([port_width, cutter_size*2, cutter_size*2]); 
    }
}

module sound_baffle() {
    baffle_height = drum_height - 2*wall_thickness;
    baffle_length = baffle_height * 1.5;
    
    // Calculate center position so bottom of baffle is flush with drum floor
    // When rotated 45°, the vertical projection is baffle_length * cos(45°)
    center_z = (baffle_length * 0.707) / 2;
    
    // Move baffle back so bottom front corner doesn't protrude beyond inner wall
    // Bottom front corner projects forward by: (wall_thickness/2 + baffle_length/2) * sin(45°)
    max_forward_projection = (wall_thickness/2 + baffle_length/2) * 0.8;
    
    // Position baffle inside the drum, clear of the port opening
    translate([drum_diameter/2 - wall_thickness - max_forward_projection, 0, center_z]) {
        rotate([0, -45, 0])
            cube([wall_thickness, port_width, baffle_length], center=true);
    }
}

module side_walls() {
    wall_height = drum_height-wall_thickness;
    wall_length = drum_diameter * 1.2;  // Extend to cover full drum width
    
    // Left wall
    translate([0, port_width/2 + wall_thickness/2, wall_height/2]) {
        cube([wall_length, wall_thickness, wall_height], center=true);
    }
    
    // Right wall
    translate([0, -port_width/2 - wall_thickness/2, wall_height/2]) {
        cube([wall_length, wall_thickness, wall_height], center=true);
    }
}

module side_cavity_caps() {
    cap_height = drum_height - 4.5;
    cap_length = drum_diameter * 1.2;  // Match side wall length
    cap_width = (drum_diameter-port_width)/2 + wall_thickness;  // Distance from center to side wall
    
    // Left cavity cap
    translate([0, drum_diameter-port_width+wall_thickness, cap_height]) {
        cube([cap_length, cap_width, wall_thickness], center=true);
    }
    
    // Right cavity cap
    translate([0, port_width-drum_diameter - wall_thickness, cap_height]) {
        cube([cap_length, cap_width, wall_thickness], center=true);
    }
}

module balance_cavity() {
    cavity_diameter = balance_cavity_diameter;
    cavity_height = drum_height;
    
    // Left cavity wall
    translate([balance_cavity_x, -balance_cavity_y, 0]) {
        difference() {
            // Outer wall
            cylinder(h=cavity_height, d=cavity_diameter + 2*wall_thickness, center=false);
            // Inner cavity
            translate([0, 0, -1])
                cylinder(h=cavity_height + 2, d=cavity_diameter, center=false);
        }
    }
    
    // Right cavity wall
    translate([balance_cavity_x, balance_cavity_y, 0]) {
        difference() {
            // Outer wall
            cylinder(h=cavity_height, d=cavity_diameter + 2*wall_thickness, center=false);
            // Inner cavity
            translate([0, 0, -1])
                cylinder(h=cavity_height + 2, d=cavity_diameter, center=false);
        }
    }
}

module drum_base() {
    clearance = 0.3;  // Clearance for assembly fit
    union() {
        // Drum floor
        difference() {
            cylinder(h=wall_thickness, d=drum_diameter, center=false);
            // Spindle opening in floor (includes wall thickness and clearance)
            translate([0, 0, -1])
                cylinder(h=wall_thickness + 2 + clearance, d=22 + 2*wall_thickness + clearance, center=false);
            // Balance cavity openings in floor (includes wall thickness and clearance)
            translate([balance_cavity_x, -balance_cavity_y, -1])
                cylinder(h=wall_thickness + 2 + clearance, d=balance_cavity_diameter + 2*wall_thickness + clearance, center=false);
            translate([balance_cavity_x, balance_cavity_y, -1])
                cylinder(h=wall_thickness + 2 + clearance, d=balance_cavity_diameter + 2*wall_thickness + clearance, center=false);
        }
        
        // Drive pulley
        drive_pulley();
    }
}

module spindle_housing() {
    spindle_inner_diameter = 22*expansion_factor;
    housing_height = 200;  // Extends to top of drum
    
    translate([0, 0, -15]) {
        intersection() {
            difference() {
                // Outer wall
                cylinder(h=housing_height+10, d=spindle_inner_diameter + 2*wall_thickness, center=false);
                // Inner cavity - hollow all the way through
                translate([0, 0, -20])
                    cylinder(h=housing_height + 40, d=spindle_inner_diameter, center=false);
            }
            
            // Clip to not extend below base
            translate([0, 0, 15])
                cylinder(h=housing_height+15, d=spindle_inner_diameter + 2*wall_thickness + 1, center=false);
        }
    }
}

module drive_pulley() {
    teeth = 80;
    pitch = 2;  // 2mm pitch
    belt_width = 9;           // Width of the drive belt
    
    // Calculate pitch diameter: (teeth × pitch) / π
    pitch_diameter = expansion_factor * (teeth * pitch) / PI;
    tooth_depth = 1.2;  // Standard GT2 tooth depth
    pulley_outer_diameter = pitch_diameter + 1;
    pulley_height = belt_width + 2;  // Belt track plus flanges
    flange_height = 1;
    
    translate([0, 0, -pulley_height+flange_height]) {
        difference() {
            union() {
                // Main pulley body with teeth
                difference() {
                    cylinder(h=pulley_height - 2*flange_height, d=pitch_diameter - 1, center=false);
                    
                    // Create teeth around the circumference
                    for (i = [0:teeth-1]) {
                        rotate([0, 0, i * 360/teeth])
                            translate([pitch_diameter/2 - tooth_depth/2, 0, belt_width-3*flange_height])
                                cube([tooth_depth, 1.2, belt_width], center=true);
                    }
                }
                
                // Bottom straight flange
                cylinder(h=flange_height, d=pulley_outer_diameter, center=false);
                
                // Bottom tapered flange
                translate([0, 0, flange_height])
                    cylinder(h=flange_height, d1=pulley_outer_diameter, d2=pitch_diameter - 1, center=false);
                
                // Top tapered flange
                translate([0, 0, pulley_height - 3*flange_height])
                    cylinder(h=flange_height, d1=pitch_diameter - 1, d2=pulley_outer_diameter, center=false);
                
                // Top straight flange
                translate([0, 0, pulley_height - 2*flange_height])
                    cylinder(h=flange_height, d=pulley_outer_diameter, center=false);
            }
            
            // Center hole for spindle
            translate([0, 0, -1])
                cylinder(h=pulley_height + 2, d=22*expansion_factor, center=false);
            
            // Thrust bearing recess on bottom
            translate([0, 0, -1])
                cylinder(h=2, d=35*expansion_factor, center=false);
        }
    }
}