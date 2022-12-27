class Move {
  int axis;
  int layer;
  int dir;

  float angle = 0;
  float speed = 0.25;
  // float speed = 10;

  Move(int axis, int layer, int dir) {
    this.axis = axis;
    this.layer = layer;
    this.dir = dir;
  }

  void update() {
    if (angle < HALF_PI) {
      angle += speed;
      if (angle > HALF_PI) {
        angle = HALF_PI;
      }
    }
  }

  boolean finished() {
    return angle == HALF_PI;
  }
}

void rotateAxis(int axis, float angle) {
  switch (axis) {
    case 0:
      rotateX(angle);
      break;
    case 1:
      rotateY(angle);
      break;
    case 2:
      rotateZ(angle);
      break;
  }
}