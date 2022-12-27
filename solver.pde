// Solving on white //

class Solver {
  Cube cube;
  ArrayList<Piece> crossPieces;
  ArrayList<Piece> yellowCrossPieces;
  ArrayList<Piece> secondLayerPieces;
  ArrayList<Piece> cornerPieces;
  ArrayList<Piece> yellowCornerPieces;

  boolean solving = false;
  boolean doneStep = true;
  int currentPhase = 0;
  int currentStep = 0;

  String fullSequence = "";

  Solver(Cube cube) {
    this.cube = cube;
    crossPieces = new ArrayList<Piece>();
    yellowCrossPieces = new ArrayList<Piece>();
    secondLayerPieces = new ArrayList<Piece>();
    cornerPieces = new ArrayList<Piece>();
    yellowCornerPieces = new ArrayList<Piece>();

    for (Piece piece : cube.pieces) {
      // initialize edges
      if (piece.type == PieceType.EDGE) {
        if (piece.hasColor(color(255))) {
          crossPieces.add(piece);
        } else if (piece.hasColor(color(255, 255, 0))) {
          yellowCrossPieces.add(piece);
        } else secondLayerPieces.add(piece);

      // initialize corners
      } else if (piece.type == PieceType.CORNER) {
        if (piece.type == PieceType.CORNER && piece.hasColor(color(255))) {
          cornerPieces.add(piece);
        } else yellowCornerPieces.add(piece);
      }
    }
  }

  void update() {
    if (!doneStep && cube.sequence == "" && !cube.animating) doneStep = true;
    if (solving && doneStep) {
      switch (currentPhase) {
        case 0: solveCross(); break;
        case 1: solveCorners(); break;
        case 2: solveSecondLayer(); break;
        case 3: solveYellowCross(); break;
        case 4: permutateYellowCross(); break;
        case 5: fixAUF(); break;
        case 6: permutateYellowCorners(); break;
        case 7: orientYellowCorners(); break;
        case 8: fixAUF(); break;
        default:
          println("Done.");
          solving = false;
          break;
      }
    }
  }

  void solve() {
    if (solving) return;
    // reset the solver and set solving to true
    currentPhase = 0;
    currentStep = 0;
    doneStep = true;
    solving = true;
    cam.setState(startingState);
    println("Starting to solve");
  }

  void nextStep(int steps) {
    currentStep++;
    if (currentStep >= steps) {
      currentStep = 0;
      currentPhase++;
      if (currentPhase == 2) cam.reset(); // tilt the camera back to yellow on top
    }
  }

  void performSequence(String seq) {
    fullSequence += seq;
    cube.doSequence(seq, true);
  }

  void solveCross() {
    println("Solving Cross Piece no. " + (currentStep + 1));
    solveNextCrossPiece(crossPieces.get(currentStep));
    nextStep(4);
  }

  void solveCorners() {
    println("Solving Corner Piece no. " + (currentStep + 1));
    solveNextCornerPiece(cornerPieces.get(currentStep));
    nextStep(4);
  }

  void solveSecondLayer() {
    println("Solving F2L Piece no. " + (currentStep + 1));
    solveNextF2LPiece(secondLayerPieces.get(currentStep));
    nextStep(4);
  }

