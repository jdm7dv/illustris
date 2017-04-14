//  Copyright (c) 2005-2008, ITT Visual Information Solutions. All
//       rights reserved. Unauthorized reproduction is prohibited.
//
// Example of using an IDL graphics window within a Java app.
// This assumes that javaidlb.jar is in the same directory.
// Requires the IDL class definitions to be in your IDL path.
// Compile using the following command:
//   javac -classpath ".;javaidlb.jar" IDLWindowExample.java
// Usage:
//   java -cp ".;javaidlb.jar" IDLWindowExample <IDL classname>
// Examples:
//   java -cp ".;javaidlb.jar" IDLWindowExample IDLgrWindowExample
//   java -cp ".;javaidlb.jar" IDLWindowExample IDLitWindowExample
//   java -cp ".;javaidlb.jar" IDLWindowExample IDLitDirectWindowExample

import java.awt.*;
import javax.swing.*;
import com.idl.javaidl.*;

// Normally, the JIDLCanvas wrapper would be automatically generated
// by the Export Bridge Assistant. For simplicity, since we do not need
// to wrap any of the IDL object methods, we can write our own
// wrapper and just call the Constructor for our superclass.
class IDLWindow extends JIDLCanvas
{
  public IDLWindow(String idlClass) {
    super(idlClass, "Default_OPS_Name");
  }
}

// Here is the user-supplied Java application,
// which uses the above wrapper.
public class IDLWindowExample extends JFrame
implements JIDLOutputListener,JIDLNotifyListener
{
  private IDLWindow   m_canvas;
  public IDLWindowExample(String idlClass) {
    // Create our IDL canvas
    m_canvas = new IDLWindow(idlClass);
    m_canvas.setSize(450, 450);
    buildGUI(idlClass);
    pack();
    setVisible(true);
    // Now create the IDL object in the canvas
    // NOTE: this must occur AFTER setVisible
    m_canvas.createObject();
    m_canvas.addIDLOutputListener(this);
    m_canvas.addIDLNotifyListener(this);
  }
  // Set up our JFrame
  private void buildGUI(String idlClass) {
    setTitle(idlClass + " Graphics in a Canvas");
    setDefaultCloseOperation( WindowConstants.DISPOSE_ON_CLOSE );
    // add canvas and color chooser to app
    getContentPane().add(BorderLayout.CENTER, m_canvas);
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
  public void dispose () {
	 m_canvas.destroyObject();
	 super.dispose();
  }
  // Requires the IDL classname as input.
  public static void main(String[] argv) {
    IDLWindowExample app = new IDLWindowExample(argv[0]);
  }
}
