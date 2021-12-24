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
  
  GameInstance g = new GameInstance();
  
  g.initRoomsExample();
  g.printRooms();
  
  g.runTestCases();

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

public class GameInstance
{
  Room[] rooms=new Room[4];
  Corridor corridor = new Corridor();  
  ArrayList<Crab> crabMasterList = new ArrayList<Crab>();

  public GameInstance()
  {
  }
  
  void runTestCases()
  {
      
    // test cases
    // 1) move crab from room to corridor
    corridor.segments[2].update(rooms[0].getCrab());
    corridor.segments[1].update(rooms[0].getCrab());
  
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
  
    println("[A] can enter room 0 with type:"+rooms[0].roomName+" "+rooms[0].canEnter(new Crab('A')));
    println("[B] can enter room 0 with type:"+rooms[0].roomName+" "+rooms[0].canEnter(new Crab('B')));
    
    println("Can I reach 8 from 2? "+corridor.canReachFrom(2,8));
    println("Can I reach 1 from 8? "+corridor.canReachFrom(8,1));
    println("Can I reach 6 from 8? "+corridor.canReachFrom(8,6));
    println("Can I reach 7 from 8? "+corridor.canReachFrom(8,7));
    println("Can I reach 6 from 6? "+corridor.canReachFrom(6,6)); // technically allowed - but its useless, so should we fail this?
    println("Can I reach 0 from 6? "+corridor.canReachFrom(6,0));
    
    corridor.segments[3].update(new Crab('A'));
    printRooms();
  
  }
  
  
  
