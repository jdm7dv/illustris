/*
'  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
'       rights reserved. Unauthorized reproduction is prohibited.
'
'+
'  FILE:
'       export_itwinmanip_doc_example.java
'
'  CALLING SEQUENCE: None.
'
'  PURPOSE:
'       Demonstrates how to access features of an IDLitWindow
'       in a Java application. This example draw a surface using
'       ISURFACE. A listbox contains tool-specific manipulator
'       strings that can be passed to a custom method that changes
'       the active manipulator in the view. You can zoom, rotate, pan
'       and perform other manipulations. This example also forwards
'       a delete key event to IDL to delete the selected visualizations.
'
'       Search for export_itwinmanip_doc_example.java in the Online Help
'       index to locate the section of documentation that describes
'       how to use the Export Bridge Assistant to create the .java
'       and .class files associated with this example.
'
'  MAJOR TOPICS: Bridges
'
'  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
'       export_itwinmanip_doc__define.pro
'       Export Bridge Assistant needs to be used to generate:
'       export_itwinamnip_doc directory which contains
'          export_itwinmanip_doc.java
'          export_itwinmanip_doc.class
'       export_itwinmanip_delete.java is a related Java file.
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
package export_itwinmanip_doc;
import com.idl.javaidl.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;


public class export_itwinmanip_doc_example extends JFrame
{
   //Member variables
   private export_itwinmanip_doc  m_canvas;
   private JList manipList;
   private String manipItems[ ] = {"Arrow", "Rotate", "View/Viewzoom", "Annotation/Text", "Annotation/Rectangle", "Annotation/Oval", "Annotation/Polygon", "Annotation/Freehand", "Surface Contour"};
   private JButton defaultBtn;

   //Note the order of the method calls - this is very important.
   public export_itwinmanip_doc_example( ) {
      // Create our IDL canvas
      m_canvas = new export_itwinmanip_delete();
      m_canvas.setSize(650, 500);

      // Building the GUI using m_canvas and setting it visible must happen
      // before calling createObject().  Otherwise createObject will not have
      // a native Window to draw to.
      buildGUI();
      pack();
      setVisible(true);

      // Now create the IDL object in the canvas
      // NOTE: this must occur AFTER setVisible
      m_canvas.createObject();
  }

   // Set up our JFrame; connect components and listeners
   private void buildGUI() {
   setTitle("IDLitWindow ISurface Manipulator Example");
   setDefaultCloseOperation( WindowConstants.DISPOSE_ON_CLOSE );

   // add canvas, button and list
   this.manipList = new JList( this.manipItems);
   manipList.setSelectedIndex(0);
   manipList.setSelectionMode( ListSelectionModel.SINGLE_SELECTION );
   getContentPane().add(manipList, BorderLayout.WEST);
   manipList.addListSelectionListener( new listStyleChanged());
   getContentPane().add(m_canvas, BorderLayout.EAST);

   // add button and generic handler
   defaultBtn = new JButton("Default Manipulator");
   getContentPane().add(defaultBtn,BorderLayout.SOUTH);
   defaultBtn.addActionListener(
      new ActionListener()
      {
         public void actionPerformed( ActionEvent event)
         {
            // Change the manipulator back to the Arrow and update listbox selection.
            String item = "Arrow";
            m_canvas.CHANGEMANIPULATOR(new JIDLString(item));
            //JList styleList = new JList( styleList.lineStyles);
            manipList.setSelectedIndex(0);
         }
      }
      );
   }

   // list listener
   class listStyleChanged implements ListSelectionListener {
      // This method is called each time the user changes the set of selected items
      public void valueChanged(ListSelectionEvent evt) {
         // When the user release the mouse button and completes the selection,
         // getValueIsAdjusting() becomes false
         if (!evt.getValueIsAdjusting()) {
            int index = manipList.getSelectedIndex();
            String value = manipItems[index];
            try {
               if (m_canvas != null && m_canvas.isObjectCreated())
	              m_canvas.CHANGEMANIPULATOR(new JIDLString(value));
            } catch (Throwable e) {
               e.printStackTrace();
            }
         }
      }
   }

   //Cleanup
   public void dispose() {
      m_canvas.destroyObject( );
      super.dispose();
   }

   public static void main( String[] argv ) {
      export_itwinmanip_doc_example example = new export_itwinmanip_doc_example( );
   }
}