  void solveYellowCross() {
    println("Solving the Yellow Cross");
    doneStep = false;
    String seq = "";

    // distinguish between the four possible cases
    ArrayList<Piece> yellowFaceUp = new ArrayList<Piece>();
    ArrayList<Piece> yellowFaceDown = new ArrayList<Piece>();
    for (Piece piece : yellowCrossPieces) {
      for (Face face : piece.faces) {
        if (face.c == color(255, 255, 0)) {
          if (face.normal.y != 0) yellowFaceUp.add(piece);
          else yellowFaceDown.add(piece);
          continue; // no need to check the remaining faces
        }
      }
    }
    
    if (yellowFaceUp.size() == 0) { // 1st case: dot
      seq = "fruRUFyyfruRUruRUFyy";
    } else if (yellowFaceUp.size() == 2) {
      // 2nd case: line
      if (abs(yellowFaceUp.get(0).pos.x) == abs(yellowFaceUp.get(1).pos.x) || 
          abs(yellowFaceUp.get(0).pos.z) == abs(yellowFaceUp.get(1).pos.z)) {
        // rotate to one of the yellow-facing-sideways edges
        Piece randomPiece = yellowFaceDown.get(floor(random(yellowFaceDown.size())));
        int axis = randomPiece.pos.x != 0 ? 0 : 2;
        int layer = floor(randomPiece.pos.x + randomPiece.pos.y + randomPiece.pos.z);
        seq += applyRotationToSequence("fruRUF", axis, layer);
      } else { // 3rd case: L shape
        int leftPieceIndex = compareNormals(yellowFaceUp.get(0).pos, yellowFaceUp.get(1).pos) ? 1 : 0;
        // rotate to the side facing away from the leftmost edge
        PVector pos = yellowFaceUp.get(leftPieceIndex).pos;
        int axis = pos.x != 0 ? 0 : 2;
        int layer = -floor(pos.array()[axis]);
        seq += applyRotationToSequence("fruRUruRUF", axis, layer);
      }
    } else { // case 4: cross already solved -> do nothing
      nextStep(1);
      return;
    }

    performSequence(seq);
    nextStep(1);
  }

  void permutateYellowCross() {
    println("Permutating the Yellow Cross");
    doneStep = false;
    String seq = "";
    String baseAlg = "ruRuruuR";

    ArrayList<Face> sideFacesAxisX = new ArrayList<Face>();
    ArrayList<Face> sideFacesAxisZ = new ArrayList<Face>();
    for (Piece piece : yellowCrossPieces) {
      for (Face face : piece.faces) {
        if (face.c != color(0) && face.c != color(255, 255, 0)) {
          if (face.normal.x != 0) sideFacesAxisX.add(face);
          else sideFacesAxisZ.add(face);
        }
        continue; // no need to check the remaining faces
      }
    }

    // distinguish between the two cases
    PVector centerNormal1 = FACE_COLOR_MAP.get(sideFacesAxisX.get(0).c);
    PVector centerNormal2 = FACE_COLOR_MAP.get(sideFacesAxisX.get(1).c);
    PVector centerNormal3 = FACE_COLOR_MAP.get(sideFacesAxisZ.get(0).c);
    PVector centerNormal4 = FACE_COLOR_MAP.get(sideFacesAxisZ.get(1).c);
    // case 1: opposite colors
    if (abs(centerNormal1.x) == abs(centerNormal2.x)) {
      if (compareNormals(sideFacesAxisX.get(0).normal, sideFacesAxisZ.get(0).normal) == compareNormals(centerNormal1, centerNormal3)) {
        // already solved -> do nothing
        nextStep(1);
        return;
      }
      int axis = sideFacesAxisX.get(0).normal.x != 0 ? 0 : 2;
      int layer = floor(sideFacesAxisX.get(0).normal.array()[axis]);
      seq = applyRotationToSequence(baseAlg + "U" + baseAlg, axis, layer);
    } else { // case 2: Z shape
      PVector cx, cz;
      int cxa, cza;
      for (Face fx : sideFacesAxisX) {
        cx = FACE_COLOR_MAP.get(fx.c);
        cxa = cx.x != 0 ? 0 : 2;
        for (Face fz : sideFacesAxisZ) {
          cz = FACE_COLOR_MAP.get(fz.c);
          cza = cz.x != 0 ? 0 : 2;
          boolean xToTheRight = compareNormals(fx.normal, fz.normal);
          boolean cxToTheRight = compareNormals(cx, cz);
          if (cxa != cza && xToTheRight == cxToTheRight) {
            int axis = xToTheRight ? 0 : 2;
            int layer = -floor(xToTheRight ? fx.normal.array()[axis] : fz.normal.array()[axis]);
            seq = applyRotationToSequence(baseAlg, axis, layer);
            break; // no need to keep searching
          }
        }
      }
    }

    performSequence(seq);
    nextStep(1);
  }

