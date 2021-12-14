import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day14_part1\\data\\example");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();
ArrayList<Instruction> instructionList = new ArrayList<Instruction>();

String exampleStr = new String("NNCB");
String myStr = new String("PSVVKKCNBPNBBHNSFKBO");


String inputStr = exampleStr;
//String inputStr = myStr;

LetterFrequencyTracker myLT;
PairTracker currentPT;
PairTracker nextPT;
PairTracker pt1;
PairTracker pt2;


void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;
  
  Instruction t;

  int l=input.lines.size();

  // Loop through each input item... setting up the instructions
  for (i=0;i<l;i++)
  {
    t=new Instruction(input.lines.get(i));
    instructionList.add(t);
    
    t.printInstruction();  
  }
  
  println("*** STARTING STRING:"+inputStr);
  myLT = new LetterFrequencyTracker(inputStr);
  myLT.printTracker();
  
  pt1 = new PairTracker(inputStr);
  pt2 = new PairTracker(inputStr);
  currentPT=pt1;
  nextPT=pt2;
  
  currentPT.printPairs();
  
  println("*** END initial state dump");
  println();
  
  int steps=10;
  long matches=0;
  for (i=0;i<steps;i++)
  {
    // for each rule - apply it to the set, creating new pairs
    l=instructionList.size();
    for (j=0;j<l;j++)
    {
      print("\\--RUNNING RULE:"+instructionList.get(j).inputPair);
      
      // create new pairs and remove any old pairs that match
      matches = updateUsingInstruction(instructionList.get(j));
      
      // capture new character added
      myLT.update(instructionList.get(j).insertChar,matches);
      
    }  
    println("iter:"+i+" locking in updates");
    currentPT.printPairs();
    println("***** END OF ITER *****");
    
    // Swap the trackers and get ready for the next update
    swapPT();
  }
  myLT.printTracker();
  println("TOTAL:"+String.valueOf(myLT.max.value - myLT.min.value));
}

void swapPT()
{
  PairTracker t;
  t=currentPT;
  currentPT=nextPT;
  nextPT=t;
}

