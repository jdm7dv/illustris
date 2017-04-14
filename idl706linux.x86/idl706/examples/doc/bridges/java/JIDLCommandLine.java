/*
'  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
'       rights reserved. Unauthorized reproduction is prohibited.
'
'+
'  FILE:
'       JIDLCommandLine.java
'
'  CALLING SEQUENCE: None.
'
'  PURPOSE:
'       Demonstrates how to use the stock Java object in a simple application
'       that replicates IDL command line functionality in a Java application.
'       For instructions on using this Java file, search the Online Help index
'       for the name of this file.
'
'  MAJOR TOPICS: Bridges
'
'  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
'       Classpath must reference javaidlb.jar
'
'  NAMED STRUCTURES:
'       none.
'
'  COMMON BLOCS:
'       none.
'
'  MODIFICATION HISTORY:
'       1/06,   PA - written
'-
'-----------------------------------------------------------------
*/
import com.idl.javaidl.*;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

public class JIDLCommandLine extends JFrame
implements JIDLOutputListener, ActionListener {
   java_IDL_connect idlobject;
   private JTextField command;
   private JTextArea output;
   public JIDLCommandLine( ) {
      super( "JIDLCommand" );
      buildGUI( );
      setVisible( true );
      setDefaultCloseOperation( WindowConstants.DISPOSE_ON_CLOSE );
      idlobject = new java_IDL_connect( );
      idlobject.createObject( );
      idlobject.addIDLOutputListener( this );
   }
   // implement IDLoutputListener
   public void IDLoutput( JIDLObjectI obj, String sMessage ) {
      output.append( sMessage );
   }
   public void actionPerformed( ActionEvent e ) {
     // Change mouse cursor to the hourglass
     setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
     try {
         String exstring = command.getText( );
         String upstring = exstring.toUpperCase( );
         // Exit java app if user types exit in command line
         if (upstring.equals("EXIT") ) {
			idlobject.destroyObject( );
            System.exit(0);
	     }
         command.setText( "" ); // Clear command line
         idlobject.executeString( exstring );
     }
     catch ( JIDLException j ) {
     // Do Nothing
   }
   // Reset the mouse cursor
   setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
   }

   private void buildGUI( ) {
      java.awt.GridBagConstraints gridBagConstraints;
      JLabel jLabel1 = new JLabel( "IDL>" );
      JLabel jLabel2 = new JLabel( "Output:" );
      JScrollPane jScrollPane = new JScrollPane( );
      command = new JTextField( );
      output = new JTextArea( );
      getContentPane( ).setLayout( new GridBagLayout( ) );
      setResizable( false );
      gridBagConstraints = new GridBagConstraints( );
      gridBagConstraints.gridx = 0;
      gridBagConstraints.gridy = 0;
      gridBagConstraints.ipadx = 4;
      gridBagConstraints.ipady = 4;
      getContentPane( ).add( jLabel1, gridBagConstraints );
      gridBagConstraints = new GridBagConstraints( );
      gridBagConstraints.fill = GridBagConstraints.HORIZONTAL;
      gridBagConstraints.ipadx = 4;
      gridBagConstraints.ipady = 4;
      gridBagConstraints.weightx = 3.0;
      gridBagConstraints.weighty = 1.0;
      getContentPane( ).add( command, gridBagConstraints );
      command.addActionListener( this );
      gridBagConstraints = new GridBagConstraints( );
      gridBagConstraints.gridx = 0;
      gridBagConstraints.gridy = 1;
      gridBagConstraints.ipadx = 4;
      gridBagConstraints.ipady = 4;
      getContentPane( ).add( jLabel2, gridBagConstraints );
      output.setColumns( 50 );
      output.setRows( 10 );
      output.setEditable( false );
      jScrollPane.setViewportView( output );
      gridBagConstraints = new GridBagConstraints( );
      gridBagConstraints.gridx = 1;
      gridBagConstraints.gridy = 1;
      gridBagConstraints.fill = GridBagConstraints.BOTH;
      gridBagConstraints.ipadx = 4;
      gridBagConstraints.ipady = 4;
      getContentPane( ).add( jScrollPane, gridBagConstraints );
      pack( );
   }

   // Cleanup
   public void dispose() {
      idlobject.destroyObject( );
      super.dispose();
   }

   public static void main( String args[] ) {
      JIDLCommandLine idlcommandline = new JIDLCommandLine( );
   }
}