  void permutateYellowCorners() {
    println("Permutating the Yellow Corners: Step no. " + (currentStep + 1));
    doneStep = false;
    String baseAlg = "rULuRUlu";
    String seq = "";

    ArrayList<Piece> solvedPieces = new ArrayList<Piece>();
    for (Piece piece : yellowCornerPieces) {
      if (piece.isPermutated()) solvedPieces.add(piece);
    }

    // skip this phase if it is already done
    if (solvedPieces.size() == 4) {
      nextStep(1);
      return;
    } else if (solvedPieces.size() == 0) { // none solved -> do the alg from any angle
      performSequence(baseAlg);
      nextStep(3);
      return;
    }

    // put the solved piece on the left side of the cube
    Piece solved = solvedPieces.get(0);
    ArrayList<Face> sideFaces = new ArrayList<Face>();
    for (Face face : solved.faces) if (face.c != color(0) && face.normal.y == 0) sideFaces.add(face);
    // take the rightmost face normal
    PVector rightNormal = sideFaces.get(compareNormals(sideFaces.get(0).normal, sideFaces.get(1).normal) ? 0 : 1).normal;
    int axis = rightNormal.x != 0 ? 0 : 2;
    int layer = floor(rightNormal.array()[axis]);
    seq += applyRotationToSequence(baseAlg, axis, layer);

    performSequence(seq);
    nextStep(3);
  }

  void orientYellowCorners() {
    println("Orienting Yellow Corner no. " + (currentStep + 1));
    orientNextYellowCorner(yellowCornerPieces.get(currentStep));
    nextStep(4);
  }

  String axisTurnToString(int axis, int layer, int dir) {
    String move = "";
    switch (axis) {
      case 0: move = layer > 0 ? "r" : "L"; break;
      case 1: move = layer > 0 ? "u" : "D"; break;
      case 2: move = layer > 0 ? "f" : "B"; break;
    }
    
    // switch move case if the direction is negative
    if (dir < 0) return move.toUpperCase() == move ? move.toLowerCase() : move.toUpperCase();
    return move;
  }

  String getAUF(int axis, int intendedAxis, int layer, int intendedLayer) {
    if (axis == intendedAxis) {
      // same axis, different layers
      if (layer != intendedLayer) return "uu"; // turn the top layer twice
      return ""; // no need to turn the top layer
    }
    if ((intendedAxis > axis && layer == intendedLayer) ||
      (intendedAxis < axis && layer != intendedLayer)) return "u"; // turn the top layer clockwise
    return "U"; // turn the top layer counter-clockwise
  }

  void fixAUF() {
    println("Fixing the Top Layer");
    doneStep = false;
    Face sideFace = null;
    for (Face face : yellowCrossPieces.get(0).faces) {
      if (face.c != color(0) && face.c != color(255, 255, 0)) {
        int axis = face.normal.x != 0 ? 0 : 2;
        int layer = floor(face.normal.array()[axis]);
        PVector centerNormal = FACE_COLOR_MAP.get(face.c);
        int intendedAxis = centerNormal.x != 0 ? 0 : 2;
        int intendedLayer = floor(centerNormal.array()[intendedAxis]);
        performSequence(getAUF(axis, intendedAxis, layer, intendedLayer));
        nextStep(1);
        return;
      }
    }
  }

  String applyRotationToSequence(String sequence, int intendedAxis, int intendedLayer) {
    // originAxis = 2, originLayer = 1 //

    // get the starting rotation
    String startingRotation = "";
    if (2 == intendedAxis) {
      // same axis, different layers
      if (1 != intendedLayer) startingRotation = "yy"; // rotate twice
    } else if ((intendedAxis > 2 && 1 == intendedLayer) ||
      (intendedAxis < 2 && 1 != intendedLayer)) startingRotation = "Y"; // rotate clockwise
    else startingRotation = "y"; // rotate counter-clockwise

    // reverse the rotation
    String endRotation = startingRotation == "y" ? "Y" : startingRotation == "Y" ? "y" : startingRotation;
    return startingRotation + sequence + endRotation;
  }

