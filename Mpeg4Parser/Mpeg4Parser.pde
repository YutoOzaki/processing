// 00 00 A9 45 -> 4 bytes
// 00 -> 8 bits = 1 byte
// 1 hex digit -> 4 bits
// 2^4 = 16

import java.nio.ByteBuffer;
import java.io.RandomAccessFile;
import java.util.Arrays;

void setup() {
  File iPodMusicFolder = new File("/Volumes/YUTO 3F/iPod_Control/Music/");
  StringBuilder sb = new StringBuilder();
  
  for(File dir: iPodMusicFolder.listFiles()) {
    if(dir.isDirectory()) {
      for(File file: dir.listFiles()) {
        String filePath = file.getPath();
        if(filePath.contains(".m4a") || filePath.contains(".aac")) {
          println("Process " + filePath + "...");
          sb.append(mainMethod(filePath));
        }
      }
    }
  }
  
  println("Write to file...");
  PrintWriter output = createWriter("iPodMPEG4Info_MN9ZU.txt");
  output.println(sb.toString());
  output.flush();
  output.close();
  
  println("done!");
}
  
String mainMethod(String filePath) {
  RandomAccessFile raf = null;
  int ATOM_SIZE = 4;
  byte[] size = new byte[ATOM_SIZE];
  byte[] name = new byte[ATOM_SIZE];
  
  String albumName = null;
  int[] trackNum = new int[2];
        
  try {
    int n = 0;
    int m = 0;
    long atomSize = 0;
    String atomName = null;
    int offset = 0;
    
    raf = new RandomAccessFile(filePath, "r");
    long fileLength = raf.length();
    
    while(fileLength > offset) {
      raf.seek(offset);
      n = raf.read(size, 0, ATOM_SIZE);
      m = raf.read(name, 0, ATOM_SIZE);
      atomName = new String(name, "UTF-8");
      atomSize = ByteBuffer.wrap(size).getInt();
      //println(" " + atomName + ": " + atomSize + " bytes (n = " + n + ", m = " + m + ")");
      offset += atomSize;
      
      if("moov".equals(atomName)) {
        while(!"udta".equals(atomName)) {
          n = raf.read(size, 0, ATOM_SIZE);
          m = raf.read(name, 0, ATOM_SIZE);
          atomName = new String(name, "UTF-8");
          atomSize = ByteBuffer.wrap(size).getInt();
          //println(" " + atomName + ": " + atomSize + " bytes (n = " + n + ", m = " + m + ")");
      
          byte[] test = atomName.getBytes("UTF-8");
          if(!Arrays.equals(test, name)) {
            String message = (filePath + " *** Invalid file format ***\n");
            return message;
          }
          
          raf.seek(raf.getFilePointer() + atomSize - n - m);
        }
        
        raf.seek(raf.getFilePointer() - atomSize);
        //println(" --Metadata begins from " + raf.getFilePointer() + "--");
        
        raf.seek(raf.getFilePointer() + n + m);
        n = raf.read(size, 0, ATOM_SIZE);
        m = raf.read(name, 0, ATOM_SIZE);
        atomName = new String(name, "UTF-8");
        atomSize = ByteBuffer.wrap(size).getInt();
        //println(" " + atomName + ": " + atomSize + " bytes (n = " + n + ", m = " + m + ")");
        
        int endFlag = 0;
        while(endFlag != 2 && raf.getFilePointer() < offset) {
          int firstCode = raf.read();
          
          if(firstCode == 169) { // find A9 (hex)
            if(raf.read() == 97) { // find "a"
              if(raf.read() == 108) { // find "l"
                if(raf.read() == 98) { // find "b"
                  //println(" --Album name begins from " + (raf.getFilePointer() - 8) + "--");
                  n = raf.read(size, 0, ATOM_SIZE);
                  m = raf.read(name, 0, ATOM_SIZE);
                  atomName = new String(name, "UTF-8");
                  atomSize = ByteBuffer.wrap(size).getInt();
                  //println(" " + atomName + ": " + atomSize + " bytes (n = " + n + ", m = " + m + ")");
                  
                  byte[] metadata = new byte[(int)atomSize - n - m];
                  raf.read(metadata, 0, (int)atomSize - n - m);
                  albumName = new String(metadata, "UTF-8");
                  
                  endFlag++;
                  firstCode = raf.read();
                }
              }
            }
          }
          
          if(firstCode == 116) { // find "t"
            if(raf.read() == 114) { // find "r"
              if(raf.read() == 107) { // find "k"
                if(raf.read() == 110) { // find "n"
                  //println(" --Track number begins from " + (raf.getFilePointer() - 8) + "--");
                 
                  n = raf.read(size, 0, ATOM_SIZE);
                  m = raf.read(name, 0, ATOM_SIZE);
                  atomName = new String(name, "UTF-8");
                  atomSize = ByteBuffer.wrap(size).getInt();
                  //println(" " + atomName + ": " + atomSize + " bytes (n = " + n + ", m = " + m + ")");
                  
                  byte[] metadata = new byte[(int)atomSize - n - m];
                  raf.read(metadata, 0, (int)atomSize - n - m);
                  int i = 0;
                  for(byte b: metadata) {
                    if(b != 0) {
                      trackNum[i] = b;
                      ++i;
                    }
                  }
                  
                  endFlag++;
                  firstCode = raf.read();
               }
             }
           }
         }
        }
      } 
      
      //println("Next offset: " + offset + " / " + fileLength + "\n");
    }
    
  } catch(IOException e) {
    e.printStackTrace();
    String message = (filePath + "*** IO Error ***\n");
    return message;
  } finally {
    try {
      if(raf != null) raf.close();
    } catch(IOException e) {
      e.printStackTrace();
      String message = (filePath + "*** IO Error ***\n");
      return message;
    }
  }
  
  StringBuilder sb = new StringBuilder();
  sb.append(filePath);
  sb.append(" -> Album: ");
  sb.append(albumName);
  sb.append(" [");
  sb.append(trackNum[0]);
  sb.append(" / ");
  sb.append(trackNum[1]);
  sb.append("]\n");
  
  String metadataInfo = sb.toString();
  return metadataInfo;
}

void draw() {
}
