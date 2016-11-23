// compare content of PDF files printed by iTunes

import org.apache.pdfbox.pdfparser.PDFParser;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.util.PDFTextStripper;

import java.io.*;
import java.util.Arrays;
import java.util.List;

void setup() {
  String sourcePDFPath = "/Users/ozakiyuuto/Documents/Backup/iPod/iPod (CD9ZS)_20161123.pdf";
  String targetPDFPath = "/Users/ozakiyuuto/Desktop/work/20161027_iPodRestore/manualList_work2.pdf";
  String outputFileName = "iTunesPDF_diff_CD9ZU.txt";
  
  mainProcess(sourcePDFPath, targetPDFPath, outputFileName);
  
  println("done!\n");
}

void mainProcess(String sourcePDFPath, String targetPDFPath, String outputFileName) {
  try {
    String sourcePDFText = getPDFText(sourcePDFPath);
    String targetPDFText = getPDFText(targetPDFPath);
  
    String diffText = compareText(sourcePDFText, targetPDFText);
    
    textOutput(diffText, outputFileName);
  } catch(IOException e) {
    println("Check your PDF filepath\n");
    e.printStackTrace();
  }
}

String compareText(String sourceText, String targetText) {
  StringBuffer sb = new StringBuffer();
  
  String[] source = split(sourceText, '\n');
  String[] target = split(targetText, '\n');
  
  List<String> targetList = Arrays.asList(target);
  
  for(String sourceContent: source) {
    if(!targetList.contains(sourceContent)) {
      sb.append(sourceContent);
      sb.append('\n');
    } 
  }
  
  return sb.toString();
}

void textOutput(String diffText, String outputFileName) throws IOException {
  PrintWriter output = createWriter(outputFileName);
  
  println(diffText);
  output.println(diffText);
    
  output.flush();
  output.close();
}

String getPDFText(String PDFFilePath) throws IOException{
  String PDFText = "";
  FileInputStream pdfStream = new FileInputStream(PDFFilePath);   
  
  try {
    PDFText = readTextFromPDF(pdfStream);
  } catch (IOException e) {
    println("readTextFromPDF Error!\n");
    e.printStackTrace();
  } finally {
    if (pdfStream != null) pdfStream.close(); 
  }
  
  return PDFText;
}

String readTextFromPDF(FileInputStream pdfStream) throws IOException{
  PDFParser parser = new PDFParser(pdfStream);
  parser.parse();
  PDDocument pdf = parser.getPDDocument();
  PDFTextStripper stripper = new PDFTextStripper();
  return stripper.getText(pdf);
}

void draw() {
}
