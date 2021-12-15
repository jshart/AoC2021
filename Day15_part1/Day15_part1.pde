import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day15_part1\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

ArrayList<Path> p1 = new ArrayList<Path>();
ArrayList<Path> p2 = new ArrayList<Path>();
ArrayList<Path> currentPathList=p1;
ArrayList<Path> nextPathList=p2;
Path reference;
long referenceRisk=0;

Frontier f;

int[][] map;
int maxX=0;
int maxY=0;
int rotation=0;
int sf=4;

void setup() {
  size(400, 400);
  background(0);
  stroke(255);
  frameRate(40);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  maxX=input.lines.size();
  maxY=input.lines.get(0).length();

  map = new int[maxX][maxY];
  reference = new Path();
  
  // Loop through each input item...
  for (i=0;i<maxX;i++)
  {
    for (j=0;j<maxY;j++)
    {
      map[i][j]=Character.getNumericValue(input.lines.get(i).charAt(j));
    }
  }
  
  //for (i=0;i<maxX;i++)
  //{
  //  for (j=0;j<maxY;j++)
  //  {
  //    print(map[i][j]+",");
  //  }
  //  println();
  //}
  println("Dimensions:"+maxX+","+maxY);
  
  reference.generateReferencePath();
  referenceRisk=reference.risk();
  
  // init the pathlist with one path...
  currentPathList.add(new Path());
  
  println("Reference Total:"+reference.risk());
 
  f=new Frontier(new PVector(0,0));
}

void printMasterList()
{
  int i=0;
  for (i=0;i<masterList.size();i++)
  {
    println("ML input:"+masterList.get(i));
  }
}

void swapPathLists()
{
  ArrayList<Path> t;
  t=currentPathList;
  currentPathList=nextPathList;
  nextPathList=t;
}

void draw() {  
  int x=0,y=0;
  int c;

  background(0);

  
  // Draw the map...
  for (x=0;x<maxX;x++)
  {
    for (y=0;y<maxY;y++)
    {
      c=255/map[x][y];
      stroke(c);
      fill(c);
      rect(x*sf,y*sf,sf,sf);
    }
  }
  
  reference.drawPath(color(255,0,0));
  
  f.expandFrontier();
  f.drawFrontier();
  
  //// draw all the paths so far
  //int l=currentPathList.size();
  //int i=0;
  //PVector lastStep;
  //Path p;
  //color col=color(0,255,0);
  //for (i=0;i<l;i++)
  //{
  //  p=currentPathList.get(i);
  //  p.drawPath(col);
    
  //  // check each cardinal direction from the last node to see if this is a valid
  //  // pathing location. if it is add a new path to the next list
  //  lastStep=p.steps.get(p.steps.size()-1);
  //  x=(int)lastStep.x;
  //  y=(int)lastStep.y;
    
  //  if (p.risk()<referenceRisk)
  //  {
  //    // check up
  //    if (p.isValid(x-1,y)>0)
  //    {
  //      nextPathList.add(new Path(p,new PVector(x-1,y)));
  //    }
  //    // check down
  //    if (p.isValid(x+1,y)>0)
  //    {
  //      nextPathList.add(new Path(p,new PVector(x+1,y)));
  //    }
  //    // check left
  //    if (p.isValid(x,y-1)>0)
  //    {
  //      nextPathList.add(new Path(p,new PVector(x,y-1)));
  //    }
  //    // check right
  //    if (p.isValid(x,y+1)>0)
  //    {
  //      nextPathList.add(new Path(p,new PVector(x,y+1)));
  //    }
  //  }
  //}
  //println("ACTIVE PATHS:"+i);
  
  //swapPathLists();
  //nextPathList.clear();
}

public class Frontier
{
  public int[][] pMap;
  PVector startLoc;
  ArrayList<PVector> p1 = new ArrayList<PVector>();
  ArrayList<PVector> p2 = new ArrayList<PVector>();
  ArrayList<PVector> cFrontier=p1;
  ArrayList<PVector> nFrontier=p2;
  
  public Frontier(PVector s)
  {
    startLoc=s;
    pMap = new int[maxX][maxY];
    
    cFrontier.add(startLoc);
  }
  
  public void visitLoc(PVector p)
  {
    pMap[(int)p.x][(int)p.y]++; 
  }
  
  public void drawFrontier()
  {
    int i=0;
    int l=cFrontier.size();
    PVector v;
    int x=0,y=0;
    
    for (i=0;i<l;i++)
    {
      v=cFrontier.get(i);
      x=(int)v.x;
      y=(int)v.y;
      stroke(0,0,255);
      fill(0,0,255);
      rect(x*sf,y*sf,sf,sf);
    }
  }
  
