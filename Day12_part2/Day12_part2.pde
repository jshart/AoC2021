import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day12_part1\\data\\example");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

CaveSystem cs = new CaveSystem();
int goodPaths=0;

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
    cs.parseCave(input.lines.get(i));
  }
  
  cs.printSystem();
  
  cs.exploreSystem();
  
  cs.printPaths();
  
  println("### GOOD PATHS FOUND="+goodPaths);
  println("Final list size was:"+cs.paths.size());
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

public class CaveSystem
{
  ArrayList<Cave> caves = new ArrayList<Cave>();
  Cave startCave;
  
  ArrayList<Path> paths = new ArrayList<Path>();
  
  public CaveSystem()
  {
  }
  
  void parseCave(String s)
  {
    String[] temp = s.split("-");
    Cave fromCave, toCave;
    
    fromCave=alreadyExists(temp[0]);
    if (fromCave==null)
    {
      fromCave = new Cave(temp[0]);
      caves.add(fromCave);
    }
    
    toCave=alreadyExists(temp[1]);
    if (toCave==null)
    {
      toCave = new Cave(temp[1]);
      caves.add(toCave);
    }
    fromCave.addConnection(toCave);
    toCave.addConnection(fromCave);
    
    if (fromCave.name.equals("start")==true)
    {
      startCave=fromCave;
    }
  }
  
  Cave alreadyExists(String s)
  {
    int i=0;
    int l=caves.size();
    for(i=0;i<l;i++)
    {
      if (caves.get(i).name.equals(s)==true)
      {
        return(caves.get(i));
      }
    }
    return(null);
  }
  
  void printSystem()
  {
    int i=0;
    int l=caves.size();
    for(i=0;i<l;i++)
    {
      caves.get(i).printCave();
    }
    
    //print("Start cave ==");
    //startCave.printCave();
  }
  
  void exploreSystem()
  {
    // initialise a path with just the "start cave" to seed the search
    Path p = new Path(startCave);
    paths.add(p);
    
    Cave lastCave;
    
    int i=0;
    int l=0;
    Path tp;
    
    int j=0;
    int cl=0;
    
    // continue to search whilst we have incomplete (but still valid) paths
    while(pathsToExplore()==true)
    {
      println("*** Iterating ***");
      pruneList();
      
      // check each path to see if we can expand it...
      l=paths.size();
      
      //for each path
      for (i=0;i<l;i++)
      {
        tp=paths.get(i);
        
        print("Exploring Path "+i+": ");
        tp.printPath();
        
        // is this path already complete? (valid or otherwise)
        if (tp.complete==false)
        {
          // its now going to be superceeded by the new longer paths we're going to create, so
          // lets mark this as complete so we dont consider it any more (we can eventually prune it,
          // but for now and to aid debugging we can simply mark that we're done with it by marking
          // it as complete)
          tp.complete=true;
          
          // Lets find the last cave in the path
          lastCave=tp.chain.get(tp.chain.size()-1);
          
          // this path still has something to explore
          // for each connection, lets fork the path and add it to the search space.
          // get the last cave in this path and setup to explore all of *its* connnections
          cl=lastCave.connectionList.size();
          
          for (j=0;j<cl;j++)
          {
            paths.add(new Path(tp,lastCave.connectionList.get(j)));
          }
        }
      }
    }
  }
  
  void pruneList()
  {
    int i=0;
    int l=paths.size();
    Path p;
    
    for (i=l-1;i>=0;i--)
    {
      p=paths.get(i);
      if (p.validPath==false && p.complete==true)
      {
        paths.remove(i);
      }
    }
  }
  
  void printPaths()
  {
    int i=0;
    int l=paths.size();
    Path p;
    
    for (i=0;i<l;i++)
    {
      p=paths.get(i);
      p.printPath();
    }
  }
  
  boolean pathsToExplore()
  {
    int i=0;
    int l=paths.size();
    Path p;
    
    for (i=0;i<l;i++)
    {
      p=paths.get(i);
      
      if (p.validPath==true && p.complete==false)
      {
        return(true);
      }
    }
    return(false);
  }
}

public class Path
{
  ArrayList<Cave> chain = new ArrayList<Cave>();
  boolean validPath=true;
  boolean complete=false;
  ArrayList<String> doNotRevistList = new ArrayList<String>();
  
  boolean usedSecondVisit=false;
  
  // add an individual node (e.g. to init with start)
  public Path(Cave c)
  {
    validPath=addCaveToPath(c);
  }
  
  // copy nodes from existing path (e.g. to fork it)
  public Path(Path p, Cave c)
  {
    int i=0;
    int l=p.chain.size();
        
    // Fork path so far...
    for (i=0;i<l;i++)
    {
      validPath=addCaveToPath(p.chain.get(i));
    }
    
    // Add additional step;
    validPath=addCaveToPath(c);
  }
  
  public boolean addCaveToPath(Cave p)
  {
    // is this the end of the path?
    if (p.name.equals("end")==true)
    {
      chain.add(p);
      
      validPath=true;
      complete=true;
      
      goodPaths++;
      
      return(true);
    }
    
    if (alreadyOnDoNotVisitList(p.name)==false)
    {
      chain.add(p);
      return(true);
    }
    
    // this path is invalid as it requires us to revisit a small cave
    // so lets end this path and mark it as invalid
    validPath=false;
    complete=true;
    
    return(false);
  }
  
  public boolean alreadyOnDoNotVisitList(String name)
  {
    int i=0;
    int l=doNotRevistList.size();
    
    // Is this cave already on the do not visit list?
    for (i=0;i<l;i++)
    {
      if (doNotRevistList.get(i).equals(name)==true)
      {
        println("LOOP FOUND:"+doNotRevistList.get(i)+"=="+name);
        return(true);
      }
    }
    
    boolean addToList=true;
    for (i=0;i<name.length();i++)
    {
      if (Character.isUpperCase(name.charAt(i))==true)
      {
        addToList=false;
        break;
      }
    }
    
    if (addToList==true)
    {
      doNotRevistList.add(name);
    }
    
    return(false);
  }
  
  public void printPath()
  {
    int i=0;
    int l=chain.size();
    
    for (i=0;i<l;i++)
    {
      print(chain.get(i).name+",");
    }
    println("valid="+validPath+" Complete="+complete);
  }
}


public class Cave
{
  String name;
  ArrayList<Cave> connectionList = new ArrayList<Cave>();
   
  public Cave(String s)
  {
    name = s;
  }
  
  public void addConnection(Cave c)
  {
    connectionList.add(c);
  }
  
  public void printCave()
  {
    println("["+name+"]");
    
    int i=0;
    int l=connectionList.size();
    for (i=0;i<l;i++)
    {
      println("  \\_["+connectionList.get(i).name+"]");
    }
  }
  
  public boolean isSmall()
  {
    int i=0;
    int l=name.length();
    
    for (i=0;i<l;i++)
    {
      if (Character.isUpperCase(name.charAt(i))==true)
      {
        return(false);
      }
    }
    return(true);
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
