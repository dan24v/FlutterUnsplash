import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Галерея изображений'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class UnsplashUser{
  final String name;

  UnsplashUser({
    this.name,
  }) ;

  factory UnsplashUser.fromJson(Map<String, dynamic> json){
    return new UnsplashUser(
      name: json['name'],
    );
  }
}


class UnsplashUrls{
  final String small;
  final String regular;
  final String full;

  UnsplashUrls({
    this.small,
    this.regular,
    this.full
  }) ;

  factory UnsplashUrls.fromJson(Map<String, dynamic> json){
    return new UnsplashUrls(
      small: json['small'],
      regular: json['regular'],
      full: json['full'],
    );
  }
}

class UnsplashImg{
  final String id;
  final String description;
  final String alt_description;
  final UnsplashUrls urls;
  final UnsplashUser user;

  UnsplashImg({
    this.id,
    this.description,
    this.alt_description,
    this.urls,
    this.user
  }) ;

  factory UnsplashImg.fromJson(Map<String, dynamic> json){
    return new UnsplashImg(
      id: json['id'].toString(),
      description: json['description'],
      alt_description: json['alt_description'],
      urls: UnsplashUrls.fromJson(json['urls']),
      user: UnsplashUser.fromJson(json['user']),
    );
  }
}

class UnsplashImgList {
  final List<UnsplashImg> imgs;

  UnsplashImgList({
    this.imgs,
  });

  factory UnsplashImgList.fromJson(List<dynamic> parsedJson) {

    List<UnsplashImg> imgs = new List<UnsplashImg>();
    imgs = parsedJson.map((i)=>UnsplashImg.fromJson(i)).toList();

    return new UnsplashImgList(
      imgs: imgs,
    );
  }
}


class FullImgPage extends StatelessWidget{
  final UnsplashImg img;

  FullImgPage(this.img);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: 'Галерея изображений')));
          },
          child: Center(
           child:  Image.network(
               img.urls.full,
               fit: BoxFit.cover
           ),
          ),
        )
      )

    );
  }

}



class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var REQUEST_URL = "https://api.unsplash.com/photos/?client_id=cf49c08b444ff4cb9e4d126b7e9f7513ba1ee58de7906e4360afc1a33d1bf4c0";

  Future <List<UnsplashImg>> getImgs() async{
    var unsplashImgList;
    var jsonData = "";

     var response = await http.get(REQUEST_URL).then((response) {
       var parsedJson = json.decode(response.body);
       unsplashImgList = UnsplashImgList.fromJson(parsedJson);

    }).catchError((error){
      print("Error: $error");
    });


    return unsplashImgList.imgs;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: FutureBuilder(
          future: getImgs(),
          builder: (BuildContext context, AsyncSnapshot snap){
            if(snap.data == null || snap.data.length < 1){
              return Container(
                child: Center(
                  child: Text("Загрузка изображений...")
                )
              );
            } else{
            return ListView.builder(
              itemCount: snap.data.length,
              itemBuilder: (BuildContext context, int index){
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FullImgPage(snap.data[index])),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text("Автор:"+snap.data[index].user.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        Image.network(
                            snap.data[index].urls.small,
                            width: 600.0,
                            height: 240.0,
                            fit: BoxFit.cover
                        ),
                        if(snap.data[index].description != null) Text(snap.data[index].description)
                        else if(snap.data[index].alt_description != null) Text(snap.data[index].alt_description)
                        else Text("Описание отсутствует...")
                      ],
                    ),



                  ),
                );
              },
            );
            }
          },
        ),

      ),
    );
  }
}
