import websockets.*;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonElement;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.*;
import java.lang.*;
import peasy.*;
import java.util.Comparator;

/*---------------------------------------------------------------------------------------------------------------------
                                                    class object
----------------------------------------------------------------------------------------------------------------------*/

class Object{
  //object defination
  String name;
  int ind;
  //object position
  PVector location;
  //object animation
  String animation;
  String destination;
  String Case;
  
  float r=0;
  int dir = 0;
  
  int animState = 0;
  PVector heightOffset =new PVector(0,0,0);
  
  //constructor to add object at a location
  Object(String name, PVector location, int index){
    this.name = name;
    this.ind = index;
    this.location = location;
    this.animation = "";
    this.destination = "";
    this.animState =0;
  }
  //constructor to add if animation and destination is known
  Object(String name, PVector location, String destination,String animation, String Case,int index){
    this.name = name;
    this.location = location;
    this.destination = destination;
    this.ind = index;
    this.animation = animation;
    this.Case = Case;
    this.animState = 1;
    
    for(Object obj: objectList){
      if(obj.getName().equals(destination)){
          heightOffset = getCaseInfo(Case, obj.getName());
      }
    }
  }
  
  String getName(){
     return this.name; 
  }
  int getIndex(){
     return this.ind; 
  }
  PVector getLoc(){
    return this.location;
  }
  void update(){
    if(animState==1){
      for(Object obj: objectList){
        if(obj.getName().equals(destination)){
          
          if(isStatic(animation)){
            this.location = PVector.add(obj.getLoc(),getCaseInfo(Case, obj.name));
            //println(location.z);
            this.animState =0;
          }
          else{
            int motionType = getMotion(Case);
            
            
            if(motionType==0){//towards
              PVector dest = obj.getLoc();
              PVector tempLoc = PVector.sub(dest,location);
              tempLoc.x = Integer.signum((int)(tempLoc.x));
              tempLoc.y = Integer.signum((int)(tempLoc.y));
              
            
              this.location = PVector.add(location,tempLoc);
              this.location.z = heightOffset.z;
            }
            else if(motionType==1){//away
              PVector dest = obj.getLoc();
              PVector tempLoc = PVector.sub(dest,location);
              if(tempLoc.equals(new PVector(0,0,0))){
                tempLoc = new PVector(1,1,0);
              }
              tempLoc.x = -Integer.signum((int)(tempLoc.x));
              tempLoc.y = -Integer.signum((int)(tempLoc.y));
              tempLoc.z = -Integer.signum((int)(tempLoc.z));
            
              this.location = PVector.add(location,tempLoc);
            }
            else if(motionType==2){//around
              
              PVector dest = obj.getLoc();
              float scale = getScale(obj.getName());
              int radius = (int)(100*scale);
              int x = (int)(radius*cos(radians(r)));
              int y = (int)(radius*sin(radians(r)));
              r=(r+(2/(scale/3)))%360;
              this.location = new PVector(dest.x+x, dest.y+y, dest.z);
   
            }
            else if(motionType==3){//static
              this.location = obj.getLoc();
            }
            else if(motionType==4){//up
              PVector dest = obj.getLoc();
              dest.z++;
              this.location = new PVector(dest.x, dest.y ,dest.z);
            }
            else if(motionType==5){//down
              PVector dest = obj.getLoc();
              dest.z--;
              this.location = new PVector(dest.x, dest.y ,dest.z);
            }
            else if(motionType==6){//left 
              PVector dest = obj.getLoc();
              dest.x--;
              this.location = new PVector(dest.x, dest.y ,dest.z);
            }
            else if(motionType==7){//right
              PVector dest = obj.getLoc();
              dest.x++;
              this.location = new PVector(dest.x, dest.y ,dest.z);
            }
            else if(motionType==8){//front
              PVector dest = obj.getLoc();
              dest.y++;
              this.location = new PVector(dest.x, dest.y ,dest.z);
            }
            else if(motionType==9){//back
              PVector dest = obj.getLoc();
              dest.y--;
              this.location = new PVector(dest.x, dest.y ,dest.z);
            }
            else if(motionType==10){//along
              PVector dest = new PVector(-obj.getLoc().x,-obj.getLoc().y,obj.getLoc().z);
              PVector tempLoc = PVector.sub(dest,this.location);
              
              
              if(tempLoc.equals(new PVector(0,0,0))){
                tempLoc = new PVector(1,1,0);
                dir=1;
              }
              if(dir==1){
                tempLoc.x = -Integer.signum((int)(tempLoc.x));
                tempLoc.y = -Integer.signum((int)(tempLoc.y));
                //tempLoc.z = heightOffset.z;
              }
              else{
                tempLoc.x = Integer.signum((int)(tempLoc.x));
                tempLoc.y = Integer.signum((int)(tempLoc.y));
                //tempLoc.z = heightOffset.z;
              }
            
              this.location = PVector.add(this.location,tempLoc);
              this.location.z = heightOffset.z;
            }
            else{//random motion
              PVector dest = new PVector(random(-500,500), random(-500,500), 0);
              PVector tempLoc = PVector.sub(dest,location);
              tempLoc.x = Integer.signum((int)(tempLoc.x));
              tempLoc.y = Integer.signum((int)(tempLoc.y));
              //tempLoc.z = heightOffset.z;
            
              this.location = PVector.add(location,tempLoc);
              this.location.z = heightOffset.z;
            }
          }
        }
      }
    }
  }
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    global variables
----------------------------------------------------------------------------------------------------------------------*/

WebsocketServer socket;

int numberofObject = 602;
String[] names = new String[numberofObject];
PImage[] images = new PImage[numberofObject];

float[][] randomMap =new float[10][10]; 
float[][] waveMap =new float[10][10]; 

float end, x;
PeasyCam cam;
CameraState state;
int min = 0;
PGraphics p;
color backgroundColor = 230;

String message = "";
String displayMessage = "";

float wave=0;
int landMode = 1;

JSONObject jsonSize;
JsonObject scalesJson;

/*---------------------------------------------------------------------------------------------------------------------
                                                    ArrayList of type object
----------------------------------------------------------------------------------------------------------------------*/

ArrayList<Object> objectList = new ArrayList();


/*---------------------------------------------------------------------------------------------------------------------
                                                    Steup function
----------------------------------------------------------------------------------------------------------------------*/

void setup(){
  size(1000,1000,P3D);
  cam = new PeasyCam(this,2500);
  cam.pan(-100,-500);
  cam.rotateX(0);
  state = cam.getState();
  
  socket = new WebsocketServer(this, 1337, "/p5websocket");
  
  hint(DISABLE_DEPTH_TEST);
  
  jsonSize = loadJSONObject("size.json");
  scalesJson = new JsonParser().parse(jsonSize.toString()).getAsJsonObject();
  println(jsonSize.get("elephant.svg"));
  
  println("setup function");
  
  /*------------------------------------------------------
                       default objects
  -------------------------------------------------------*/
  objectList.add(new Object("sky", new PVector(0,0,-1000), -1));
  objectList.add(new Object("ground", new PVector(0,0,min), -1));
  objectList.add(new Object("centre", new PVector(0,0,0), -1));
  objectList.add(new Object("background", new PVector(0,-1000,0), -1));
  objectList.add(new Object("left", new PVector(-700,0,0), -1));
  objectList.add(new Object("right", new PVector(700,0,0), -1));
  
  /*------------------------------------------------------
                   Initialize random map
  -------------------------------------------------------*/
  float yoff = 0;
  for(int y=0; y<10; y++){
    float xoff = 0;
    for(int x=0; x<10; x++){
      randomMap[x][y] = map(noise(xoff,yoff),0,1,0,50);
      xoff += 0.5;
    }
    yoff+=0.5;
  }
  
  
  String path = sketchPath()+"/doodlesProcessed/";
  names = listFileNames(path);
  
  printArray(names);
  println("Loading Dataset");
  
  for(int i=0; i<numberofObject; i++){
    try{
      images[i] = loadImage("doodlesProcessed/"+names[i]);
      println("loading "+names[i]);
    }
    catch(Exception e){
      println("Failed to load hhhhh  " +names[i]);
      println(e);
    }
  }
  println("Done Loading");
}


String[] listFileNames(String dir) {
   File file = new File(dir);
   if (file.isDirectory()) {
     String names[] = file.list();
     return names;
   } else {
     return null;
   }
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    draw function 
----------------------------------------------------------------------------------------------------------------------*/

void draw() {
  background(backgroundColor);
  imageMode(CENTER);
  
  if(landMode==0){
    spacePlane();
    backgroundColor=100;
    cam.beginHUD();
    fill(0,20,255);
    text("Space Mode",10, 10);
    cam.endHUD();
  }
  else if(landMode==1){
    defaultPlane(min);
    backgroundColor=230;
    cam.beginHUD();
    fill(0,20,255);
    text("Land Mode",10, 10);
    cam.endHUD();
  }
  else if(landMode==2){
    wavePlane(min);
    backgroundColor=230;
    cam.beginHUD();
    fill(0,20,255);
    text("Water Mode",10, 10);
    cam.endHUD();
  }
  else{
    beachPlane(min);
    backgroundColor=230;
    cam.beginHUD();
    fill(0,20,255);
    text("Land Water Mode",10, 10);
    cam.endHUD();
  }
  //defaultPlane(min);
  //beachPlane(min);
  //wavePlane(min);
  
  if(!message.equals("")){
    if(message.length()>0){
      try{
        stanfordNLP(message);
      }
      catch(Exception e){
         println("Exception while processing"); 
      }
    }
  }
  
  /*------------------------------------------------------
                    heads up display
  -------------------------------------------------------*/
  cam.beginHUD();
  fill(0);
  rect(15, height-75, width-30, 50,20);
  fill(255);
  text(displayMessage,20, height-40);
  cam.endHUD();
  
  //Collection.sort(objectList);
  Collections.sort(objectList, new Comparator<Object>() {
    @Override
    public int compare(Object o1, Object o2) {
        return (int)o1.getLoc().y - (int)o2.getLoc().y;
    }
  });
  
  if(message.contains("remove") || message.contains("delete")){
    String object = message.replace("remove","").trim();
    //object = object.replace("remove","").trim();
    for(Object obj: objectList){
      if(obj.getName().equals(object)){
        objectList.remove(obj); 
        break;
      }
    }
  }
  else{
    for(Object obj : objectList){
      obj.update();
  
      int ind = obj.getIndex();
      PVector loc = obj.getLoc();
      
      float scale = getScale(obj.getName());
      
      translate(0,0,loc.y);
      if(ind!=-1){ 
        image(images[ind],loc.x, loc.z-(50*scale), 100*scale, 100*scale);
      }
      translate(0,0,-loc.y);
    }
  }
  message = "";
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    key inputs to set camera
----------------------------------------------------------------------------------------------------------------------*/

public void keyReleased() {
  if (key == '1') state = cam.getState();
  if (key == '2') cam.setState(state, 1000);
}

/*---------------------------------------------------------------------------------------------------------------------
                                                default plane 
----------------------------------------------------------------------------------------------------------------------*/

void defaultPlane(int min){
  pushMatrix();
  translate(-1000,0,-1000);
  for(int y=0; y<9; y++){
    beginShape(TRIANGLE_STRIP);
    fill(255,200);
    stroke(150);
    for(int x=0; x<10; x++){
      vertex(x*200, min+randomMap[x][y], y*200);
      vertex(x*200, min+randomMap[x][y+1], (y+1)*200);
    }
    endShape();
  }
  popMatrix(); 
}

/*---------------------------------------------------------------------------------------------------------------------
                                                wave plane 
----------------------------------------------------------------------------------------------------------------------*/

void wavePlane(int min){
  
  wave +=0.05;
  
  float yoff = wave;
  for(int y=0; y<10; y++){
    float xoff = 0;
    for(int x=0; x<10; x++){
      waveMap[x][y] = map(noise(xoff,yoff),0,1,0,100);
      xoff += 0.8;
    }
    yoff+=0.8;
  }
  
  
  pushMatrix();
  translate(-1000,0,-1000);
  for(int y=0; y<9; y++){
    beginShape(TRIANGLE_STRIP);
    //noFill();
    fill(12, 225, 255,170);
    stroke(12, 164, 255);
    for(int x=0; x<10; x++){
        vertex(x*200, min+10+waveMap[x][y], y*200);
        vertex(x*200, min+10+waveMap[x][y+1], (y+1)*200);
    }
    endShape();
  }
  popMatrix();
}

/*---------------------------------------------------------------------------------------------------------------------
                                                beach plane 
----------------------------------------------------------------------------------------------------------------------*/

void beachPlane(int min){

  fill(255,200);
  
  wavePlane(min+20);

  pushMatrix();
  translate(-1000,0,-1000);
  for(int y=0; y<9; y++){
    beginShape(TRIANGLE_STRIP);
    fill(255);
    stroke(150);
    for(int x=0; x<10; x++){
      if(y<4){
        vertex(x*200, min+randomMap[x][y], y*200);
        vertex(x*200, min+randomMap[x][y+1], (y+1)*200);
      }
      else if(y==4){
        vertex(x*200, min+randomMap[x][y], y*200);
        vertex(x*200, min+250+randomMap[x][y+1], (y+1)*200);
      }
      else if(y==5){
        vertex(x*200, min+250+randomMap[x][y], y*200);
        vertex(x*200, min+320+randomMap[x][y+1], (y+1)*200);
      }
      else{
        vertex(x*200, min+320+randomMap[x][y], y*200);
        vertex(x*200, min+320+randomMap[x][y+1], (y+1)*200);
      }
    }
    endShape();
  }
  popMatrix();
}

/*---------------------------------------------------------------------------------------------------------------------
                                                space plane 
----------------------------------------------------------------------------------------------------------------------*/

void spacePlane(){

  fill(255,200);
  beginShape(LINES);
  stroke(255,0,0);
  vertex(1000,0,0);
  vertex(-1000,0,0);
  endShape();
  beginShape(LINES);
  stroke(0,255,0);
  vertex(0,1000,0);
  vertex(0,-1000,0);
  endShape();
  beginShape(LINES);
  stroke(0,0,255);
  vertex(0,0,1000);
  vertex(0,0,-1000);
  endShape();

}

/*---------------------------------------------------------------------------------------------------------------------
                                    web sockets to connection to speech to text 
----------------------------------------------------------------------------------------------------------------------*/

void webSocketServerEvent(String msg){
  //println("abcd");
  println(msg);
  msg = msg.toLowerCase().trim();
  
  
  if(msg.contains("clear scene") || msg.contains("reset scene")){
    objectList.clear();
    objectList.add(new Object("sky", new PVector(0,0,-1000), -1));
    objectList.add(new Object("ground", new PVector(0,0,min), -1));
    objectList.add(new Object("centre", new PVector(0,0,0), -1));
    objectList.add(new Object("background", new PVector(0,-1000,0), -1));
    objectList.add(new Object("left", new PVector(-700,0,0), -1));
    objectList.add(new Object("right", new PVector(700,0,0), -1));
  }
  else if(msg.contains("remove") || msg.contains("delete")){
    String object = msg.replace("remove","").trim();
    object = object.replace("remove","").trim();
    for(Object obj: objectList){
      if(obj.getName().equals(object)){
        objectList.remove(obj); 
        break;
      }
    }
  }
  else if(msg.equals("land mode") || msg.equals("land mod")){
    objectList.clear();
    objectList.add(new Object("sky", new PVector(0,0,-1000), -1));
    objectList.add(new Object("ground", new PVector(0,0,min), -1));
    objectList.add(new Object("centre", new PVector(0,0,0), -1));
    objectList.add(new Object("background", new PVector(0,-1000,0), -1));
    objectList.add(new Object("left", new PVector(-700,0,0), -1));
    objectList.add(new Object("right", new PVector(700,0,0), -1));
    
    objectList.add(new Object("land", new PVector(0,0,0), -1));
    landMode = 1;
  }
  else if(msg.equals("water mode") || msg.equals("water mod")){
    objectList.clear();
    objectList.add(new Object("sky", new PVector(0,0,-1000), -1));
    objectList.add(new Object("centre", new PVector(0,0,0), -1));
    objectList.add(new Object("background", new PVector(0,-1000,0), -1));
    objectList.add(new Object("left", new PVector(-700,0,0), -1));
    objectList.add(new Object("right", new PVector(700,0,0), -1));
    
    objectList.add(new Object("ocean", new PVector(0,0,170), -1));
    objectList.add(new Object("sea", new PVector(0,0,170), -1));
    landMode = 2;
  }
  else if(msg.equals("land water mode") || msg.equals("land water mod")){
    objectList.clear();
    objectList.add(new Object("sky", new PVector(0,0,-1000), -1));
    objectList.add(new Object("ground", new PVector(0,0,min), -1));
    objectList.add(new Object("centre", new PVector(0,0,0), -1));
    objectList.add(new Object("background", new PVector(0,-1000,0), -1));
    objectList.add(new Object("left", new PVector(-700,0,0), -1));
    objectList.add(new Object("right", new PVector(700,0,0), -1));
    
    objectList.add(new Object("land", new PVector(0,-500,0), -1));
    objectList.add(new Object("water", new PVector(0,500,170), -1));
    objectList.add(new Object("ocean", new PVector(0,500,170), -1));
    objectList.add(new Object("sea", new PVector(0,500,170), -1));
    objectList.add(new Object("river", new PVector(0,500,170), -1));
    objectList.add(new Object("shore", new PVector(0,-100,0), -1));
    landMode = 3;
  }
  else if(msg.equals("space mode") || msg.equals("space mod")){
    objectList.clear();
    objectList.add(new Object("centre", new PVector(0,0,0), -1));
    objectList.add(new Object("background", new PVector(0,-1000,0), -1));
    objectList.add(new Object("left", new PVector(-700,0,0), -1));
    objectList.add(new Object("right", new PVector(700,0,0), -1));
    
    objectList.add(new Object("space", new PVector(0,-500,0), -1));
    landMode = 0;
  }
  else{
    message = msg;
    displayMessage = msg;
  }
  
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    getScale function
----------------------------------------------------------------------------------------------------------------------*/

float getScale(String name){
  
  float scale = 3;
  try{
    scale = scalesJson.get(name+".svg").getAsFloat();
    //print("scale of "+name +" " +scale);
  }
  catch(Exception e){
    //println("error "+e);
  }
   return scale/3; 
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    getMotion function
----------------------------------------------------------------------------------------------------------------------*/

int getMotion(String Case){
  if(Case.equals("to") || Case.equals("towards") || Case.equals("in") || Case.equals("into") || Case.equals("onto") || Case.equals("under") || Case.equals("behind")){
    return 0;
  }
  else if(Case.equals("away") || Case.equals("away_from") || Case.equals("from") || Case.equals("off_of") || Case.equals("out_of") || Case.equals("out") || Case.equals("outside") || Case.equals("outdoors")){
    return 1;
  }
  else if(Case.equals("around") || Case.equals("round") || Case.equals("revolve")){
    return 2;
  }
  else if(Case.equals("against") || Case.equals("next_to")){
    return 3;
  }
  else if(Case.equals("up") || Case.equals("uphill") || Case.equals("upwards")){
    return 4;
  }
  else if(Case.equals("down") || Case.equals("downwards")){
    return 5;
  }
  else if(Case.equals("left")){
    return 6;
  }
  else if(Case.equals("right")){
    return 7;
  }
  else if(Case.equals("in_front_of") || Case.equals("forward") || Case.equals("of")){
    return 8;
  }
  else if(Case.equals("back") || Case.equals("backwardsd")){
    return 9;
  }
  else if(Case.equals("across") || Case.equals("over") || Case.equals("through") || Case.equals("by")){
    return 10;
  }
  else{
    return -1;
  }
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    getCaseInfo function
----------------------------------------------------------------------------------------------------------------------*/

PVector getCaseInfo(String relation, String name){
  //read scale from json
  //reduce scale by 3
  float scale = getScale(name);
  
  PVector pos = new PVector(0,0,0);
  if(relation.equals("on")){
    pos.z = -75 - 50 - 50*scale;
  }
  else if(relation.equals("above")){
    pos.z = -random(110,300) - 50 - 50*scale;
  }
  else if(relation.equals("over")){
    pos.z = -random(75,200) - 50 - 50*scale;
  }
  else if(relation.equals("against") || relation.equals("beside") || relation.equals("by")){
    int rand = (int)random(0,1);
    if(rand==1){
      pos.x = 100*scale/3;
    }
    else{
      pos.x = -100*scale/3;
    }
  }
  else if(relation.equals("behind")){
    pos.y = -100;
  }
  else if(relation.equals("below")){
    pos.z = -50*scale;
  }
  else if(relation.equals("beneath") || relation.equals("underneath") || relation.equals("under")){
    pos.z = random(75, 250) - 100 - 50*scale;
  }
  else if(relation.equals("in_front_of") || relation.equals("of") || relation.equals("front")){
    pos.y = 100;
  }
  else if(relation.equals("inside") || relation.equals("in") || relation.equals("into")){
    pos = new PVector(random(-50*scale,50*scale),random(-5*scale,5*scale),10);
  }
  else if(relation.equals("near")){
    int x = (int)random(-300,300);
    int y = (int)random(-300,300);
    pos.x = x;
    pos.y = y;
  }
  else if(relation.equals("next_to")){
    int x = (int)random(-150,150);
    int y = (int)random(-150,150);
    pos.x = x;
    pos.y = y;
  }
  return pos;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    getTag function
----------------------------------------------------------------------------------------------------------------------*/

String getTag(String text, JsonArray tokenJsonArray){
  for(JsonElement obj: tokenJsonArray){
     if(obj.getAsJsonObject().get("word").getAsString().equals(text)){
        return obj.getAsJsonObject().get("pos").getAsString();
     }
  }
  return null;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    getLemma function
----------------------------------------------------------------------------------------------------------------------*/

String getLemma(String text, JsonArray tokenJsonArray){
  for(JsonElement obj: tokenJsonArray){
     if(obj.getAsJsonObject().get("word").getAsString().equals(text)){
        return obj.getAsJsonObject().get("lemma").getAsString();
     }
  }
  return text;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    isStatic function
----------------------------------------------------------------------------------------------------------------------*/

Boolean isStatic(String animation){
  String[] motionVerbs = {"walk","run","move", "jump","hop","bounce","drag","fly","revolve","chase","follow"};
  for(String s: motionVerbs){
    if(animation.equals(s)){return false;}
  }
  return true;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    ifExist function
----------------------------------------------------------------------------------------------------------------------*/

Boolean ifExist(String object){
  for(Object obj : objectList){
    String item = obj.getName();
    if(item.equals(object)){
      return true;
    }
  }
  return false;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    ifExistInDatabase function
----------------------------------------------------------------------------------------------------------------------*/

Boolean ifExistInDatabase(String object){
  for(int i=0; i<numberofObject; i++){
    if(names[i].equals(object+".png")){
      return true;
    }
  }
  return false;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    getObject function
----------------------------------------------------------------------------------------------------------------------*/

Object getObject(String name){
  for(Object obj : objectList){
    String item = obj.getName();
    if(item.equals(name)){
      return obj;
    }
  }
  return null;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    findInd function
----------------------------------------------------------------------------------------------------------------------*/

int findInd(String name){
  for(int i=0; i<numberofObject; i++){
    if(names[i].equals(name+".png")){
      return i;
    }
  }
  return -1;
}

/*---------------------------------------------------------------------------------------------------------------------
                                                    stanfordNLP function
----------------------------------------------------------------------------------------------------------------------*/

void stanfordNLP(String text)throws Exception{
  URL obj = new URL("http://localhost:9000/");
  HttpURLConnection con = (HttpURLConnection) obj.openConnection();
  con.setRequestMethod("POST");
  con.setRequestProperty("Content-Type", "application/json");
  con.setDoInput(true);
  con.setDoOutput(true);

  List<String> params = new ArrayList<String>();
  params.add(text);

  OutputStream os = con.getOutputStream();
  BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(os, "UTF-8"));
  writer.write(text);
  writer.flush();
  writer.close();
  os.close();
  con.connect();

  int responseCode = con.getResponseCode();
  System.out.println("Response Code : " + responseCode);
  BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
  String inputLine;
  StringBuffer response = new StringBuffer();
  while ((inputLine = in.readLine()) != null) {
      response.append(inputLine);
  }
  in.close();
  //println(response.toString());
        
  JsonObject myJson = new JsonParser().parse(response.toString()).getAsJsonObject();
  JsonArray myJArray = myJson.get("sentences").getAsJsonArray();
  JsonObject myJsonObject = myJArray.get(0).getAsJsonObject();
  
  processJsonDependencyTree(myJsonObject.get("enhancedPlusPlusDependencies").getAsJsonArray(), myJsonObject.get("tokens").getAsJsonArray());
}

/*---------------------------------------------------------------------------------------------------------------------
                                             process json dependency tree 
----------------------------------------------------------------------------------------------------------------------*/


void processJsonDependencyTree(JsonArray mJsonArray, JsonArray tokenJsonArray){
  
  String nsubj = "";
  String obj= "";
  String obl= "";
  String root= "";
  String caseIn= "";
  String acl= "";
  String conj= "";
  String nmod = "";
  String relTemp = "";
  String fixed = "";
  
  for( JsonElement object: mJsonArray){
    if(object.getAsJsonObject().get("dep").getAsString().equals("nsubj")){
        nsubj= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("obj")){
        obj= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().contains("obl")){
        obl= object.getAsJsonObject().get("dependentGloss").getAsString();
        relTemp = object.getAsJsonObject().get("dep").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("ROOT")){
        root= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("case")){
        caseIn = object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("acl")){
        acl = object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("conj")){
        conj= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().contains("nmod")){
        nmod= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("fixed")){
        fixed = fixed+"_"+object.getAsJsonObject().get("dependentGloss").getAsString();
    }
  }
  
  String relation;
  
  String[] objCase = relTemp.split(":");
  println(objCase.length);
  if(objCase.length==2){
     relation = objCase[1]; 
  }
  else{
    if(!fixed.equals("")){
       relation = caseIn+fixed;
    }
    else{
       relation = caseIn; 
    }
  }
  
  String[] subjects = new String[10];
  String object = "";
  String animation = "";
  
  subjects[0]="";
  
  
  //process object
  if(!obj.equals("") && getTag(obj, tokenJsonArray).equals("NN")){ 
    object = getLemma(obj,tokenJsonArray); 
  }
  else if(!obl.equals("") && getTag(obl, tokenJsonArray).equals("NN")){ 
    object = getLemma(obl,tokenJsonArray); 
  }
  else if(!nmod.equals("") && getTag(nmod, tokenJsonArray).equals("NN")){ 
    if(nmod.contains(":")){
        object = getLemma(nmod.split(":")[0],tokenJsonArray);
    }
    else{
        object = getLemma(nmod,tokenJsonArray);
    }
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).equals("NN")){ 
    object = getLemma(root,tokenJsonArray); 
    root = "";
  }
  
  //process subject
  int numOfSubjects = 1;
  if(!nsubj.equals("") && getTag(nsubj, tokenJsonArray).equals("NN")){ 
    subjects[0] = getLemma(nsubj,tokenJsonArray); 
  }
  else if(!nsubj.equals("") && getTag(nsubj, tokenJsonArray).equals("NNS")){ 
    numOfSubjects = (int)random(1,10);
    for(int i=0; i<numOfSubjects; i++){
      subjects[i] = getLemma(nsubj,tokenJsonArray); 
    }
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).equals("NN")){ 
    subjects[0] = getLemma(root,tokenJsonArray); 
    root = "";
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).equals("NNS")){ 
    numOfSubjects = (int)random(1,10);
    for(int i=0; i<numOfSubjects; i++){
      subjects[i] = getLemma(root,tokenJsonArray); 
    }
    root = "";
  }
  
  //process animation
  if(!acl.equals("") && getTag(acl, tokenJsonArray).contains("VB")){ 
    animation = getLemma(acl,tokenJsonArray); 
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).contains("VB")){ 
    animation = getLemma(root,tokenJsonArray);
    root = "";
  }
  
  for(int i=0; i<10; i++){
  
    if(subjects[i]==null && i!=0){break;}
    String subject = subjects[i];
  
    println("subject "+subject+"\nobject "+object+"\nrelation "+relation+"\nanimation "+animation);
  
    float scale = getScale(object);
    float scaleSub = getScale(subject);
    
    PVector offset = new PVector( 20*scale + getCaseInfo(relation,object).x,
                                  getCaseInfo(relation,object).y,
                                  getCaseInfo(relation,object).z);
                                  
    PVector near = new PVector( 20*scale + getCaseInfo("near",object).x,
                                getCaseInfo("near",object).y,
                                getCaseInfo("near",object).z);
  
    if(!animation.equals("")){
      // add object with animation
      int objInd = findInd(object);
      int subInd = findInd(subject);
  
        if(ifExist(object) && ifExist(subject) && numOfSubjects==1){
          Object mObject = getObject(subject);
          int objListIndex = objectList.indexOf(mObject);
          objectList.remove(objListIndex);
  
          Object Object = getObject(object);
          //PVector location = Object.getLoc();
          objectList.add(new Object(subject, mObject.location , object, animation, relation, subInd));
        }
        else if(ifExist(subject) && numOfSubjects==1){
          Object mObject = getObject(subject);
          int objListIndex = objectList.indexOf(mObject);
          objectList.remove(objListIndex);
  
          PVector location = new PVector((int)random(-500,500),(int)random(-500,500),0);
          if(objInd!=-1){
            objectList.add(new Object(object, location, objInd));
          }
          else{
            println(object+" does not exist in database");
          }
          objectList.add(new Object(subject, PVector.add(location,near) , object, animation, relation,subInd));
        }
        else if(ifExist(object)){
          Object mObject = getObject(object);
          PVector location = mObject.getLoc();
          if(subInd!=-1){
            objectList.add(new Object(subject, PVector.add(location,near) , object, animation, relation,subInd));
          }
          else{
            println(subject+" does not exist in database");
          }
        }
        else{
          PVector location = new PVector((int)random(-500,500),(int)random(-500,500),0);
          if(objInd!=-1){
            objectList.add(new Object(object, location, objInd));
          }
          else{
            println(object+" does not exist in database");
          }
          
          if(subInd!=-1){
            objectList.add(new Object(subject, PVector.add(location,near) , object, animation, relation,subInd));
          }else{
            println(subject+" does not exist in database");
          }
        }
    }
    else{
      //add object without animation
      int objInd = findInd(object);
      int subInd = findInd(subject);
  
        if(ifExist(object) && ifExist(subject) && numOfSubjects==1){
          Object mObject = getObject(subject);
          int objListIndex = objectList.indexOf(mObject);
          objectList.remove(objListIndex);
  
          Object Object = getObject(object);
          PVector location = Object.getLoc();
          objectList.add(new Object(subject, PVector.add(location,offset), subInd));
  
        }
        else if(ifExist(subject) && numOfSubjects==1){
          Object mObject = getObject(subject);
          int objListIndex = objectList.indexOf(mObject);
          objectList.remove(objListIndex);
  
          PVector location = new PVector((int)random(-500,500),(int)random(-500,500),0);
          if(objInd!=-1){
            objectList.add(new Object(object, location, objInd));
          }
          else{
            println(object+" does not exist in database");
          }
          objectList.add(new Object(subject, PVector.add(location,offset), subInd));
          
        }
        else if(ifExist(object)){
          println(object+" is der");
          Object mObject = getObject(object);
          PVector location = mObject.getLoc();
          if(subInd!=-1){
            //println(location);
            //println(offset);
            //println(PVector.add(location,offset));
            objectList.add(new Object(subject, PVector.add(location,offset), subInd));
          }
          else{
            println(subject+" does not exist in database");
          }
          
        }
        else{
          PVector location = new PVector((int)random(-500,500),(int)random(-500,500),0);
          if(objInd!=-1){
            objectList.add(new Object(object, location, objInd));
          }
          else{
            println(object+" does not exist in database");
          }
          
          if(subInd!=-1){
            objectList.add(new Object(subject, PVector.add(location,offset), subInd));
          }
          else{
            println(subject+" does not exist in database");
          }
          
        }
    }
  }
}
