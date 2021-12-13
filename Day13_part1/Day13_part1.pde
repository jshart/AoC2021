import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day13_part1\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();


PVector[] rawCoords;
int totalCoords=0;
ArrayList<Instruction> insList = new ArrayList<Instruction>();
Maximum maxX = new Maximum();
Maximum maxY = new Maximum();
int[][] space;

int maxIterations=12;
int currentInteration=0;

void setup() {
  size(1400,900);
  background(0);
  stroke(255);
  frameRate(0.5);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  rawCoords=new PVector[input.lines.size()];
  String[] temp;
  int x=0,y=0;

  // Loop through each input item...
  for (i=0;i<input.lines.size();i++)
  {
    if (input.lines.get(i).contains(",")==true)
    {
      // this is a co-ord
      temp = input.lines.get(i).split(",");
      x=Integer.parseInt(temp[0]);
      y=Integer.parseInt(temp[1]);
      rawCoords[totalCoords++]=new PVector(x,y);
      maxX.set(x);
      maxY.set(y);
    }
    else
    {
      // this is an instruction
      insList.add(new Instruction(input.lines.get(i)));
    }
  }
  
  // lets inc maxx, maxy as we need the extra row/column in the array for these values, as our array is 0-indexed
  // these now represent the number of elements in the array and not the max values found
  maxX.value++;
  maxY.value++;
  
  // Lets map the raw coords into a 2-d array to make manipulating the folds easier
  space=new int[maxX.value][maxY.value];
  for (i=0;i<totalCoords;i++)
  {
    space[(int)rawCoords[i].x][(int)rawCoords[i].y]=1;
  }
  
  println("Max X/Y:"+maxX.value+","+maxY.value);
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
  int x=0,y=0;
  int total=0;
 
  int i;
  
  i=currentInteration;
  
  background(0);
  
  for (x=0;x<maxX.value;x++)
  {
    for (y=0;y<maxY.value;y++)
    {
      if (space[x][y]==1)
      {
        stroke(255,0,0);
        fill(255,0,0);
        point(x,y);

        stroke(255,255,255);
        fill(255,255,255);
        rect(x*i,y*i,i,i);
        total++;
      }
    }
  }



  insList.get(currentInteration).drawIns();
  insList.get(currentInteration).printIns();
  insList.get(currentInteration).foldSpace();

  println("Total:"+total);
  
  maxIterations--;
  if (maxIterations==0)
  {
    for (y=0;y<maxY.value;y++)
    {
      for (x=0;x<maxX.value;x++)
      {
        if (space[x][y]==1)
        {
          print("#");
        }
        else
        {
          print(" ");
        }
      }
      println();
    }
    
    background(0);

    for (x=0;x<maxX.value;x++)
    {
      for (y=0;y<maxY.value;y++)
      {
        if (space[x][y]==1)
        {
          stroke(255,0,0);
          fill(255,0,0);
          point(x,y);
  
          stroke(255,255,255);
          fill(255,255,255);
          rect(x*i,y*i,i,i);
          total++;
        }
      }
    }
    
    noLoop();
    return;
  }
  
  currentInteration++;
}

public class Instruction
{
  int axis=0;
  char direction;
  
  public Instruction()
  {
  }
  
  public Instruction(String s)
  {
    String temp[] = s.split("=");
    
    direction=temp[0].charAt(0);
    axis=Integer.parseInt(temp[1]);
  }
  
  public void printIns()
  {
    println("axis:"+axis+" dir:"+direction);
  }
  
  public void drawIns()
  {    
    switch(direction)
    {
      case 'y': // horizontal
        line(0,axis,maxX.value,axis);
        break;
      case 'x': // vertical
        line(axis,0,axis,maxY.value);
        break;
    }
  }
  
  public void foldSpace()
  {
    int xi=0, yi=0;
    int newx=0, newy=0;
    
    println("FOLDING SPACE, hold on to your shorts");
    switch(direction)
    {
      case 'y': // horizontal
        //line(0,axis,maxX.value,axis)
        for (xi=0;xi<maxX.value;xi++)
        {
          for (yi=maxY.value-1;yi>axis;yi--)
          {
            if (space[xi][yi]==1)
            {
              newy=axis-(yi-axis);
              space[xi][newy]=1;
            }
          }
        }
        print("Changing Y axis from:"+maxY.value);
        maxY.value-=(axis+1);
        println(" To:"+maxY.value);

        break;
      case 'x': // vertical
        //line(axis,0,axis,maxY.value);      
        for (yi=0;yi<maxY.value;yi++)
        {
          for (xi=maxX.value-1;xi>axis;xi--)
          {
            if (space[xi][yi]==1)
            {
              newx=axis-(xi-axis);
          println(xi+","+yi+" newx:"+newx+" axis:"+axis);
              space[newx][yi]=1;
            }
          }
        }
        print("Changing X axis from:"+maxX.value);
        maxX.value-=(axis+1);
        println(" To:"+maxX.value);
        
        break;
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
