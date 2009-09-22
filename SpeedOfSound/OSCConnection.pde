import oscP5.*;
import netP5.*;


class OSCConnection {
    public OscP5 oscP5;
    /* a NetAddress contains the ip address and port number of a remote location in the network. */
    public NetAddress oscDestination; 
    LemurPoint[] points;

    OSCConnection (Object theParent, String server, int port) {
        /* create a new instance of oscP5. 
        * 12000 is the port number you are listening for incoming osc messages.
        */
        oscP5 = new OscP5(theParent,12000);

        /* create a new NetAddress. a NetAddress is used when sending osc messages
        * with the oscP5.send method.
        */

        /* the address of the osc broadcast server */
        oscDestination = new NetAddress(server,port);
    }

    void sendPointsToOSC(LemurPoint[] points) {
        /* Update lemur with the new points.. important for visualisation that
         * move the points around (but lemur physics should be turned off)
         */

        // Base path
        String pointPath = new String("/points/");// + p.index + "/");
        // send x,y coordinates
        OscMessage xOscMessage = new OscMessage(pointPath + "x");
        OscMessage yOscMessage = new OscMessage(pointPath + "y");
        float[] xs = new float[points.length];
        float[] ys = new float[points.length];
        //for (LemurPoint p : points) {
        for (int i = 0; i < points.length; i++) {
            LemurPoint p = points[i];
            xs[i] = (float) p.x / width;
            ys[i] = 1.0 - (float) p.y / height;
        }
        /* add a value to the OscMessage */
        xOscMessage.add(xs);
        yOscMessage.add(ys);
        /* send the OscMessage to a remote location */
        oscP5.send(xOscMessage, oscDestination);
        oscP5.send(yOscMessage, oscDestination);
    }

    void connectToPoints(LemurPoint[] points) {
        this.points = points;
        osc.sendPointsToOSC(points);  
    }

    void updateX(int i, float x) {
        if (points != null && i < points.length) {
            points[i].x = (int) (x * width);
        }
    }

    void updateY(int i, float y) {
        if (points != null && i < points.length) {
            points[i].y = (int) ( (1.0 - y) * height);
        }
    }
    
    void changePreset(int p) {
      if (p >= 0 && p < numPointSets) {
        currentPreset = p;
        connectToPoints(pointSets[currentPreset]);
      }
      sendNumPointsToOSC();
    }
    
    void sendNumPointsToOSC() {
      int active = 0;
      for (int i = 0; i < pointSets[currentPreset].length; i++) {
        if (pointSets[currentPreset][i].active) {
          active ++;
        }
      }
      
      OscMessage numOscMessage = new OscMessage("/NumPoints/x");
      float num = active;
      numOscMessage.add(num);
      
      oscP5.send(numOscMessage, oscDestination);
    }
    

    void handleMessage(OscMessage theOscMessage) {
        String path = theOscMessage.addrPattern();
        /* get and print the address pattern and the typetag of the received OscMessage */
        println("SOS received an osc message with addrpattern "+path+" and typetag "+theOscMessage.typetag());
        theOscMessage.print();
        String elements[] = path.split("/");
        println(elements);
        if (elements[1].equals("points")) {
            //int pIndex = Integer.parseInt(path.substring(6,path.indexOf("/",6)));
            if (elements[2].equals("x")) {
                int pointCount = theOscMessage.typetag().length();
                for (int i = 0; i < pointCount; i++) {
                    float x = theOscMessage.get(i).floatValue();
                    updateX(i,x);
                }
            } else if (elements[2].equals("y")) {
                int pointCount = theOscMessage.typetag().length();
                for (int i = 0; i < pointCount; i++) {
                    float y = theOscMessage.get(i).floatValue();
                    updateY(i,y);
                }
            }
        } else if (elements[1].equals("PointsPreset") &&
            elements[2].equals("x")) {
            int presetCount = theOscMessage.typetag().length();
            int pIndex = 0;
            for (int i = 0; i < presetCount; i++) {
                float x = theOscMessage.get(i).floatValue();
                if (x == 1.0) {
                  pIndex = i; break;
                }
            }
            changePreset(pIndex);
        } else if (elements[1].equals("NumPoints")) {
          int numPoints = int(round(theOscMessage.get(0).floatValue()));
          for (int i = 0; i < pointSets[currentPreset].length; i++) {
            if (i >= numPoints) {
              pointSets[currentPreset][i].active = false;
            } else {
              pointSets[currentPreset][i].active = true;
            }
          }
        } else if (elements[1].equals("BackgroundSource")) {
          int backgroundCount = theOscMessage.typetag().length();
          int bIndex = 0;
          for (int i = 0; i < backgroundCount; i++) {
            float x = theOscMessage.get(i).floatValue();
            if (x == 1.0) {
              bIndex = i; break;
            }
          }
          if (bIndex < vids.length) {
            sosMovie.switchVideo(vids[bIndex]);
            sosMovie.loop();
          } else {
            sosMovie.switchVideo(vids[0]); // Revert to default video
            sosMovie.loop();
          }
        } else if (elements[1].equals("VideoSpeed")) {
          int speed = int(round(theOscMessage.get(0).floatValue()));
          if (speed == 1) {
            sosMovie.setRate(speed);
          } else {
            sosMovie.setRate(speed * 2);
          }
        } else if (elements[1].equals("RorschachToggle")) {
          int bool = int(round(theOscMessage.get(0).floatValue()));
          if (bool == 1) {
            useRorschach = true;
          } else {
            useRorschach = false;
          }
        } else if (elements[1].equals("ResetRorschach")) {
          rorschachLayer.resetParams();
        } else if (elements[1].equals("SizeRange")) {
          int bottom = int(round(theOscMessage.get(0).floatValue()));
          int top = int(round(theOscMessage.get(1).floatValue()));
          pArtist.beatSize = top * 10;
          pArtist.minSize = bottom * 10;
        }
    }

}
