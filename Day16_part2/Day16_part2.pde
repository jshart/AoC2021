import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day16_part2\\data\\example");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("p2input3.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();
String rawHex;


public enum PStates {
  HEADER,
  LITERAL,
  OPERATOR,
  CHECK,
};

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0;

  // Loop through each input item...
  for (i=0;i<input.lines.size();i++)
  {
  
  }
  println("LINES:"+input.lines.size());

  
  rawHex=input.lines.get(0);
  String s;
  String binaryString;
  int decValue;
  
  String paddedString;
  String binaryPacket=new String();
  
  for (i=0;i<rawHex.length();i++)
  {
    // Grab a single Hex digit to start converting
    s=rawHex.substring(i,i+1);
    print("H:0x"+s+" ");
    
    // Take the Hex digit and convert it to decimal int
    decValue=Integer.parseInt(s,16);
    
    // Take the decimal value and convert it to binary string
    binaryString=Integer.toBinaryString(decValue);
    paddedString=leadingPad(binaryString,4);
    print(" "+paddedString);
    binaryPacket+=paddedString;
    
    println(" "+decValue);
  }
  
  SubPacket parsedPacket = new SubPacket();
  
  println("BINARY PACKET:"+binaryPacket);
  int r=processPacket(binaryPacket,parsedPacket,0,-1);
  
  //int total=0;
  //for (i=0;i<subs.size();i++)
  //{
  //  if (subs.get(i).version>0)
  //  {
  //    println("V:"+subs.get(i).version);
  //  }
  //  total+=subs.get(i).version;
  //}
  //println("TOTAL:"+total);
  println("*** EXITED ***");
  
  parsedPacket.printPacket(1);
  println("FINAL RESULT:"+parsedPacket.solve());
}

public int processPacket(String b, SubPacket parentPacket, int d, int findPacketCount)
{
  
  // General parsing structures, used by all components
  boolean stillProcessing=true;
  int currentIndex=0;
  PStates pState = PStates.HEADER;
  String literalBuffer= new String();
  int packetsFound=0;
  int i=0;
  boolean allZeros=false;
  SubPacket sp=new SubPacket();

  
  // local temp vars for parsing sub-componets
  int operatorLen=0;
  int operatorFindPackets=0;
  char lenIndicator=0;
  long tempLiteral=0;
  
  printd("PROCESS PACKET called with:",d);
  println(d);

  while (stillProcessing==true)
  {
    switch (pState)
    {
      case HEADER:
        printd("PROCESSING HEADER",d);
        println();
        // Header consists of 6 bits
        // - 3 bits is the packet version
        // - 3 bits is the type ID
        sp = new SubPacket();
        sp.version=Integer.parseInt(b.substring(currentIndex,currentIndex+3),2);
        
        printd("VERSION:",d);
        println(sp.version);
        
        currentIndex+=3;
        
        sp.type=Integer.parseInt(b.substring(currentIndex,currentIndex+3),2);
        
        printd("TYPE:",d);
        println(+sp.type); 
        
        currentIndex+=3;
        
        switch(sp.type)
        {
          case 4:
            pState=PStates.LITERAL;
            break;
          default:
            pState=PStates.OPERATOR;
            break;
        }      
        sp.s=PStates.HEADER;
        //parentPacket.subs.add(sp);
        
        packetsFound++;
        break;
        
      case LITERAL:
        printd("PROCESSING LITERAL",d);
        println();
        //sp = new SubPacket();

        // is this the last group?
        if (b.charAt(currentIndex)=='1')
        { 
          currentIndex++;
          literalBuffer+=b.substring(currentIndex,currentIndex+4);
          printd("LITERAL part found:",d);
          println(literalBuffer);
        }
        else
        {
          currentIndex++;
          literalBuffer+=b.substring(currentIndex,currentIndex+4);
          tempLiteral=Long.parseLong(literalBuffer,2);
          sp.literal=tempLiteral;
          
          printd("LITERAL end found:",d);
          println(literalBuffer+" ["+tempLiteral+"]");
          literalBuffer="";
          
          sp.s=PStates.LITERAL;
          pState=PStates.CHECK;  
        }
        currentIndex+=4;
        break;
        
      case OPERATOR:
        //sp = new SubPacket();
        sp.s=PStates.OPERATOR;
        printd("PROCESSING OPERATOR",d);
        println();
        
        // Get the length indicator
        lenIndicator=b.charAt(currentIndex);
        currentIndex++;   
        printd("LEN_IND[",d);
        println(lenIndicator+"]");
        
        switch(lenIndicator)
        {
          case '0': // total length
            operatorLen=Integer.parseInt(b.substring(currentIndex,currentIndex+15),2);
            printd("LEN[",d);
            
            println(operatorLen+"]");
            currentIndex+=15;
            printd("sub-operator to process:",d);
            println(b.substring(currentIndex,currentIndex+operatorLen));
            
            // recursively call our packet processing function on this sub-string.
            sp.contents=new String(b.substring(currentIndex,currentIndex+operatorLen));
            currentIndex+=processPacket(sp.contents,sp,d+1,-1);
            
            printd("sub-packet processed and return:",d);
            println(currentIndex);
            //parentPacket.subs.add(sp);
            
            pState=PStates.CHECK;
            break;
          case '1':
            operatorFindPackets=Integer.parseInt(b.substring(currentIndex,currentIndex+11),2);
            currentIndex+=11;
            
            // TODO - not sure how to set the sp.contents for this case :(
            
            
            currentIndex+=processPacket(b.substring(currentIndex),sp,d+1,operatorFindPackets);
            printd("sub-packet processed and return:",d);
            println(currentIndex);
            //parentPacket.subs.add(sp);
            
            pState=PStates.CHECK;
            break; // sub packets
        }

        break;
        
      case CHECK:
        // finished with a packet, so close it out and save it
        parentPacket.subs.add(sp);

        // dont know what mode we're in now, so we need
        // to check the digits to determine what to do next
        // if we've run out of string length then lets stop processing
        // and exit
        //printd("len check:",d);
        //println(currentIndex+","+b.length());
        if (currentIndex>=b.length()-1)
        {
          stillProcessing=false;
        }
        //printd("end zeros check:",d);
        allZeros=true;
        for (i=currentIndex;i<b.length()-1;i++)
        {
          if (b.charAt(i)!='0')
          {
            //println(" not all zeros:"+b.substring(currentIndex,b.length()-1));
            allZeros=false;
          }
        }
        if (allZeros==true)
        {
          //println(" all zeros");
          stillProcessing=false;
        }
        
        // if we were told to find a specific number of packets,
        // and we have now found those, then we're done.
        if (findPacketCount>0 && findPacketCount==packetsFound)
        {
          stillProcessing=false;
        }
        // we've not hit an exit condition, so lets look for another header
        if (stillProcessing==true)
        {
          pState=PStates.HEADER;
        }
        
        break;
    }
  }
  printd("ENDED, processed:",d);
  println(packetsFound);
  return(currentIndex);
}

