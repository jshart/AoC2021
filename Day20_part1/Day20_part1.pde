import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day20_part1\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Notes - the fact that 0=="on" and 511="off" in the bitmask - I think means that a 3x3 square of the same state
// will toggle back and forth. Therefore, so long as there is a 3x3 border around the "image" it will effectively
// mark a parameter?


String exampleIEA=new String("..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#");
String myIEA=new      String("#.#.#.#.#......#.#.#.#.##..#.##.##..#..##...#.#.#.#...##.##.##.###....#..#...#.#..###.#...#..##.#.###..#..####.###...#.#.#..##..##.##..##..###..#....#.#....#####.#...###...#.#....###...#..##.##..#..#.##..###..#.##.###..#.####...#.##.....#.###...#.##.##.#.#######...#.###..##..##..#.#.#.#####...#....#.....##.#.#...##.######....#..#......#.#.#.#.##...######.#.#####..#####..#.#.#.#.###.#.#....#..##..#..#.#.#..##....##..#.#.......##...#..####.####.#.#..#.###..#...#......###...#...#.##.#.####..#.#....###.####..#.");
String useIEA=myIEA;

int borderSize=256;
int gs=1;

// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

GameBoard board1;
GameBoard board2;
GameBoard currentBoard;
GameBoard nextBoard;


void setup() {
  size(1024, 1024);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  // Loop through each input item...
  //for (i=0;i<input.lines.size();i++)
  //{
  //}
  
  int maxX=input.lines.get(0).length();
  int maxY=input.lines.size();
  
  board1 = new GameBoard(maxX,maxY);
  board1.loadBoard();
  currentBoard=board1;
  board2 = new GameBoard(maxX,maxY);
  nextBoard=board2;
}

public void swapBoards()
{
  GameBoard temp;
  temp=currentBoard;
  currentBoard=nextBoard;
  nextBoard=temp;
  nextBoard.resetBoard();
}

void printMasterList()
{
  int i=0;
  for (i=0;i<masterList.size();i++)
  {
    println("ML input:"+masterList.get(i));
  }
}

int iterations=0;
void draw()
{  
  background(0);
//println("useIEA:"+useIEA);

  currentBoard.drawBoard();
  println("Count for iteration:"+iterations+" is:"+currentBoard.countBoard2());

  currentBoard.updateBoardTo(nextBoard,useIEA);
  swapBoards();
  iterations++;
  
  stroke(0,0,255);
  noFill();
  rect(borderSize/2,borderSize/2,currentBoard.maxX-borderSize,currentBoard.maxY-borderSize);
  
  if (iterations==51)
  {
    noLoop();
  }
}

public class GameBoard
{
  int[][] content;
  int maxX=0;
  int maxY=0;
  int textMaxX=0;
  int textMaxY=0;
  
  public GameBoard(int maxX_, int maxY_)
  {
    textMaxX=maxX_;
    textMaxY=maxY_;
    // we add 2x the border size to each axis, so that we have a border all around
    maxX=maxX_+(borderSize*2);
    maxY=maxY_+(borderSize*2);
    
    content=new int[maxX][maxY];
  }
  
  public void loadBoard()
  {
    int x=0,y=0;
    
    // we need to i
    
    // load the board into the middle of the space...
    for (x=0;x<textMaxX;x++)
    {
      for (y=0;y<textMaxY;y++)
      {
        content[x+borderSize][y+borderSize]=input.lines.get(y).charAt(x)=='#'?1:0;
      }
    }
  }
  
  public void resetBoard()
  {
    int x=0,y=0;
    
    for (x=0;x<maxX;x++)
    {
      for (y=0;y<maxY;y++)
      {
        content[x][y]=0;
      }
    }
  }
  
  public int countBoard()
  {
    int x=0,y=0;
    
    int count=0;
    
    for (x=1;x<maxX-1;x++)
    {
      for (y=1;y<maxY-1;y++)
      {
        count+=(content[x][y]==1?1:0);
      }
    }
    return(count);
  }
  
  public int countBoard2()
  {
    int x=0,y=0;
    
    int count=0;
    
    for (x=borderSize/2;x<maxX-(borderSize/2);x++)
    {
      for (y=borderSize/2;y<maxY-(borderSize/2);y++)
      {
        count+=(content[x][y]==1?1:0);
      }
    }
    return(count);
  }
  
  public void updateBoardTo(GameBoard g, String iea)
  {
    int x=0,y=0;
    
    clearEdges();
    
    // for now lets ignore the very edges...
    for (x=1;x<maxX-1;x++)
    {
      for (y=1;y<maxY-1;y++)
      {
        //println("IEA:"+iea);
        //println("mask:"+getInputMask(x,y));
        g.content[x][y]=(iea.charAt(getInputMask(x,y))=='#'?1:0);
      }
    }
    g.clearEdges();
  }
  
  public void clearEdges()
  {
    int i=0;
    for (i=0;i<maxX;i++)
    {
      content[i][0]=0;
      content[i][maxY-1]=0;
    }
    
    for (i=0;i<maxY;i++)
    {
      content[0][i]=0;
      content[maxX-1][i]=0;
    }
  }
  
  public int getInputMask(int x, int y)
  {
    int result=0;
    int xs=x-1;
    int xe=x+1;
    int ys=y-1;
    int ye=y+1;
    int xi=0,yi=0;
    
    String output = new String();
    
    for (yi=ys;yi<=ye;yi++)
    {
      for (xi=xs;xi<=xe;xi++)
      {
        // is a valid point in the input?
        if (xi>=0 && xi<maxX && yi>=0 && yi<maxY)
        {
          output+=(content[xi][yi]==1?'1':'0');
        }
        else
        {
          //println("error - border detected");
        }
      }
    }
    
//println("X,Y:"+x+","+y+" O:"+output);
    result=Integer.parseInt(output,2);
    
    return(result);
  }
  
  public void drawBoard()
  {
    int x=0,y=0;
    
    for (x=0;x<maxX;x++)
    {
      for (y=0;y<maxY;y++)
      {
        if (content[x][y]==1)
        {
          stroke(255,255,255);
          fill(255,0,0);
          rect(x*gs,y*gs,gs,gs);
          
          stroke(0,255,0);
          noFill();
          rect(x*gs,y*gs,gs,gs);
        }
      }
    }
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
