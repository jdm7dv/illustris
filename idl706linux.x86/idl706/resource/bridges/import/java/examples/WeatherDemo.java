/*
   Copyright (c) 2001-2008, ITT Visual Information Solutions. All
  rights reserved. This software includes information which is
  proprietary to and a trade secret of ITT Visual Information Solutions.
  It is not to be disclosed to anyone outside of this organization.
  Reproduction by any means whatsoever is prohibited without express
  written permission.
 */
import java.net.*;
import java.io.*;
import java.util.*;


public class WeatherDemo {
   static final String QUERY_BASE 
      = "http://iwin.nws.noaa.gov/iwin/co/climate.html";

   /** Query the web server for data.  
    *
    * Limit query to data section beginning with given sMarker 
    * and ending with .END
    */
   private static String queryWeatherData(BufferedReader in, String sMarker) {
      StringBuffer weather = new StringBuffer();
      String line;
      boolean bInSection = false;
      try {
         while((line = in.readLine()) != null) {
            if (!bInSection) {
               if (line.indexOf(sMarker) >= 0) {
                  bInSection = true;
               }
            }
            else {
               if (line.indexOf(".END") >= 0) {
                  break;
               } else {
                  // valid weather lines have a "::" in them
                  if (line.indexOf("::") >= 0) 
                     weather.append(line + '\n');
               }

            }
         }
      } catch (IOException e) {
      }

      return weather.toString();            
   }

   /** Parse the data into a simple, comma delimited list
    *
    * Format looks like:
    *   <id>: <city>   ::  <elev>  <time>:   <high> / <low> / ....
    * For example:
    *   LGRC2: BOULDER ::  8500  1907:   M / 34 /    0 /   0 /  0
    */
   private static String parseWeatherData(String data) {
      StringBuffer outBuffer = new StringBuffer();

      StringTokenizer token;
      StringTokenizer lineToken = new StringTokenizer(data, ""+'\n');
      while(lineToken.hasMoreElements()) {
         String s;
         // get next line
         token = new StringTokenizer(lineToken.nextToken(), ":");
         try {
            // skip ID tag
            s = token.nextToken();
            // City
            s = token.nextToken().trim();
            outBuffer.append(" City="+s); // city
            // Skip ::
            s = token.nextToken(" ").trim();
            //Elevation
            s = token.nextToken(" ").trim();
            outBuffer.append(", Elev=" + s);
            // Time of day
            s = token.nextToken(":").trim();
            outBuffer.append(", Time=" + s);
            // High temp
            s = token.nextToken(" ");  // skip space
            s = token.nextToken("/").trim();
            outBuffer.append(", High temp.=" + s);
            // Low temp
            s = token.nextToken("/").trim();
            outBuffer.append(", Low temp.=" + s);

            outBuffer.append('\n');  //New Line

         }catch(Exception e) {
            e.printStackTrace();            
         }
      }

      return outBuffer.toString();
   }

   /**
    * Make the http request and then format the data.  
    * Return the data as a String.
    */
   public static String getWeather() {       
      String sOutput = "Unable to connect to server";

      try {
         //Establish the http connection
         URL url = new URL(QUERY_BASE);

         //Set up a reader to read the data from the http server
         BufferedReader in = new BufferedReader(
                                new InputStreamReader(url.openStream()));            

         String data = queryWeatherData(in, "NORTH CENTRAL COLO");

         sOutput = parseWeatherData(data);
      } catch(Exception e) {
      } 
      return sOutput;
   }

   public static void main(String[] args) {
      String w = getWeather();

      System.out.println("Weather:");
      System.out.println(w);
   }

}
