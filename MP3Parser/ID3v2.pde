class ID3v2 {
  RandomAccessFile raf;
  String filePath;
  final int SIZE_OFFSET_ID3v2 = 6;
  final int SIZE_BYTE = 4;
  String charCode = "UTF-8";
  
  ID3v2(RandomAccessFile raf,String filePath) {
    this.raf = raf;
    this.filePath = filePath;
  }
  
  void close() throws IOException {
    if(raf != null) raf.close();
  }
  
  String mainMethod() throws IOException{
    return "Override this method!\n";
  }
}
