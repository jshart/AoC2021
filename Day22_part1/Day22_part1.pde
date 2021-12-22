import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day22_part1\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

ArrayList<Range> rangeList = new ArrayList<Range>();

Minimum minx=new Minimum();
Minimum miny=new Minimum();
Minimum minz=new Minimum();
Maximum maxx=new Maximum();
Maximum maxy=new Maximum();
Maximum maxz=new Maximum();

int[][][] reactor = new int[200][200][200];


void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  // Loop through each input item...
  for (i=0;i<input.lines.size();i++)
  {
    rangeList.add(new Range(input.lines.get(i)));
  }
  
  for (i=0;i<rangeList.size();i++)
  {
    rangeList.get(i).printRange();
    println();
    updateMinMaxRange(rangeList.get(i));
  }
  println("Total x range:"+minx.value+","+maxx.value+" diff="+(maxx.value-minx.value));
  println("Total y range:"+miny.value+","+maxy.value+" diff="+(maxy.value-miny.value));
  println("Total z range:"+minz.value+","+maxz.value+" diff="+(maxz.value-minz.value));
  
  part1Solution();
}

public void part1Solution()
{
  
  int i=0;
  int l=rangeList.size();
  Range r;
  long count=0;
  
  int xc=0,yc=0,zc=0;
  
  for (i=0;i<l;i++)
  {
    r=rangeList.get(i);
    
    print("Power=["+r.on+"] Reactor for:");
    r.printRange();
    if (r.goodRange()==false)
    {
      println(" Skipping, as bad range");
      continue;
    }
    
    for (xc=r.startx;xc<=r.endx;xc++)
    {
      for (yc=r.starty;yc<=r.endy;yc++)
      {
        for (zc=r.startz;zc<=r.endz;zc++)
        {
          if (r.on==true)
          {
            reactor[xc][yc][zc]=1;
          }
          else
          {
            reactor[xc][yc][zc]=0;
          }
        }
      }
    }
    print("   ");
    countCubes();
  }
}

public long countCubes()
{
  int i=0;
  int l=rangeList.size();
  Range r;
  long count=0;
  
  int xc=0,yc=0,zc=0;
  for (xc=0;xc<200;xc++)
  {
    for (yc=0;yc<200;yc++)
    {
      for (zc=0;zc<200;zc++)
      {
        if (reactor[xc][yc][zc]==1)
        {
          count++;
        }
      }
    }
  }
  println("TOTAL:"+count);
  return(count);
}

public void updateMinMaxRange(Range r)
{
  minx.set(r.startx);
  miny.set(r.starty);
  minz.set(r.startz);
  
  maxx.set(r.endx);
  maxy.set(r.endy);
  maxz.set(r.endz);
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

public class Range
{
  int startx=0;
  int starty=0;
  int endx=0;
  int endy=0;
  int startz=0;
  int endz=0;
  boolean on=false;
  
  public Range(String s)
  {
    String temp[];
    String temp2[];
    temp=s.split(" ");
    int i=0;
    char c;
    
//println("Processing: "+s);
    
    if (temp[0].equals("on")==true)
    {
      on=true;
    }
    temp=temp[1].split(",");
    
    for (i=0;i<temp.length;i++)
    {
      c=temp[i].charAt(0);
      
      temp[i]=temp[i].substring(2,temp[i].length());
//println("- temp[i] after chomp:"+temp[i]);
      temp2=temp[i].split(":");
      
//println("- Processing:"+temp2[0]+" for:"+c);
//println("- Processing:"+temp2[1]+" for:"+c);
      
      switch (c)
      {
        case 'x':
          startx=Integer.parseInt(temp2[0]);
          endx=Integer.parseInt(temp2[1]);
          break;
        case 'y':
          starty=Integer.parseInt(temp2[0]);
          endy=Integer.parseInt(temp2[1]);
          break;
        case 'z':
          startz=Integer.parseInt(temp2[0]);
          endz=Integer.parseInt(temp2[1]);
          break;
      }
    }
    
    // for part 1 - lets offset everything by 50, to ensure the entire
    // matrix is positive
    startx+=50;
    starty+=50;
    startz+=50;
    endx+=50;
    endy+=50;
    endz+=50;
  }
  
  public boolean goodRange()
  {
    if (startx<0 || starty<0 || startz<0)
    {
      return(false);
    }
    if (endx>100 || endy>100 || endz>100)
    {
      return(false);
    }
    return(true);
  }
  
  public void printRange()
  {
    print("Xr:"+startx+","+endx+" Yr:"+starty+","+endy+" Zr:"+startz+","+endz);
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
