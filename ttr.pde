// where will we store the output file?
String dataPath = "/Users/hapless/Documents/Processing/ttr/data/";
String filename = "userdata.tsv";

// which level to start on, and how many seconds per level
final int START_LEVEL = 1;
final int SEC_PER_LVL = 15;
int level = START_LEVEL;

// flag for how we want the keyboard keys to map to notes
final int TRACKER_STYLE = 0;
final int TYPING_STYLE = 1;
int kbd_style = TYPING_STYLE;


// libraries we need to play sound and write to a file
import ddf.minim.*;
import ddf.minim.ugens.*;
import java.io.FileWriter;

// main objects for producing sound
Minim       minim;  
AudioOutput out;
Oscil       wave;

// object for writing data to file
FileWriter output;

// hash map relates a 'key' to a 'value'
// eg, in freq_mappings, key 'g' is mapped to value 440
// so, each keyboard key is related to a frequency to play, and a note name to display
HashMap<Character, Float> freq_mappings;
HashMap<Character, String> note_mappings;
String available = "f j";

// keeps track of where to display text
// that code is very messy, wrote it in my first 24 hours of using Processing
int cx, cy, r, R;

// 'handles' to control the actual waveform
String note = "G";  // this is what gets displayed
float freq;         // this gets displayed, and controls the current pitch
float amp = 0.5;    // base amplitude
float decay = .97;  // every frame, multiply the amplitude by this factor
float decayed = 1;  // how much we've decayed so far

// will display a formula instead of note and frequency
boolean toggleText = false;  
String equation = "";


void setup() {
  // create our window and set the frame rate to 120 frames per second
  size(1000, 800);
  frameRate(120);

  // start with a nice middle G tone
  freq = 440 * pow(2, -2.0/12);
  
  // initialize hashmaps
  freq_mappings = new HashMap<Character, Float>();
  note_mappings = new HashMap<Character, String>();
  loadMappings(kbd_style);
  
  // get set up to display text
  PFont thisFont = createFont("Helvetica", 72);
  textFont(thisFont);
  cx = width / 2;
  cy = height / 2;
  r = min(cx, cy) / 2;
  R = r/2;

  // most of the audio code is ripped from an example in the minim documentation
  minim = new Minim(this);
  out = minim.getLineOut();                  // the Minim object creates our AudioOutput object
  wave = new Oscil(freq, amp, Waves.SINE );  // create nice sine wave, using the frequency and amplitude we specified earlier
  wave.patch( out );                         // patch the Oscil to the output

  
  // get ready to record key presses
  // this try/catch stuff is so that your program knows how to deal with predictable problems
  // in this case, issues can arise like you try to write to a file in a directory that doesn't exist
  // or maybe the hard drive is full, or you don't have permission to write in the directory you've specified
  try {
    output = new FileWriter(dataPath + filename, true);
    output.write("\n--\n" + month() + "/" + day() + "/" + year() + " " + hour() + ":" + minute() + "\n");
    output.write(kbd_style == TRACKER_STYLE ? "tracker style\n" : "typing style\n");
  } 
  catch (IOException e) {
    println("Can't output to file!");
    println("Look at line 2 in the source code and use a directory that actually exists on your computer");
    println("Hint: open the terminal and type pwd");
    exit();
  }
}



void draw()
{
  // black background, draw thin white lines
  background(0);
  stroke(255);
  strokeWeight(1);

  // draw the waveform by grabbing values from the output buffer
  for (int i = 0; i < out.bufferSize() - 1; i++){
    line( i,  cy/2  - out.left.get(i)*cy/4,  i+1, cy/2  -  out.left.get(i+1)*cy/4 );
    line( i, 3*cy/2 - out.right.get(i)*cy/4, i+1, 3*cy/2 - out.right.get(i+1)*cy/4 );
  }
    
  // draw the waveform we are using in the oscillator
  stroke( 128, 0, 0 );
  strokeWeight(4);
  for ( int i = 0; i < width-1; ++i ) {
    point( i, height/2 - (height*0.49) * wave.getWaveform().value( (float)i / width ) );
  }

  // update amplitude after decaying the waveform
  decayed = decayed * decay;
  wave.setAmplitude( amp * decayed);

  // display information about the note being played
  fill(255);
  textSize(72);
  if (toggleText) {
    equation = str(float(round(10.0*amp))/10.0)+"sin(2PI*"+str(int(freq))+"t)*exp(-kt)";
    text(equation, cx-15*equation.length(), cy+24);
  } else {
    text(note, cx/2-18*note.length(), cy+24);
    text(str(int(freq))+" Hz", 3*cx/2-18*(3+str(int(freq)).length()), cy+24);
  }
  
  // tell the user which keys are available
  fill(192);
  textSize(24);
  text("Available keys: " + available, 20, 20);
  
  // advance to next level if enough time has passed
  if(kbd_style == TYPING_STYLE && level * SEC_PER_LVL * 1000 < millis()) {
    // println("level: " + level + "\tlevel*SEC_PER_LVL*1000 = ", (level*SEC_PER_LVL*1000), "millis() = " + millis());
    level += 1;
    available = loadLevel();
  }
}


// this function is run whenever the the user presses a key
void keyPressed()
{ 
  // check if the key is associated with a frequency
  // if so, change the tone that is played, reset the decay, and write to the output file
  if (freq_mappings.containsKey(key)) {
    freq = freq_mappings.get(key);
    note = note_mappings.get(key);
    out.mute();
    wave.setFrequency(int(freq));
    out.unmute();
    decayed = 1;
    try {
      output.write(key + "\t" + millis() + "\n");
      println(key + "\t" + millis());
      output.flush();
    } 
    catch (IOException e) { }
  }

  // switch statements are roughly like if statements
  switch( key ) {  
  case ESC: 
    try {
      output.close();
    } 
    catch (IOException e) {
      println("Couldn't close file!");
    }
  
  // display the equation for the waveform 
  case '`': 
    toggleText = !toggleText;
    break;
    
  // change the waveform for the oscillator
  case '0':
    wave.setWaveform( Waves.SINE );
    break;
  case '[':
    wave.setWaveform( Waves.SQUARE );
    break;      
  case ']':
    wave.setWaveform( Waves.QUARTERPULSE );
    break;
  case '\\':
    wave.setWaveform( Waves.TRIANGLE );
    break;
  case '\'':
    wave.setWaveform( Waves.SAW );
    break;
  
  // control starting amplitude used when a new note is played
  case '=':
    amp += 0.1;
    if (amp > 1) amp = 1;
    break;
  case '-':
    amp -= 0.1;
    if (amp < 0) amp = 0;
    break;
    
    
  // control the decay rate
  case '.':
    decay -= 0.015;
    if (decay < 0.85) decay = 0.85;
    break;
  case '/':
    decay +=  0.015;
    if (decay > 1) decay = 1;
    break;

  default: 
    break;
  }

  wave.setAmplitude(amp * decayed);

}