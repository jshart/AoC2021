import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day3_part1\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

int o2=0;
int co2=0;

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  //int i=0,j=0;

  //String temp = input.lines.get(0);
  //BitProcessor bits = new BitProcessor(temp.length());
  

  //// Loop through each input item...
  //for (i=0;i<input.lines.size();i++)
  //{
  //  bits.update(input.lines.get(i));
  //}
  
  //bits.results();
  
  
  SplitList sList = new SplitList(input.lines, 0, 0); //O2
  SplitList sList2 = new SplitList(input.lines, 0, 1); // CO2
  
  print("FINAL: CO="+co2+" O2="+o2+" LSR="+(co2*o2));

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

public class SplitList
{
  ArrayList<String> list0 = new ArrayList<String>();
  ArrayList<String> list1 = new ArrayList<String>();
  
  public SplitList(ArrayList<String> list, int splitPos, int mode)
  {
    int l=list.get(0).length();
    
    // Verify we're not beyond the bit position possible for the word we're processing
    if (splitPos<l)
    {
      int i=0;
      int listL=list.size();
      
      String temp;
      
      // for each element in the input list, split the list
      for (i=0;i<listL;i++)
      {
        temp = list.get(i);
        if (temp.charAt(splitPos)=='0')
        {
          list0.add(temp);
        }
        else
        {
          list1.add(temp);
        }
      }
      
      // List is now divided into elements with 0 or 1 in the "splitPos" position.
      // depending on mode, I now need to iterate on a specific sublist.
      // mode==0 oxygen, mode==1 CO2
      int size0=list0.size();
      int size1=list1.size();
      
      println("List split. 0="+size0+" 1="+size1);
      
      if (mode==0) //Oxygen
      {
        // Oxygen looks for most common value (so longest list)
        // if equal length, go for list1
        if (size0>size1)
        {
          // use size0 list
          if (size0==1)
          {
            print("O2 found:"+list0.get(0));
            println(","+(o2=Integer.parseInt(list1.get(0),2)));
            return;
          }
          else
          {
            SplitList sl = new SplitList(list0,++splitPos,mode);
          }
        }
        else
        {
          // use size1 list
          if (size1==1)
          {
            print("O2 found:"+list1.get(0));
            println(","+(o2=Integer.parseInt(list1.get(0),2)));

            return;
          }
          else
          {
            SplitList sl = new SplitList(list1,++splitPos,mode);
          }
        }
      }
      else //C02
      {
        // CO2 looks for least common value (so shortest list)
        // if equal length, go for list0
        if (size0<=size1)
        {
          // use size0 list
          if (size0==1)
          {
            print("CO2 found:"+list0.get(0));
            println(","+(co2=Integer.parseInt(list0.get(0),2)));
            return;
          }
          else
          {
            SplitList sl = new SplitList(list0,++splitPos,mode);
          }
        }
        else
        {
          // use size1 list
          if (size1==1)
          {
            print("CO2 found:"+list1.get(0));
            println(","+(co2=Integer.parseInt(list1.get(0),2)));

            return;
          }
          else
          {
            SplitList sl = new SplitList(list1,++splitPos,mode);
          }
        }
      }
    }
  }
}

public class BitProcessor
{
  ArrayList<BitCount> bitTotals = new ArrayList<BitCount>();
  public BitProcessor(int s)
  {
    int i;
    for (i=0;i<s;i++)
    {
      bitTotals.add(new BitCount());
    }
  }
  
  public void update(String s)
  {
    int l = s.length();
    int i=0;
    for (i=0;i<l;i++)
    {
      bitTotals.get(i).update(s.charAt(i));
    }
  }
  
  public void results()
  {
    int i;
    int result;
    String gamma=new String();
    String eplison= new String();
    int g,e;
    for (i=0;i<bitTotals.size();i++)
    {
      print("Pos:"+i+" ");
      result=bitTotals.get(i).getResult();
      gamma+=String.valueOf(result);
      eplison+=String.valueOf(result==1?0:1);
      println();
    }
    print("GAMMA:"+gamma+ " EPLISON:"+eplison);
    g=Integer.parseInt(gamma,2);
    e=Integer.parseInt(eplison,2);
    println("e="+2+" g="+g+" Power:"+(g*e));
  }
}

public class BitCount
{
  int zeros=0;
  int ones=0;
  public BitCount()
  {
  }
  
  public void update(char c)
  {
    switch (c)
    {
      case '0':
        zeros++;
        break;
      case '1':
        ones++;
        break;
      default:
        println("Processing Error:"+c);
    }
  }
  
  public int getResult()
  {
    print("Zeros:"+zeros+" Ones:"+ones+" ");
    if (zeros>ones)
    {
      print("0");
      return(0);
    }
    else
    {
      print("1");
      return(1);
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
