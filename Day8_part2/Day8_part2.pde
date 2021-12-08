import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day8_part2\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();
ArrayList<SegDecoder> segsToDecode = new ArrayList<SegDecoder>();

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();

  int i=0, j=0;
  SegDecoder tsd;
  int runningTotal=0;
  int total=0;

  // Loop through each input item...
  for (i=0; i<input.lines.size(); i++)
  {
    tsd=new SegDecoder(input.lines.get(i));
    tsd.printInput();
    segsToDecode.add(tsd);
    tsd.decode();
    total=tsd.decodeOutput();
    println("## TOTAL after:"+i+"="+total);
    println();
    runningTotal+=total;
  }
  println("FINAL TOTAL:"+runningTotal);
}

void printMasterList()
{
  int i=0;
  for (i=0; i<masterList.size(); i++)
  {
    println("ML input:"+masterList.get(i));
  }
}


void draw() {
}

public class SegDecoder
{
  String input;
  String output;

  String[] outputSegments;

  String[] inputSegments;
  boolean[] digitKnown=new boolean[10];
  int[] indexToSegs=new int[10];

  //char a;
  //char b;
  //char c;
  //char d;
  //char e;
  //char f;
  //char g;

  public SegDecoder(String s)
  {

    String[] temp;

    temp = s.split(",");
    input=temp[0];
    output=temp[1];

    inputSegments=input.split(" ");
    outputSegments=output.split(" ");
  }


  void decode()
  {
    int i=0;
    int l=inputSegments.length;

    // set everything to unknown to start with.
    for (i=0; i<l; i++)
    {
      digitKnown[i]=false;
    }

    // Start with the simple ones that are unique, check each segment to see if it matches
    // a unique length, then we can assign it to the digits known
    for (i=0; i<l; i++)
    {
      switch (inputSegments[i].length())
      {
      case 2:
        indexToSegs[1]=i;
        digitKnown[1]=true;
        break;
      case 3:
        indexToSegs[7]=i;
        digitKnown[7]=true;
        break;
      case 4:
        indexToSegs[4]=i;
        digitKnown[4]=true;
        break;
      case 7:
        indexToSegs[8]=i;
        digitKnown[8]=true;
        break;
      }
    }

    //printDecoded();

    String temp;

    //// STEP 1 - work out Segment A
    //// Work out Segment A
    //println("*** STEP 1 decode");
    //a=diff(getInputByKnownNum(7),getInputByKnownNum(1)).charAt(0);
    //println("Seg A="+a);



    // STEP 2 - work out '5'
    // taking an intersect of 4 & 1, leaves us with "b" and "d" segments
    println("*** STEP 2 decode");
    temp=diff(getInputByKnownNum(4), getInputByKnownNum(1));

    // if we search for segments of length 5, with both "b" and "d" segment - it must be the 5 digit
    for (i=0; i<10; i++)
    {
      if (inputSegments[i].length()==5)
      {
        // Candidate digit - lets see if it contains "b" and "d";
        if (containsChars(inputSegments[i], temp)==true)
        {
          // this must be digit 5
          indexToSegs[5]=i;
          digitKnown[5]=true;
        }
      }
    }
    //printDecoded();



    // STEP 3 - work out '0'
    // now that we know 5, any digit string with 6 segments, that *Doesnt* contain all of the same digits as '5'
    // must be 0 (becasue its missing d)
    println("*** STEP 3 decode");
    for (i=0; i<10; i++)
    {
      if (inputSegments[i].length()==6)
      {
        if (containsChars(inputSegments[i], getInputByKnownNum(5))==false)
        {
          // this must be digit 0
          indexToSegs[0]=i;
          digitKnown[0]=true;
        }
      }
    }
    //printDecoded();

    // STEP 4 - work out 2 & 3
    // there are now only 2 "5 segment" numbers unknown - 2 & 3. 3 has an intersect with 1 and 2 doesnt. so we can
    // use 1 to split them and work them both out
    println("*** STEP 4 decode");
    for (i=0; i<10; i++)
    {
      if (inputSegments[i].length()==5)
      {

        // need to *exclude* '5' as we already know that.
        if (containsCharsAnyOrder(inputSegments[i], getInputByKnownNum(5))!=true)
        {

          if (containsChars(inputSegments[i], getInputByKnownNum(1))==false)
          {
            // this must be digit 0
            indexToSegs[2]=i;
            digitKnown[2]=true;
          }
          else
          {
            indexToSegs[3]=i;
            digitKnown[3]=true;
          }
        }
      }
    }
    //printDecoded();

    // STEP 5 - work out 6 & 9
    // there are now only 2 "6 segment" numbers unknown - 6 & 9. 9 has an intersect with 1 and 6 doesnt. so we can
    // use 1 to split them and work them both out
    println("*** STEP 5 decode");
    for (i=0; i<10; i++)
    {
      if (inputSegments[i].length()==6)
      {
        // need to *exclude* '0' as we already know that.
        if (containsCharsAnyOrder(inputSegments[i], getInputByKnownNum(0))!=true)
        {

          if (containsChars(inputSegments[i], getInputByKnownNum(1))==true)
          {
            // this must be digit 0
            indexToSegs[9]=i;
            digitKnown[9]=true;
          }
          else
          {
            indexToSegs[6]=i;
            digitKnown[6]=true;
          }
        }
      }
    }
    printDecoded();
  }

