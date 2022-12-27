class Cube {
  Piece[] pieces;
  int dim = 3;

  boolean animating = false;
  Move move = null;

  String sequence = "";
  int seqIndex = 0;

  // String XRotation = "fdbu";
  // String YRotation = "blfr";
  // String ZRotation = "uldr";
  // int xRotationAmount = 0;
  // int yRotationAmount = 0;
  // int zRotationAmount = 0;

  HashMap<Character, Character> rotationMap;
  HashMap<Character, Character> prevRotationMap;

  Cube() {
    pieces = new Piece[(int)Math.pow(dim, 3) - 1];
    rotationMap = new HashMap<Character, Character>();
    prevRotationMap = new HashMap<Character, Character>();
    for (char k : new char[] { 'r', 'l', 'u', 'd', 'f', 'b', 'y' }) {
      rotationMap.put(k, k);
      prevRotationMap.put(k, k);
    }

    println(rotationMap);

    int index = 0;
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          if (!(x == 0 && y == 0 && z == 0)) {
            pieces[index] = new Piece(x, y, z);
            index++;
          }
        }
      }
    }
  }

  void doSequence(String seq, boolean parsed) {
    if (parsed) {
      sequence = seq;
    } else {
      // parse the sequence
      String[] splitted = seq.split("\\s+");
      String newSeq = "";
      for (String m : splitted) {
        newSeq += MOVE_MAP.get(m);
      }
      
      sequence = newSeq;
    }
  }

  void applyRotation(int dir, int amount, String rotationString) {
    // get set of key bindings
    // EntrySet<Character> keys = rotationMap.keySet();
    // println("rotating");
    for (char k : rotationMap.keySet()) {
      // iterate through each binding
      char binding = rotationMap.get(k);
      int index = rotationString.indexOf(binding);
      // check if this binding is affected by the rotation
      if (index == -1) continue;
      // if it does, set a new binding to the given control key
      int newIndex = index + amount * dir;
      // fix index if it is out of bounds
      newIndex %= rotationString.length();
      while (newIndex < 0) {
        newIndex += rotationString.length();
      }
      // update the key binding
      rotationMap.replace(k, rotationString.charAt(newIndex));
    }
    // println("done", rotationMap);
  }

  void applyXRotation(int dir, int amount) {
    applyRotation(dir, amount, "fdbu");
  }

  void applyYRotation(int dir, int amount) {
    applyRotation(dir, amount, "blfr");
  }

  void applyZRotation(int dir, int amount) {
    applyRotation(dir, amount, "uldr");
  }

  // char updateMoveByRotation(char move, int amount, String rotationMoves) {
  //   // no rotations needed
  //   if (amount == 0) return move;

  //   // get index of move in the array
  //   int index = rotationMoves.indexOf(Character.toLowerCase(move));
  //   if (index == -1) return move;

  //   int newIndex = index + amount;
  //   // fix index if it is out of bounds
  //   newIndex %= rotationMoves.length();
  //   while (newIndex < 0) {
  //     newIndex += rotationMoves.length();
  //   }

  //   char newChar = rotationMoves.charAt(newIndex);
  //   // uppercase
  //   if (getMoveDir(move) == -1) return Character.toUpperCase(newChar);
  //   return newChar;
  // }

  void applyMove(char move) {
    if (!animating) {
      int dir = getMoveDir(move);
      char newMove = rotationMap.get(Character.toLowerCase(move));
      switch (newMove) {
        // x-fixed
        case 'r':
          animateAxis(0, 1, dir);
          break;
        case 'l':
          animateAxis(0, -1, -dir);
          break;

        // y-fixed
        case 'u': 
          animateAxis(1, -1, dir);
          break;
        case 'd':
          animateAxis(1, 1, -dir);
          break;

        // z-fixed
        case 'f':
          animateAxis(2, 1, dir);
          break;
        case 'b':
          animateAxis(2, -1, -dir);
          break;

        // rotations
        case 'y':
          applyYRotation(dir, 1);
      }
    }
  }

  int getMoveDir(char move) {
    if (Character.toLowerCase(move) == move) return 1;
    else return -1;
  }

  void animateAxis(int axis, int layer, int dir) {
    animating = true;
    move = new Move(axis, layer, dir);
  }

  void turnAxis(int axis, int layer, int dir) {
    switch (axis) {
      case 0:
        turnX(layer, dir);
        break;
      case 1:
        turnY(layer, dir);
        break;
      case 2:
        turnZ(layer, dir);
        break;
    }
  }

  void turnX(int layer, int dir) {
    for (Piece piece : pieces) {
      if (piece.pos.x == layer) {
        piece.turnX(dir);
      }
    }
  }

  void turnY(int layer, int dir) {
    for (Piece piece : pieces) {
      if (piece.pos.y == layer) {
        piece.turnY(dir);
      }
    }
  }

  void turnZ(int layer, int dir) {
    for (Piece piece : pieces) {
      if (piece.pos.z == layer) {
        piece.turnZ(dir);
      }
    }
  }

  void update() {
    // sequence
    if (sequence.length() > 0) {
      if (!animating) {
        applyMove(sequence.charAt(seqIndex));
        seqIndex++;
      }

      if (seqIndex == sequence.length()) {
        sequence = "";
        seqIndex = 0;
      }
    }

    // turn animation
    if (animating) {
      move.update();

      if (move.finished()) {
        turnAxis(move.axis, move.layer, move.dir);
        animating = false;
        move = null;
      }
    }
  }

  void show() {
    for (Piece piece : pieces) {
      push();
      // turning animation
      if (animating && piece.pos.array()[move.axis] == move.layer) {
        int dir = move.dir;
        if (move.axis == 1) {
          dir *= -1;
        }

        rotateAxis(move.axis, move.angle * dir);
      }
      piece.show();
      pop();
    }
  }
}