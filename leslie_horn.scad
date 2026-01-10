$fn=360;

expansion_factor = 1.01;  // Allowance for model contraction
wall_thickness = 3;       // Wall thickness
horn_length = 120;        // Length of each horn
throat_diameter = 25;     // Diameter at throat (narrow end)
mouth_diameter = 80;      // Diameter at mouth (wide end)
throat_tube_length = 20;  // Length of cylindrical tube at throat
baffle_ratio=0.7;
internal_diameter=60;
drum_height=60;
easement = 0.2;           // Clearance for fit
entry_diameter=22;

baffle_diameter=mouth_diameter * baffle_ratio;

// Build adapter with flange
//horn();
drum_assembly();
//adapter_assembly(false);
//drive_pulley();

module adapter_assembly(open_through=false) {
    // Inner section: fits inside horn throat
    horn_insert_diameter = throat_diameter - 2*easement;
    
    difference() {
        union() {
            // Horizontal adapter tube
            translate([throat_tube_length,0,drum_height/2])
                rotate([0, 90, 0])
                    adapter();
            
            // Flange positioned at the adapter
            adapter_flange();
        }
        
        // Trim cylinder with inside diameter of drum
        cylinder(h=drum_height + 2, d=internal_diameter, center=false);
        
        // Optional: make adapter tube open all the way through flange
        if (open_through) {
            translate([0, 0, drum_height/2])
                rotate([0, 90, 0])
                    cylinder(h=internal_diameter + 20, d=horn_insert_diameter, center=true);
        }
    }
}

module adapter() {
    adapter_length = 40;  // Total length of adapter
    
    // Inner section: fits inside horn throat
    horn_insert_diameter = throat_diameter - 2*easement;
    
    // Outer section: fits into drum hole
    tube_outer_diameter = throat_diameter + 2*wall_thickness + 2*easement;
    drum_insert_diameter = tube_outer_diameter - 2*easement;
    
    difference() {
        // Outer tube
        cylinder(h=adapter_length, d=drum_insert_diameter, center=false);
        
        // Inner hole
        translate([0, 0, -0.5])
            cylinder(h=adapter_length + 1, d=horn_insert_diameter, center=false);
    }
}

module adapter_flange(height_factor=1.5, width_factor=1.2) {
    easement = 0.2;  // Clearance for fit
    
    // Adapter outer diameter
    tube_outer_diameter = throat_diameter + 2*wall_thickness + 2*easement;
    drum_insert_diameter = tube_outer_diameter - 2*easement;
    
    // Tube height: same as drum height
    tube_height = drum_height;
    
    // Inside diameter: matches outside diameter of drum
    drum_outer_diameter = internal_diameter + 2*wall_thickness;
    tube_inner_diameter = drum_outer_diameter;
    
    // Cutting cylinder diameter: configurable multiple of adapter diameter
    cutting_cylinder_diameter = drum_insert_diameter * width_factor;
    
    // Cutting cylinder length (needs to be long enough to cut through the tube)
    cutting_cylinder_length = tube_inner_diameter + 2*wall_thickness + 2;
    
    // Offset the cutting cylinder so only one wall segment remains
    cylinder_offset = (tube_inner_diameter + 2*wall_thickness) / 2 - cutting_cylinder_diameter / 2 + wall_thickness;
    
    intersection() {
        // Horizontal cutting cylinder at midpoint, offset to leave single wall
        translate([cylinder_offset, 0, tube_height/2])
            rotate([0, 90, 0])
                cylinder(h=cutting_cylinder_length, d=cutting_cylinder_diameter, center=true);
        
        // Flange tube
        difference() {
            // Outer tube
            cylinder(h=tube_height, d=tube_inner_diameter + 2*wall_thickness, center=false);
            
            // Inner hollow
            translate([0, 0, -0.5])
                cylinder(h=tube_height + 1, d=tube_inner_diameter, center=false);
        }
    }
}

module drum_assembly() {
    difference() {
        drum();
        // Center hole for spindle
        translate([0, 0, -1])
            cylinder(h=wall_thickness + 2, d=entry_diameter*expansion_factor, center=false);
    }
            // Drive pulley on top
    //translate([0, 0, drum_height])
        drive_pulley();
}

module drum() {
    easement = 0.2;  // Clearance for fit
    
    // Tube outer diameter (needs to fit horn throat with easement)
    tube_outer_diameter = throat_diameter + 2*wall_thickness + 2*easement;
    