  public boolean expandFrontier()
  {
    boolean result=false;
    int i=0;
    int l=cFrontier.size();
    PVector v;
    int x=0,y=0;
    
    for (i=0;i<l;i++)
    {
      v=cFrontier.get(i);
      x=(int)v.x;
      y=(int)v.y;
      
      // check up
      if (isValid(x-1,y)>0)
      {
        nFrontier.add(new PVector(x-1,y));
        pMap[x-1][y]++;
      }
      // check down
      if (isValid(x+1,y)>0)
      {
        nFrontier.add(new PVector(x+1,y));
        pMap[x+1][y]++;
      }
      // check left
      if (isValid(x,y-1)>0)
      {
        nFrontier.add(new PVector(x,y-1));
        pMap[x][y-1]++;
      }
      // check right
      if (isValid(x,y+1)>0)
      {
        nFrontier.add(new PVector(x,y+1));
        pMap[x][y+1]++;
      }
    }
    
    swapFLists();
    nFrontier.clear();
    
    return(result);
  }
  
  public int isValid(int x, int y)
  {    
    if (x<0 || y<0 || x>=maxX || y>=maxY)
    {
      return(-1);
    }
    
    if (pMap[x][y]>0)
    {
      return(-3);
    }
    return(1);
  }
  
  void swapFLists()
  {
    ArrayList<PVector> t;
    t=cFrontier;
    cFrontier=nFrontier;
    nFrontier=t;
  }
}

public class Path
{
  ArrayList<PVector> steps = new ArrayList<PVector>();
  PVector start = new PVector(0,0);
  PVector end = new PVector(maxX-1,maxY-1);
  boolean[][] mask = new boolean[maxX][maxY];
  
  boolean active=true;
  
  public Path()
  {
    initMask();
    steps.add(start);
  }
  
  public void initMask()
  {
    int x=0,y=0;
    // Loop through each input item...
    for (x=0;x<maxX;x++)
    {
      for (y=0;y<maxY;y++)
      {
        mask[x][y]=false;
      }
    }
  }
  
  public Path(Path p, PVector s)
  {
    int i=0;
    int l=p.steps.size();
    
    // copy everything we need from the parent path
    
    copyMask(p);
    
    for (i=0;i<l;i++)
    {
      steps.add(p.steps.get(i));
    }
    
    // add the extra location
    addStep(s);
  }
  
  public void copyMask(Path p)
  {
    int x=0,y=0;
    // Loop through each input item...
    for (x=0;x<maxX;x++)
    {
      for (y=0;y<maxY;y++)
      {
        mask[x][y]=p.mask[x][y];
      }
    }
  }
  
  public void generateReferencePath()
  {
    int i=0;
    PVector t;
    for (i=1;i<maxX;i++)
    {
      t=new PVector(i,i);
      addStep(t);
    }
  }
  
  public void addStep(PVector step)
  {
    steps.add(step);
    mask[(int)step.x][(int)step.y]=true;
  }
  
  public void drawPath(color c)
  {
    int l=steps.size();
    int i=0;
    PVector t;
    for (i=0;i<l;i++)
    {
      t=steps.get(i);
 
      stroke(c);
      fill(c);
      rect(t.x*sf,t.y*sf,sf,sf);
    }
  }
  
  public long risk()
  {
    int l=steps.size();
    int i=0;
    PVector t;
    long total=0;
    
    for (i=0;i<l;i++)
    {
      t=steps.get(i);
      total+=map[(int)t.x][(int)t.y];
    }
    return(total);
  } 
  
  public int isValid(int x, int y)
  {    
    if (x<0 || y<0 || x>=maxX || y>=maxY)
    {
      return(-1);
    }
    
    if (mask[x][y]==true)
    {
      return(-3);
    }
    return(1);
  }
}

//void draw() {  
//  int x=0,y=0;
//  int c;
//  int sf=2;
  
//  translate(200, 200, -200);

//  background(0);
//  //rotateY(rotation++);
//  rotateX(radians(rotation++));
  
//  // Loop through each input item...
//  for (x=0;x<maxX;x++)
//  {
//    for (y=0;y<maxY;y++)
//    {
//      c=255/map[x][y];
//      stroke(c);
//      fill(c);
//      translate(0,sf,0);
//      box(sf,sf,map[x][y]*sf);
//    }
//    translate(sf,-(sf*(y-1)),0);
//  }
//}



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
