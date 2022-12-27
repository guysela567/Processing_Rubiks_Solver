enum PieceType { CENTER, CORNER, EDGE }

class Piece {
  PVector pos;
  PVector solvedPos;
  Face[] faces;
  PieceType type;

  Piece(float x, float y, float z) {
    pos = new PVector(x, y, z);
    solvedPos = new PVector(x, y, z);

    faces = new Face[6];
    initializeFaces();

    float axisSum = abs(x) + abs(y) + abs(z);
    type = axisSum == 3 ? PieceType.CORNER : axisSum == 2 ? PieceType.EDGE : PieceType.CENTER;
  }

  void initializeFaces() {
    int i = 0;
    for (HashMap.Entry<Integer, PVector> entry : FACE_COLOR_MAP.entrySet()) {
      faces[i] = new Face(entry.getValue().copy(), entry.getKey(), pos);
      i++;
    }
  }

  boolean hasColor(color c) {
    for (Face face : faces) {
      if (face.c == c) return true;
    }
    return false;
  }

  boolean isPermutated() {
    return pos.x == solvedPos.x && pos.y == solvedPos.y && pos.z == solvedPos.z;
  }

  void turnX(int dir) {
    PMatrix2D m = new PMatrix2D();
    m.rotate(HALF_PI * dir);
    m.translate(pos.y, pos.z);
    pos.y = round(m.m02);
    pos.z = round(m.m12);

    for (Face face : faces) {
      face.turnX(dir);
    }
  }

  void turnY(int dir) {
    PMatrix2D m = new PMatrix2D();
    m.rotate(HALF_PI * dir);
    m.translate(pos.x, pos.z);
    pos.x = round(m.m02);
    pos.z = round(m.m12);

    for (Face face : faces) {
      face.turnY(dir);
    }
  }

  void turnZ(int dir) {
    PMatrix2D m = new PMatrix2D();
    m.rotate(HALF_PI * dir);
    m.translate(pos.x, pos.y);
    pos.x = round(m.m02);
    pos.y = round(m.m12);

    for (Face face : faces) {
      face.turnZ(dir);
    }
  }

  void show() {
    push();
    translate(pos.x, pos.y, pos.z);
    noFill();
    box(1);

    for (Face face : faces) {
      face.show(pos);
    }

    pop();
  }
}