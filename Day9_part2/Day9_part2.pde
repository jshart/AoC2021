import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day9_part2\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();
int[][] dMap;
boolean[][] mask;
int maxX;
int maxY;

int maxList=300;
int[] values = new int[maxList];

void setup() {
  size(1000, 1000);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0, j=0;

  maxX=input.lines.size();
  maxY=input.lines.get(0).length();
  
  println("Init map size:"+maxX+","+maxY);
  dMap=new int[maxX][maxY];
  mask=new boolean[maxX][maxY];
  
  
  for (i=0;i<maxX;i++) // loop through each "line" in the input
  {
    for (j=0;j<maxY;j++) // loop through each "char" in the line
    {
      dMap[i][j]=Character.getNumericValue(input.lines.get(i).charAt(j));    
      print(dMap[i][j]+" ");
      
      // init the mask
      mask[i][j]=false;
    }
    println();
  }
  println("*** MATRIX loaded ***");
  println("Low point risk:"+findLowPoints());
}

int findLowPoints()
{
  int i=0, j=0;
  int total=0, t=0;
  int basinCount=0;
  
  for (i=0;i<maxX;i++) // loop through each "line" in the input
  {
    for (j=0;j<maxY;j++) // loop through each "char" in the line
    {
      //println("check:"+i+","+j);
      t=checkIfLow(i,j);
      if (t>=0) // Basin found
      {
        println("*** BASIN FOUND:"+basinCount);        
        values[basinCount]=mapBasin2(i,j);
        basinCount++;
        
        total+=(t+1);
      }
    }
  }
  
  values=sort(values);
  
  // print list of basin sizes
  for (i=0;i<maxList;i++)
  {
    println("Size:"+values[i]);
  }
  int b = values[maxList-1]*values[maxList-2]*values[maxList-3];
  println("BASIN total="+b);
  
  return(total);
}

public class BasinLocation
{
  int x;
  int y;
  public BasinLocation(int xIn, int YIn)
  {
    x=xIn;
    y=YIn;
  }
  
  public int isValid()
  {    
    if (x<0 || y<0 || x>=maxX || y>=maxY)
    {
      return(-1);
    }
    
    if (dMap[x][y]==9)
    {
      return(-2);
    }
    
    if (mask[x][y]==true)
    {
      return(-3);
    }
    return(1);
  }
  
  public void printLocation()
  {
    print(x+","+y);
  }
  
  public void printContents()
  {
    print("["+dMap[x][y]+"]");
  }
  
  public void setMask()
  {
    mask[x][y]=true;
  }
}


int mapBasin2(int tx, int ty)
{
  ArrayList<BasinLocation> candidates = new ArrayList<BasinLocation>();
  ArrayList<BasinLocation> confirmed = new ArrayList<BasinLocation>();
  
  BasinLocation t=new BasinLocation(tx,ty);
  
  candidates.add(t);
  
  int reason;
  
  while (candidates.size()>0)
  {
    t=candidates.get(0);
    candidates.remove(0);
    
    //print("Testing Location:");
    //t.printLocation();
    
    reason=t.isValid();
    
    if (reason>0)
    {
      //t.printContents();
      //println(" VALID, expanding");
      t.setMask();
      
      confirmed.add(t);
      tx=t.x;
      ty=t.y;
      
      t=new BasinLocation(tx+1,ty);
      candidates.add(t);
      //print("... adding:");
      //t.printLocation(); println();
      
      t=new BasinLocation(tx-1,ty);
      candidates.add(t);
      //print("... adding:");
      //t.printLocation(); println();
      
      t=new BasinLocation(tx,ty+1);
      candidates.add(t);
      //print("... adding:");
      //t.printLocation(); println();
      
      t=new BasinLocation(tx,ty-1);
      candidates.add(t);
      //print("... adding:");
      //t.printLocation(); println();
      
    }
    else
    {
      //println(" INVALID, reason:"+reason);
    }
  }
  
  int i=0;
  for (i=0;i<confirmed.size();i++)
  {
    confirmed.get(i).printLocation();
    println();
  }
  println("\\-- Size:"+confirmed.size());

  return(confirmed.size());
}


//void mapBasin(int tx, int ty, int dx, int dy, int rdepth)
//{
//  // If tx/ty is ever out of bounds lets quit
//  tx+=dx;
//  ty+=dy;
  
//  int i=0;
//  print(rdepth);
//  for (i=0;i<rdepth;i++)
//  {
//    print("_");
//  }
  
  
//  if (tx<0 || ty<0 || tx>=maxX || ty>=maxY)
//  {
//    println("Boundary detected");
//    return;
//  }
  
//  // if we get here, we're inside the Map area - but is this location a high point?
//  if (dMap[tx][ty]==9)
//  {
//    println("high point detected");
//    return;
//  }
  
//  // ok so this is *inbounds* and its *not* a high point - but did we already visit this point?
//  if (mask[tx][ty]==true)
//  {
//    println("been here");
//    return;
//  }
  
//  // OK - this appears to still be part of the basin and we've not visited this location yet.
//  // so lets flag that...
  
//  println("BP:"+tx+","+ty+" ["+dMap[tx][ty]+"] Mask:"+mask[tx][ty]);
//  mask[tx][tx]=true;
  

//  println("trying North");
//  mapBasin(tx,ty,0,-1,rdepth+1);

//  println("trying South");
//  mapBasin(tx,ty,0,+1,rdepth+1);

//  println("trying West");
//  mapBasin(tx,ty,-1,0,rdepth+1);

//  println("trying East");
//  mapBasin(tx,ty,+1,0,rdepth+1);
//}



int checkIfLow(int tx, int ty)
{
  // work out our "box" we want to check
  int sx=tx-1;
  int ex=tx+1;
  int sy=ty-1;
  int ey=ty+1;
  
  // deal with boundary conditions;
  sx=sx<0?0:sx;
  sy=sy<0?0:sy;
  
  ex=ex>=maxX?maxX-1:ex;
  ey=ey>=maxY?maxY-1:ey;
  
  int i=0;
  int j=0;
  
  boolean isLow=true;
  
  for (i=sx;i<=ex;i++)
  {
    for (j=sy;j<=ey;j++)
    {
      // ignore "this" location
      if (i!=tx || j!=ty)
      {
        if (dMap[tx][ty]>=dMap[i][j])
        {
          isLow=false;
        }
      }
    }
  }
  
  if (isLow)
  {
    println("low location found:"+tx+","+ty+" value:"+dMap[tx][ty]);
    return(dMap[tx][ty]);
  }
  
  return(-1);
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
  int i=0, j=0;
  int gs=0;
  int sf=8;

  for (i=0;i<maxX;i++) // loop through each "line" in the input
  {
    for (j=0;j<maxY;j++) // loop through each "char" in the line
    {
      gs=dMap[i][j]*(255/10);
      
      
      if (mask[i][j]==true)
      {
        fill(0,0,255-gs);
        stroke(0,0,255-gs);
      }
      else
      {
        fill(0,gs,0);
        stroke(0,gs,0);
      }
     
      rect(i*sf,j*sf,sf,sf);      
    }
  }
  
  for (i=0;i<maxX;i++) // loop through each "line" in the input
  {
    for (j=0;j<maxY;j++) // loop through each "char" in the line
    {
      if (dMap[i][j]==9)
      {
        stroke(255,0,0);
        rect(i*sf,j*sf,sf,sf); 
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
