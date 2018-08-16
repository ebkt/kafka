   ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                          Contains elements of code from a template by Lior Ben Gai                     //
 //                                    With additional acknowledgements below                              //
////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This Template is inspired by:
// RandomBook.pde example
// https://github.com/processing/processing/blob/master/java/libraries/pdf/examples/RandomBook/RandomBook.pde
// CountingStrings example
// https://github.com/processing/processing-docs/blob/master/content/examples/Topics/Advanced%20Data/CountingStrings/CountingStrings.pde
// Dictionary file source:
// https://raw.githubusercontent.com/sujithps/Dictionary/master/Oxford%20English%20Dictionary.txt
// as well as Daniel Shiffman's Word Counting in Processing tutorial
// https://www.youtube.com/watch?v=JRlqDsuK3Is

     ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    //                          A visualisation of Haruki Murakami's "Kafka On The Shore" (2002)             //
   //                        Specifically, a visualisation of each individual word that appears in          //
  //                            the novel in the order of how many times it appears in the text            //
 //                                       Elias Berkhout, December 2017-January 2018                      //
///////////////////////////////////////////////////////////////////////////////////////////////////////////


   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //  Running this code takes around 5 minutes. It will print & export a large PDF of between 1.1 and 1.5MB in size. //
 //     Progress can be tracked in the console and the program will be exited once the wordcounter reaches 10 470.  //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// declare variables and PDF export
import processing.pdf.*;
PGraphicsPDF pdf;

int wordCounter, numWords;
String[] lines;
String[] words;
String kafka;
String[] keys;

IntDict concordance;

// ----------------------------------------------------------------

void setup() {
  size(6000, 3375, PDF, "KafkaOnTheShore.pdf");
  background(255); // white background
  init();          // run init function to initialise variables
}

// ----------------------------------------------------------------

void draw() {
  // draw each word in concordance, until each word in the intdict is completed
  if (wordCounter < concordance.size()) {
    drawWord(keys[wordCounter]);
    wordCounter++;
    println("Wordcounter:");
    println( wordCounter );
  }

  // when each word has been drawn, stop the code
  if (wordCounter >= concordance.size()) {
    //  flush the file
    endRecord(); // close export
    exit(); // quit program
  }

  while (wordCounter >= concordance.size()) {
    break; // if we run out of words - break the loop
  }
}

// ----------------------------------------------------------------

void drawWord(String word) {

  // Loop through each letter in each word and draw a shape according to
  // the distance between letters, with the number of times the word appears
  // in the text altering the strokeWeight and alpha values.
  // Alpha values are extremely low, which, along with narrow strokeWeight,
  // provides intricate texture as they are drawn over and over one another

  for (int i = 0; i < word.length()-1; i++) {
    int count = concordance.get(keys[i]);

    // variables to find individual characters in the words
    char c = word.charAt(i);
    char c2 = word.charAt(i+1);

    // variables to measure the distance between characters in the word
    float a = c2-c;
    float b = c-c2;

    // map variables and counts to useful values
    float mapA = map(a, 0, 26, 0, width);
    float mapB = map(b, 0, 26, 0, height);
    float alpha = map(count, 1, 8651, 5, 0.1);
    float weight = map(count, 1, 8651, 5, 0);

    pushStyle();
    pushMatrix();
    noFill();
    stroke(0, alpha);
    strokeWeight(1);
    translate(width/2, height/2);
    beginShape();
      vertex(mapA, mapB);
      vertex(random(width), random(height));
      vertex(c*word.length(), c2*word.length());
      vertex(c2*word.length(), c*word.length());
    endShape();
    popMatrix();
    popStyle();

    // After a word's shape has been drawn, translate to draw arcs around a large circle.
    // The size of the circle the arcs trace is constant, but the angle/amount of the arc drawn is
    // controlled by the length of the word and the number of times it appears in the text.
    // strokeWeight and alpha values are controlled by the same values as above

    noFill();
    pushMatrix();
    pushStyle();
    stroke(200, 20, 20, alpha+5);
    translate(width/2, height/2);
    strokeWeight(weight+3);
    rotate(word.length()*(wordCounter/100));
    arc(0, width/4, height/40, height/40, (word.length()/HALF_PI), TWO_PI-count/10);
    popMatrix();
    popStyle();
  }
}

// ----------------------------------------------------------------

void init() {

  // Load the entire novel into an array of strings
  println("starting import... ");
  lines = loadStrings("KafkaOnTheShore.txt");       // import each line of the novel
  kafka = join(lines, " ");                         // join the lines into one large string
  words = splitTokens(kafka, " .,!?;:\\---");        // split the large string into individual words
  concordance = new IntDict();

  // concordance intdict counts the number of times each word appears in the text and stores each word,
  // along with the number of times it appears, in a keyArray
  for (int i = 0; i < words.length; i++) {
    concordance.increment(words[i].toLowerCase());
    keys = concordance.keyArray();
  }

  // sort the values of concordance in descending order, i.e. "the" is first as it appears
  // the most times of any word in the novel, and so on
  concordance.sortValuesReverse();
  println(concordance);

  // initialize counters
  wordCounter = 0;
  numWords = concordance.size();

  println("Ready! " + numWords + " words loaded.");
}
