// K-Cup variables are just to get the general shape of the cylinder.
// E.g. height is to the first "ridge" and top diameter is measured about that ridge, rather than the true top.
kcupBottomDiameter = 37;
kcupTopDiameter = 43.5;
kcupHeight = 39;
kcupTopSpacing = 4;
kcupSideSpacing = 2;
wallThickness = 2;
wallHeight = 6;
baseHeight = wallThickness * 4;
baseWidth = kcupTopDiameter + (kcupTopSpacing * 2);
notchHeight = baseHeight - wallThickness;
notchWidth = wallThickness * 4;
notchSpacing = .4;

module Holder(xCount = 1, yCount = 1) {
    totalBaseWidthX = (baseWidth * xCount) + ((xCount - 1) * notchWidth);
    totalBaseWidthY = (baseWidth * yCount) + ((yCount - 1) * notchWidth);
    kcupOffset = ((kcupTopDiameter + kcupSideSpacing) / 2) + kcupTopSpacing - 1;
    cutoutOffset = kcupTopDiameter + kcupTopSpacing;
    
    difference() {
        /* main cube */
        union() {
            difference() {
                cube(size = [totalBaseWidthX, totalBaseWidthY, baseHeight]);
        
                translate([wallThickness, wallThickness, wallThickness]) {
                    cube(size = [totalBaseWidthX - wallThickness * 2, totalBaseWidthY - wallThickness * 2, baseHeight - wallThickness]);
                }
            }
        
            /* K-Cup walls */
            for (x = [0 : xCount - 1]) {
                for (y = [0 : yCount - 1]) {
                    translate([kcupOffset + x * (baseWidth + notchWidth), kcupOffset + y * (baseWidth + notchWidth), 0]) {
                        cylinder(
                            d1 = kcupBottomDiameter + kcupSideSpacing + wallThickness, 
                            d2 = kcupTopDiameter + kcupSideSpacing + wallThickness, 
                            h = kcupHeight
                        );
                    }
                }
            }
        }
        
        /* cube inset */
        translate([0, 0, baseHeight]) {
            cube(size = [totalBaseWidthX, totalBaseWidthY, kcupHeight]);
        }
        
        /* K-Cup cutouts */
        for (x = [0 : xCount - 1]) {
            for (y = [0 : yCount - 1]) {
                translate([kcupOffset + x * (baseWidth + notchWidth), kcupOffset + y * (baseWidth + notchWidth), 0]) {
                    cylinder(d1 = kcupBottomDiameter + kcupSideSpacing, d2 = kcupTopDiameter + kcupSideSpacing, h = kcupHeight);
                    
                    translate([0, 0, -wallThickness]) {
                        cylinder(
                            d1 = kcupBottomDiameter + kcupSideSpacing, 
                            d2 = kcupBottomDiameter + kcupSideSpacing, 
                            h = wallThickness * 2
                        );
                    }
                }
            }
        }
        
        /* other cutouts */
        for (x = [0 : xCount]) {
            for (y = [0 : yCount]) {
                translateX = (x * baseWidth) + (x * kcupTopSpacing) + ((x - 1) * (notchWidth / 2));
                translateY = (y * baseWidth) + (y * kcupTopSpacing) + ((y - 1) * (notchWidth / 2));
                diameter = kcupBottomDiameter + kcupTopSpacing;
                
                translate([translateX, translateY, wallThickness / 2]) {
                    cylinder(d1 = diameter, d2 = diameter + wallThickness, h = wallThickness, center = true);
                }
            }
        }
    }
    
    /* notches */
    translate([0, -notchWidth + wallThickness, 0]) {
        resize([totalBaseWidthX, 0, 0]) {
            NotchOuter();
        }
    }
    
    translate([totalBaseWidthX + notchWidth - wallThickness, 0, 0]) {
        rotate([0, 0, 90]) {
            resize([totalBaseWidthY, 0, 0]) {
                NotchOuter();
            }
        }
    }
    
    translate([0, totalBaseWidthY, 0]) {
        resize([totalBaseWidthX, 0, 0]) {
            NotchInner();
        }
        
        // fill in gaps from cutouts
        translate([0, -wallThickness, 0]) {
            cube(size = [totalBaseWidthX, wallThickness, baseHeight]);
        }
    }
    
    translate([0, 0, 0]) {
        rotate([0, 0, 90]) {
            resize([totalBaseWidthY, 0, 0]) {
                NotchInner();
            }
            
            // fill in gaps from cutouts
            translate([0, -wallThickness, 0]) {
                cube(size = [totalBaseWidthY, wallThickness, baseHeight]);
            }
        }
    }
}

module NotchOuter() {
    rotate([0, 0, 90]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = baseWidth) {
                polygon(points = [
                    [wallThickness * 3, 0],
                    [wallThickness * 4, 0], 
                    [wallThickness * 4, wallThickness * 4], 
                    [0, wallThickness * 4], 
                    [0, wallThickness],
                    [wallThickness, wallThickness],
                    [wallThickness * 1.5, wallThickness * 1.5],
                    [wallThickness, wallThickness * 3],
                    [wallThickness, wallThickness * 3],
                    [wallThickness * 3, wallThickness * 3],
                    [wallThickness * 3, 0]
                ]);
            }
        }
    }
}

module NotchInner() {
    rotate([0, 0, 90]) {
        rotate([90, 0, 0]) {
            linear_extrude(height = baseWidth) {
                polygon(points = [
                    [0, 0],
                    [wallThickness * 3 - notchSpacing, 0], 
                    [wallThickness * 3 - notchSpacing, wallThickness * 3 - notchSpacing], 
                    [wallThickness + (notchSpacing * 1.5), wallThickness * 3 - notchSpacing], 
                    [wallThickness * 1.5 + notchSpacing, wallThickness * 1.5 + notchSpacing],
                    [wallThickness * 1.5 + notchSpacing, wallThickness * 1.5 - notchSpacing],
                    [wallThickness + notchSpacing, wallThickness  - notchSpacing],
                    [0, wallThickness - notchSpacing],
                    [0, 0]
                ]);
            }
        }
    }
}


/* 
    Command-line Support
    -------------------------

    Options:
        action  "holder" to generate a holder -- requires: x, y
        x       K-Cup count in X direction
        y       K-Cup count in Y direction
*/

action = undef;

if (action != undef) {
    assert(x != undef);
    assert(y != undef);

    if (action == "holder") {
        Holder(x, y);
    }
}
else {
    Holder(2, 5);
}