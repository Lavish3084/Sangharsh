
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:majdoor/main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.4 , vertical: 4),
      elevation:  0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell( onTap:(){
      
      
      } ,   child: ListTile(
         leading: CircleAvatar(child: Icon(CupertinoIcons.person),),
          title: Text('demo user'),
          subtitle: Text('last user message', maxLines: 1,),
          trailing: Text('12:00 PM',
          style: TextStyle(
      
            color: Colors.white
          ),),
      
      ),),
    );
  }
}