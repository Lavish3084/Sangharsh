import 'package:flutter/material.dart';
import 'package:majdoor/screens/dashboard.dart';
import 'package:majdoor/screens/profiles/account.dart';
import 'package:majdoor/screens/services.dart'; // Make sure this is the right path
import 'package:majdoor/screens/chat/chat_dashboard.dart';  // Make sure this is the right path
import 'package:firebase_auth/firebase_auth.dart';

class IconBottomBar extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const IconBottomBar({
    Key? key,
    required this.text,
    required this.icon,
    this.selected = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 25,
            color: selected
                ? Theme.of(context).primaryColor
                : Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1,
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBarFb2 extends StatelessWidget {
  final int currentIndex; // 0: Home, 1: Search, 2: Chat, 3: Profile

  const BottomNavBarFb2({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      
      color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).cardColor,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconBottomBar(
              text: "Home",
              icon: Icons.home,
              selected: currentIndex == 0,
              onPressed: () {
                if (currentIndex != 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  );
                }
              },
            ),
            IconBottomBar(
              text: "Search",
              icon: Icons.search,
              selected: currentIndex == 1,
              onPressed: () {
                if (currentIndex != 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServicesScreen()),
                  );
                }
              },
            ),
            IconBottomBar(
              text: "Chat",
              icon: Icons.chat_bubble_outline,
              selected: currentIndex == 2,
              onPressed: () {
                if (currentIndex != 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatDashboard()),
                  );
                }
              },
            ),
            IconBottomBar(
              text: "Profile",
              icon: Icons.person_outline,
              selected: currentIndex == 3,
              onPressed: () {
                if (currentIndex != 3) {
                  User? user = FirebaseAuth.instance.currentUser;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountScreen(), // Pass user if needed
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
