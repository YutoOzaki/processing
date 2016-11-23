import java.nio.ByteBuffer;
import java.io.RandomAccessFile;
import java.util.Arrays;
import java.nio.ByteOrder;

void setup() {
  File iPodMusicFolder = new File("/Volumes/YUTO 3F/iPod_Control/Music/");
  StringBuilder sb = new StringBuilder();
  
  for(File dir: iPodMusicFolder.listFiles()) {
    if(dir.isDirectory()) {
      for(File file: dir.listFiles()) {
        String filePath = file.getPath();
        if(filePath.contains(".mp3")) {
          println("Process " + filePath + "...");
          sb.append(mainMethod(filePath));
        }
      }
    }
  }
  
  println("Write to file...");
  PrintWriter output = createWriter("iPodMP3Info_MN9ZU.txt");
  output.println(sb.toString());
  output.flush();
  output.close();
  
  println("done!");
}

String mainMethod(String filePath) {
  RandomAccessFile raf = null;
  ID3v2 parser = null;
  
  try {
    raf = new RandomAccessFile(filePath, "r");
    
    byte[] ID3 = {73, 68, 51};
    byte[] check = new byte[3];
    raf.read(check, 0, 3);
    
    if(Arrays.equals(ID3, check)) {
      int versionInfo = raf.read();
      if(versionInfo == 3 || versionInfo == 0) {
        parser = new ID3v2_3(raf, filePath);
        return parser.mainMethod();
      } else {
        parser = new ID3v2_2(raf, filePath);
        return parser.mainMethod();
      }
    } else {
      String message = (filePath + " is not ID3v2 tag\n");
      return message;
    }
  } catch(IOException e) {
    e.printStackTrace();
    String message = (filePath + "*** IO Error ***\n");
    return message;
  } finally {
    try {
      parser.close();
    } catch(IOException e) {
      e.printStackTrace();
      String message = (filePath + "*** IO Error ***\n");
      return message;
    }
  }
}

void draw() {
}
