// TODO: refactor this later
void initializeMoveMap(HashMap<String, String> moveMap) {
  // R notation
  moveMap.put("R", "r");
  moveMap.put("R\'", "R");
  moveMap.put("R2", "rr");
  
  // L notation
  moveMap.put("L", "l");
  moveMap.put("L\'", "L");
  moveMap.put("L2", "ll");

  // U notation
  moveMap.put("U", "u");
  moveMap.put("U\'", "U");
  moveMap.put("U2", "uu");
  
  // D notation
  moveMap.put("D", "d");
  moveMap.put("D\'", "D");
  moveMap.put("D2", "dd");

  // F notation
  moveMap.put("F", "f");
  moveMap.put("F\'", "F");
  moveMap.put("F2", "ff");
  
  // B notation
  moveMap.put("B", "b");
  moveMap.put("B\'", "B");
  moveMap.put("B2", "bb");

  // Y notation
  moveMap.put("y", "y");
  moveMap.put("y'", "yy");
}

// String XRotation = 'rflb';
// String[] YRotation = { 'ud', 'fb' };