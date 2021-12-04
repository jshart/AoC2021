import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

//String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day4_part1\\data\\example"); int boards=3;
//int[] mNumbers = {7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1};

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day4_part1\\data\\mydata"); int boards=100;
int[] mNumbers = {69,88,67,56,53,97,46,29,37,51,3,93,92,78,41,22,45,66,13,82,2,7,52,40,18,70,32,95,89,64,84,68,83,26,43,0,61,36,57,34,80,39,6,63,72,98,21,54,23,28,65,16,76,11,20,33,96,4,10,25,30,19,90,24,55,91,15,8,71,99,58,14,60,48,44,17,47,85,74,87,86,27,42,38,81,79,94,73,12,5,77,35,9,62,50,31,49,59,75,1};

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();



int[][][] matrix = new int[boards][5][5];
boolean[] won = new boolean[boards];

// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  ParseMatrix pm=new ParseMatrix(input.lines);
  BingoMatrix bm=new BingoMatrix();
  
  int b=0,r=0,c=0;
  
  // Dump boards for sanity check
  for (b=0;b<boards;b++)
  {
    bm.printBoard(matrix[b]);
    won[b]=false;
  }

  // Check for a winner
  int l=mNumbers.length;
  
  for (i=0;i<l;i++)
  {
    println("*** checking number:"+mNumbers[i]);
    for (b=0;b<boards;b++)
    {
      if (won[b]==false)
      {
        bm.updateBoard(matrix[b],mNumbers[i]);
        
        if (bm.checkBoard(matrix[b])==true)
        {
          bm.printBoard(matrix[b]);
          int ans=bm.calculateWin(matrix[b],mNumbers[i]);
          print("BOARD:"+b+" completes with "+ans);
          won[b]=true;
        }
      }
    }
  }
  
  // Dump boards for sanity check
  //for (b=0;b<boards;b++)
  //{
  //  bm.printBoard(matrix[b]);
  //}
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

public class BingoMatrix
{
  public BingoMatrix()
  {
  }
  
  public void updateBoard(int[][] board, int num)
  {
    int r=0,c=0;
    
    for (r=0;r<5;r++)
    {
      for (c=0;c<5;c++)
      {
        if (board[r][c]==num)
        {
          board[r][c]=-1;
        }
      }
    }
  }
  
  public int calculateWin(int[][] board, int lastNum)
  {
    int r=0,c=0;
    int total=0;
    
    // check each row;
    for (r=0;r<5;r++)
    {
      for (c=0;c<5;c++)
      {
        if (board[r][c]>0)
        {
          total+=board[r][c];
        }
      }
    }
    total*=lastNum;
    return(total);
  }
  
  public boolean checkBoard(int[][] board)
  {
    int r=0,c=0;
    boolean winner=true;
    
    // check each column;
    for (r=0;r<5;r++)
    {
      // assume we are winning until we know otherwise...
      winner=true;
      
      for (c=0;c<5;c++)
      {
        if (board[r][c]>=0)
        {
          // this column has a value that hasn't been called
          // so abandon this column and try the next
          winner=false;
          break;
        }
      }
      
      // we got through the whole column without finding
      // an uncalled value, so we have a winner
      if (winner==true)
      {
        // we found a winning column!
        return(true);
      }
    }

    
    // check each row;
    for (c=0;c<5;c++)
    {
      // assume we are winning until we know otherwise...
      winner=true;
      
      for (r=0;r<5;r++)
      {
        if (board[r][c]>=0)
        {
          // this row has a value that hasn't been called
          // so abandon this column and try the next
          winner=false;
          break;
        }
      }
      
      // we got through the whole row without finding
      // an uncalled value, so we have a winner
      if (winner==true)
      {
        // we found a winning row!
        return(true);
      }
    }
    
    // this means we didnt find a winner, so return false
    return(false);
  }
  
  void printBoard(int[][] board)
  {
    int r=0,c=0;

    for (r=0;r<5;r++)
    {
      for (c=0;c<5;c++)
      {
        print(board[r][c]+",");
      }
      print(" | ");
    }
    println("END BOARD");
  }
}

public class ParseMatrix
{
  public ParseMatrix(ArrayList<String> list)
  {
    int l=list.size();
    int i=0,j=0;
    
    int m=5;
    int board=0;
    int row=0;
    
    for (i=0;i<l;i++)
    {
      println("crunching:"+list.get(i));
      if (list.get(i).length()>2)
      {
        //String[] temp=list.get(i).split(" ");
        //for (j=0;j<m;j++)
        //{
        //  println("F: "+temp[j]);
        //}
        matrix[board][row++]=splitDigits(list.get(i));
      }
      else
      {
        println("BLANK LINE");
        board++;
        row=0;
      }
    }
  }
  
  public int[] splitDigits(String s)
  {
    int i;
    int m=5;
    int output[] = new int[m];
    for (i=0;i<m;i++)
    {
      output[i]=Integer.parseInt( s.substring(i*3,(i*3)+2).trim() );
      
      println("F:"+output[i]);
    }
    
    return(output);
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
