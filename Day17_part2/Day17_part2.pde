import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day17_part2\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
//InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

public enum Accuracy {
  MHIT,
  MLEFT,
  MSKIPPED,
  MRIGHT,
  MTOO_EARLY
};

ArrayList<JVector> goodHits = new ArrayList<JVector>();

// TODO LIST:
// 1) work out how to flip and run for both positive and
//    negative values of 'y'. Will need another mode switch
//    in the main logic to run all +y *and* -y for a given x
// 2) Need to add the concept of initial direction to the probe
//    class as we need to check for the SKIP case in either
//    a negative or a positive direction  
//
// NOTES:
// 1) there is a minimum 'x' value such as needed
//    to brige the gap to the target - for the example
//    this is '6' because anything less - e.g. '5'
//    will not generate enough x-delta before drag
//    brings it to zero, e.g. 5+4+3+2+1=15, so no
//    matter the 'y' value the probe can never hit
//    the target.
// 2) there is a maximum 'x' value such that beyond
//    that value the 'x' will immediately "gap" past
//    the target. e.g. for the example, an 'x' of 30
//    means the probe will immediately jump to the
//    far right of the target, any larger and it will
//    immediately be beyond it and can never hit it.
// 3) The far 'x' range is dependent on 'y' value. For
//    certain values the *first* x increment can place
//    you inside the target because the 'y' is aiming
//    at the side rather than above/below. So the
//    extreme 'x' value is the distance from the start
//    position to the far side of the target.
//
// Therefore the algorithm needs to check all 'y' values
// for the range of valid 'x' values.
//
// Part 1 found a total of 108 valid 'y' positions for the
// highest case. So our rough worst case magnitude is valid_x_range * 216
//
// for my data, this is;
// Calibration completed, valid x ranges:19->221 Range Size:202
// This gives me an order of magnitude of about 43632 permutations.
// This is an upper end estimate assuming that all 'y' values are as
// bad as the worst case. This is highly unlikely and its more probable
// that the magntitude is half or quarter or less of this, however it
// gives us some confidence that the complete list can be stored in a
// rational amount of memory.


// BUG: missing end 'x' cases where x=9 - must be calculating x-range too short?


int sf=1;
Target target = new Target();
Probe probe = new Probe();
boolean testCaseActive=true;
boolean increaseX=false;
JVector testcase=new JVector();
Maximum max = new Maximum();
int total=0;