void printd(String s, int d)
{
  int i=0;
  for (i=0;i<d;i++)
  {
    print(" ");
  }
  print("\\_"+s);
}

String leadingPad(String in, int toLen)
{
  int l = in.length();
  int i=0;
  
  for (i=0;i<toLen-l;i++)
  {
    in="0"+in;
  }
  return(in);
}

void printMasterList()
{
  int i=0;
  for (i=0;i<masterList.size();i++)
  {
    println("ML input:"+masterList.get(i));
  }
}


void draw() {  

}

public class SubPacket
{
  int type=0;
  int version=0;
  //ArrayList<Long> literals = new ArrayList<Long>();
  long literal;
  PStates s;
  String contents;
  ArrayList<SubPacket> subs = new ArrayList<SubPacket>();
  
  boolean resolved=false;
  long output=0;
  
  public SubPacket()
  {
  }
  
  public long solve()
  {
    ArrayList<Long> results = new ArrayList<Long>();
    int i=0;
    long finalResult=0;
    Minimum min = new Minimum();
    Maximum max = new Maximum();
    
    // start by checking if any of the subpackets need resolving
    for (i=0;i<subs.size();i++)
    {
      results.add(subs.get(i).solve());
    }
    
    
    switch (type)
    {
      case 0: // SUM
        for (i=0;i<results.size();i++)
        {
          finalResult+=results.get(i);  
        }
        break;
      case 1: // PRODUCT
        finalResult=results.get(0);
        for (i=1;i<results.size();i++)
        {
          finalResult*=results.get(i);  
        }
        break;
      case 2: // MIN
        for (i=0;i<results.size();i++)
        {
          min.set(results.get(i));  
        }
        finalResult=min.value;
        break;
      case 3: // MAX
        for (i=0;i<results.size();i++)
        {
          max.set(results.get(i));  
        }
        finalResult=max.value;
        break;
      case 4: // LIT
        finalResult=literal;
        break;
      case 5: // GT
        finalResult=results.get(0)>results.get(1)?1:0;
        break;
      case 6: // LT
        finalResult=results.get(0)<results.get(1)?1:0;
        break;
      case 7: // EQ
        finalResult=results.get(0)==results.get(1)?1:0;
        break;
    }
    
    return(finalResult);
  }
  
