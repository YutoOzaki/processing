class ID3v2_2 extends ID3v2{
  private final int FRAME_SIZE_BYTE = 3;
  
  ID3v2_2(RandomAccessFile raf, String filePath) {
    super(raf, filePath);
  }
  
  @Override
  public String mainMethod() throws IOException{
    String albumName = null;
    String trackNum = null;
    
    raf.seek(SIZE_OFFSET_ID3v2);
    byte[] size = new byte[SIZE_BYTE];
    raf.read(size, 0, SIZE_BYTE);
        
    int totalTagSize = ((size[0] & 0x7F) << 21) + ((size[1] & 0x7F) << 14) + ((size[2] & 0x7F) << 7) + (size[3] & 0x7F);
    
    int endFlag = 0;
    byte[] TAG = new byte[FRAME_SIZE_BYTE + 1];
    while(endFlag != 2 && raf.getFilePointer() < totalTagSize) {
      int len = raf.read(TAG, 0, FRAME_SIZE_BYTE + 1);
          
      if(TAG[0] == 84) { // find "T"
        if(TAG[1] == 65) { // find "A"
          if(TAG[2] == 76) { // find "L"
            if(TAG[3] == 0) {
              raf.seek(raf.getFilePointer() - 1);
                
              size = new byte[FRAME_SIZE_BYTE];
              raf.read(size, 0, FRAME_SIZE_BYTE);
                    
              int tagSize = 0;
              for(int i=0; i<FRAME_SIZE_BYTE; ++i) {
                tagSize += (size[i] & 0xFF);
              }
              
              int encoding = raf.read();
              if(encoding == 0) {
                raf.seek(raf.getFilePointer() - 1);
                byte[] metadata = new byte[tagSize];
                raf.read(metadata, 0, tagSize);
                albumName = new String(metadata, charCode);
              }else if(encoding == 1) {
                if(raf.read() == 255) {
                  if(raf.read() == 254) {
                    byte[] metadata = new byte[tagSize - 3];
                    raf.read(metadata, 0, tagSize - 3);
                    ByteBuffer b = ByteBuffer.wrap(metadata).order(ByteOrder.LITTLE_ENDIAN);
                    
                    StringBuilder sb = new StringBuilder();
                    int limit = b.limit() / 2;
                    for(int i=0; i<limit; ++i) {
                      sb.append(b.getChar());
                    }
                    albumName = sb.toString();
                  }
                }
              }
            
              endFlag++;
            }
          }
        }
      }
          
      if(TAG[0] == 84) { // find "T"
        if(TAG[1] == 82) { // find "R"
          if(TAG[2] == 75) { // find "K"
            if(TAG[3] == 0) {
              raf.seek(raf.getFilePointer() - 1);
          
              size = new byte[FRAME_SIZE_BYTE];
              raf.read(size, 0, FRAME_SIZE_BYTE);
              
              int tagSize = 0;
              for(int i=0; i<FRAME_SIZE_BYTE; ++i) {
                tagSize += (size[i] & 0xFF);
              }
              
              byte[] metadata = new byte[tagSize];
              raf.read(metadata, 0, tagSize);
              trackNum = new String(metadata, charCode);
                      
              endFlag++; 
            }
          }
        }
      }
      
      raf.seek(raf.getFilePointer() - len + 1);
    }
      
    StringBuilder sb = new StringBuilder();
    sb.append(filePath);
    sb.append(" -> Album: ");
    sb.append(albumName);
    sb.append(" [");
    sb.append(trackNum);
    sb.append("]\n");
      
    String metadataInfo = sb.toString();
    println(metadataInfo);
    return metadataInfo;
  }
}