  public void initRoomsExample()
  {
    
    int i=0;
    for (i=0;i<4;i++)
    {
          rooms[i]=new Room();
    }
  
    //   int[] corridorMask={1,1,0,1,0,1,0,1,0,1,1};
  
    rooms[0].roomName='A';
    rooms[0].corridorAccess=2;
    rooms[1].roomName='B';
    rooms[1].corridorAccess=4;
    rooms[2].roomName='C';
    rooms[2].corridorAccess=6;
    rooms[3].roomName='D';
    rooms[3].corridorAccess=8;
  
    
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
  
  public int roomNameToCorridorAccess(char t)
  {
    switch (t)
    {
      case 'A':
        return(2);
      case 'B':
        return(4);
      case 'C':
        return(6);
      case 'D':
        return(8);
    }
    return(-1);
  }
  
  public void printRooms()
  {
    int i=0,j=0;
    
    println("#############");
    print("#");
    for (i=0;i<11;i++)
    {
      print(corridor.segments[i].corridorContains());
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
    println();
    printMoveCandidates();
  }
  
  public void printMoveCandidates()
  {
    int i=0;
    Crab c;
    
    ArrayList<Crab> movableCrabs = new ArrayList<Crab>();
    
    print("Move candidates:");
    // First check all the rooms
    for (i=0;i<4;i++)
    {
      // we're only interest in looking in rooms which have crabs
      // and that room isn't already open (an open room indicates
      // its either empty or the crabs that are in it are the right
      // type - and if they're the right type we dont want to move
      // them again).
      if (rooms[i].crabs.size()>0 && rooms[i].open()==false)
      {
        c=rooms[i].crabs.get(rooms[i].crabs.size()-1);
        print(c.type+",");
        
        legalToMoveHome(rooms[i].corridorAccess,c);
      }
      println();
    }
    
    for (i=0;i<11;i++)
    {
      if (corridor.segments[i].occupant!=null)
      {
        print("|");
        c=corridor.segments[i].occupant;
        print(corridor.segments[i].occupant.type+",");
        
        legalToMoveHome(i,c);

        println();
      }
    }
  }
  
  // Location here is the position in the corridor the crab would be if it exited
  // its current room, and therefore the complete "move" needs to also account
  // for where the crab is in the original room before it moves (if it is in a room).
  public boolean legalToMoveHome(int location, Crab c)
  {
    if (corridor.canReachFrom(location,roomNameToCorridorAccess(c.type))==true)
    {
      print(" Can reach home");
      if (c.myTargetRoom(rooms).open()==true)
      {
        print(" and its open");
        return(true);
      }
      else
      {
        print(" but its closed");
      }
    }
    else
    {
      print(" can not reach home");
    }
    return(false);
  }
  
  // TODO - stub - need to fill this in
  public void calculatePermittedMoves()
  {
    // anything in a corridor can only move to 
    // its final room - so we can check if the room is 
    // open. In order to get there, we need code that
    // can tell if there are any crabs in the way (basically
    // are any of the permitted locations between us and the 
    // destination blocked.
    
    // Any crabs that meet the above criteria are most likely
    // the highest priority ones to move, as they then finalise
    // their position and are out of scope.
    
    // next loop through each of the crabs at the head of a room
    // to see if its a candidate.
    // 1) if the room is open, do not move the crab, that means
    //    its already in the room it should be in
    // 2) if the crab can move directly to its desired room from
    //    this location, then that is a good move to follow through
    //
    // Finally what are the possible corridor locations we can 
    // reach (i.e. are not blocked by another crab?
    //
    // this last part is the bit Im unsure about - is there a smart
    // way to calculate which/if a crab should move into a particular
    // corridor location?
    //
    // We should at least sort the permitted moves list by least cost
    // to most cost. We're looking for the lowest cost fuel level,
    // so we know the solution is mostly going to be made up of low
    // cost fuel moves, so we should favour those.
    //
    // that probably means we should generate an arraylist of some sort
    // of "movement" objects that we can then sort and pick one to execute.
    //
    // Notes on movement, movement is made up of discrete segments;
    // 1) a crab exiting a room (cost to get from stack position to open location
    //    directly in front of the room)
    // 2) Corridor cost - cost to move left/right n spaces in the corridor
    // 3) cost to enter a room (cost to get from open location directly in front
    //    of room down to a stack location in the room).
    //
    // A move may consist of one of the following combinations;
    // (1) + (2)
    // (1) + (2) + (3)
    //       (2) + (3)
  } 
}

public class Corridor
{
  CorridorSegment[] segments=new CorridorSegment[11];
  int[] corridorMask={1,1,0,1,0,1,0,1,0,1,1};
  
  public Corridor()
  {
    int i=0;
    for (i=0;i<11;i++)
    {
      segments[i]=new CorridorSegment(corridorMask[i]);
    }
  }
  
  
  // NOTE this function just checks to see if a corridor segment
  // is reachable without going through another crab. it does not
  // care if the destination segment is a permitted stopping point
  // or not. It is assuming that the calling code will only call
  // this for valid segment destinations.
  public boolean canReachFrom(int s, int e)
  {
    int i=0;
    // left to right?
    if (e>s)
    {
      for (i=s+1;i<=e;i++)
      {
        if (segments[i].occupant!=null)
        {
          // something in the way...
          return(false);
        }
      }
    }
    else
    {
      for (i=s-1;i>=e;i--)
      {
        if (segments[i].occupant!=null)
        {
          // something in the way...
          return(false);
        }
      }
    }
    return(true);
  }
  
  // simple search to see if this crab is in the corridor or not, should
  // not be needed as we now have back-links from the crab to the location
  // its stored in - to make things easier to map back and forth.
  public boolean isInCorridor(Crab c)
  {
    int i=0;
    for (i=0;i<11;i++)
    {
      if (c==segments[i].occupant)
      {
        return(true);
      }
    }
    return(false);
  }
}

public class CorridorSegment
{
  Crab occupant=null;
  int permitted=0;
  
  public CorridorSegment(int p)
  {
    permitted=p;
  }
  
  public boolean update(Crab c)
  {
    if (permitted==1)
    {
      occupant=c;
      c.corridorLocation=this;
      c.roomLocation=null;
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

// TODO - fill out stubs
public class Movement
{
  int exitCost=0;
  int leftCost=0;
  int rightCost=0;
  int enterCost=0;
  
  public Movement()
  {
  }
  
  public int calcExitCost()
  {
    return(0);
  }
  
  public int calcEntryCost()
  {
    return(0);
  }
  
  public int calcCorridorCost()
  {
    return(0);
  }
}

public class Crab
{
  char type=' ';
  int fuelUsed=0; // TODO - we need to add the maths into the move code to update this.
  CorridorSegment corridorLocation=null;
  Room roomLocation=null;
  
  public Crab(char t)
  {
    type=t;
  }
  
  public Room myTargetRoom(Room[] r)
  {
    Room myTarget=null;
    int i=0;
    int l=r.length;
    for (i=0;i<l;i++)
    {
      myTarget=r[i];
      
      if (myTarget.roomName==type)
      {
        return(myTarget);
      }
    }
    return(myTarget);
  }
}

public class Room
{
  char roomName=' ';
  int corridorAccess=0;
  ArrayList<Crab> crabs = new ArrayList<Crab>();
  
  public Room()
  {

  }
  
  public Crab getCrab()
  {
    if (crabs.size()==0)
    {
      println("*** Illegal attempt to take a crab from a room that is empty, room was="+roomName);
      return(null);
    }
    
    // TODO: hook this into a move calculation somehow...
    println("cost to EXIT room is:"+(5-crabs.size()));


    Crab r=crabs.get(crabs.size()-1);
    crabs.remove(crabs.size()-1);
    return(r);
  }
  
  public boolean addCrab(Crab c)
  {
    if (c.type!=roomName)
    {
      println("*** Illegal attempt to add crab ["+c.type+"] to room type="+roomName);
      return(false);
    }
    c.roomLocation=this;
    c.corridorLocation=null;
    
    // TODO: hook this into a move calculation somehow...
    println("cost to ENTER room is:"+(4-crabs.size()));
    
    crabs.add(c);
    return(true);
  }
  
  public boolean canEnter(Crab c)
  {
    if (open()==true)
    {
      if (c.type==roomName)
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
        if (crabs.get(i).type!=roomName)
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
