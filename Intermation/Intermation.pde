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

WebsocketServer socket;

int numberofObject = 345;
String[] names = new String[345];
QuickDraw[] qd = new QuickDraw[345];
float end, x;


//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class Object{
  String name;
  PVector location;
  int ind;
  Object(String name, PVector location, int index){
    this.name = name;
    this.location = location;
    this.ind = index;
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
}


//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ArrayList<Object> objectList = new ArrayList();

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void setup(){
  size(500,500,P2D);
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
  
  String msg = "bird is standing on the banana";
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
  
  background(245);
 
  for(Object obj : objectList){
    int ind = obj.getIndex();
    PVector loc = obj.getLoc();
    qd[ind].create(loc.x,loc.y, 100,100);
    
  }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

void processJsonOpenIE(JsonObject openieJsonArray,JsonArray tokenJsonArray){
  if(openieJsonArray.size()==0){
     println("cound not understand object relation");
  }
  else{
    String object = openieJsonArray.get("object").getAsString();
    String subject = openieJsonArray.get("subject").getAsString();
    String relation = openieJsonArray.get("relation").getAsString();
    
    if(relation.contains("on")){
      int obj = findInd(object);
      int sub = findInd(subject);
      
      if(obj!=-1 && sub!=-1){
        if(ifExist(object) && ifExist(subject)){
          Object mObject = getObject(object);
          PVector tempObj = mObject.getLoc();
          
          Object mSubject = getObject(subject);

          int objListIndex = objectList.indexOf(mSubject);
          objectList.remove(objListIndex);
          objectList.add(new Object(subject,new PVector(tempObj.x,(tempObj.y)-50),sub));
        }
        else if(ifExist(object)){
          Object mObject = getObject(object);
          PVector temp = mObject.getLoc();
          objectList.add(new Object(subject,new PVector(temp.x,temp.y-50),sub));
        }
        else if(ifExist(subject)){
          Object mObject = getObject(subject);
          PVector temp = mObject.getLoc();
          objectList.add(new Object(object,new PVector(temp.x,temp.y+50),obj));
        }
        else{
          float x = random(50,450);
          float y = random(50,450);
          objectList.add(new Object(object,new PVector(x,y),obj));
          objectList.add(new Object(subject,new PVector((x),(y)-50),sub));
        }
      }
      else{
        println("does not exist in the dataset");        
      }
    }
    
  }
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
  
  processJsonOpenIE(myJsonObject.get("openie").getAsJsonArray().get(0).getAsJsonObject(),  myJsonObject.get("tokens").getAsJsonArray());
  
}