  public void printPacket(int d)
  {
    String p=new String();
    int i=0;
    for (i=0;i<d;i++)
    {
      p+=" ";
    }
    p+="\\_";
    
    println(p+"T:"+type+" V:"+version+" L:"+literal+" SS:"+subs.size()+" Op:"+operatorName(type));
    //println(p+"T:"+type+" V:"+version+" LS:"+literals.size()+" SS:"+subs.size());

    //for (i=0;i<literals.size();i++)
    //{
    //  println(p+"L:["+literals.get(i)+"]");
    //}
    for (i=0;i<subs.size();i++)
    {
      subs.get(i).printPacket(d+1);
    }
  }
  
  public String operatorName(int op)
  {
    switch (op)
    {
      case 0:
        return("SUM");
      case 1:
        return("PRODUCT");
      case 2:
        return("MIN");
      case 3:
        return("MAX");
      case 4:
        return("LIT");
      case 5:
        return("GT");
      case 6:
        return("LT");
      case 7:
        return("EQ");
    }
    return("NA");
  }
}



///////////////////////////////////////////////
// AFTER THIS POINT ARE UTILITY FUNCTIONS ONLY
///////////////////////////////////////////////

public void OutputFile(String name)
{
  PrintWriter outFile = createWriter(name);
  int j=0;
  
  for (j=0;j<masterList.size();j++)
  {
    outFile.print(masterList.get(j));
  }
  
  outFile.flush();
  outFile.close();
}

String diff(String s1, String s2)
{
  for (char c : s2.toCharArray())
  {
    s1=s1.replaceAll(String.valueOf(c), "");
  }
  return(s1);
}

boolean containsChar(String s1, char c)
{
  // for each char in s1, can we find input 'c'
  for (char c1 : s1.toCharArray())
  {
    if (c1==c)
    {
      return(true);
    }
  }
  return(false);
}

boolean containsChars(String s1, String s2)
{
  // for each char in s2, can we find it in s1
  for (char c2 : s2.toCharArray())
  {
    if (containsChar(s1, c2)==false)
    {
      return(false);
    }
  }
  return(true);
}

boolean containsCharsAnyOrder(String s1, String s2)
{
  if (s1.length()!=s2.length())
  {
    return(false);
  }
  return(containsChars(s1, s2));
}

public class InputFile
{
  ArrayList<String> lines = new ArrayList<String>();
  int numLines=0;
  String fileName;
  
  public InputFile(String fname)
  {
    fileName=fname;
    
    try {
      String line;
      
      File fl = new File(filebase+File.separator+fileName);
  
      FileReader frd = new FileReader(fl);
      BufferedReader brd = new BufferedReader(frd);
    
      while ((line=brd.readLine())!=null)
      {
        println("loading:"+line);
        lines.add(line);
      }
      brd.close();
      frd.close();
  
    } catch (IOException e) {
       e.printStackTrace();
    }
    
    numLines=lines.size();
  }
  
  public void printFile()
  {
    println("CONTENTS FOR:"+fileName);
    int i=0;
    for (i=0;i<numLines;i++)
    {
      println("L"+i+": "+lines.get(i));
    }
  }
}


// Allows you to set and fetch arbitary bits in a bit mask
public class BitMask
{
  int bm=0;
  public BitMask()
  {
  }
  public int setBit(int i)
  {
    bm |= 1<<i;   
    return(bm);
  }
  public int bitSet(int i)
  {
    return(bm & (1<<i));
  }
  public void printBitMask()
  {
    println("BM:"+Integer.toBinaryString(bm));
  }
}

public class Minimum
{
  long value=0;
  boolean set=false;
  
  public Minimum()
  {
  }

  public void set(long v)
  {
    // Always set if this is the first time, but subsequently only set
    // if its less as we're trying to track the shortest distant. This
    // is overkill, as the *first* time should always be the shortest
    if (set==false)
    {
      value=v;
      set=true;
    }
    else
    {
      if (v<value)
      {
        value=v;
      }
    }
  }
}

public class Maximum
{
  long value=0;
  
  public Maximum()
  {
  }

  public void set(long v)
  {

    if (v>value)
    {
      value=v;
    }
  }
}

public class LinkedList
{
  LinkedList forward=null;
  LinkedList back=null;
  int cupLabel=-1;
  
  public LinkedList(int c)
  {
    cupLabel=c;
  }
  
  public LinkedList(int c, LinkedList l)
  {
    cupLabel=c;
    back=l;
    l.forward=this;
  }
  