    // Hole diameter (tube outer diameter plus easement)
    hole_diameter = tube_outer_diameter + 2*easement;
    
    difference() {
        // Outer cylinder
        cylinder(h=drum_height, d=internal_diameter + 2*wall_thickness, center=false);
        
        // Inner hollow
        translate([0, 0, wall_thickness])
            cylinder(h=drum_height, d=internal_diameter, center=false);
        
        // Horizontal hole through drum at midpoint
        translate([0, 0, drum_height/2])
            rotate([0, 90, 0])
                cylinder(h=internal_diameter + 2*wall_thickness + 2, d=hole_diameter, center=true);
    }
}

// Build a single vertical conical horn
//horn();

module horn() {
    conical_horn();
    conical_baffle();
    baffle_struts();
}

module conical_horn() {
    difference() {
        union() {
            // Throat tube
            cylinder(h=throat_tube_length, d=throat_diameter + 2*wall_thickness, center=false);
            
            // Outer cone
            translate([0, 0, throat_tube_length])
                cylinder(h=horn_length, d1=throat_diameter + 2*wall_thickness, 
                         d2=mouth_diameter + 2*wall_thickness, center=false);
        }
        
        // Inner hollow
        union() {
            // Hollow throat tube
            translate([0, 0, -0.5])
                cylinder(h=throat_tube_length + 1, d=throat_diameter, center=false);
            
            // Hollow cone
            translate([0, 0, throat_tube_length])
                cylinder(h=horn_length + 1, d1=throat_diameter, d2=mouth_diameter, center=false);
        }
    }
}

module conical_baffle() {
    // Calculate baffle dimensions
    cone_radius = baffle_diameter / 2;
    
    cone_height = cone_radius;
    
    // Calculate the radius at the bottom of the inverted cone
    // For a 45 degree cone, radius decreases by the same amount as height
    bottom_radius = 0;
    
    // Position so top is 5mm above horn top
    // Horn top is at: throat_tube_length + horn_length
    horn_top = throat_tube_length + horn_length;
    baffle_top = horn_top + 5;
    
    // Inverted cone: wide end at top, narrow end at bottom
    translate([0, 0, baffle_top - cone_height])
    {
        difference() {
            // Outer cone (inverted: r1 is small, r2 is large)
            cylinder(h=cone_height, r1=bottom_radius, r2=cone_radius, center=false);
            
            // Inner cone to create wall thickness
            translate([0, 0, wall_thickness*1.2])
                cylinder(h=cone_height, 
                         r1=max(0, bottom_radius), 
                         r2=cone_radius, center=false);
        }
    }
}

module baffle_struts() {
    horn_top = throat_tube_length + horn_length;
    baffle_top = horn_top + 5;
    
    cone_radius = baffle_diameter / 2;
    cone_height = cone_radius;
    bottom_radius = 0;
    
    // Baffle bottom position
    baffle_bottom_z = baffle_top - cone_height;
    
    // Strut dimensions
    strut_width = wall_thickness;
    strut_height = 25;
    strut_angle = -45;  // Angle of strut from horizontal
    
    // Calculate where struts should start at horn mouth to reach baffle bottom
    // Struts should reach the bottom radius of the baffle
    strut_length = mouth_diameter;
    
    // Start position: at horn mouth, higher so bottom reaches baffle bottom
    strut_start_z = baffle_bottom_z;
    
    // Create three struts at 120 degree intervals, clipped to horn exterior
    intersection() {
        // Create outer horn shape for clipping
        union() {
            cylinder(h=throat_tube_length, d=throat_diameter + 2*wall_thickness, center=false);
            translate([0, 0, throat_tube_length])
                cylinder(h=horn_length, d1=throat_diameter + 2*wall_thickness, 
                         d2=mouth_diameter + 2*wall_thickness, center=false);
        }
        
        union() {
            for (angle = [0:120:240]) {
                rotate([0, 0, angle]) {
                    translate([0, -strut_width/2, strut_start_z]) {
                        rotate([0, -strut_angle, 0]) {
                            cube([strut_length, strut_width, strut_height]);
                        }
                    }
                }
            }
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
                cylinder(h=pulley_height + 2, d=entry_diameter*expansion_factor, center=false);
            
            // Thrust bearing recess on bottom
            translate([0, 0, -1])
                cylinder(h=2, d=35*expansion_factor, center=false);
        }
    }
}