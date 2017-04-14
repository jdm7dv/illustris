/*
  Copyright (c) 2002-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */

//
// Purpose: create an image of greyscale bands.
//

import java.awt.*;
import java.awt.image.*;

public class GreyBandsImage extends BufferedImage
{
 // Members
 private int m_height;
 private int m_width;


 //
 // ctor
 //
 public GreyBandsImage() {
    super(100, 100, BufferedImage.TYPE_INT_ARGB);
    generateImage();
    m_height = 100;
    m_width = 100;
 }

 //
 // private method to generate the image
 //
 private void generateImage() {
    Color c;
    int width  = getWidth();
    int height = getHeight();
    WritableRaster raster = getRaster();
    ColorModel model = getColorModel();

    int BAND_PIXEL_WIDTH = 5;
    int nBands = width/BAND_PIXEL_WIDTH;
    int greyDelta = 255 / nBands;
    for (int i=0 ; i < nBands; i++) {
          c = new Color(i*greyDelta, i*greyDelta, i*greyDelta);
          int argb = c.getRGB();
          Object colorData = model.getDataElements(argb, null);

          for (int j=0; j < height; j++) 
             for (int k=0; k < BAND_PIXEL_WIDTH; k++) 
                raster.setDataElements(j, (i*5)+k, colorData);
          
    }
 }


 //
 // mutators
 //
 public int[] getRawData() {
   Raster oRaster = getRaster();
   Rectangle oBounds = oRaster.getBounds(); 
   int[] data = new int[m_height * m_width * 4];

   data = oRaster.getPixels(0,0,100,100, data);
   return data;
 }
 public int getH() {return m_height; }
 public int getW() {return m_width; }


}

