/*
  Copyright (c) 2002-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */

import java.awt.*;
import java.awt.image.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;

// Using Java to grab data from a src and giving to IDL
// 
public class RSIImageFrame extends JFrame {
   // Member variables
   String m_sFile;           // File name of Image loaded into m_imgArea
   RSIImageArea m_imgArea;   // Image GUI component
   int m_xsize;              // display size of imgArea component
   int m_ysize;              // display size of imgArea component
   Point m_point = null;     // last point selected in ImageArea 

   // Constructor
   public RSIImageFrame(String sTitle, String sFile, int w, int h) {
      super(sTitle);

      // Dispose the frame when the sys close is hit
      setDefaultCloseOperation(DISPOSE_ON_CLOSE);

      m_xsize = w;
      m_ysize = h;
      m_sFile = sFile;

      buildGUI();
   }

   // Create and display GUI
   public void buildGUI() {
      final String LABEL_TEXT = "Click on map to update IDL globe.";

      // create ImageArea and listen for mouse events
      m_imgArea = new RSIImageArea(m_sFile, 
                                   new Dimension(m_xsize, m_ysize));
      m_imgArea.addMouseListener(new MouseAdapter() {
         public void mousePressed(MouseEvent e) {

            if (m_point == null) {
               m_point = new Point(e.getX(), e.getY());
            } else {
               m_point.x = e.getX();
               m_point.y = e.getY();
            }
            repaint();

         }

      });

      Box box1 = Box.createVerticalBox();
      box1.add(new JLabel(LABEL_TEXT));
      box1.add(m_imgArea);

      getContentPane().add(box1);

      pack();
      setVisible(true);
   }

   // grab image data in 3D array
   public byte[][][]  getImageData() {
      byte [][][] bytearray = null;
      int width = 1;
      int height = 1;
      PixelGrabber pGrab;

      width  = m_imgArea.getWidth();
      height = m_imgArea.getHeight();

      if ((width > 0) && (height > 0)) {
         // pixarray for the grab - 3D bytearray for display        
         int [] pixarray = new int[width*height];            
         bytearray = new byte[3][width][height];


         // create a pixel grabber - out of AWT grabs img data
         pGrab = new PixelGrabber(m_imgArea.getImageObj(), 
                                  0,0, width, height, pixarray, 0, width);

         // grab the pixels from the image
         try {
            boolean b = pGrab.grabPixels();
         } catch (InterruptedException e) {
            System.err.println("pixel grab interrupted");
            return bytearray;
         }

         // break down the 32-bit integers from the grab into 8-bit bytes
         // and fill the return 3D array ARGB -- this is why ION
         // doesn't support True color.
         int pixi = 0;
         int curpix = 0;
         for (int j=0;j<height;j++) {
            for (int i=0;i<width;i++) {
               curpix = pixarray[pixi++];
               bytearray[0][i][j] = (byte) ((curpix >> 16) & 0xff);
               bytearray[1][i][j] = (byte) ((curpix >>  8) & 0xff);
               bytearray[2][i][j]  = (byte) ((curpix      ) & 0xff);
            }
         }
      }
      return bytearray;

   }


   // return last cursor position (in pixels) to IDL
   public int[] getLastCursorPos(boolean transY) {
      int [] ret = {0, 0};
      if (m_point != null) {
         ret[0] = m_point.x;
         //  translate Y if requested
         ret[1] = (transY) ? m_imgArea.getHeight()-m_point.y : m_point.y;
      } 

      return ret;
   }

   // Allows testing from the command line
   // e.g. > java -classpath . RSIImageFrame
   public static void main(String [] args) {
      final String FILENAME = "d:\\rsi\\idl61\\examples\\data\\avhrr.png";
      RSIImageFrame f = new RSIImageFrame("testing", FILENAME, 720, 360);
   }
}    
