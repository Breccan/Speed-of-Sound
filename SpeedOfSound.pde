/**
 * Speed of Sound Lemur interface
 * by Joel Pitt, Kelly, Will Marshall
 *
 * Adapted from example:
 * Frequency Energy 
 * by Damien Di Fede.
 *  
 * This sketch demonstrates how to use the BeatDetect object in FREQ_ENERGY mode.
 * You can use <code>isKick</code>, <code>isSnare</code>, </code>isHat</code>, 
 * <code>isRange</code>, and <code>isOnset(int)</code> to track whatever kind 
 * of beats you are looking to track, they will report true or false based on 
 * the state of the analysis. To "tick" the analysis you must call <code>detect</code> 
 * with successive buffers of audio. You can do this inside of <code>draw</code>, 
 * but you are likely to miss some audio buffers if you do this. The sketch implements 
 * an <code>AudioListener</code> called <code>BeatListener</code> so that it can call 
 * <code>detect</code> on every buffer of audio processed by the system without repeating 
 * a buffer or missing one.
 * 
 * This sketch plays an entire song so it may be a little slow to load.
 */

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;

LemurPoint[] points = new LemurPoint[10];

void setup()
{
  size(512, 200);
  smooth();
  
  minim = new Minim(this);

  song = minim.loadFile("marcus_kellis_theme.mp3", 2048);
  song.play();
  System.out.println(song.sampleRate());

  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);

  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(2);

  textFont(createFont("SanSerif", 16));
  textAlign(CENTER);

  // Create LemurPoint objects
  for (int i = 0; i < 10; i++) {
    points[i] = new LemurPoint(beat, i*10, i*10);
    points[i].setBand(i*2, i*2 + 3, 2);
  }    
}

void draw()
{
  background(0);
  fill(255);

  for (int i = 0; i < 10; i++) {
    points[i].drawPoint();
  }
  beat.drawGraph(this);

}

void stop()
{
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}