void setup() {
  size(800, 800);
  background(0);
  stroke(255);
  frameRate(120);
  rectMode(CORNERS);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  //input.printFile();
  
  int i=0,j=0;

//  // Loop through each input item...
//  for (i=0;i<input.lines.size();i++)
//  {
  
//  }

  probe.calibrateXRange(target);
  testcase.x=probe.xRangeS;
  probe.trajectory.set(testcase);
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
  JVector drawOffset= new JVector(400,400); 
  Accuracy result=Accuracy.MTOO_EARLY;
  
  translate(drawOffset.x,drawOffset.y);
  target.drawTarget();
  
  //print("TARGET:");
  //target.ts.printVector();
  //print("->");
  //target.te.printVector();
  //println();
  
  boolean endConditionMet=false;
  int i=0;
  
  // If we've finished a test case then we'll mark this
  // state as inactive, and we should then reset the test
  // conditions to the next case - if there are any.
  if (testCaseActive==false)
  {
    // if we've explored all the 'y' values at this
    // location, then we may need to increase 'x'
    // to test a new range of 'y' values
    if (increaseX==true)
    {
      increaseX=false;
      testcase.x++;
      
      // if thew new 'x' location is beyond the valid
      // 'x' range, then we're done with our test runs
      if (testcase.x>probe.xRangeE)
      {
        println("testcase.x too high at;"+testcase.x);

        // we've exhausted all 'x' values, stop processing
        // report and quit
        endConditionMet=true;
        
        if (endConditionMet==true)
        {
          // we've exhausted all 'x' values, stop processing
          // report and quit
          println("\n### ALL RUNS COMPLETE");
          println("Total:"+total);
          
          println("Array size="+goodHits.size());
          for (i=0;i<goodHits.size();i++)
          {
            goodHits.get(i).printVector();
            println();
          }
          noLoop();
        }
      }
    }
    

    
    probe.reset();
    probe.trajectory.set(testcase);
    print("*** STARTING NEW RUN for case: ");
    testcase.printVector();
    println();
    
    testCaseActive=true;
    background(0);
  }
  
  probe.drawProbe();
  probe.moveProbe();
  
  //print("Pos:");
  //probe.position.printVector();
  //print(" Traj:");
  //probe.trajectory.printVector();
  //println();
  
  result=probe.hasHit(target);
  
  // extra case we need to deal with
  if (probe.position.x>probe.xRangeE)
  {
    println("x position too high at;"+probe.position.x);
    testcase.y=0;
    testCaseActive=false;
    increaseX=true;
    probe.peaked=false;
  }
  

  
  // has the probe height peaked?
  // if it has we now we need to start
  // tracking if it will actually hit
  // or not, this just saves us from boundary
  // checking whilst the probe is still going up
  if (probe.peaked==true)
  {
    switch (result)
    {
      case MHIT:
        println(" +- HIT! max="+probe.h.value);
        print(" +- Pos:");
        probe.position.printVector();
        print(" Traj:");
        probe.trajectory.printVector();
        print(" Base:");
        testcase.printVector();
        println();
        testCaseActive=false;
        
        goodHits.add(new JVector(testcase));
  
        // lets see if we can go higher?
        testcase.y++;
        max.set(probe.h.value);
        total++;
        
        break;
      //case MLEFT:
      //  // add x
      //  testcase.x++;
      //  testcase.y++;
      //  println("MISSED - maybe recoverable:"+testcase.x+","+testcase.y);
      //  testCaseActive=false;
      //  break;
      //case MRIGHT:
      //  println("MISSED - unrecoverable max="+probe.h.value);
      //  print("Pos:");
      //  probe.position.printVector();
      //  print(" Traj:");
      //  probe.trajectory.printVector();
      //  print(" Base:");
      //  testcase.printVector();
      //  println();
      //  testCaseActive=false;
        
      //  println("MAX:"+max.value);
      //  noLoop();
      //  break;
      case MSKIPPED:
        if (abs(probe.trajectory.y)>(abs(target.h)*3))
        {
          println("MISSED - can not continue:"+testcase.x+","+testcase.y);
          probe.printProbe();
          println();
          println("H="+target.h);
          
          // we've really finished with this case now - we've gone a reasonable
          // window past the last positive results, so lets try another 'x' value
          testCaseActive=false;
          increaseX=true;
          
          // reset the 'y' range
          testcase.y=0;
        } 
        else
        {
          println("MISSED - maybe recoverable:"+testcase.x+","+testcase.y);
          probe.printProbe();
          println();
          println("H="+target.h);
          
          // Finished with this test case - but lets see if there are
          // more results beyond where we are.
          testcase.y++;
          testCaseActive=false;
        }
 
        break;

    }
  }
}

public class Target
{
  // example data
  JVector ts=new JVector(20,-5);JVector te=new JVector(30,-10);
  // my data
  //JVector ts=new JVector(185,-74);JVector te=new JVector(221,-122);
  int h;


  public Target()
  {
    h=te.y-ts.y;
  }
  
  public void drawTarget()
  {
    fill(0,255,0);
    rect(ts.x*sf,ts.y*sf,te.x*sf,te.y*sf);
  }
}

public class Probe
{
  JVector position=new JVector(0,0);
  JVector trajectory=new JVector();
  Maximum h=new Maximum();
  boolean peaked=false;
  int xRangeS=0;
  int xRangeE=0;

  public void drawProbe()
  {
    fill(255,0,0);
    rect(position.x+sf,position.y+sf,position.x+(sf*2),position.y+(sf*2));
  }
  
  public void printProbe()
  {
    print("P["+position.x+","+position.y+"] T["+trajectory.x+","+trajectory.y+"]");
  }
  