  int dirToUp(PVector whiteOrientation, PVector colorOrientation, int layer) {
    // get the face that is normal to the z-axis
    boolean zNormalWhite = whiteOrientation.z != 0;
    int whiteSum = floor(whiteOrientation.x + whiteOrientation.y + whiteOrientation.z);
    int colorSum = floor(colorOrientation.x + colorOrientation.y + colorOrientation.z);
    // if the sums are equal, than the z-axis normal is the leftmost vector
    return layer * (whiteSum == colorSum ? 1 : -1) * (zNormalWhite ? 1 : -1);
  }

  boolean compareNormals(PVector normal1, PVector normal2) {
    // returns whether the first normal is the rightmost vector of the two //
    // get the vector that is on the z-axis
    boolean zNormalFirst = normal1.z != 0;
    int firstSum = floor(normal1.x + normal1.y + normal1.z);
    int secondSum = floor(normal2.x + normal2.y + normal2.z);
    // if the sums are equal, than the z-axis normal is the leftmost vector
    if (firstSum == secondSum) return !zNormalFirst;
    return zNormalFirst;
  }

  boolean vectorsAreEqual(PVector a, PVector b) {
    return a.x == b.x && a.y == b.y && a.z == b.z;
  }

  boolean pieceSolved(Piece piece) {
    for (Face face : piece.faces) {
      if (face.c != color(0)) {
        PVector faceNormal = face.normal;
        PVector colorNormal = FACE_COLOR_MAP.get(face.c);
        if (!vectorsAreEqual(faceNormal, colorNormal)) return false;
      }
    }
    return true;
  }

  void solveNextCrossPiece(Piece piece) {
    if (pieceSolved(piece)) return; // already solved
    doneStep = false;
    String seq = "";

    // find y-axis layer, color and orientation
    float yLayer = piece.pos.y;
    Face whiteFace = null;
    Face colorFace = null;
    for (Face face : piece.faces) {
      if (face.c == color(255)) whiteFace = face;
      else if (face.c != color(0)) colorFace = face;
    }

    PVector whiteOrientation = whiteFace.normal;
    PVector colorOrientation = colorFace.normal;
    boolean topLayerCheckSkip = false;

    // 1st scenario
    if (yLayer == 1) { // the piece is at the bottom layer
      // turn the piece to the top layer
      PVector sidePieceOrientation = whiteOrientation.y == 0 ? whiteOrientation : colorOrientation;
      int layer = floor(sidePieceOrientation.x + sidePieceOrientation.y + sidePieceOrientation.z);
      int axis = floor(sidePieceOrientation.x != 0 ? 0 : sidePieceOrientation.y != 0 ? 1 : 2);
      
      // update the move sequence
      seq += axisTurnToString(axis, layer, 1);
      seq += axisTurnToString(axis, layer, 1);
      
      yLayer = -1; // update the yLayer
      // now that the piece is at the top layer, we can move to the third/fourth scenarios
    }

    // 2nd scenario
    if (yLayer == 0) { // the piece is fully facing sideways
      // turn the piece to the top layer
      int layer = floor(colorOrientation.x + colorOrientation.y + colorOrientation.z);
      int dir = dirToUp(whiteOrientation, colorOrientation, layer);
      int axis = floor(colorOrientation.x != 0 ? 0 : colorOrientation.y != 0 ? 1 : 2);
      
      // update the move sequence
      seq += axisTurnToString(axis, layer, dir); // move upwards
      seq += "uu"; // move the piece out of the way
      seq += axisTurnToString(axis, layer, dir * -1); // turn the layer back down
      seq += "uu"; // place the piece back where it is intended to be

      yLayer = -1; // update the yLayer
      topLayerCheckSkip = true; // skip the checking since the piece is not yet updated
      // now that white is facing upwards, we can move to the third scenario
    }

    if (yLayer == -1) { // the piece is at the top layer
      // 3rd scenario
      if (topLayerCheckSkip || whiteOrientation.y != 0) { // white is facing upwards
        PVector centerColorNormal = FACE_COLOR_MAP.get(colorFace.c);
        int layer = floor(colorOrientation.x + colorOrientation.y + colorOrientation.z);
        int axis = floor(colorOrientation.x != 0 ? 0 : colorOrientation.y != 0 ? 1 : 2);
        int intendedLayer = floor(centerColorNormal.x + centerColorNormal.y + centerColorNormal.z);
        int intendedAxis = floor(centerColorNormal.x != 0 ? 0 : centerColorNormal.y != 0 ? 1 : 2);

        // turn the cross edge until the side color is flash with the center color
        seq += getAUF(axis, intendedAxis, layer, intendedLayer);
        
        // finally, turn the face of the color normal twice to solve the cross edge
        seq += axisTurnToString(intendedAxis, intendedLayer, 1);
        seq += axisTurnToString(intendedAxis, intendedLayer, 1);

      // 4th scenario
      } else { // white is facing sideways
        PVector centerColorNormal = FACE_COLOR_MAP.get(colorFace.c);
        int layer = floor(whiteOrientation.x + whiteOrientation.y + whiteOrientation.z);
        int axis = floor(whiteOrientation.x != 0 ? 0 : whiteOrientation.y != 0 ? 1 : 2);
        int intendedLayer = floor(centerColorNormal.x + centerColorNormal.y + centerColorNormal.z);
        int intendedAxis = floor(centerColorNormal.x != 0 ? 0 : centerColorNormal.y != 0 ? 1 : 2);

        // move the cross edge until the side color is flash with the center color
        seq += getAUF(axis, intendedAxis, layer, intendedLayer);
        // finally, perform an insertion alg on the intended face
        seq += applyRotationToSequence("URfr", intendedAxis, intendedLayer);
      }
    }

    performSequence(seq);
  }

