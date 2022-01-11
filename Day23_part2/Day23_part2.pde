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


// TODO - complete clean up of get/set stuff for classes and work out how to
// replace direct access of x-ref's with dynamic looks ups where-ever possible
// to make the save/retreive of state info much easier.



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
  
  g.runTestCases2();

  //g.printGameInstance();
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
  int runningScore=0;

  public void printGameInstance()
  {
    println("/=== Start Game Instance Dump ====");
    int i=0;
    for (i=0;i<4;i++)
    {
      rooms[i].printRoom();
    }
    
    corridor.printCorridor();
    println("\\=== End Game Instance Dump ====");

  }

  public GameInstance()
  {
  }
  
  void runTestCases2()
  {
    //rooms[1].getCrab();
    //rooms[1].getCrab();
    //rooms[1].getCrab();
    //rooms[1].getCrab();
    //printRooms();

    do
    {
    }
    while(calculateMoves()==true);
    
    // need to add some crabs to the corridor to test blocking - for example
    // add a 'B' at position '5' would block all crabs to the right from moving left
    //corridor.segments[5].update(new Crab('B',rooms));
    //printRooms();

    //calculateMoves();
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
  
    
    rooms[0].forceAddCrab(new Crab('A',rooms));
    rooms[0].forceAddCrab(new Crab('D',rooms));
    rooms[0].forceAddCrab(new Crab('D',rooms));
    rooms[0].forceAddCrab(new Crab('B',rooms));  
   
    rooms[1].forceAddCrab(new Crab('D',rooms));
    rooms[1].forceAddCrab(new Crab('B',rooms));   
    rooms[1].forceAddCrab(new Crab('C',rooms));
    rooms[1].forceAddCrab(new Crab('C',rooms));
  
    rooms[2].forceAddCrab(new Crab('C',rooms));
    rooms[2].forceAddCrab(new Crab('A',rooms));
    rooms[2].forceAddCrab(new Crab('B',rooms));
    rooms[2].forceAddCrab(new Crab('B',rooms));
  
    rooms[3].forceAddCrab(new Crab('A',rooms));
    rooms[3].forceAddCrab(new Crab('C',rooms));
    rooms[3].forceAddCrab(new Crab('A',rooms));
    rooms[3].forceAddCrab(new Crab('D',rooms));
    
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
    println("Current score:"+runningScore);
  }
  
  // we should repeat steps 1 & 2 in this until no more
  // can be found, this ensures that all crabs that can ever
  // get home in a round do. Then we do a "room->corridor" move
  // to start the next round.
  // check for the null case where no moves are computed/
  // possible. If this occurs this branch is a dead end with no
  // solution, eventually we need to code the ability to roll
  // back.
  // update/maintain a running count of the fuel spent on
  // this game instance.
  public boolean calculateMoves()
  {
    int i=0,j=0;
    Crab crab;
    
    // TODO - restructure this, so that corridorMoves is stored in
    // the crab object its associated with to simplify game state
    // replication. We only ever need to worry about room->corridor
    // moves as no other set needs ever need to be rewound/rerun.
    // this also fixes the issue that currently corridorMoves is
    // homeless and really needs to belong to part of the object
    // tree.
    Movement homeMove=null;
    boolean moveHomeFound=false;
    boolean anyMoveFound=false;
    
    
    do
    {
      moveHomeFound=false;
      println("Move home candidates in corridor:");
      
      // First check all the corridor segments for any crabs that;
      // 1) their target room is open for entry
      // 2) and there are no blocking crabs in the corridor
      // these crabs can move directly to home, so lets move
      // them and get them out of the way, as they are always
      // the best move to make. They remove a crab from play *and*
      // free up corridor movement.
      for (i=0;i<11;i++)
      {
        if (corridor.segments[i].occupied==true)
        {
          crab=corridor.segments[i].occupant;
          
          homeMove=canCrabMoveHome(crab, corridor, rooms);
          
          if (homeMove!=null)
          {
            print("Crab:"+crab.type+" in room:"+i);
            print(" Can reach home by; "+homeMove.movementSummary(crab));
            println();
            
            runningScore+=homeMove.executeMove(crab, corridor, rooms);
            moveHomeFound=true;
            anyMoveFound=true;

          }
          else
          {
            print(" cant reach home");
          }
        }
      }
      
      println("Move home candidates in rooms:");
  
      
      // Next check all the rooms for any crabs that are;
      // 1) at the head of the stack
      // 2) their target room is open for entry
      // 3) and there are no blocking crabs in the corridor
      // these crabs can move directly to home, so lets move
      // them and get them out of the way, as they are always
      // the next best  move to make.
      for (i=0;i<4;i++)
      {
        // we're only interest in looking in rooms which have crabs
        // and that room isn't already open (an open room indicates
        // its either empty or the crabs that are in it are the right
        // type - and if they're the right type we dont want to move
        // them again).
  //print("Room:"+i+" "+rooms[i].crabs.size()+" "+rooms[i].open()+" ");
        if (rooms[i].crabs.size()>0 && rooms[i].open()==false)
        {
          // find the crab nearest the opening
          crab=rooms[i].crabs.get(rooms[i].crabs.size()-1);
          print("Found:"+crab.type);
          
          homeMove=canCrabMoveHome(crab, corridor, rooms);
          
          if (homeMove!=null)
          {
  //print("TM:"+testMoves.size());
            print(" Crab:"+crab.type+" in room:"+i);
            print(" Can reach home by; "+homeMove.movementSummary(crab));
            
            runningScore+=homeMove.executeMove(crab, corridor, rooms);
            moveHomeFound=true;
            anyMoveFound=true;
          }
          else
          {
            print(" cant reach home");
          }
          println();
        }
      }
      
      printRooms();
    
      if (moveHomeFound==true)
      {
        println("Move found, so re-iterating");
      }
      else
      {
        println("No more moves found, trying corridors");
      }
    } while (moveHomeFound==true);
    
    // there is one sorting edge case where the below code breaks
    // down. Each returned list of moves is pre-sorted into cost order,
    // but if we have *2 or more* crabs of the same type that may move
    // this turn, each of those will return a seperate list, and we 
    // need to manage that sets (basically we either need to sort them, or
    // take the lowest cost from each).
    //
    // Note: at any one round there are a maximum of 4 candidates that
    // can move into the corridor. This is because there are only a
    // maximum of 4 rooms that crabs can come from *into* the corridor.
    //
    // We should simply (somehow) track the output of the 4 searchs, and
    // then check each list for the lowest value (a max of 4 comparisons
    // is not too costly and saves us sorting elements)
    // 
    // the above is a more effecient approach, but it was actually fiddly
    // to make that work, so I've gone with a simplier approach of concat
    // all the lists and just doing a simple linear search for the move
    // with the lowest cost.
    
    // Check each room in turn looking for a room that has a candidate
    // to move out into the corridor.
    println("Move from room to corridor candidates:");
    anyMoveFound=false;
    int numMovesFound=0;
    Movement currentBestMove=null;
    Movement tempMove=null;
    Crab currentCrabWithBestMove=null;
    for (i=0;i<4;i++)
    {
      // we're only interest in looking in rooms which have crabs
      // and that room isn't already open (an open room indicates
      // its either empty or the crabs that are in it are the right
      // type - and if they're the right type we dont want to move
      // them again
      if (rooms[i].crabs.size()>0 && rooms[i].open()==false)
      {
        // find the crab nearest the opening
        crab=rooms[i].crabs.get(rooms[i].crabs.size()-1);
        println("Found:"+crab.type);
        
        // retreive all of its permitted moves into the corridor
        numMovesFound=crab.permittedCorridorMovesForthisCrab(rooms,corridor);
        
        if (numMovesFound>0)
        {
          anyMoveFound=true;

          for (j=0;j<numMovesFound;j++)
          {
            println("\\-"+crab.permittedCorridorMoves.get(j).movementSummary(crab));
          }

          
          // find the best move of all the moves permitted by this particular crab
          // then compare it with a running "best move" to see if this is the new
          // best move.
          tempMove=findLeastCost(crab.permittedCorridorMoves);
          if (tempMove!=null)
          {
            // if this is the first move - then just set it as a marker to start from
            if (currentBestMove==null)
            {
              currentBestMove=tempMove;
              currentCrabWithBestMove=crab;
            }
            else
            {
              // if this is a better move then set it.
              if (tempMove.calcWeightedScore(crab) < currentBestMove.calcWeightedScore(currentCrabWithBestMove))
              {
                currentBestMove=tempMove;
                currentCrabWithBestMove=crab;
              }
            }
          }
        }
      }
    }
    
    // TODO - this *almost* represents the state we want to save - we need to remove the instance of the
    // movement rule we're about to test, such that next time we re-enter we can test a different rule.
    printGameInstance();
    
    if (anyMoveFound==true)
    {
      println("Lowest cost corridor move is; "+currentBestMove.movementSummary(currentCrabWithBestMove));
      
      runningScore+=currentBestMove.executeMove(currentCrabWithBestMove, corridor, rooms);
      
      printRooms();
    }
    
    if (anyMoveFound==true)
    {
    }
    
    return(anyMoveFound);
  }
  
  public Movement findLeastCost(ArrayList<Movement> input)
  {
    int i=0;
    int l=input.size();
    Minimum min=new Minimum();
    
    for (i=0;i<l;i++)
    {
      min.set(input.get(i).weightedCost,i);
    }
    return(input.get(min.index));
  }
  
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
  public Movement canCrabMoveHome(Crab c, Corridor corridor, Room[] r)
  {
    Movement permittedMove;
    int s=0;
    
    // First of all, can this crab move directly home? If so this
    // is the highest priority and we want to do that above any
    // other valid moves.
    
    // is the target room open?
    if (c.getTargetLocation(r).open()==true)
    {
      // our start location is either in the cave or in the corridor, so we need to
      // set appropriately.
      if (c.getRoomLocation(r)!=null)
      {
        s=c.getRoomLocation(r).corridorAccess;
      }
      else if (c.getCorridorSegmentIndex()>=0)
      {
        s=c.getCorridorSegmentIndex();
      }
      else
      {
        println("**** ERROR: canCrabMoveHome called without a valid current location:"+c.getRoomLocation(r)+":"+c.corridorSegmentRef);
      }
      //s=c.roomLocation!=null?c.roomLocation.corridorAccess:c.corridorLocation.location;
      
      // ok if the corridor between here and there is open, then this is a valid move
      if (corridor.canReachFrom(s,c.getTargetLocation(rooms).corridorAccess)==true)
      {
        // we've validated this is a permitted move, so we can add this as a permitted move
        permittedMove = new Movement(c, rooms);
        
        // as this crab can move directly to home there is no value in calculating corridor
        // moves.
        return(permittedMove);
      }
    }
    return(null);
  }
}



