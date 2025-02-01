import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/screens/account.dart';
import 'package:majdoor/screens/history.dart';
import 'package:majdoor/services/services.dart';
import 'package:majdoor/screens/wallet.dart';
import 'package:majdoor/widgets/Uihelper.dart';
import 'package:majdoor/services/bottumnavbar.dart';

class Labourer {
  final String name;
  final String location;
  final double reviews;
  final int Rs;
  final String photo;

  Labourer(this.name, this.location, this.reviews, this.Rs, this.photo);
}

class DashboardScreen extends StatelessWidget {
  final List<Labourer> labourers = [
    Labourer('Himanshu', 'Bihar, India', 4.5, 500, 'himanshu.png'),
    Labourer('Shaurya', 'Mumbai, India', 4.7, 600, 'shaurya.png'),
    Labourer('Lavish', 'Hyderabad, India', 4.9, 700, 'lavish.png'),
    Labourer('Prateek', 'Chennai, India', 4.6, 550, 'prateek.png'),
    Labourer('Vatan', 'Kolkata, India', 4.8, 620, 'vatan.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'Sangharsh',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet, color: Color(0xFF8A4FFF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WalletScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  style: GoogleFonts.roboto(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for Locations',
                    hintStyle: GoogleFonts.roboto(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF8A4FFF)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.schedule, color: Color(0xFF8A4FFF)),
                      onPressed: () {},
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  ),
                ),
              ),
            ),
            _buildSectionTitle('Quick Access'),
            _buildLocationTiles(context),
            _buildSectionTitle('Services'),
            _buildServiceIcons(context),
            _buildPromoCard(context),
            _buildSectionTitle('Top Rated Labourers'),
            _buildLabourersList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLocationTiles(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildLocationTile('Kharar', 'Mohali, Punjab'),
          SizedBox(height: 10),
          _buildLocationTile('Guru Teg Bahadur Nagar', 'Mohali Sector 122'),
        ],
      ),
    );
  }

  Widget _buildLocationTile(String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.roboto(color: Colors.grey),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF8A4FFF)),
      ),
    );
  }

  Widget _buildServiceIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceIcon(
                icon: Icons.handyman,
                label: 'Carpenter',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Carpenter'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.construction,
                label: 'Labourer',
                promo: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Labourer'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.electrical_services,
                label: 'Electrician',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Electrician'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.plumbing,
                label: 'Plumber',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Plumbing'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ServiceIcon(
                icon: Icons.cleaning_services,
                label: 'Cleaning',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Cleaning'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.home_repair_service,
                label: 'Repair',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Repair'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.person,
                label: 'Painting',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ServicesScreen(initialCategory: 'Painting'),
                  ),
                ),
              ),
              ServiceIcon(
                icon: Icons.more_horiz,
                label: 'More',
                onTap: () => Navigator.pushNamed(context, '/services'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8A4FFF), Color(0xFF5D3FD3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Terms & Conditions Apply',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            Icon(Icons.discount, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabourersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: labourers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFF8A4FFF), width: 2),
                        ),
                        child: ClipOval(
                          child: UiHelper.customimage(
                            imagepath: labourers[index].photo,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labourers[index].name,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Location: ${labourers[index].location}',
                              style: GoogleFonts.roboto(color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '${labourers[index].reviews}',
                                  style:
                                      GoogleFonts.roboto(color: Colors.amber),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.credit_card,
                                    color: Colors.white70, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '${labourers[index].Rs} Rupees/Day',
                                  style:
                                      GoogleFonts.roboto(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/booking',
                          arguments: labourers[index],
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF8A4FFF),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF1E1E1E),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color(0xFF8A4FFF),
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), label: 'Account'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DashboardScreen()));
            break;
          /*case 1:
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewScreen2()));
          break;*/
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookingHistoryScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AccountScreen()));
            break;
        }
      },
    );
  }
}

class ServiceIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool promo;
  final VoidCallback onTap;

  ServiceIcon({
    required this.icon,
    required this.label,
    this.promo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(icon, size: 40, color: Color(0xFF8A4FFF)),
                ),
                if (promo)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Text(
                        'Recommended',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ));
  }
}