  void solveNextCornerPiece(Piece piece) {
    if (pieceSolved(piece)) return; // already solved
    doneStep = false;
    String seq = "";

    // find Y layer and orientation of the visible faces
    float yLayer = piece.pos.y;
    Face whiteFace = null;
    Face[] colorFaces = new Face[2];

    int i = 0;
    for (Face face : piece.faces) {
      if (face.c == color(255)) whiteFace = face;
      else if (face.c != color(0)) {
        colorFaces[i] = face;
        i++;
      }
    }

    // gather info about the faces of the corner piece
    PVector whiteOrientation = whiteFace.normal;
    PVector colorNormal1 = colorFaces[0].normal;
    PVector colorNormal2 = colorFaces[1].normal;
    // get the center normals of the two colors of the corner piece
    PVector centerColorNormal1 = FACE_COLOR_MAP.get(colorFaces[0].c);
    PVector centerColorNormal2 = FACE_COLOR_MAP.get(colorFaces[1].c);
    // declare the side color normal here
    PVector sideColorNormal = null;
    int side = 0;
    boolean topLayerCheckSkip = false; // check skip if the piece was already checked

    if (yLayer == 1) { // the piece is at the bottom layer
      // 1st scenario
      if (whiteOrientation.y == 1) { // the white face is facing down
        // get the face on the piece that has the color facing sideways
        int selectedNormal, axis, layer;
        boolean firstNormalToTheRight = compareNormals(colorNormal1, colorNormal2);

        // assume that the piece is on the right side of the face
        if (firstNormalToTheRight) {
          axis = colorNormal2.x != 0 ? 0 : 2;
          layer = floor(colorNormal2.array()[axis]);
          sideColorNormal = colorNormal1;
          whiteOrientation = colorNormal2;
        } else {
          axis = colorNormal1.x != 0 ? 0 : 2;
          layer = floor(colorNormal1.array()[axis]);
          sideColorNormal = colorNormal2;
          whiteOrientation = colorNormal1;
        }
        
        // rotate the cube and move the piece to the top layer
        seq += applyRotationToSequence("ruRU", axis, layer);
        side = 1;
      } else { // the white face is facing the sides
        // 2nd scenario
        sideColorNormal = colorNormal1.y != 0 ? colorNormal1 : colorNormal2; // set the side color normal
        PVector otherColorNormal = colorNormal1.y != 0 ? colorNormal2 : colorNormal1; // get the other color normal
        // compare the other color normal with the whie normal
        side = compareNormals(whiteOrientation, otherColorNormal) ? -1 : 1;
        int axis = whiteOrientation.x != 0 ? 0 : 2;
        int layer = floor(whiteOrientation.x + whiteOrientation.y + whiteOrientation.z);
        seq += applyRotationToSequence(side > 0 ? "rUR" : "Lul", axis, layer);
      }
      yLayer = -1; // now move to the 4th scenario
      topLayerCheckSkip = true;
    }

    if (yLayer == -1) { // the piece is at the top layer
      // 3rd scenario
      if (!topLayerCheckSkip && whiteOrientation.y != 0) { // the white face is facing up
        // get the face on the piece that has the color facing sideways
        int selectedNormal, axis, layer;
        boolean firstNormalToTheRight = compareNormals(colorNormal1, colorNormal2);

        // assume that the piece is on the right side of the face
        if (firstNormalToTheRight) {
          axis = colorNormal2.x != 0 ? 0 : 2;
          layer = floor(colorNormal2.array()[axis]);
        } else {
          axis = colorNormal1.x != 0 ? 0 : 2;
          layer = floor(colorNormal1.array()[axis]);
        }

        // check which normal is the rightmost of the two vector
        boolean firstCenterToTheRight = compareNormals(centerColorNormal1, centerColorNormal2);
        // now define the desired spot for the white face of the corner piece
        int selectedCenter, intendedAxis, intendedLayer;
        if (firstCenterToTheRight) selectedCenter = 1;
        else selectedCenter = 0;

        if (selectedCenter == 0) { // move the corner piece to the first center face
          intendedAxis = centerColorNormal1.x != 0 ? 0 : 2;
          intendedLayer = floor(centerColorNormal1.array()[intendedAxis]);
        } else { // move the corner piece to the second center face
          intendedAxis = centerColorNormal2.x != 0 ? 0 : 2;
          intendedLayer = floor(centerColorNormal2.array()[intendedAxis]);
        }

        // obtain the U moves required to move the piece to the desired position
        seq += getAUF(axis, intendedAxis, layer, intendedLayer);
        seq += applyRotationToSequence("ruuRUruR", intendedAxis, intendedLayer);
      }
      
      else if (topLayerCheckSkip || whiteOrientation.y == 0) { // the white face is facing the sides
        // 4th scenario
        if (!topLayerCheckSkip) {
          // get the face on the piece that has the color facing sideways
          sideColorNormal = colorNormal1.y == 0 ? colorNormal1 : colorNormal2;
          // check if the white face is supposed to be inserted on the right side or on the left side of the face
          side = compareNormals(whiteOrientation, sideColorNormal) ? -1 : 1;
        }

        // check which normal is the rightmost of the two vector
        boolean firstCenterToTheRight = compareNormals(centerColorNormal1, centerColorNormal2);
        // now define the desired spot for the white face of the corner piece
        int selectedCenter, intendedAxis, intendedLayer;
        if (firstCenterToTheRight) selectedCenter = side > 0 ? 1 : 0;
        else selectedCenter = side > 0 ? 0 : 1;

        if (selectedCenter == 0) { // move the corner piece to the first center face
          intendedAxis = centerColorNormal1.x != 0 ? 0 : 2;
          intendedLayer = floor(centerColorNormal1.array()[intendedAxis]);
        } else { // move the corner piece to the second center face
          intendedAxis = centerColorNormal2.x != 0 ? 0 : 2;
          intendedLayer = floor(centerColorNormal2.array()[intendedAxis]);
        }

        // obtain the U moves required to move the piece to the desired position
        int axis = whiteOrientation.x != 0 ? 0 : 2;
        int layer = floor(whiteOrientation.x + whiteOrientation.y + whiteOrientation.z);
        seq += getAUF(axis, intendedAxis, layer, intendedLayer);
        seq += applyRotationToSequence(side > 0 ? "urUR" : "ULul", intendedAxis, intendedLayer);
      }
    }

    performSequence(seq);
  }

