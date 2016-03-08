import java.util.List;
import java.util.Map;

void setup() {
  size(60,40);
  selectFolder("Select a folder to process:", "folderSelected");
  
  /*
  java.util.Set<Thread> threadSet = Thread.getAllStackTraces().keySet();
  println(threadSet.size() + " threads are running");
  for(Thread thread: threadSet) {
    println(" " + thread.getId() + ", " + thread.getName());
  }
  */
}

void draw() {
}

void folderSelected(File selection) {  
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    
    String url = selection.getAbsolutePath();
    FileRetriever FR = new FileRetriever();
    FR.folderSearch(url);
    FR.printPath();
    println("done!");
  }
}

class FileRetriever {
  private List<String> pathContainer = new ArrayList<String>();
  
  FileRetriever() {
  }
  
  final public void folderSearch(String startDirectory) {
    File file = new File(startDirectory);
    File[] files = file.listFiles();
    
    for(int i=0, end=files.length; i<end; ++i) {      
      if(files[i].getName().endsWith(".m4a") || files[i].getName().endsWith(".aac") || files[i].getName().endsWith(".mp3") || files[i].getName().endsWith(".au")) {
          String file_path = files[i].getAbsolutePath();
          pathContainer.add(file_path);
        }   
       if(files[i].isDirectory()) folderSearch(files[i].getAbsolutePath());
    }
  }
  
  final public void printPath(){
    PrintWriter output = createWriter("gtzan.txt");
    for(String path: pathContainer) output.println(path);
    output.flush();
    output.close();
  }
}
