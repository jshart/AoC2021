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

JVector[] neighbours = new JVector[4];


Frontier f;

JVector[][] map;
int maxX=0;
int maxY=0;
int rotation=0;
int sf=8;

void setup() {
  size(800, 800);
  background(0);
  stroke(255);
  frameRate(40);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  maxX=input.lines.size();
  maxY=input.lines.get(0).length();

  map = new JVector[maxX][maxY];
  
  JVector t;
  
  // Loop through each input item...
  for (i=0;i<maxX;i++)
  {
    for (j=0;j<maxY;j++)
    {
      t=new JVector(i,j);
      
      t.cost=Character.getNumericValue(input.lines.get(i).charAt(j));
      
      map[i][j]=t;
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

  neighbours[0] = new JVector(-1,0);
  neighbours[1] = new JVector(1,0);
  neighbours[2] = new JVector(0,-1);
  neighbours[3] = new JVector(0,1);
 
  f=new Frontier(new JVector(0,0));
}

void printMasterList()
{
  int i=0;
  for (i=0;i<masterList.size();i++)
  {
    println("ML input:"+masterList.get(i));
  }
}



int iterations=500;

void draw() {  
  int x=0,y=0;

  background(0);

  
  // Draw the map...
  for (x=0;x<maxX;x++)
  {
    for (y=0;y<maxY;y++)
    {
      map[x][y].drawVectorLocation();
    }
  }
  
  
  JVector result;
  
  result=f.expandFrontier();
  f.drawFrontier();
  //f.drawVectorConnections();
  //f.printFrontierWeights(f.cFrontier);

  //print("*");
  
  iterations--;
  //if (iterations==0)
  if (result!=null)
  {
    noLoop();
    f.printFrontierWeights(f.cFrontier);
  }
  if (result!=null)
  {
  
    print("RETURNED VECTOR:"+result.x+","+result.y+" w="+result.w);
    print("Weight at locatin:"+result.w);
  }
}

public class Frontier
{
  JVector startLoc;

  ArrayList<JVector> cFrontier= new ArrayList<JVector>();

  
  public Frontier(JVector s)
  {
    startLoc=s;    
    cFrontier.add(startLoc);
    visitLoc(startLoc,startLoc);
  }
  
  public void visitLoc(JVector t, JVector f)
  {
    map[t.x][t.y].predecessor=f; 
  }
  
  public void drawVectorConnections()
  {
    int x=0,y=0;

    stroke(0,255,255);
    fill(0,255,255);
    for (x=0;x<maxX;x++)
    {
      for (y=0;y<maxY;y++)
      {
        if (map[x][y]!=null)
        {
          map[x][y].drawVectorConnection();
        }
      }
    }
  }
  
  public void drawFrontier()
  {
    int i=0;
    int l=cFrontier.size();
    JVector v;
    
    for (i=0;i<l;i++)
    {
      v=cFrontier.get(i);

      stroke(0,0,255);
      fill(0,0,255);
      rect(v.x*sf,v.y*sf,sf,sf);
    }
  }
  
  public JVector expandFrontier()
  {
    int i=0,j=0;
    JVector currentV;
    int x=0,y=0;
    JVector nextV;
    int dx=0,dy=0;
    int w;        

//println("walking frontier "+i);

    // grab the head of the list - its the lowest cost
    currentV=cFrontier.get(0);
    cFrontier.remove(0);
    
    x=currentV.x;
    y=currentV.y;
    

//println("inside map");
    
    // Check each neighbour to see if we can expand into it
    for (j=0;j<neighbours.length;j++)
    {
      // work out the delta to this neighbour
      dx=x+neighbours[j].x;
      dy=y+neighbours[j].y; 
      

      
      // is this within the map?
      if (isValid(dx,dy)==true)
      {
        // get the next node to check
        nextV=map[dx][dy];
        
        // Calculate new weight for this path
        w=currentV.w+nextV.cost;
        
        // We've hit our target, return the value
        if (dx==maxX-1 && dy==maxY-1)
        {
          map[dx][dy].w=w;
          return(map[dx][dy]);
        }
        
        if (betterMatch(dx,dy,w)==true)
        {
          if (addOrderedByWeight(cFrontier,nextV,w)==true)
          {
            nextV.w=w;
            currentV.predecessor=nextV;
          }
        }
      }
    }
    
    return(null);
  }

  public boolean addOrderedByWeight(ArrayList<JVector> n, JVector t, int w)
  {
    int i=0;
    int l=n.size();
    JVector v;

//print("Trying to add:"+t.x+","+t.y+","+w);

    // check each frontier element in turn, looking for a space to
    // insert this new one
    for (i=0;i<l;i++)
    {
      v=n.get(i);

      // if this is the same as or worse than an existing entry - skip it.
      // we've reached the same location using the same or higher cost, so 
      // this path cant be any better than the one that already
      // was found.
      if (w>=v.w && v.x==t.x && v.y==t.y)
      {
//println(" not added");
        return(false);
      }
      
      // this current element has a weight higher than this one
      // so lets add this one before it.
      if (v.w>w)
      {
//println(" location found at:"+i);
        n.add(i,t);
        return(true);
      }
    }
//println(" location found at END:"+i);
    n.add(t);
    return(true);
  }
  
  public boolean isValid(int x, int y)
  {    
    if (x<0 || y<0 || x>=maxX || y>=maxY)
    {
      return(false);
    }
    return(true);
  }
 
  public boolean betterMatch(int x, int y, int newW)
  {
    JVector v;

    v=map[x][y];
    
    // First time visiting this node?
    if (v.predecessor==null)
    {
      return(true);
    }

    // Been here already, is this new path shorter?
    // if so then override.
    if (newW<v.w)
    {
      return(true);
    }
    
    // All other conditions mean we shouldnt add the node
    return(false);
  }
  
  
  void printFrontierWeights(ArrayList<JVector> f)
  {
    int l=f.size();
    JVector v;

    int i=0;
    for (i=0;i<l;i++)
    {
      v=f.get(i);
      println(i+": ["+v.x+","+v.y+"].w="+ v.w);
    }
    println("TOTAL F's:"+l);
  }
}



public class JVector
{
  int x=0;
  int y=0;
  int w=0;
  int cost=0;
  JVector predecessor;
  
  public JVector()
  {
  }
  
  public JVector(int x_, int y_)
  {
    x=x_;
    y=y_;
  }
  
  public void drawVectorConnection()
  {
    int sx=0,sy=0,ex=0,ey=0;
    
    if (predecessor==null)
    {
      return;
    }
    
    sx=((predecessor.x)*sf)+sf/2;
    sy=((predecessor.y)*sf)+sf/2;
    
    ex=(x*sf)+sf/2;
    ey=(y*sf)+sf/2;
    
    line(sx,sy,ex,ey);
    circle(ex,ey,sf/2);
  }
  
  public void drawVectorLocation()
  {
    int c;
    c=255/map[x][y].cost;
    stroke(c);
    fill(c);
    rect(x*sf,y*sf,sf,sf);
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
