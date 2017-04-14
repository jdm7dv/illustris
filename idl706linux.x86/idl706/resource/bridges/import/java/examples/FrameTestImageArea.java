/*
  Copyright (c) 2002-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.util.Vector;
import java.io.File;

public class FrameTestImageArea extends RSIImageArea
                                implements MouseMotionListener,
                                           MouseListener {

        
    int m_boxw = 100;
    int m_boxh = 100;
    Dimension c_dim;
    boolean m_pressed = false;
    int m_button = 0;
    Vector c_resizelisteners = null;

    public FrameTestImageArea(String imgFile, Dimension dim) {
       super(imgFile, dim);
        
        c_dim = dim;
        addMouseMotionListener(this);
        addMouseListener(this);
        
    }

    public void addResizeListener(FrameTestImageAreaResizeListener l) {
        if (c_resizelisteners == null) 
           c_resizelisteners = new Vector();
        if (! c_resizelisteners.contains(l))  
           c_resizelisteners.add(l);
    }  
    public void removeResizeListener(FrameTestImageAreaResizeListener l) {
        if (c_resizelisteners == null) 
           return;             
        if (c_resizelisteners.contains(l)) 
           c_resizelisteners.remove(l);
    }

    public void displayImage() {
        Graphics g = getGraphics();
        update(g);
    }

    public void paint(Graphics g) {
        int xsize = getWidth();
        int ysize = getHeight();            
        if (xsize != -1 && ysize != -1) {
            if (xsize != c_dim.width || ysize != c_dim.height) {
                c_dim.width = xsize;
                c_dim.height = ysize;
                setPreferredSize(c_dim);
                setSize(c_dim);
                if (c_resizelisteners != null) {
                    FrameTestImageAreaResizeListener l = null;                    
                    for (int j=0;j<c_resizelisteners.size();j++) {
                        l = (FrameTestImageAreaResizeListener) c_resizelisteners.elementAt(j);
                        l.areaResized(xsize, ysize);
                    }
                }
            }
        }        
        super.paint(g);
    }

    public void setImageFile(String filename) {          
       super.loadImage(filename);
       displayImage();
    }

    public void drawZoomBox(MouseEvent e) {
        int bx = e.getX() - m_boxw/2;            
        bx = (bx >=0) ? bx :0;
        int by = e.getY() - m_boxh/2;
        by = (by >=0) ? by :0;
        int ex = bx + m_boxw;
        if  (ex > c_dim.width) {
            ex = c_dim.width;
            bx = c_dim.width-m_boxw;
        }
        int ey = by + m_boxh;
        if  (ey > c_dim.height) {
            ey = c_dim.height;
            by = c_dim.height-m_boxh;
        }
        
        displayImage();
        Graphics g = getGraphics();
        g.drawImage(super.m_img, bx, by, ex, ey, 
                    bx+(m_boxw/4),by+(m_boxh/4),
                    ex-(m_boxw/4),ey-(m_boxh/4),
                    null);
        g.setColor(Color.white);
        g.drawRect(bx, by, m_boxw, m_boxh);
    }
    
    public void mouseDragged(MouseEvent e) {
        drawZoomBox(e);
    }
    public void mouseMoved(MouseEvent e) {       
        
        Graphics g = getGraphics();
        if (m_pressed && (m_button == 1)) {
            drawZoomBox(e);                
            g.setColor(Color.white);
            g.drawString("DRAG", 10,10);
        } else {
            g.setColor(Color.white);
            String s = "("+e.getX()+","+e.getY()+")";
            displayImage();
            g.drawString(s, e.getX(), e.getY());
        }
        
    }
    
    public void mouseClicked(MouseEvent e) {}        
    public void mouseEntered(MouseEvent e) {}        
    public void mouseExited(MouseEvent e) {}
    
    public void mousePressed(MouseEvent e) {
        m_pressed = true;
        m_button = e.getButton();
        if (m_button == 1) drawZoomBox(e);
    }
    public void mouseReleased(MouseEvent e) {
        m_pressed = false;
        m_button = 0;
    }                
}
    
