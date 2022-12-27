class Face {
  PVector normal;
  color c;

  Face(PVector normal, color c, PVector pos) {
    this.normal = normal;
    this.c = c;

    float[] posArr = pos.array();
    float[] normalArr = normal.array();
    for (int i = 0; i < 3; i++) {
      float axis = posArr[i];
      float normalComp = normalArr[i];
      
      if ((axis > 0 && normalComp < 0) || 
          (axis < 0 && normalComp > 0) || 
          (axis == 0 && normalComp != 0)) {
        this.c = color(0);
      }
    }
  }

  void turnX(int dir) {
    float angle = HALF_PI * dir;
    float newY = normal.y * cos(angle) - normal.z * sin(angle);
    float newZ = normal.y * sin(angle) + normal.z * cos(angle);
    normal.y = round(newY);
    normal.z = round(newZ);
  }
  
  void turnY(int dir) {
    float angle = HALF_PI * dir;
    float newX = normal.x * cos(angle) - normal.z * sin(angle);
    float newZ = normal.x * sin(angle) + normal.z * cos(angle);
    normal.x = round(newX);
    normal.z = round(newZ);
  }
  
  void turnZ(int dir) {
    float angle = HALF_PI * dir;
    float newX = normal.x * cos(angle) - normal.y * sin(angle);
    float newY = normal.x * sin(angle) + normal.y * cos(angle);
    normal.x = round(newX);
    normal.y = round(newY);
  }

  void show(PVector pos) {
    push();
    translate(0.5 * normal.x, 0.5 * normal.y, 0.5 * normal.z);

    if (abs(normal.x) > 0) {
      rotateY(HALF_PI);
    } else if (abs(normal.y) > 0) {
      rotateX(HALF_PI);
    }

    fill(c);
    noStroke();
    square(0, 0, 1);
    pop();
  }
}