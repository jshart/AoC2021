import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day18_part1\\data\\mydata");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


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

  Snailfish temp=new Snailfish();
 
  println(input.lines.get(0));
  temp.populate(input.lines.get(0),0);
  //temp.printRawSF(input.lines.get(0));
  temp.printTree(temp,0);
  

  
  // we only encode the "left" side of the top object, as the top object is 
  // really a wrapper for the whole tree and it expands out from under the
  // first sub-child (which is the left side). its easier to just take the
  // left side and use that than it is to muddy the code with "exception"
  // paths to do something special with the object model for the top level
  println("ENCODED:"+temp.encodeBackToString(temp.left));
  
  temp.findDeepNode(temp.left,0);
  
  temp.buildStackView(temp);
  temp.printStackView();

  // Loop through each input item...
  for (i=0;i<input.lines.size();i++)
  {
  
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

public class Snailfish
{
  Snailfish backtrack=null;
  Snailfish left=null;;
  Snailfish right=null;
  String exp=null;
  int leftValue=0;
  int rightValue=0;
  
  boolean leftRight=false; // false==left, true==right
  
  ArrayList<Snailfish> stackview = new ArrayList<Snailfish>();
  
  public Snailfish()
  {
  }
  
  public int populate(String in, int d_)
  {
    int d=d_;
    int i=0;
    
    for (i=0;i<in.length();i++)
    {
//println("** Checking:"+in.charAt(i));
      switch (in.charAt(i))
      {
        case '[':
          println(depthPad(d)+(leftRight==false?"Left ":"Right ")+"SF start found [");
          i++;
 
          if (leftRight==false)
          {
            left=new Snailfish();
            left.backtrack=this;
            i+=left.populate(in.substring(i),d+1);
          }
          else
          {
            right=new Snailfish();
            right.backtrack=this;
            i+=right.populate(in.substring(i),d+1);
          }
          
//println("** i after return:"+i);

          break;
        case ']':
          println(depthPad(d)+"SF end found ]");

          return(i);
        case ',':
          println(depthPad(d)+"SF left/right transition found ,");
          leftRight=!leftRight;
          break;
        default:
          if (leftRight==false)
          {
            leftValue=Character.getNumericValue(in.charAt(i));
            print(depthPad(d)+"left "+"SF value found:"+leftValue);
            println();
          }
          else
          {
            rightValue=Character.getNumericValue(in.charAt(i));
            print(depthPad(d)+"Right "+"SF value found:"+rightValue);
            println();
          }
          // safety check - I think all values should be one
          // char long, but just as a safety check lets verify
          // the next char isnt a digit, because if so, its an
          // error
          if (Character.isDigit(in.charAt(i+1))==true)
          {
            println("*** ERROR - value more than one digit long found, need to add code to deal with this! ***");
            println("Was processing:"+in.charAt(i)+" was checking ahead and found:"+in.charAt(i+1));
            return(in.length());
          }
      }
    }
    return(in.length());
  }
  
  public void findDeepNode(Snailfish sf, int d)
  {
    if (sf.left==null && sf.right==null)
    {
      println("Deep node found at depth:"+d+" Obj:"+sf+" LV:"+sf.leftValue+" RV:"+sf.rightValue);
      //backtrackFrom(sf);
    }
    if (sf.left!=null)
    {
      findDeepNode(sf.left,d+1);
    }
    
    if (sf.right!=null)
    {
      findDeepNode(sf.right,d+1);
    }
  }
  
  public void buildStackView(Snailfish sf)
  {
    println("Building stack view for:"+sf);
    
    if (sf.left!=null)
    {
      buildStackView(sf.left);
    }

    if (sf.right!=null)
    {
      buildStackView(sf.right);
    }
    
    stackview.add(sf);
  }
  
  public void printStackView()
  {
    int i=0;
    int l=stackview.size();
    
    println("Stackview size:"+l);
    
    for (i=0;i<l;i++)
    {
      println(stackview.get(i).printThisSnailfish());
    }
    println();
  }
  
  public int backtrackFrom(Snailfish sf)
  {
    Snailfish bt=sf.backtrack;
    
    print("TRACKING BACK ["+sf+"]");
    
    do 
    {
      print("--> ["+bt+"]");
      printNumbersBelow(bt);
      
      bt=bt.backtrack;
    } while (bt.backtrack!=null); // we ignore the very top object as its a special container for the whole tree and not strictly part of the tree
    println();
    return(-1); 
  }
  
  public void printNumbersBelow(Snailfish sf)
  {
    print("[");
    if (sf.left!=null)
    {
      printNumbersBelow(sf.left);
    }
    else
    {
      print("L"+sf.leftValue+",");
    }
    if (sf.right!=null)
    {
      printNumbersBelow(sf.right);
    }
    else
    {
      print("R"+sf.rightValue+",");
    }
    print("]");
  }
  
  public String encodeBackToString(Snailfish sf)
  {
    String s=new String();
    
    println("Encoding:"+sf);
    
    s+="[";
    
    if (sf.left!=null)
    {
      s+=encodeBackToString(sf.left);
    }
    else
    {
      s+=sf.leftValue;
    }
    s+=",";
    if (sf.right!=null)
    {
      s+=encodeBackToString(sf.right);
    }
    else
    {
      s+=sf.rightValue;
    }
    s+="]";
    
    return(s);
  }
  
  public void printTree(Snailfish s, int d)
  {
    println(depthPad(d)+s.printThisSnailfish());
    if (s.left!=null)
    {
      printTree(s.left,d+1);
    }
    if (s.right!=null)
    {
      printTree(s.right,d+1);
    }
  }
  
  public String printThisSnailfish()
  {
    String s=new String();
    s="Obj:"+this;
    s+="=>[";
    s+=(left!=null?"L Obj="+left:"L value="+leftValue);
    s+=" ";
    s+=(right!=null?"R Obj="+right:"R value="+rightValue);
    s+="]";

    //return("Obj:"+this+" L Obj:"+left+" R Obj:"+right+" Value:"+leftValue+","+rightValue);
    return(s);
  }
  
  public void printRawAsFormatted(String in)
  {
    int d=0;
    int i=0;
    
    for (i=0;i<in.length();i++)
    {
      switch (in.charAt(i))
      {
        case '[':
          println(depthPad(d)+"SF start found [");
          d++;
          break;
        case ']':
          println(depthPad(d)+"SF end found ]");
          d--;
          break;
        case ',':
          println(depthPad(d)+"SF left/right transition found ,");
          break;
        default:
          leftValue=Character.getNumericValue(in.charAt(i));
          print(depthPad(d)+"SF value found:"+leftValue);
          println();
          
          // safety check - I think all values should be one
          // char long, but just as a safety check lets verify
          // the next char isnt a digit, because if so, its an
          // error
          if (Character.isDigit(in.charAt(i+1))==true)
          {
            println("*** ERROR - value more than one digit long found, need to add code to deal with this! ***");
            println("Was processing:"+in.charAt(i)+" was checking ahead and found:"+in.charAt(i+1));
            return;
          }
      }
    }
  }
  

  
  public String depthPad(int d)
  {
    int i=0;
    String s=new String();
    for (i=0;i<d;i++)
    {
      s+="|";
    }
    s+="--";
    return(s);
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
