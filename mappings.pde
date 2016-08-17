// this part is kind of messy

void loadMappings(int style) {
  
  // if we want to use the program like a tracker, this will map the keyboard keys to notes in that style
  // note that the white keys on a piano correspond to ZXCVBNM and QWERTYU, while the black keys are above and between them
  char[] tracker_style_keys            =  {'z', 's', 'x', 'd', 'c', 'v', 'g', 'b', 'h', 'n', 'j', 'm', ',', 
                                           'q', '2', 'w', '3', 'e', 'r', '5', 't', '6', 'y', '7', 'u', 'i'};
  float[] tracker_style_freq_exponents = {  -9,  -8,  -7,  -6,  -5,  -4,  -3,  -2,  -1,   0,   1,   2,   3, 
                                             3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15 };
  String[] tracker_style_notes         = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "c", 
                                           "c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b", "c\'" };


  // when we start out in learn-to-type mode, these are the only two keys available
  // however, this bit of code is now obsolete, replaced by loadLevel() below
  char[]   typing_style_keys   = {'f', 'j'};
  float[]  typing_style_exps   = {-2,   5};
  String[] typing_style_notes  = {"G", "d"};


  char[]   loading_keys;
  float[]  loading_exps;
  String[] loading_notes;


  

  if (style == TRACKER_STYLE) {
    println("tracker_style");
    loading_keys = tracker_style_keys;
    loading_exps = tracker_style_freq_exponents;
    loading_notes = tracker_style_notes;
  } else {
    println("typing_style");
    loadLevel();
    return;
    /*
    loading_keys  = typing_style_keys;
    loading_exps  = typing_style_exps;
    loading_notes = typing_style_notes;
    */
  }
  
  if (loading_keys.length != loading_exps.length || loading_keys.length != loading_notes.length) {
    println("Fatal error: not all arrays are same length");
    exit();
  }

  // actually stuff the values into the hash maps
  for (int i = 0; i< loading_keys.length; i++) { 
    freq_mappings.put(loading_keys[i], 440*pow(2, loading_exps[i]/12.0));  // here be maths
    note_mappings.put(loading_keys[i], loading_notes[i]); 
  }
}


// returns a string displayed to the user describing what keys can be pressed
String loadLevel() {
  freq_mappings.clear();
  note_mappings.clear();
  String avail = "";
  print("New level: ");
  
  char[] keys  =   {'f',  'j',     'd',  'k',     's',  'l',    'a',  ';',     'g',  'h',    
                    'r',  'u',     'e',  'i',     'w',  'o',    'q',  'p',     't',  'y',  
                    'v',  'm',     'c',  ',',     'x',  '.',    'z',  '/',     'b',  'n',
  };
  
  float[] exps  = { -2,   5,        -5,    7,      -7,   10,     -9,   12,       0,    3,      
                     10,  17,        7,   19,       5,   22,      3,   24,      12,   15,
                    -14,  -7,      -17,   -5,     -19,   -2,    -21,    0,     -12,   -9
  };
  
  String[] notes = { "G",  "D",    "E",  "e",     "D",  "c",    "C",  "a",     "A",  "c",      
                     "g",  "d",    "e", "e'",     "d", "c'",    "c", "a'",     "a", "c'",
                    "G,", "D,",    "E,", "E",    "D,",  "C",   "C,",  "A",    "A,", "C"
  }; 
  
  // we'll add two new keys every time we advance a level
  for(int i = 0; i < 2*level && i < keys.length; i++) {
    freq_mappings.put(keys[i], 440*pow(2, exps[i]/12.0));
    note_mappings.put(keys[i], notes[i]); 
    avail += keys[i];
    print(keys[i]);
  }
  print("\n");
  return avail;
  
}