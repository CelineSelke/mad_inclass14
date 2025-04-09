import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState(){
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("normal_message");
    messaging.subscribeToTopic("important_message");

    messaging.getToken().then((value) {
      print("TOKEN");
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      print(event.data.values);
      late Color notificationColor;
      if(event.data['type'] == "normal"){
          notificationColor = Colors.lightBlue;
          playBell();
      }
      if(event.data['type'] == "important"){
        notificationColor = Colors.red;
        playSiren();
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(event.notification!.title!),
              content: SingleChildScrollView(child:Column(children:[Text(event.notification!.body!), Image.network(event.notification!.android!.imageUrl!)])),
              backgroundColor: notificationColor,
              actions: [Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  child: Text("Close", textAlign: TextAlign.center,),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if(event.data['type'] == "important") 
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.push(context, MaterialPageRoute(builder: (context) => TrolledScreen()));
                      }, 
                    child: Text("dude really this is so important check this out", textAlign: TextAlign.center,)
                  )
              ]),

          
              
              ],
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  void playBell() async {
    await audioPlayer.play(AssetSource('sounds/bell.wav'));
  }

    void playSiren() async {
    await audioPlayer.play(AssetSource('sounds/siren.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(child: Text("Messaging Tutorial")),
    );
  }
}

class TrolledScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trolled")

      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Row(mainAxisAlignment: MainAxisAlignment.center,children:[Text("i lied it isnt important get trolled"),])])
    );
  }
}