  public boolean inList(int c)
  {
    LinkedList start;
    LinkedList n;
    
    n=this;
    start=this;
    
    do 
    {
      if (n.cupLabel==c)
      {
        return(true);
      }
      n=n.forward;
    }
    while (n!=null && n!=start);
    return(false);
  }
  
  public LinkedList cutSubList(int nodes)
  {
    int i=0;
    LinkedList subListStart=null;
    LinkedList remainderList=null;
    LinkedList cutpoint=null;
    
    // capture the start of the sublist
    subListStart=this.forward;
    this.forward=null;
    cutpoint=this;
    
    // wind forward to the point where the remainder list starts
    remainderList=subListStart;
    for (i=0;i<nodes;i++)
    {
      remainderList=remainderList.forward;
    }
    
    // detach the sublist from the main list
    remainderList.back.forward=null;
    subListStart.back=null;
    
    //reattach the 2 halves of the list
    //println("recombining lists; this node");
    //this.printNode();
    //println("remainder:");
    //remainderList.printList();
    
    cutpoint.forward=remainderList;
    remainderList.back=cutpoint;

    //println("Combined list:");
    //this.printList();
    
    return(subListStart);
  }
  
  public void addListAfter(LinkedList subListToAdd)
  {
    LinkedList addToLocation=null;
    LinkedList nextNodeToAdd=null;
    
    addToLocation=this;
    boolean done=false;

    int max=5;
    
    do 
    {
      // is this the end of the sublist?
      if (subListToAdd.forward==null)
      {
        done=true;
      }
      else
      {
        // Save the next node
        nextNodeToAdd=subListToAdd.forward;
        
        // detach this one from the sub list.
        subListToAdd.forward=null;
      }

      //print("adding to node:");
      //addToLocation.printNode();

      //print("adding node:");
      //subListToAdd.printNode();
      subListToAdd.addNodeAfter(addToLocation);
      
      //print("node added:");
      //subListToAdd.printNode();
      
      // move forward after the node we just added
      addToLocation=addToLocation.forward;
      
      
      // move to the next node in the sublist we're trying to add
      subListToAdd=nextNodeToAdd;
    }
    while (done==false && max-- >=0);    
  }

  // Assumes an *always* valid node b to attach too, will optionally forward
  // link if b already has a forward link. i.e. will *insert* if b is middle
  // of a list, but will add if b is end of list.
  public void addNodeAfter(LinkedList b)
  {
    // save the current forward link, as we'll attach this node to that eventually
    LinkedList f=b.forward;
    
    // connect this node *backwards* to the b node...
    this.back=b;
    b.forward=this;
    
    if (f!=null)
    {
      // ... and *forwards* to the f node, which we saved earlier
      this.forward=f;
      f.back=this;
    }
  }

  public void printList()
  {
    LinkedList start;
    LinkedList n;
    
    n=this;
    start=this;
    
    do 
    {
      n.printNode();
      n=n.forward;
    }
    while (n!=null && n!=start);
  }
  
  
  public void printNode()
  {
    //println("C:"+cupLabel+" fwd cup label:"+(forward==null?"null":forward.cupLabel)+" back cup label:"+(back==null?"null":back.cupLabel));
    println((back==null?"null":back.cupLabel)+"<-["+cupLabel+"]->"+(forward==null?"null":forward.cupLabel));
  }
}

// Given a string, this class can create *all* permutations
// of that string by rearranging characters - each character
// is still used only the same amount of times as the original
// source.
public class Permutations
{
  String components;
  
  public Permutations(String s)
  {
    components=s;
  }
  
  public void walk()
  {
    walk(components,"");
  }
  
  public void walk(String input, String current)
  {
    int i=0;
    
    // for each character in the input
    for (i=0;i<input.length();i++)
    {
      // if there is more than 1 character left, then we need to fork and repeat
      // the walk for each new substring
      if (input.length()>1)
      {
        // lock in this char, by removing the character at the current index from the string
        String remainder=input.substring(0,i)+input.substring(i+1,input.length());
        //println(input.charAt(i)+" R:"+remainder);
        
        // walk the tree for the remaining characters now that we've locked one
        // in for this set of permuations.
        walk(remainder,current+input.charAt(i));
      }
      else
      {
        // we only have one character left, so we cant "walk" any further on this branch
        // dump the permuation so far, plus this last remaining char
        //println("[P]-->"+current+input);
        printPerm(current+input);
      }
    }
  }
  
  public void printPerm(String s)
  {
    int i=0;
    print("{");
    
    for (i=0;i<s.length();i++)
    {
      print(s.charAt(i));
      if (i+1<s.length())
      {
        print(",");
      }
    }
    println("},");
  }
}