  String getInputByKnownNum(int in)
  {

    if (digitKnown[in]==true)
    {
      return(inputSegments[indexToSegs[in]]);
    }

    return(null);
  }

  int getOutputBySegments(String s)
  {
    // first of all find which input this corresponds to
    int i=0, j=0;
    int ret=-1;

    for (i=0; i<10; i++)
    {
      //if (inputSegments[i].compareTo(s)==0)
      if (containsCharsAnyOrder(inputSegments[i], s)==true)
      {
        for (j=0; j<10; j++)
        {
          if (indexToSegs[j]==i)
          {
            ret=j;
          }
        }
      }
    }
    return(ret);
  }

  int decodeOutput()
  {
    int i=0;
    int l=outputSegments.length;
    int digit=0;
    int total=0;
    int j=0;

    for (i=l-1; i>=0; i--)
      //for (i=0;i<l;i++)
    {
      digit=getOutputBySegments(outputSegments[i]);
      println("Seg:"+outputSegments[i]+" maps to "+digit);
      total+=digit*(j==0?1:Math.pow(10, j));
      j++;
    }
    return(total);
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

  void printInput()
  {
    int i;
    println("IN["+input+"] OUT["+output+"]");
    for (i=0; i<10; i++)
    {
      println("{IN["+i+"]\""+inputSegments[i]+"\" len:"+inputSegments[i].length()+"}");
    }
  }

  void printDecoded()
  {
    int i=0;

    for (i=0; i<10; i++)
    {
      if (digitKnown[i]==true)
      {
        println("["+i+"] Known:"+digitKnown[i]+" value Index:"+indexToSegs[i]+" Value:"+inputSegments[indexToSegs[i]]);
      }
      else
      {
        println("["+i+"] unknown");
      }
    }
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
    }
    catch (IOException e) {
      e.printStackTrace();
    }

    numLines=lines.size();
  }

  public void printFile()
  {
    println("CONTENTS FOR:"+fileName);
    int i=0;
    for (i=0; i<numLines; i++)
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
  int value=0;
  boolean set=false;

  public Minimum()
  {
  }

  public void set(int v)
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
  int value=0;

  public Maximum()
  {
  }

  public void set(int v)
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
    for (i=0; i<nodes; i++)
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
    walk(components, "");
  }

  public void walk(String input, String current)
  {
    int i=0;

    // for each character in the input
    for (i=0; i<input.length(); i++)
    {
      // if there is more than 1 character left, then we need to fork and repeat
      // the walk for each new substring
      if (input.length()>1)
      {
        // lock in this char, by removing the character at the current index from the string
        String remainder=input.substring(0, i)+input.substring(i+1, input.length());
        //println(input.charAt(i)+" R:"+remainder);

        // walk the tree for the remaining characters now that we've locked one
        // in for this set of permuations.
        walk(remainder, current+input.charAt(i));
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

    for (i=0; i<s.length(); i++)
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
