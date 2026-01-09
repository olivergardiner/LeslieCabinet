$fn=360;

expansion_factor = 1.01;  // Allowance for model contraction
bearing_diameter=35;      // Diameter of the thrust bearing
bracket_diameter=70;
shaft_diameter=22;
thickness=6;

// Bracket parameters

bracket();

module bracket() {
    difference() {
        cylinder(h=thickness,d=bracket_diameter);
        translate([0,0,thickness-2])
            cylinder(h=thickness,d=bearing_diameter);
        translate([0,0,-1])
            cylinder(h=thickness+2,d=shaft_diameter*expansion_factor);
    }
}

