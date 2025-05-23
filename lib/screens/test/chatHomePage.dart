import 'package:chat_page/AppColorCodes.dart';
import 'package:chat_page/ChatHomeScreen/calls.dart';
import 'package:chat_page/ChatHomeScreen/recent_chats.dart';
import 'package:chat_page/ChatHomeScreen/people/active.dart';
//import 'package:chat_page/AppColorCodes.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 0;
  final List<Widget> _children = [Chats(),People(), Calls()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(color: pPrimaryColor),
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.messenger,), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.people,), label: "People"),
          BottomNavigationBarItem(icon: Icon(Icons.call,), label: "Calls"),
        ],
      ),
    );
  }
}