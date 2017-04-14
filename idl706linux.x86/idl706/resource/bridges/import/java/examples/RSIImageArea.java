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
import javax.swing.*;
import java.io.File;

public class RSIImageArea extends JComponent {

   // Member variables
   protected BufferedImage m_img;

   // Constructor
   public RSIImageArea(String imgFile, Dimension dim) {
      loadImage(imgFile);
      setPreferredSize(dim);
      setSize(dim);
   }

   // Mutators
   public BufferedImage getImageObj() {
      return m_img;
   }
   public int getHeight() {
      return m_img.getHeight();
   }
   public int getWidth() {
      return m_img.getWidth();
   }

   public void paint(Graphics g) {
      Rectangle rect = this.getBounds();
      if(m_img != null) {
         g.drawImage(m_img, 0, 0, rect.width, rect.height, this);
      }
   }

   // Load image by filename
   protected void loadImage(String sFilename) {
      BufferedImage bi = null;
      try {
         bi = javax.imageio.ImageIO.read(new File(sFilename));
      } catch(Exception e) {
         bi = null;
      }
      if (bi == null) {
         System.err.println("Error: File "+sFilename+" could not be loaded");
      }
      m_img = bi;
   }

   
}


