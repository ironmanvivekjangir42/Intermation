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
import cbl.quickdraw.*;
import java.lang.*;
import peasy.*;



//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
  
  int r=0;
  
  //constructor to add object at a location
  Object(String name, PVector location, int index){
    this.name = name;
    this.ind = index;
    this.location = location;
    this.animation = "";
    this.destination = "";
  }
  //constructor to add if animation and destination is known
  Object(String name, PVector location, String destination,String animation, String Case,int index){
    this.name = name;
    this.location = location;
    this.destination = destination;
    this.ind = index;
    this.animation = animation;
    this.Case = Case;
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
    for(Object obj: objectList){
      if(obj.getName().equals(destination)){
        
        if(isStatic(animation)){
          this.location = obj.getLoc();
        }
        else{
          int motionType = getMotion(Case);
          
          if(motionType==0){//towards
            PVector dest = obj.getLoc();
            PVector tempLoc = PVector.sub(dest,location);
            tempLoc.x = Integer.signum((int)(tempLoc.x));
            tempLoc.y = Integer.signum((int)(tempLoc.y));
          
            this.location = PVector.add(location,tempLoc);
          }
          else if(motionType==1){//away
            PVector dest = obj.getLoc();
            PVector tempLoc = PVector.sub(dest,location);
            tempLoc.x = -Integer.signum((int)(tempLoc.x));
            tempLoc.y = -Integer.signum((int)(tempLoc.y));
          
            this.location = PVector.add(location,tempLoc);
          }
          else if(motionType==2){//around
            
            PVector dest = obj.getLoc();
            int radius = 150;
            int x = (int)(radius*cos(radians(r)));
            int y = (int)(radius*sin(radians(r)));
            r=(r+2)%360;
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
            PVector dest = obj.getLoc();
            dest.mult(2);
            PVector tempLoc = PVector.sub(dest,location);
            tempLoc.x = Integer.signum((int)(tempLoc.x));
            tempLoc.y = Integer.signum((int)(tempLoc.y));
          
            this.location = PVector.add(location,tempLoc);
          }
          else{//random motion
            PVector dest = new PVector(random(-500,500), random(-500,500), 0);
            PVector tempLoc = PVector.sub(dest,location);
            tempLoc.x = Integer.signum((int)(tempLoc.x));
            tempLoc.y = Integer.signum((int)(tempLoc.y));
          
            this.location = PVector.add(location,tempLoc);
          }
        }
      }
    }
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WebsocketServer socket;

int numberofObject = 345;
String[] names = new String[345];
QuickDraw[] qd = new QuickDraw[345];
float end, x;
PeasyCam cam;
CameraState state;
int min = 0;

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ArrayList<Object> objectList = new ArrayList();


//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void setup(){
  size(1000,1000,P3D);
  cam = new PeasyCam(this,2000);
  state = cam.getState();
  
  socket = new WebsocketServer(this, 1337, "/p5websocket");
  
  println("setup function");
  
  String path = sketchPath()+"/finaldraw/";
  names = listFileNames(path);
  
  printArray(names);
  println("Loading Dataset");
  
  for(int i=0; i<345; i++){
    try{
      println("finaldraw/"+names[i]);
      qd[i] = new QuickDraw(this, "finaldraw/"+names[i]);
    }
    catch(Exception e){
      println("Failed to load hhhhh  " +names[i]);
      println(e);
    }
  }
  
  println("Done Loading");
  
  String msg = "bird is on banana";
  
  println(msg);
  if(msg.length()>0){
    try{
      stanfordNLP(msg);
    }
    catch(Exception e){
       println("Exception while processing"); 
    }
  }
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

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void draw() {
  
  background(230);
  
  fill(255);
  beginShape();
  vertex(1000, min+75, 1000);
  vertex(1000, min+75, -1000);
  vertex(-1000, min+75, -1000);
  vertex(-1000, min+75, 1000);
  
  endShape(CLOSE);
 
  for(Object obj : objectList){
    obj.update();
    int ind = obj.getIndex();
    PVector loc = obj.getLoc();
    
    translate(0,0,loc.y);
    qd[ind].create(loc.x,loc.z, 100,100);
    translate(0,0,-loc.y);
    
  }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

public void keyReleased() {
  if (key == '1') state = cam.getState();
  if (key == '2') cam.setState(state, 1000);
}

void webSocketServerEvent(String msg){
  //println("abcd");
  println(msg);
  if(msg.length()>0){
    try{
      stanfordNLP(msg);
      
    }
    catch(Exception e){
       println("Exception while processing"); 
    }
  }
}

int getMotion(String Case){
  if(Case.equals("to") || Case.equals("towards") || Case.equals("into") || Case.equals("onto") || Case.equals("under")){
    return 0;
  }
  else if(Case.equals("away") || Case.equals("from") || Case.equals("off of") || Case.equals("out of") || Case.equals("out") || Case.equals("outside") || Case.equals("outdoors")){
    return 1;
  }
  else if(Case.equals("around") || Case.equals("round") || Case.equals("revolve")){
    return 2;
  }
  else if(Case.equals("against")){
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
  else if(Case.equals("front") || Case.equals("forward")){
    return 8;
  }
  else if(Case.equals("back") || Case.equals("backwardsd")){
    return 9;
  }
  else if(Case.equals("across") || Case.equals("over") || Case.equals("through") || Case.equals("by")){
    return 10;
  }
  return 2; 
}

PVector getCaseInfo(String relation){
  PVector pos = new PVector(0,0,0);
  if(relation.equals("on")){
    pos.z = -75;
  }
  else if(relation.equals("above")){
    pos.z = -random(110,300);
  }
  else if(relation.equals("over")){
    pos.z = -random(75,250);
  }
  else if(relation.equals("against") || relation.equals("beside") || relation.equals("by")){
    int rand = (int)random(0,1);
    if(rand==1){
      pos.x = 100;
    }
    else{
      pos.x = -100;
    }
  }
  else if(relation.equals("behind")){
    pos.y = -100;
  }
  else if(relation.equals("below")){
    pos.z = 50;
  }
  else if(relation.equals("beneath") || relation.equals("underneath") || relation.equals("under")){
    pos.z = random(75, 250);
  }
  else if(relation.equals("in front of")){
    pos.y = 100;
  }
  else if(relation.equals("inside") || relation.equals("in") || relation.equals("into")){
    pos = new PVector(0,0,0);
  }
  else if(relation.equals("near")){
    int x = (int)random(-300,300);
    int y = (int)random(-300,300);
    pos.x = x;
    pos.y = y;
  }
  else if(relation.equals("next to")){
    int x = (int)random(-150,150);
    int y = (int)random(-150,150);
    pos.x = x;
    pos.y = y;
  }
  return pos;
}

String getTag(String text, JsonArray tokenJsonArray){
  for(JsonElement obj: tokenJsonArray){
     if(obj.getAsJsonObject().get("word").getAsString().equals(text)){
        return obj.getAsJsonObject().get("pos").getAsString();
     }
  }
  return null;
}
String getLemma(String text, JsonArray tokenJsonArray){
  for(JsonElement obj: tokenJsonArray){
     if(obj.getAsJsonObject().get("word").getAsString().equals(text)){
        return obj.getAsJsonObject().get("lemma").getAsString();
     }
  }
  return text;
}

Boolean isStatic(String animation){
  String[] motionVerbs = {"walk","run","move", "jump","hop","bounce","drag","fly","revolve","chase","follow"};
  for(String s: motionVerbs){
    if(animation.equals(s)){return false;}
  }
  return true;
}

Boolean ifExist(String object){
  for(Object obj : objectList){
    String item = obj.getName();
    if(item.equals(object)){
      return true;
    }
  }
  return false;
}

Boolean ifExistInDatabase(String object){
  for(int i=0; i<345; i++){
    if(names[i].equals(object+".ndjson")){
      return true;
    }
  }
  return false;
}

Object getObject(String name){
  for(Object obj : objectList){
    String item = obj.getName();
    if(item.equals(name)){
      return obj;
    }
  }
  return null;
}

int findInd(String name){
  for(int i=0; i<345; i++){
    if(names[i].equals(name+".ndjson")){
      return i;
    }
  }
  return -1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
  println(myJsonObject.get("openie").getAsJsonArray());
  println(myJsonObject.get("tokens").getAsJsonArray());
  
  for(JsonElement jsonElement : myJsonObject.get("openie").getAsJsonArray()){
    //processJsonOpenIE(myJsonObject.get("openie").getAsJsonArray().get(0).getAsJsonObject(),  myJsonObject.get("tokens").getAsJsonArray());
    //processJsonOpenIE(jsonElement.getAsJsonObject(),  myJsonObject.get("tokens").getAsJsonArray());
  }
  processJsonDependencyTree(myJsonObject.get("basicDependencies").getAsJsonArray(), myJsonObject.get("tokens").getAsJsonArray());
}

void processJsonDependencyTree(JsonArray mJsonArray, JsonArray tokenJsonArray){
  String nsubj = "";
  String obj= "";
  String obl= "";
  String root= "";
  String caseIn= "";
  String acl= "";
  String conj= "";
  
  for( JsonElement object: mJsonArray){
    if(object.getAsJsonObject().get("dep").getAsString().equals("nsubj")){
        nsubj= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("obj")){
        obj= object.getAsJsonObject().get("dependentGloss").getAsString();
    }
    if(object.getAsJsonObject().get("dep").getAsString().equals("obl")){
        obl= object.getAsJsonObject().get("dependentGloss").getAsString();
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
  }
  
  String subject = "";
  String object = "";
  String relation = caseIn;
  String animation = "";
  
  //process object
  if(!obj.equals("") && getTag(obj, tokenJsonArray).equals("NN")){ 
    object = getLemma(obj,tokenJsonArray); 
  }
  else if(!obl.equals("") && getTag(obl, tokenJsonArray).equals("NN")){ 
    object = getLemma(obl,tokenJsonArray); 
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).equals("NN")){ 
    object = getLemma(root,tokenJsonArray); 
    root = "";
  }
  
  //process subject
  if(!nsubj.equals("") && getTag(nsubj, tokenJsonArray).equals("NN")){ 
    subject = getLemma(nsubj,tokenJsonArray); 
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).equals("NN")){ 
    subject = getLemma(root,tokenJsonArray); 
    root = "";
  }
  
  //process animation
  if(!acl.equals("") && getTag(acl, tokenJsonArray).equals("VBG")){ 
    animation = getLemma(acl,tokenJsonArray); 
  }
  else if(!root.equals("") && getTag(root, tokenJsonArray).equals("VBG")){ 
    animation = getLemma(root,tokenJsonArray);
    root = "";
  }
  
  println("subject "+subject+"\nobject "+object+"\nrelation "+relation+"\nanimation "+animation);

  PVector offset = getCaseInfo(relation);
  PVector near = getCaseInfo("near");

  if(!animation.equals("")){
    // add object with animation
    int objInd = findInd(object);
    int subInd = findInd(subject);

      if(ifExist(object) && ifExist(subject)){
        Object mObject = getObject(subject);
        int objListIndex = objectList.indexOf(mObject);
        objectList.remove(objListIndex);

        Object Object = getObject(object);
        PVector location = Object.getLoc();
        objectList.add(new Object(subject, PVector.add(location,near) , object, animation, relation, subInd));
        
        if(location.z>min){min = (int)location.z;}

      }
      else if(ifExist(subject)){
        Object mObject = getObject(subject);
        int objListIndex = objectList.indexOf(mObject);
        objectList.remove(objListIndex);

        PVector location = new PVector((int)random(-500,500),(int)random(-500,500),0);
        if(location.z>min){min = (int)location.z;}
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
        if(location.z>min){min = (int)location.z;}
        if(subInd!=-1){
          objectList.add(new Object(subject, PVector.add(location,near) , object, animation, relation,subInd));
        }
        else{
          println(subject+" does not exist in database");
        }
      }
      else{
        PVector location = new PVector((int)random(-500,500),(int)random(-500,500),0);
        if(location.z>min){min = (int)location.z;}
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

      if(ifExist(object) && ifExist(subject)){
        Object mObject = getObject(subject);
        int objListIndex = objectList.indexOf(mObject);
        objectList.remove(objListIndex);

        Object Object = getObject(object);
        PVector location = Object.getLoc();
        objectList.add(new Object(subject, PVector.add(location,offset), subInd));
        if(location.z>min){min = (int)location.z;}
        if(PVector.add(location,offset).z>min){min = (int)PVector.add(location,offset).z;}

      }
      else if(ifExist(subject)){
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
        if(location.z>min){min = (int)location.z;}
        if(PVector.add(location,offset).z>min){min = (int)PVector.add(location,offset).z;}
      }
      else if(ifExist(object)){
        Object mObject = getObject(object);
        PVector location = mObject.getLoc();
        if(subInd!=-1){
          objectList.add(new Object(subject, PVector.add(location,offset), subInd));
        }
        else{
          println(subject+" does not exist in database");
        }
        if(location.z>min){min = (int)location.z;}
        if(PVector.add(location,offset).z>min){min = (int)PVector.add(location,offset).z;}
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
        if(location.z>min){min = (int)location.z;}
        if(PVector.add(location,offset).z>min){min = (int)PVector.add(location,offset).z;}
      }
  }
}
