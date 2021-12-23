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

Room[] rooms=new Room[4];
Corridor[] corridor=new Corridor[11];
int[] corridorMask={1,1,0,1,0,1,0,1,0,1,1};
ArrayList<Crab> crabMasterList = new ArrayList<Crab>();

void setup() {
  size(200, 200);
  background(0);
  stroke(255);
  frameRate(10);

  //System.out.println("Working Directory = " + System.getProperty("user.dir"));
  //println();
  //input.printFile();
  
  //int i=0,j=0;

  //// Loop through each input item...
  //for (i=0;i<input.lines.size();i++)
  //{
  
  //}
  
  initRoomsExample();
  printRooms();
  
  
  // test cases
  // 1) move crab from room to corridor
  corridor[2].update(rooms[0].getCrab());
  corridor[1].update(rooms[0].getCrab());

  println();
  printRooms();
  
  // 2) add crab to room
  rooms[0].addCrab(new Crab('Z'));
  println();
  printRooms();
  
  // 3) room open?
  rooms[0].getCrab();
  rooms[0].getCrab();
  rooms[0].getCrab();
  rooms[0].getCrab();
  println();
  printRooms();

  rooms[0].addCrab(new Crab('A'));
  rooms[0].addCrab(new Crab('A'));
  rooms[0].addCrab(new Crab('A'));
  println();
  printRooms();

  println("[A] can enter room 0 with type:"+rooms[0].targetName+" "+rooms[0].canEnter(new Crab('A')));
  println("[B] can enter room 0 with type:"+rooms[0].targetName+" "+rooms[0].canEnter(new Crab('B')));

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


public void initRoomsExample()
{
  
  int i=0;
  for (i=0;i<4;i++)
  {
        rooms[i]=new Room();
  }
  for (i=0;i<11;i++)
  {
        corridor[i]=new Corridor(corridorMask[i]);
  }
  
  rooms[0].targetName='A';
  rooms[1].targetName='B';
  rooms[2].targetName='C';
  rooms[3].targetName='D';
  
  rooms[0].crabs.add(new Crab('A'));
  rooms[0].crabs.add(new Crab('D'));
  rooms[0].crabs.add(new Crab('D'));
  rooms[0].crabs.add(new Crab('B'));  
 
  rooms[1].crabs.add(new Crab('D'));
  rooms[1].crabs.add(new Crab('B'));   
  rooms[1].crabs.add(new Crab('C'));
  rooms[1].crabs.add(new Crab('C'));

  rooms[2].crabs.add(new Crab('C'));
  rooms[2].crabs.add(new Crab('A'));
  rooms[2].crabs.add(new Crab('B'));
  rooms[2].crabs.add(new Crab('B'));

  rooms[3].crabs.add(new Crab('A'));
  rooms[3].crabs.add(new Crab('C'));
  rooms[3].crabs.add(new Crab('A'));
  rooms[3].crabs.add(new Crab('D'));
  
  // copy all the crabs into the master list for easy access
  // not sure yet if I need this, but lets make it anyway.
  for (i=0;i<4;i++)
  {
    crabMasterList.addAll(rooms[i].crabs);
  }
}

public void printRooms()
{
  int i=0,j=0;
  
  println("#############");
  print("#");
  for (i=0;i<11;i++)
  {
    print(corridor[i].corridorContains());
  }
  println("#");
  
  for (i=3;i>=0;i--)
  {
    print("##");
    for (j=0;j<4;j++)
    {
      if (i>rooms[j].crabs.size()-1)
      {
        print("# ");
      }
      else
      {
        print("#"+rooms[j].crabs.get(i).type);
      }
    }
    println("###");
  }
  println("#############");
  
  print("   ");
  for (i=0;i<4;i++)
  {
    print((rooms[i].open()==true?"O":"-")+" ");
  }
  print("     ");
  printMoveCandidates();
}

public void printMoveCandidates()
{
  int i=0;
  
  print("Move candidates:");
  // First check all the rooms
  for (i=0;i<4;i++)
  {
    if (rooms[i].crabs.size()>0)
    {
      print(rooms[i].crabs.get(rooms[i].crabs.size()-1).type+",");
    }
  }
  print("|");
  
  for (i=0;i<11;i++)
  {
    if (corridor[i].occupant!=null)
    {
      print(corridor[i].occupant.type+",");
    }
  }
  println();
}



public class Corridor
{
  Crab occupant=null;
  int permitted=0;
  
  public Corridor(int p)
  {
    permitted=p;
  }
  
  public boolean update(Crab c)
  {
    if (permitted==1)
    {
      occupant=c;
      return(true);
    }
    println("*** Illegal attempt to place crab ["+c.type+"] into corridor location not allowed");
    return(false);
  }
  
  public Character corridorContains()
  {
    if (occupant==null)
    {
      return(permitted==1?'_':'.');
    }
    else
    {
      return(occupant.type);
    }
  }
}

public class Crab
{
  char type=' ';
  
  public Crab(char t)
  {
    type=t;
  }
}

public class Room
{
  char targetName=' ';
  ArrayList<Crab> crabs = new ArrayList<Crab>();
  
  public Room()
  {

  }
  
  public Crab getCrab()
  {
    if (crabs.size()==0)
    {
      println("*** Illegal attempt to take a crab from a room that is empty, room was="+targetName);
      return(null);
    }
    Crab r=crabs.get(crabs.size()-1);
    crabs.remove(crabs.size()-1);
    return(r);
  }
  
  public boolean addCrab(Crab c)
  {
    if (c.type!=targetName)
    {
      println("*** Illegal attempt to add crab ["+c.type+"] to room type="+targetName);
      return(false);
    }
    crabs.add(c);
    return(true);
  }
  
  public boolean canEnter(Crab c)
  {
    if (open()==true)
    {
      if (c.type==targetName)
      {
        return(true);
      }
    }
    return(false);
  }
  
  // signifies if the room is open for crabs to
  // enter - which is defined as an empty room
  // or one that only has the right type of crab
  public boolean open()
  {
    int i=0;
    if (crabs.size()==0)
    {
      return(true);
    }
    else
    {
      for (i=0;i<crabs.size();i++)
      {
        if (crabs.get(i).type!=targetName)
        {
          return(false);
        }
      }
    }
    return (true);
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
