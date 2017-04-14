/*
'  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
'       rights reserved. Unauthorized reproduction is prohibited.
'
'+
'  FILE:
'       export_grwindow_doc_example.java
'
'  CALLING SEQUENCE: None.
'
'  PURPOSE:
'       Demonstrates how to access features of a custom IDL object in a
'       Java application once the IDL object has been exported by the IDL
'       Bridge Export Assistant. This object creates a monochrome or RGB
'       histogram plot for a selected image file. For instructions on using
'       this Java file, search the Online Help index for the name of this file.
'
'  MAJOR TOPICS: Bridges
'
'  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
'       export_grwindow_doc__define.pro
'       Export Bridge Assistant needs to be used to generate:
'       export_grwindow_doc directory which contains
'          export_grwindow_doc.java
'          export_grwindow_doc.class
'
'  NAMED STRUCTURES:
'       none.
'
'  COMMON BLOCS:
'       none.
'
'  MODIFICATION HISTORY:
'       1/06,   SM - written
'-
'-----------------------------------------------------------------
*/

package export_grwindow_doc;
import com.idl.javaidl.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;

// This object extends JFrame..
public class export_grwindow_doc_example extends JFrame
implements JIDLOutputListener,JIDLNotifyListener
{
   //Member variables
   private export_grwindow_doc  m_canvas;
   private JList styleList;
   private String lineStyles[ ] = {"Solid (default)", "Dotted", "Dashed", "Dash dot", "Dash dot dot dot", "Long dash",	"No line drawn"};
   private JButton Openbtn;

   //Note the order of the method calls - this is very important.
   public export_grwindow_doc_example( ) {
   // Create our IDL canvas
   m_canvas = new export_grwindow_doc();
   m_canvas.setSize(650, 500);

   // Building the GUI using m_canvas and setting it visible must happen
   // before calling createObject(). Otherwise createObject will not have
   // a native Window to draw to.
   buildGUI();
   pack();
   setVisible(true);

   // Now create the IDL object in the canvas
   // NOTE: this must occur AFTER setVisible
   m_canvas.createObject();
   m_canvas.addIDLOutputListener(this);
   m_canvas.addIDLNotifyListener(this);
  }

   // Set up our JFrame; connect components and listeners
   private void buildGUI() {
      setTitle("IDLgrWindow Histogram Plot Example");
      setDefaultCloseOperation( WindowConstants.DISPOSE_ON_CLOSE );

      // add canvas and list
      this.styleList = new JList( this.lineStyles);
      styleList.setSelectedIndex(0);
      styleList.setSelectionMode( ListSelectionModel.SINGLE_SELECTION );
      getContentPane().add(styleList, BorderLayout.WEST);
      styleList.addListSelectionListener( new listStyleChanged());
      // add button and generic listener
      Openbtn = new JButton("Open New Image");
      getContentPane().add(Openbtn,BorderLayout.SOUTH);
      Openbtn.addActionListener(
         new ActionListener()
         {
            public void actionPerformed( ActionEvent event)
            {
               // call IDL object's OPEN method
               String  sfile = new String();
	  	       m_canvas.OPEN(new JIDLString(sfile));
               styleList.setSelectedIndex(0);
            }
         }
      );
      getContentPane().add(m_canvas, BorderLayout.EAST);
   }

   // list listener
   class listStyleChanged implements ListSelectionListener {
      // This method is called each time the user changes the set of selected items
      public void valueChanged(ListSelectionEvent evt) {
         // When the user release the mouse button and completes the selection,
         // getValueIsAdjusting() becomes false
            if (!evt.getValueIsAdjusting()) {
               int index = styleList.getSelectedIndex();
               try {
                  if (m_canvas != null && m_canvas.isObjectCreated())
                     m_canvas.CHANGELINE(new JIDLInteger(index));
               } catch (Throwable e) {
                  e.printStackTrace();
               }
            }
         }
      }

   // implement JIDLOutputListener
   public void IDLoutput(JIDLObjectI obj, String sMessage) {
      System.out.println("IDL: "+sMessage);
   }
   // implement JIDLNotifyListener
   public void OnIDLNotify(JIDLObjectI obj, String s1, String s2) {
      System.out.println("OnIDLNotify: "+s1+" "+s2);
   }
   // Cleanup
   public void dispose() {
      m_canvas.destroyObject( );
      super.dispose();
   }
   public static void main( String[] argv ) {
      export_grwindow_doc_example example = new export_grwindow_doc_example( );
   }
}