  public void moveProbe()
  {
    // move by the velocity
    position.x+=trajectory.x;
    position.y+=trajectory.y;
    
    // adjust the velocity based on drag
    trajectory.x=trajectory.x<=0?0:trajectory.x-1;
    // adjust the velocity based on gravity
    trajectory.y--;
    
    peaked=h.set(position.y)==true?false:true;
  }
  
  public boolean canStillHit(Target t)
  {
    // if the probe lower than the target area
    // then it can not hit it
    if (position.y<t.te.y)
    {
      return(false);
    }
    return(true);
  }
  public Accuracy hasHit(Target t)
  {
    if (position.y<=t.ts.y && position.y>=t.te.y && position.x>=t.ts.x && position.x<=t.te.x)
    {
      return(Accuracy.MHIT);
    }
    // did we fall short to the left?
    if (position.x<t.ts.x && position.y<=t.te.y)
    {
      return(Accuracy.MLEFT);
    }
    // did we over shoot to the right?
    if (position.x>t.te.x)
    {
      return(Accuracy.MRIGHT);
    }
    
    // TODO - this needs to check both y positions to accurately deal with positive/negative cases
    // did we just skip over?
    if (position.y<t.te.y)
    {
      return(Accuracy.MSKIPPED);
    }
    return(Accuracy.MTOO_EARLY);
  }
  
  public void reset()
  {
    position.x=0;
    position.y=0;
    trajectory.x=0;
    trajectory.y=0;
    peaked=false;
  }
  
  public void calibrateXRange(Target t)
  {
    int i=0;
    int j=0;
    int test=0;
    boolean startRangeFound=false;
    
    
    println("Calibrating X to find range for:"+t.ts.x+"->"+t.te.x);
    while (startRangeFound==false)
    {
      // setup a new test x value
      i++;
      test=0;
      println("Testing x="+i);
      
      // calculate how far this would take us
      for (j=i;j>=0;j--)
      {
        test+=j;
      }

      // is this inside our target area? if it is
      // and its the first value to be in the area
      // then we've found are start range
      if (test>=t.ts.x && startRangeFound==false)
      {
        xRangeS=i;
        startRangeFound=true;
      }
      
      //// if this value exactly hits the end then
      //// its valid, but also its clearly the last
      //// such value
      //if (test==t.te.x)
      //{
      //  xRangeE=i;
      //  endRangeFound=true;
      //}
      
      //// if this value is greater than the end range
      //// then the previous value must've been the end
      //// value
      //if (test>t.te.x)
      //{
      //  xRangeE=i-1;
      //  endRangeFound=true;
      //}
    }
    xRangeE=t.te.x;
    println("Calibration completed, valid x ranges:"+xRangeS+"->"+xRangeE+" Range Size:"+(xRangeE-xRangeS));
  }
}

public class JVector
{
  int x=0;
  int y=0;
  int w=0;
  int cost=0;
  
  public JVector()
  {
  }
  
  public JVector(JVector j)
  {
    set(j);
  }
  public JVector(int x_, int y_)
  {
    set(x_,y_);
  }
  public void set(int x_, int y_)
  {
    x=x_;
    y=y_;
  }
  
  public void drawVectorConnection()
  {
    int sx=0,sy=0,ex=0,ey=0;
    
    ex=(x*sf)+sf/2;
    ey=(y*sf)+sf/2;
    
    line(sx,sy,ex,ey);
    circle(ex,ey,sf/2);
  }
  
  public void drawVectorLocation()
  {
    color c=color(255,0,0);

    stroke(c);
    fill(c);
    rect(x*sf,y*sf,sf,sf);
  }
  
  public void add(JVector i)
  {
    x+=i.x;
    y+=i.y;
  }
  
  public void printVector()
  {
    print(x+","+y);
  }
  
  public void set(JVector i)
  {
    x=i.x;
    y=i.y;
    w=i.w;
    cost=i.cost;
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

  public boolean set(long v)
  {
    if (v>value)
    {
      value=v;
      return(true);
    }
    return(false);
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