  void solveNextF2LPiece(Piece piece) {
    if (pieceSolved(piece)) return; // already solved
    doneStep = false;
    String seq = "";
    
    Face[] colorFaces = new Face[2];
    int i = 0;
    for (Face face : piece.faces) {
      if (face.c != color(0)) {
        colorFaces[i] = face;
        i++;
      }
    }

    Face sideFace = null;
    int topFaceColor = 0;
    int axis = 0;
    int layer = 0;
    boolean topLayerCheckSkip = false;

    // find the y-layer of the edge piece
    float yLayer = piece.pos.y;

    if (yLayer == 0) { // 1st scenario: the piece is at the middle layer
      // assume that the piece is at the right side of the cube
      int frontFaceIndex = compareNormals(colorFaces[0].normal, colorFaces[1].normal) ? 1 : 0;
      // the font face will end up as the top face in the second scenario
      Face topFace = colorFaces[frontFaceIndex];
      sideFace = colorFaces[1 - frontFaceIndex];
      topFaceColor = topFace.c;
      axis = topFace.normal.x != 0 ? 0 : 2;
      layer = -floor(topFace.normal.x + topFace.normal.y + topFace.normal.z);

      // get the rotation and move the piece to the top layer
      seq += applyRotationToSequence("rURUFuf", axis, -layer);

      yLayer = -1; // now go on to the second scenario
      topLayerCheckSkip = true;
    }

    if (yLayer == -1) { // 2nd scenario: the piece is at the top layer
      if (!topLayerCheckSkip) {
        if (colorFaces[0].normal.y == 0) {
          sideFace = colorFaces[0];
          topFaceColor = colorFaces[1].c;
        } else {
          sideFace = colorFaces[1];
          topFaceColor = colorFaces[0].c;
        }

        axis = sideFace.normal.x != 0 ? 0 : 2;
        layer = floor(sideFace.normal.x + sideFace.normal.y + sideFace.normal.z);
      } 
      
      // get the AUF & rotation and solve the piece
      PVector centerColorNormal = FACE_COLOR_MAP.get(sideFace.c);
      PVector sideColorNormal = FACE_COLOR_MAP.get(topFaceColor);
      int side = compareNormals(centerColorNormal, sideColorNormal) ? -1 : 1;
      int intendedAxis = centerColorNormal.x != 0 ? 0 : 2;
      int intendedLayer = floor(centerColorNormal.x + centerColorNormal.y + centerColorNormal.z);
      seq += getAUF(axis, intendedAxis, layer, intendedLayer);
      seq += applyRotationToSequence(side > 0 ? "urURUFuf" : "ULulufUF", intendedAxis, intendedLayer);
    }

    performSequence(seq);
  }