public long updateUsingInstruction(Instruction ins)
{
  int i=0;
  Pair t;
  long childPairCount;
  
  // does this instruction match any existing pairs?
  t=currentPT.findPair(ins.inputPair);
  
  if (t!=null) // rule matches a pair
  {
    println("--- RULE MATCHED:"+t.pair);
    
    // We should create the same number of new nodes.
    childPairCount=t.currentCount;

    // update pairs based on the output
    for (i=0;i<2;i++)
    {
      nextPT.updatePair(ins.output[i],childPairCount);
    }

    // new pairs should have the same count as the pair we're running the instruction on
    // as each existing pair that matches that instruction will generate new pairs
    return(childPairCount);
  }
  else
  {
    println(" NO MATCH");
  }
  return(0);
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

public class PairTracker
{
  ArrayList<Pair> pairs = new ArrayList<Pair>();
  
  public PairTracker(String s)
  {
    int l=s.length();
    int i=0;
  
    // -1 because this is a 0 based array (effectively) and we want to stop at the last pair, not the last char
    for (i=0;i<l-1;i++)
    {
      // check to see if this pair matches an instruction
      updatePair(s.substring(i,i+2),1);
    }
  }
  
  public void clearTracker()
  {
    pairs.clear();
  }
  
  public Pair findPair(String s)
  {
    int l=pairs.size();
    int i=0;
    Pair t=null;
    
    for (i=0;i<l;i++)
    {
      t=pairs.get(i);
      if (t.pair.equals(s)==true)
      {
         return(t);
      }
    }
    return(null);
  }
  
  public void updatePair(String s, long c)
  {
    Pair t=findPair(s);
    if (t==null)
    {
      t=new Pair(s);
      pairs.add(t);
    }
    
    t.currentCount=c;
  }
  
  public void printPairs()
  {
    int l=pairs.size();
    int i=0;
    Pair t=null;
    
    for (i=0;i<l;i++)
    {
      t=pairs.get(i);
      print("IDX:"+i+" ");
      t.printPair();
    }
  }
  
  //public void lockInUpdates()
  //{
  //  int l=pairs.size();
  //  int i=0;
  //  Pair t=null;
    
  //  for (i=0;i<l;i++)
  //  {
  //    t=pairs.get(i);
  //    t.lockedIn=true;
  //    t.currentCount+=t.updatedCount;
  //  }
  //}
}

public class Pair
{
  String pair;
  long currentCount=0;
  
  public Pair()
  {
  }
  
  public Pair(String p)
  {
    pair= new String(p);
  }
  
  public void printPair()
  {
    println("["+pair+"]="+currentCount);
  }
}

public class LetterFrequencyTracker
{
  long[] totals= new long[26];
  Maximum max=new Maximum();
  Minimum min=new Minimum();
  
  public LetterFrequencyTracker(String s)
  {
    int l=s.length();
    int i=0;
    int ci;
    char c;
    
    // for each character in the input string, check it
    for (i=0;i<l;i++)
    {
      // convert the char to an index
      c=s.charAt(i);
      ci=c-'A';
      
      // increment the occurance of this char
      totals[ci]++;
      
      // reset the min/max counters to reflect this updated value
      max.set(totals[ci]);  
      min.set(totals[ci]);
    }
  }
  
  void update(char c, long count)
  {
    int ci;
    ci=c-'A';
     
    // increment the occurance of this char
    totals[ci]+=count;
      
    // reset the min/max counters to reflect this updated value
    max.set(totals[ci]);  
    min.set(totals[ci]);
  }
  
  void printTracker()
  {
    int i=0;
    println("TRACKER:");
    for (i=0;i<26;i++)
    {
      println((char)('A'+i)+"="+totals[i]);
    }
  }
}


//String expandString(String in)
//{
//  int l=in.length();
//  int i=0;
//  String output = new String();
//  int insIndex=0;
  
//  // -1 because this is a 0 based array (effectively) and we want to stop at the last pair, not the last char
//  for (i=0;i<l-1;i++)
//  {
    
//    // check to see if this pair matches an instruction
//    insIndex=findInstruction(in.substring(i,i+2));
    
//    //print("MATCHING ["+in.substring(i,i+2)+"]");
    
//    if (insIndex>=0)
//    {
//      //print(" M ["+instructionList.get(insIndex).newStr+"]");
//      output+=instructionList.get(insIndex).newStr;
//    }
//    else
//    {
//      //print(" X ["+in.substring(i,i+2)+"]");
//      output+=in.substring(i,i+2);
//    }
    
//    //println("--- "+output);
//  }
  
//  // we need to do a special case and add the last digit back on
//  // I hate this - but cant come up with a better solution at the moment
//  output+=in.charAt(l-1);
  
//  return(output);
//}





int findInstruction(String in)
{
  int l=instructionList.size();
  int i=0;
  
  for (i=0;i<l;i++)
  {
    if (instructionList.get(i).inputPair.equals(in)==true)
    {
      return(i);
    }
  }
  return(-1);
}

public class Instruction
{
  String inputPair;
  char insertChar;
  String newStr;
  String[] output = new String[2];
  
  public Instruction()
  {
  }
  
  public Instruction(String s)
  {
    String[] temp;  
    
    temp=s.split(",");
    inputPair=new String(temp[0]);
    insertChar=temp[1].charAt(0);
    
    // left char + input char == left pair
    output[0]=String.valueOf(inputPair.charAt(0))+String.valueOf(insertChar);
    
    // input char + right char == right pair
    output[1]=String.valueOf(insertChar)+String.valueOf(inputPair.charAt(0));
  }
  
  void printInstruction()
  {
    println("Ins:["+inputPair+"] insert="+insertChar+" Result:"+newStr);
  } 
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
