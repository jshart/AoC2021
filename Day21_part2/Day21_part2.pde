import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\DayXX\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
//InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

long p1Board=6;
long p1Score=0;
long p2Board=4;
long p2Score=0;

int p1StartingScore=4;
int p2StartingScore=8;

long dice=1;
long rem=0;
long diceTotal=0;
long diceRolls=0;
boolean turn=true;

// This is the distribution matrix for a normal distribution 
int[] distribution={0,0,0,1,3,6,7,6,3,1};
GameBoard gb1=new GameBoard();
GameBoard gb2=new GameBoard();
GameBoard currentBoard=gb1;
GameBoard nextBoard=gb2;

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  //input.printFile();
  
  int i=0,j=0,k=0;

  //// Loop through each input item...
  //for (i=0;i<input.lines.size();i++)
  //{
  
  //}
  //printDiceTable(); 
  
  //// until someone wins
  //while (p1Score<1000 && p2Score<1000)
  //{
  //  // calculate the new score by adding up the next 3 dice rolls
  //  diceTotal=(dice++)+(dice++)+(dice++);
  //  print("Dice:"+diceTotal+" ");
  //  diceRolls+=3;

  //  // p1 turn==true, p2 turn==false
  //  if (turn==true)
  //  {
  //    // What is this players new score 
  //    rem=(diceTotal + p1Board) % 10;
  //    // space '0' is actually treated as '10'
  //    rem=(rem==0?10:rem);
  //    p1Score+=rem;
  //    p1Board=rem;
      
  //    print("P1:"+p1Board+","+p1Score);
  //    println();
  //  }
  //  else
  //  {
  //    // What is this players new score 
  //    rem=(diceTotal + p2Board) % 10;
  //    // space '0' is actually treated as '10'
  //    rem=(rem==0?10:rem);
  //    p2Score+=rem;
  //    p2Board=rem;
      
  //    print("P2:"+p2Board+","+p2Score);
  //    println();
  //  }
  //  // switch players
  //  turn=!turn;
  //}
  //println("Rolls:"+diceRolls);
  //println("P1 score:"+diceRolls*p1Score);
  //println("P2 score:"+diceRolls*p2Score);
  
  currentBoard.updateWorldCountByScore(p1StartingScore,p1StartingScore,1);
  currentBoard.printBoard();
  
  int iterations=0;
  boolean winner=false;
  while (winner==false)
  {
    nextBoard.resetBoard();
    winner=currentBoard.takeTurn(nextBoard);
    
    println("**** AFTER ITERATIONS="+iterations);
    nextBoard.printBoard();
    swapBoards();
    iterations++;
  }
}

public void swapBoards()
{
  GameBoard temp;
  temp=currentBoard;
  currentBoard=nextBoard;
  nextBoard=temp;
}

public class GameBoard
{
  // 1-10 == score squares 1-10 - note '0' is not used, we skip this index.
  // 0-21 == number of "worlds" that currently have that score. bottom part of this table will
  // always remain empty as the worlds start with scores, but we leave the array fullsized
  // to make indexing clean - note we also make it 22, so we can ignore 0-indexing and actually
  // assign worlds with score x into cell x.
  long[][] gb=new long[11][23];
  
  void printBoard()
  {
    int i=0,j=0;
    for (i=0;i<11;i++)
    {
      print("Index:"+i+" worlds:");
      for (j=0;j<22;j++)
      {
        print(gb[i][j]+",");
      }
      println();
    }
  }

  public void updateWorldCountByScore(int scoreSpace,int score, long worlds)
  {
    gb[scoreSpace][score]=worlds;
  }
  
  public boolean takeTurn(GameBoard updateBoard)
  {
    int scoreSquare=0,score=0;
    boolean winner=false;
    
    // for each square along the board...
    for (scoreSquare=0;scoreSquare<10;scoreSquare++)
    {
      // for each set of worlds with a given score
      // at this location on the board
      for (score=0;score<23;score++)
      {
        // do any worlds exist in this state?
        if (gb[scoreSquare][score]!=0)
        {
          // Yes - we need to fork this set of worlds
          // using the distribution matrix to create
          // new worlds
          winner=forkWorlds(updateBoard,scoreSquare,score);
          if (winner==true)
          {
            return(true);
          }
        }
      }
    }
    return(false);
  }
  
  public boolean forkWorlds(GameBoard updateBoard,int scoreSquare, int score)
  {
    int d=0;
    long worlds=gb[scoreSquare][score]; // count of the number of worlds at this point on the board with a given score
    int newLocation=0;
    int newScore=0;
    
    // fork the input worlds for each of the possible
    // dice outcomes...
    for (d=0;d<distribution.length;d++)
    {
      // some permutations are impossible - we can skip these, we could do this
      // in the loop above and save a bit of processing, but the code is a bit
      // cleaner this way (and would work if we changed the type of dice)
      if (distribution[d]!=0)
      {
        
        // work out the new board location where the player now resides in this world
        newLocation=scoreSquare+distribution[d]; 
//println("Newlocation calculated to:"+newLocation+" from dist:"+distribution[d]);
        // wrap around if needed
        newLocation=newLocation>10?newLocation-10:newLocation;
        
        // work out the new score for this world/player combo
        newScore=score+newLocation;
        
        // update the board with the new world/score/square value - and combine it
        // with any existing values, as previous world expansions this round may
        // already resulted in worlds existing in this state
        
        if (newScore>21)
        {
          return(true);
        }
        updateBoard.gb[newLocation][newScore]+=worlds;
      }
    }
    return(false);
  }
  
  public void resetBoard()
  {
    int i=0,j=0;
    for (i=0;i<11;i++)
    {
      for (j=0;j<23;j++)
      {
        gb[i][j]=0;
      }
    }
  }
}

void printDiceTable()
{
  int total=0;
  int table[] = new int[10];
  int i=0,j=0,k=0;

  for (i=1;i<4;i++)
  {
    for (k=1;k<4;k++)
    {
      for (j=1;j<4;j++)
      {
        println("Dice:"+i+","+k+","+j+" total score:"+(i+k+j));
        total=i+k+j;
        table[total]++;
      }
    }
  }
  
  for (i=0;i<10;i++)
  {
    print("No of times (N)"+i+" appeared (M)"+table[i]+" ");
    for(j=0;j<table[i];j++)
    {
      print("#");
    }
    println();
  }
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