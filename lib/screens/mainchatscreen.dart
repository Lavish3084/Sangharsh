import 'package:flutter/material.dart';
import 'package:majdoor/widgets/chat_user_card.dart';
import 'package:majdoor/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: ListView.builder(
        itemCount: 10,
        padding: EdgeInsets.only(top: mq.height * 0.01),
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return ChatUserCard(); // No data passing
        },
      ),
    );
  }
}