// TODO - I need to add a crab bag here to store the crabs that are
// in the corridor (basically the corridor is a specalised room).
// Notes:
// 1) when we move a crab from a room to the corridor we need to add
//    it to the bag
// 2) when we need to move a crab from the corridor to a room we need
//    to consult this.
// 3) This also gives us a way to look up details from the crab
//
// If we're storing objects in the corridor in "something", then is
// it really any different than storing them into an array? Just
// so long as we never explicitly reference them by an object ref
// from another location?
public class Corridor
{
  CorridorSegment[] segments=new CorridorSegment[11];
  int[] corridorMask={1,1,0,1,0,1,0,1,0,1,1};
  
  public void printCorridor()
  {
    int i=0;
    for (i=0;i<segments.length;i++)
    {
      segments[i].printCorridorSegment();
    }
  }
  
  public Corridor()
  {
    int i=0;
    for (i=0;i<11;i++)
    {
      segments[i]=new CorridorSegment(i,corridorMask[i]);
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
        if (segments[i].occupied==true)
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
        if (segments[i].occupied==true)
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
  int location=0;
  boolean occupied=false;
  
  public void printCorridorSegment()
  {
    // print segment specific stuff first
    println("[LC:"+location+" P:"+permitted+" O:"+occupied+" Crab:"+occupant+"]");
    if (occupant!=null)
    {
      occupant.printCrab();
    }
  }
  
  public CorridorSegment duplicate()
  {
    CorridorSegment c=new CorridorSegment(location, permitted);
    // TODO need to work out what to do with the occupant - as we need to fork these to new instances?
    c.occupant=occupant;
    c.occupied=occupied;
    return(c);
  }
  
  public CorridorSegment(int i, int p)
  {
    location=i;
    permitted=p;
  }
  
  //public boolean update(Crab c)
  //{
  //  if (permitted==1)
  //  {
  //    occupant=c;
  //    c.setCorridorLocation(this);
  //    c.setTargetLocation(null);
  //    return(true);
  //  }
  //  println("*** Illegal attempt to place crab ["+c.type+"] into corridor location not allowed");
  //  return(false);
  //}
  
  public Character corridorContains()
  {
    if (occupied==false)
    {
      return(permitted==1?'_':'.');
    }
    else
    {
      return(occupant.type);
    }
  }
}

public class Movement
{
  int exitCost=0;
  int leftCost=0;
  int rightCost=0;
  int enterCost=0;
  int weightedCost=0;
  int corridorIndex=0;
  
  public Movement()
  {
  }
  
  // move from crab from its current location (either in a room or in a corridor)
  // to its target location.
  public Movement(Crab c, Room[] r)
  {
    Room targetRoom=c.getTargetLocation(r);
    int e=targetRoom.corridorAccess;
    int s=0;

    if (c.getRoomLocation(r)!=null)
    {
      // if we're in a room we need calculate the
      // cost to exit the room and what our start location
      // is for any corridor move.
      Room currentRoom=c.getRoomLocation(r);
      calcExitCost(currentRoom);
      
      s=currentRoom.corridorAccess;
    }
    else if (c.getCorridorSegmentIndex()>=0)
    {
      // if we're already in the corridor, we just use that
      // location as our starting point.
      s=c.getCorridorSegmentIndex();
    }
    else
    {
      println("**** Error: Movement(crab c) constructor called without a crab location set");
    }
    
    // now that we're in the corridor we just calculate the costs
    // to move along the corridor to the target room and the
    // cost to enter.
    corridorIndex=s;
    calcCorridorCost(s,e);
    calcEntryCost(targetRoom);
    calcWeightedScore(c);
  }
  
  // Move from a room to a corridor segment
  public Movement(Crab c, CorridorSegment seg, Room[] r)
  {
    Room currentRoom=c.getRoomLocation(r);
    int s=currentRoom.corridorAccess;
    int e=seg.location;
    
    corridorIndex=e;
    calcExitCost(currentRoom);
    calcCorridorCost(s,e);
    calcWeightedScore(c);
  }
  
  // Move from a corridor segment to a room
  //public Movement(CorridorSegment seg, Crab c)
  //{
  //  int s=seg.location;
  //  int e=c.myTargetRoom.corridorAccess;
  //  calcCorridorCost(s,e);
  //  calcEntryCost(c.myTargetRoom);
    
  //  type=c.type;
  //}
  
  // A move may consist of one of the following combinations;
  // (1) + (2)
  // (1) + (2) + (3)
  //       (2) + (3)
  //
  // where (1) is an exit from a room, (2) is using the corridor and
  // (3) is entering the target room. This means our execute needs
  // to deal with 3 cases of move;
  // 1) crab is moving to their target room from another room
  // 2) crab is moving to their target room from the corridor
  // 3) crab is moving from their current room into the corridor.
  public int executeMove(Crab crab, Corridor c, Room[] r)
  {
    Crab temp=null;
    
    // Lets work out our destination depending on if this is a move
    // into a room, or a move into the corridor
    if (enterCost>0) // is this a movement into the targets room?
    {

      if (exitCost>0)
      {
        // 1) crab is moving to their target room from another room
        
        // even though we already have a link to the crab, we still
        // explicitly call the getCrab() as this cleans up the state
        // of the room stack and cross links
        temp=crab.getRoomLocation(r).getCrab();
      }
      else
      {
        // 2) crab is moving to their target room from the corridor

        // even though we already have a link to the crab, we still
        // explicitly remove it from the corridor to free up that segment
        temp=crab.getCorridorLocation(c).occupant;
        crab.getCorridorLocation(c).occupant=null;
        crab.getCorridorLocation(c).occupied=false;
      }
      
      // irrespective of the source of the move, temp now points to the
      // object we're moving.
      
      // move to target room (addCrab updates the internal object
      // x-refs so this is a one liner)
      crab.getTargetLocation(r).addCrab(temp);
    }
    else // must be a move to the corridor
    {
      
      // 3) crab is moving from their current room into the corridor.

      
      // this is simplier as a move to the corridor can only be executed
      // from a room.
      
      // even though we already have a link to the crab, we still
      // explicitly call the getCrab() as this cleans up the state
      // of the room stack and cross links
      temp=crab.getRoomLocation(r).getCrab();
      
      // move to corridor index
      c.segments[corridorIndex].occupant=temp;
      c.segments[corridorIndex].occupied=true;
      temp.setCorridorLocation(c.segments[corridorIndex]);
      temp.setCorridorSegmentIndex(corridorIndex);
      
      // Now that we've moved, throw away the old moves.
      temp.permittedCorridorMoves.clear();
    }
    return(weightedCost);
  }
 
  public String movementSummary(Crab crab)
  {
    String s=new String();
    //s+=this;
    s+=" TY:"+crab.type;
    s+=" EX:"+exitCost;
    s+=" LC:"+leftCost;
    s+=" RC:"+rightCost;
    s+=" EN:"+enterCost;
    s+=" RawC:"+rawCost();
    s+=" WC:"+weightedCost;
    
    return(s);
  }
  
  public boolean calcExitCost(Room exitRoom)
  {
    if (exitRoom==null)
    {
      return(false);
    }
    exitCost=5-exitRoom.crabs.size();
    return(true);
  }
  
  public boolean calcEntryCost(Room enterRoom)
  {
    if (enterRoom==null)
    {
      return(false);
    }
    enterCost=4-enterRoom.crabs.size();
    return(true);
  }
  
  public boolean calcCorridorCost(int s, int e)
  {
    //if (c.canReachFrom(s,e)==false)
    //{
    //  return(false);
    //}
//print("["+s+","+e+"]");
    if (s<e)
    {
//print("["+s+"<"+e+"]");

      rightCost=abs(s-e);
    }
    if (s>e)
    {
//print("["+s+">"+e+"]");

      leftCost=abs(e-s);
    }
    return(true);
  }
  
  public int rawCost()
  {
    return(enterCost+leftCost+rightCost+exitCost);
  }
  
  public int calcWeightedScore(Crab crab)
  {
    switch (crab.type)
    {
      case 'A':
        weightedCost=rawCost();
        break;
      case 'B':
        weightedCost=rawCost()*10;
        break;
      case 'C':
        weightedCost=rawCost()*100;
        break;
      case 'D':
        weightedCost=rawCost()*1000;
    }
    return(weightedCost);
  }
}

public class Crab
{
  char type=' ';
  private CorridorSegment corridorSegmentRef=null;
  private int corridorSegmentIndex=-1;
  //private Room roomLocationRef=null;
  //private Room myTargetRoomRef=null;
  ArrayList<Movement> permittedCorridorMoves = new ArrayList<Movement>();

  public void printCrab()
  {
    // Print the crab specific info
    println("* TY:"+type+" CSI:"+corridorSegmentIndex+" CSR:"+corridorSegmentRef);
    
    int i=0;
    for (i=0;i<permittedCorridorMoves.size();i++)
    {
      println("->"+permittedCorridorMoves.get(i).movementSummary(this));
    }
  }
  
  public Crab(char t, Room[] rooms)
  {
    type=t;
    //myTargetRoomRef=getTargetLocation(rooms);
  }
  
  public Crab(char t, Room _myTargetRoom)
  {
    type=t;
    //myTargetRoomRef=_myTargetRoom;
  }
    
  public boolean crabIsHome(Room[] r)
  {
    // if the room this crab is in is "open", then
    // it means it must be in the room its meant
    // to be in and there are only the right
    // type of crabs in this room. note a crab could
    // be in the right room, but there maybe other
    // crabs below it in the stack, which means it
    // would still need to exit to let them out
    // before returning to this location.
    return(getRoomLocation(r).open());
  }
  
  // GET/SET for roomLocation
  public Room getRoomLocation(Room[] r)
  {
    Room myLocation=null;
    int i=0;
    int l=r.length;
    
    // Search each room in turn to see
    // if this carb is in that location
    for (i=0;i<l;i++)
    {
      myLocation=r[i];
      if (myLocation.crabInThisRoom(this)==true)
      {
        return(myLocation);
      }
    }
    return(null);
    //return(roomLocation);
  }
  //public void setRoomLocation(Room r)
  //{
  //  roomLocationRef=r;
  //}
  
  // GET/SET for targetLocation
  //public void setTargetLocation(Room target)
  //{
  //  myTargetRoomRef=target;
  //}
  public Room getTargetLocation(Room[] r)
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
    //return(myTargetRoom);
  }
  
  // GET/SET for corridorLocation
  public void setCorridorLocation(CorridorSegment c)
  {
    corridorSegmentRef=c;
  }
  public CorridorSegment getCorridorLocation(Corridor corridor)
  {
    return(corridorSegmentRef);
  }
  
  public int getCorridorSegmentIndex()
  {
    return(corridorSegmentIndex);
  }
  public void setCorridorSegmentIndex(int i)
  {
    corridorSegmentIndex=i;
  }
  
  public int permittedCorridorMovesForthisCrab(Room[] rooms, Corridor corridor)
  { 

    // This crab can't move directly to the home cave, so lets consider which corridor
    // segments it can reach.
    int lefti=0, righti=0;
    boolean leftComplete=false;
    boolean rightComplete=false;
    
    // clear out any previous moves this crab may have been viable for from a previous move
    // as the game state has now changed and these may no longer be valid, and so we recalculate.
    permittedCorridorMoves.clear();

    lefti=getRoomLocation(rooms).corridorAccess;
    righti=getRoomLocation(rooms).corridorAccess;
    
    
    // do a linear search simulataneously to the left & the right from this location
    // looking for valid movement locations. By doing both searches at the same time
    // we automatically sort them into least cost to most cost in the output list, as
    // the "shortest" moves are found first and added to the list first, this means
    // the list is pre-ordered correctly when we return and we dont need to further
    // sort the list. If we then call this function for crabs from the least cost 
    // to the highest cost (A-D) then we know we'll be able to prioritise all the
    // moves from least costly to most costly across the whole crab population.
    do
    {
      
      // Check for permitted moves to the left. A permitted move is on that;
      // 1) is not outside the bounds of the corridor
      // 2) does not go through an occupied space
      // 3) is to a permitted "rest" location (i.e. not in front of a cave)
      if (leftComplete==false)
      {
        if (corridor.segments[lefti].occupied==true)
        {
          leftComplete=true;
        }
        else
        {
          if (corridor.segments[lefti].permitted>0)
          {
            permittedCorridorMoves.add(new Movement(this,corridor.segments[lefti],rooms));
          }
        }
        lefti--;
        if (lefti<0)
        {
          leftComplete=true;
        }
      }
      
      // Check for permitted moves to the right. A permitted move is on that;
      // 1) is not outside the bounds of the corridor
      // 2) does not go through an occupied space
      // 3) is to a permitted "rest" location (i.e. not in front of a cave)
      if (rightComplete==false)
      {
        if (corridor.segments[righti].occupied==true)
        {
          rightComplete=true;
        }
        else
        {
          if (corridor.segments[righti].permitted>0)
          {
            permittedCorridorMoves.add(new Movement(this,corridor.segments[righti],rooms));
          }
        }
        righti++;
        if (righti>=corridor.segments.length)
        {
          rightComplete=true;
        }
      }
    }
    while (leftComplete==false || rightComplete==false);
    
    return(permittedCorridorMoves.size());
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
  
  public void printRoom()
  {
    // print room specific info
    println("[RM:"+roomName+" CA:"+corridorAccess+"]");
    
    int i=0;
    for (i=0;i<crabs.size();i++)
    {
      crabs.get(i).printCrab();
    }
  }
  
  public Crab getCrab()
  {
    if (crabs.size()==0)
    {
      println("*** Illegal attempt to take a crab from a room that is empty, room was="+roomName);
      return(null);
    }
    
    Crab r=crabs.get(crabs.size()-1);
    crabs.remove(crabs.size()-1);
    println(" new stack size is:"+crabs.size());
    return(r);
  }
  
  public boolean addCrab(Crab c)
  {
    if (c.type!=roomName)
    {
      println("*** Illegal attempt to add crab ["+c.type+"] to room type="+roomName);
      return(false);
    }

    return(forceAddCrab(c));
  }
  
  public boolean forceAddCrab(Crab c)
  {
    //c.setRoomLocation(this);
    c.setCorridorLocation(null);
    c.setCorridorSegmentIndex(-1);
    
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
  
  public boolean crabInThisRoom(Crab c)
  {
    int i=0;
    int l=crabs.size();
    for (i=0;i<l;i++)
    {
      if (c==crabs.get(i))
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


public class Minimum
{
  long value=0;
  boolean set=false;
  int index=0;
  
  public Minimum()
  {
  }

  public void set(long v, int i)
  {
    // Always set if this is the first time, but subsequently only set
    // if its less as we're trying to track the shortest distant. This
    // is overkill, as the *first* time should always be the shortest
    if (set==false)
    {
      value=v;
      index=i;
      set=true;
    }
    else
    {
      if (v<value)
      {
        value=v;
        index=i;
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
