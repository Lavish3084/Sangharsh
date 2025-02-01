import 'package:flutter/material.dart';
import 'package:majdoor/screens/dashboard.dart';
import 'package:majdoor/screens/history.dart';
import 'package:majdoor/screens/account.dart';

class BottomNavBarFb2 extends StatelessWidget {
  const BottomNavBarFb2({Key? key}) : super(key: key);

  final primaryColor = const Color(0xff4338CA);
  final secondaryColor = const Color(0xff6D28D9);
  final accentColor = const Color(0xffffffff);
  final backgroundColor = const Color(0xffffffff);
  final errorColor = const Color(0xffEF4444);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.black,
      child: SizedBox(
        height: 60, // Increased height for better button display
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBottomBar(
                text: "Home",
                icon: Icons.home,
                selected: true,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  );
                },
              ),
              IconBottomBar(
                text: "Services",
                icon: Icons.room_service,
                selected: false,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  );
                },
              ),
              IconBottomBar(
                text: "History",
                icon: Icons.history,
                selected: false,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BookingHistoryScreen()),
                  );
                },
              ),
              IconBottomBar(
                text: "Profile", // New button added
                icon: Icons.account_circle_outlined,
                selected: false,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AccountScreen()), // Navigate to Account screen
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconBottomBar extends StatelessWidget {
  const IconBottomBar(
      {Key? key,
      required this.text,
      required this.icon,
      required this.selected,
      required this.onPressed})
      : super(key: key);

  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;

  final primaryColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 25,
            color: selected
                ? primaryColor
                : const Color.fromARGB(255, 74, 74, 74).withOpacity(.9),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            height: .1,
            color: selected
                ? primaryColor
                : const Color.fromARGB(255, 53, 61, 74).withOpacity(.9),
          ),
        ),
      ],
    );
  }
}
