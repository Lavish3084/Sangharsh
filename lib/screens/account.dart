import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/screens/dashboard.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  void _navigateToScreen(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          ),
        ),
        title: Text(
          'Account',
          style: GoogleFonts.roboto(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section with Merchant Info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    // Add your image here
                    backgroundImage: AssetImage('assets/photos/vatan.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Santraam',
                          style: GoogleFonts.roboto(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Thekedaar',
                          style: GoogleFonts.roboto(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // View Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToScreen(context, '/profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'View full profile',
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Business Management Section
              Text(
                'Bussiness Management',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildNavigationItem(
                context,
                'My bookings',
                '/bookings',
              ),
              _buildNavigationItem(
                context,
                'My messages',
                '/messages',
              ),
              _buildNavigationItem(
                context,
                'Job Listings',
                '/listings',
              ),
              _buildNavigationItem(
                context,
                'Worker Applications',
                '/applications',
              ),
              const SizedBox(height: 32),

              // Support Section
              Text(
                'Support',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildNavigationItem(
                context,
                'App feedback',
                '/feedback',
              ),
              _buildNavigationItem(
                context,
                'Help centre',
                '/help',
              ),
              _buildNavigationItem(
                context,
                'Report an Issue',
                '/report',
              ),
              _buildNavigationItem(
                context,
                'Business Support',
                '/business-support',
              ),
              const SizedBox(height: 32),

              // Preferences Section
              Text(
                'Preferences',
                style: GoogleFonts.roboto(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPreferenceItem(
                context,
                'Language',
                'English',
                '/language',
              ),
              _buildNavigationItem(
                context,
                'Notifications',
                '/notifications',
              ),
              _buildPreferenceItem(
                context,
                'Bussiness Location',
                'Mohali',
                '/location',
              ),
              _buildPreferenceItem(
                context,
                'Payment Methods',
                'Manage',
                '/payment-methods',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    String title,
    String route,
  ) {
    return InkWell(
      onTap: () => _navigateToScreen(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    String title,
    String value,
    String route,
  ) {
    return InkWell(
      onTap: () => _navigateToScreen(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: GoogleFonts.roboto(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
