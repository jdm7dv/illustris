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
import java.io.File;

public class FrameTest extends JFrame {
   String m_filename;
   FrameTestImageArea c_imgArea;
   int m_xsize;
   int m_ysize;
   Box c_controlBox;

   public FrameTest(String filename) {
      super("Example IDL-Java Interaction");

      m_filename = filename;
      // Dispose the frame when the sys close is hit
      setDefaultCloseOperation(DISPOSE_ON_CLOSE);
      m_xsize = 350;
      m_ysize = 371;
      buildGUI();
   }

   public void buildGUI() {

      c_controlBox = Box.createVerticalBox();

/*
      JButton bLoadFile = new JButton("Load new file");
      bLoadFile.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            JFileChooser chooser = new JFileChooser(new File(m_filename));
            chooser.setDialogTitle("Enter a JPEG file");
            if (chooser.showOpenDialog(FrameTest.this) 
                                  == JFileChooser.APPROVE_OPTION) {

               java.io.File fname = chooser.getSelectedFile();
               String filename = fname.getPath();
               System.out.println(filename);
               c_imgArea.setImageFile(filename);
            }
         }
      });
*/
      JButton b1 = new JButton("Close");
      b1.addActionListener(new ActionListener() {
         public void actionPerformed(ActionEvent e) {
            dispose();
         }
      });

      c_imgArea = new FrameTestImageArea(m_filename,
            new Dimension(m_xsize,m_ysize));



      Box mainBox = Box.createVerticalBox();
      Box rowBox = Box.createHorizontalBox();       
      rowBox.add(b1);
//      rowBox.add(bLoadFile);

//      c_controlBox.add(l1);
      c_controlBox.add(rowBox);
      mainBox.add(c_imgArea);
      mainBox.add(c_controlBox);

      getContentPane().add(mainBox);

      pack();
      setVisible(true);
      c_imgArea.displayImage();
      c_imgArea.addResizeListener(new FrameTestImageAreaResizeListener() {
         public void areaResized(int newx, int newy) {
            Dimension cdim = c_controlBox.getSize(null);
            Insets i = getInsets();
            newx = i.left + i.right + newx;
            newy = i.top + cdim.height + newy + i.bottom;
            setSize(new Dimension(newx, newy));
         }
      });
   }
/*
   public void setImageData(int [] imgData, int xsize, int ysize) {
      MemoryImageSource ims = new MemoryImageSource(xsize, ysize, 
            imgData, 
            0, ysize);
      Image imgtmp = createImage(ims);
      Graphics g = c_imgArea.getGraphics();
      g.drawImage(imgtmp, 0, 0, null);

   }


   public void setImageData(byte [][][] imgData, int xsize, int ysize) {


      int newArray [] = new int[xsize*ysize];
      int pixi = 0;
      int curpix = 0;
      short [] currgb = new short[3];
      for (int i=0;i<m_xsize;i++) {
         for (int j=0;j<m_ysize;j++) {
            for (int k=0;k<3;k++) {
               currgb[k] = (short) imgData[k][i][j];
               currgb[k] = (currgb[k] < 128) ? (short) currgb[k] : (short) (currgb[k]-256);
            }
            curpix = (int) currgb[0] *  +
               ((int) currgb[1] * (int) Math.pow(2,8)) +
               ((int) currgb[2] * (int) Math.pow(2,16));
            newArray[pixi++] = curpix;                   
         }
      }

      MemoryImageSource ims = new MemoryImageSource(xsize, ysize, 
            newArray, 
            0, ysize);
      c_imgArea.setImageObj(c_imgArea.createImage(ims));

   }
*/
   public byte[][][] getImageData() 
   {
      int width = 1;
      int height = 1;
      PixelGrabber pGrab;

      width = m_xsize;
      height = m_ysize;

      // pixarray for the grab - 3D bytearray for display        
      int [] pixarray = new int[width*height];            
      byte [][][] bytearray = new byte[3][width][height];


      // create a pixel grabber
      pGrab = new PixelGrabber(c_imgArea.getImageObj(), 
            0,0, 
            width,height, 
            pixarray, 
            0, width);

      // grab the pixels from the image
      try {
         boolean b = pGrab.grabPixels();
      } catch (InterruptedException e) {
         System.err.println("pixel grab interrupted");
         return bytearray;
      }

      // break down the 32-bit integers from the grab into 8-bit bytes
      // and fill the return 3D array
      int pixi = 0;
      int curpix = 0;
      for (int j=0;j<m_ysize;j++) {
         for (int i=0;i<m_xsize;i++) {
            curpix = pixarray[pixi++];
            bytearray[0][i][j] = (byte) ((curpix >> 16) & 0xff);
            bytearray[1][i][j] = (byte) ((curpix >>  8) & 0xff);
            bytearray[2][i][j]  = (byte) ((curpix      ) & 0xff);
         }
      }
      return bytearray;
   }

}    
