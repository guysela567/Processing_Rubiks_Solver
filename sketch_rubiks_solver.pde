import peasy.*;
import java.util.Map;

final HashMap<String, String> MOVE_MAP = new HashMap<String, String>();
final HashMap<Integer, PVector> FACE_COLOR_MAP = new HashMap<Integer, PVector>();
final float SCALE = 50;

PeasyCam cam;
CameraState startingState;
Cube cube;
Solver solver;


void setup() {
  size(600, 600, P3D);
  cam = new PeasyCam(this, 400);

  FACE_COLOR_MAP.put(color(255, 255, 0), new PVector(0, -1, 0));
  FACE_COLOR_MAP.put(color(255, 255, 255), new PVector(0, 1, 0));
  FACE_COLOR_MAP.put(color(0, 0, 255), new PVector(0, 0, -1));
  FACE_COLOR_MAP.put(color(0, 255, 0), new PVector(0, 0, 1));
  FACE_COLOR_MAP.put(color(255, 0, 0), new PVector(-1, 0, 0));
  FACE_COLOR_MAP.put(color(255, 150, 0), new PVector(1, 0, 0));

  cube = new Cube();
  solver = new Solver(cube);
  strokeWeight(8 / SCALE);
  rectMode(CENTER);
  
  initializeMoveMap(MOVE_MAP);
  // cube.doSequence("F U2 L2 D B2 D' B2 U F2 L2 U' L2 U L' D F2 R' B D' R2", false);
  cube.doSequence("B2 L2 B2 R2 D F2 R2 U R2 D' U2 R D2 L' U2 B D' B L' U'", false);
  // cube.doSequence("R2 D2 U2 R2 F' R2 B F2 D2 R2 U2 R' D' B2 L B U' F D U", false);
  // cam.rotateX(-PI);
  startingState = cam.getState();

  // disable some controls
  cam.setCenterDragHandler(null);
  cam.setRightDragHandler(null);
}

void draw() {
  background(100);
  scale(SCALE);
  // rotateX(-PI / 8);
  // rotateY(-PI / 4);
  solver.update();
  cube.update();
  cube.show();
}

void keyPressed() {
  if (key == ' ') {
    // cube.doSequence("R U' R U R U R U' R' U' R2", false);
  } else if (key == 's') {
    solver.solve();
  } else if ("rludfby".indexOf(Character.toLowerCase(key)) != -1) {
    cube.applyMove(key);
  }
}