  void orientNextYellowCorner(Piece piece) {
    // assume that the corner piece is on the right side of the cube
    doneStep = false;
    String baseAlg = "RDrdRDrd";
    String seq = "";

    // distinguish between the 3 cases
    ArrayList<Face> sideFaces = new ArrayList<Face>();
    Face yellowFace = null;
    for (Face face : piece.faces) {
      if (face.c != color(0) && face.normal.y == 0) sideFaces.add(face);
      if (face.c == color(255, 255, 0)) yellowFace = face;
    }

    int yellowIndex = sideFaces.indexOf(yellowFace);
    // case 1: yellow at the top -> already solved, do nothing
    if (yellowIndex != -1) {
      boolean yellowOnTheRight = compareNormals(yellowFace.normal, sideFaces.get(1 - yellowIndex).normal);
      Face leftFace = yellowOnTheRight ? sideFaces.get(1 - yellowIndex) : yellowFace;
      // get the U moves
      int axis = leftFace.normal.x != 0 ? 0 : 2;
      int layer = floor(leftFace.normal.array()[axis]);
      seq += getAUF(axis, 2, layer, 1);
      seq += baseAlg; // case 2: yellow is on the right side -> do base alg once
      if (!yellowOnTheRight) seq += baseAlg; // case 3: yellow is on the right side -> do base alg twice
    }

    performSequence(seq);
  }
}