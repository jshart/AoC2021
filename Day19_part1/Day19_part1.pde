import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

String filebase = new String("C:\\Users\\jsh27\\OneDrive\\Documents\\GitHub\\AoC2021\\Day19_part1\\data\\example");

//ArrayList<String> fieldLines = new ArrayList<String>();
//int numFieldLines=0;
//ArrayList<Long> invertedNumbers = new ArrayList<Long>();
//long[] invertedNumbers = new long[25];
//HashMap<Long, Long> memoryMap = new HashMap<Long, Long>();


// NOTES: there is a tendancy for most beacons to be deployed into small clusters of 3 nodes
// with some scanners having a small (1-3) number of beacons very close to them. If we group the
// beacons into 3's perhaps that would help us work out the relationships, as they'd form a triangle,
// which could potentially be a unique signature to look for?

// Raw input and parsed input lists for *all data*
InputFile input = new InputFile("input.txt");

// Master list of all data input, ready for subsequent processing
ArrayList<String> masterList = new ArrayList<String>();

ArrayList<Scanner> scannerList = new ArrayList<Scanner>();

void setup() {
  size(1200, 1200, P3D);
  background(0);
  stroke(255);
  frameRate(30);

  System.out.println("Working Directory = " + System.getProperty("user.dir"));
  println();
  input.printFile();
  
  int i=0,j=0;

  Scanner temp=null;
  int scannerNo=0;


  // **** FILE PARSING SECTION
  // Loop through each input item...
  for (i=0;i<input.lines.size();i++)
  {
    if (input.lines.get(i).startsWith("---")==true)
    {
      println("Scanner "+i+" found");
      if (temp!=null)
      {
        scannerList.add(temp);
      }
      temp=new Scanner(scannerNo);
      scannerNo++;
    }
    else
    {
      if (temp!=null)
      {
        temp.parseBeacon(input.lines.get(i));
      }
      else
      {
        println("ERROR: unable to add beacon to empty scanner object");
      }
    }
  }
  
  // Once we exit the loop, there maybe the last scanner unsaved, lets
  // check and close it out if it is;
  if (temp!=null)
  {
    scannerList.add(temp);
  }
  temp=new Scanner(scannerNo);
  // **** END FILE PARSING SECTION

  
  
  // From here we're done with the text file and can work directly on the
  // object versions of the scanners
  for (i=0;i<scannerList.size();i++)
  {
    scannerList.get(i).printScanner();
    scannerList.get(i).pairUpBeacons();
  }
  
  // for each scanner build the beacon groups
  for (i=0;i<scannerList.size();i++)
  {
    scannerList.get(i).buildBeaconGroup();
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

int degree=0;
int drawIndex=0;
int ztranslate=-2000;
void draw()
{ 
  background(0);
  noStroke();
  translate(500,500,ztranslate);
  rotateX(radians(degree));
  rotateY(radians(degree));
  rotateZ(radians(degree));
  scannerList.get(drawIndex).drawScanner();
  

  
  degree=(degree>360?0:degree+1);
}

void keyPressed()
{
  switch (key)
  {
    case 'q':
      drawIndex=(drawIndex==scannerList.size()-1?0:drawIndex+1);
      println("Draw Index updated to:"+drawIndex);
      break;
    case 'z':
      drawIndex=(drawIndex==0?scannerList.size()-1:drawIndex-1);
      println("Draw Index updated to:"+drawIndex);
      break;
    case 'w':
      ztranslate-=100;
      break;
    case 's':
      ztranslate+=100;
      break;
  }
}

public class Beacon
{
  PVector position = new PVector();
  int distanceFromScanner=0;
  Beacon nearest;
  int beaconSize=20;
  
  ArrayList<Beacon> beaconGroup = new ArrayList<Beacon>();
  PVector groupCenter= new PVector();

  
  public Beacon(int x, int y, int z)
  {
    position.set(x,y,z);
    distanceFromScanner=(int)PVector.dist(position, new PVector(0,0,0));
  }
  
  public void drawBeacon(PVector scannerLocation)
  {
    PVector location = new PVector();
    
    location.set(scannerLocation);
    location.add(position);
    
    //fill(random(255),random(255),random(255));
    pushMatrix();
    fill(255,255,0);
    translate(location.x,location.y,location.z);
    sphere(beaconSize);
    popMatrix();
    
    //stroke(255,255,255);
    //line(position.x,position.y,position.z,nearest.position.x,nearest.position.y,nearest.position.z);
    //noStroke();
    drawBeaconGroup();
  }
  
  public void drawBeaconGroup()
  {
    int i=0;
    int l=beaconGroup.size();
    Beacon b;
    
    // this allows us to filter/ignore certain groups if we're not interested in them.
    if (l!=3)
      return;
    
    stroke(255,255,255);
    
    pushMatrix();
    translate(groupCenter.x,groupCenter.y,groupCenter.z);
    sphere(beaconSize/3);
    popMatrix();

    for(i=0;i<l;i++)
    {
      b=beaconGroup.get(i);
      line(b.position.x,b.position.y,b.position.z,groupCenter.x,groupCenter.y,groupCenter.z);
    }
    noStroke();

  }
  
  public void findNearest(ArrayList<Beacon> bl)
  {
    int i=0;
    int l=bl.size();
    Minimum min = new Minimum();
    int d=0;
    Beacon b;
    
    for (i=0;i<l;i++)
    {
      b=bl.get(i);
      
      // dont check this beacon... but all others
      if (this!=b)
      {
        if (min.set((long)position.dist(b.position))==true)
        {
          nearest=b;
        }
      }
    }
  }
  
  public void buildBeaconGroup(ArrayList<Beacon> bl)
  {
    int i=0;
    int l=bl.size();
    Beacon b;
    int x=0, y=0, z=0;
        
    // for each element in the beacon list, see if
    // that element has listed this one as its
    // nearest neighbour, if it has then its part
    // of the same group.
    for (i=0;i<l;i++)
    {
      b=bl.get(i);
      
      // did the beacon in the list mark us as its nearest
      // neighbour?
      if (b.nearest==this)
      {
        // add the beacon to our beacon group
        beaconGroup.add(b);
        
        // calculate the average
        x+=b.position.x;
        y+=b.position.y;
        z+=b.position.z;
      }
    }
    
    // finally add ourselves to the group
    beaconGroup.add(this);
    x+=position.x;
    y+=position.y;
    z+=position.z;
    
    i=beaconGroup.size();
    if (i>0)
    {
      print("SET GROUP, size:"+i);
      groupCenter.set(x/i,y/i,z/i);
      println(" group centre at:"+(x/i)+","+(y/i)+","+(z/i));
    }
  }
}

public class Scanner
{
  ArrayList<Beacon> beacons = new ArrayList<Beacon>();
  int scannerID=0;
  
  int scannerSize=40;
  
  PVector scannerLocation=new PVector(0,0,0);
  
  public Scanner(int id)
  {
    scannerID=id;
  }
  
  public void parseBeacon(String input)
  {
    String[] nums=input.split(",");
    Beacon t=new Beacon(Integer.parseInt(nums[0]),Integer.parseInt(nums[1]),Integer.parseInt(nums[2]));
    
    beacons.add(t);
  }
  
  public void printBeacons()
  {
    int i=0;
    int l=beacons.size();
    PVector t;
    
    for (i=0;i<l;i++)
    {
      t=beacons.get(i).position;
      println(" |=B:"+t.x+","+t.y+","+t.z+" DIST:"+beacons.get(i).distanceFromScanner);
    }
  }
  
  public void printScanner()
  {
    println("*** SCANNER:"+scannerID+" Can see "+beacons.size()+" beacons;");
    printBeacons();
  }
  

  
  public void drawScanner()
  {
    pointLight(255,255,255,scannerLocation.x,scannerLocation.y,scannerLocation.z);
    //pointLight(255,255,255,0,0,0);


    //specular(0,0,255);
    pushMatrix();
    fill(0,255,255);
    stroke(0,0,255);
    translate(scannerLocation.x,scannerLocation.y,scannerLocation.z);
    sphere(scannerSize);
    popMatrix();
    
    noStroke();

    int i=0;
    int l=beacons.size();
    Beacon b;
    
    for (i=0;i<l;i++)
    {
      b=beacons.get(i);
      b.drawBeacon(scannerLocation);
    }
    
    stroke(255,0,0);
    noFill();
    box(2000,2000,2000);
  }
  
  public void pairUpBeacons()
  {
    int i=0;
    int l=beacons.size();
    Beacon t;
    
    for (i=0;i<l;i++)
    {
      t=beacons.get(i);
      t.findNearest(beacons);
    }
  }
  
  public void buildBeaconGroup()
  {
    int i=0;
    int l=beacons.size();
    Beacon t;
    
    // for each beacon this scanner can see
    // build a group for it to be a member of
    for (i=0;i<l;i++)
    {
      t=beacons.get(i);
      t.buildBeaconGroup(beacons);
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

  public boolean set(long v)
  {
    // Always set if this is the first time, but subsequently only set
    // if its less as we're trying to track the shortest distant. This
    // is overkill, as the *first* time should always be the shortest
    if (set==false)
    {
      value=v;
      set=true;
      return(true);
    }
    else
    {
      if (v<value)
      {
        value=v;
        return(true);
      }
    }
    return(false);
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
