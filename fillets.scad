// 2d primitive for outside fillets.
module fil_2d_o(r, angle=90) {
    intersection() {
      circle(r=r);
      polygon([
        [0, 0],
        [r, 0],
        [r, r * tan(angle/2)],
        [r * cos(angle), r * sin(angle)],
      ]);
    }
}

// 2d primitive for inside fillets.
// overlap is how much add to the back of the fillet walls.
module fil_2d_i(r, overlap=0, angle=90) {
  translate([r*tan(angle/2), r]) {
    difference() {
      polygon([
        [0, 0],
        [0, (-r - overlap)],
        [(-r - overlap) * tan(angle/2), (-r - overlap)],
        [(-r - overlap) * sin(angle), (-r - overlap) * cos(angle)]
      ]);
      circle(r=r);
    }
  }
}

// 2d primitive for inside fillets based on edge length.
module edge_fil_2d_i(e, overlap=0, angle=90) {
  r = tan((180-angle)/2) * e;
  fil_2d_i(r=r, overlap=overlap, angle=angle);
}

// 3d polar outside fillet.
module fil_polar_o(R, r, angle=90) {
  rotate_extrude(convexity=10) {
    translate([R, 0, 0]) {
      fil_2d_o(r, angle);
    }
  }
}

// 3d polar inside fillet.
module fil_polar_i(R, r, angle=90) {
  rotate_extrude(convexity=10) {
    translate([R, 0, 0]) {
      fil_2d_i(r, angle);
    }
  }
}

// 3d linear outside fillet.
module fil_linear_o(l, r, angle=90) {
  translate([0, 0, -l/2]) {
    linear_extrude(height=l, center=false) {
      fil_2d_o(r, angle);
    }
  }
}

// 3d linear inside fillet.
module fil_linear_i(l, r, angle=90) {
  translate([0, 0, -l/2]) {
    linear_extrude(height=l, center=false) {
      fil_2d_i(r, angle);
    }
  }
}

// 3d linear inside fillet.
module edge_fil_linear_i(l, e, overlap=0, angle=90) {
  translate([0, 0, -l/2]) {
    linear_extrude(height=l, center=false) {
      edge_fil_2d_i(e, overlap=overlap, angle=angle);
    }
  }
}
