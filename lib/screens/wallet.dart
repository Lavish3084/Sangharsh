import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatefulWidget {
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Custom color scheme for dark theme
  final Color primaryColor = const Color(0xFFECECEC);
  final Color accentColor = const Color(0xFF00B894);
  final Color backgroundColor = const Color(0xFF1A1A1A);
  final Color cardColor = const Color(0xFF2D2D2D);

  String? selectedAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wallet Cash',
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₹0',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureItem(Icons.flash_on, 'Easy & Fast\nPayments'),
                _buildFeatureItem(Icons.refresh, 'Instant\nRefunds'),
                _buildFeatureItem(Icons.local_offer, 'Exclusive\nOffers'),
              ],
            ),
            SizedBox(height: 32.0),
            Text(
              'Add Money to Wallet',
              style: GoogleFonts.poppins(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              style: GoogleFonts.poppins(color: primaryColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cardColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cardColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor),
                ),
                filled: true,
                fillColor: cardColor,
                labelText: 'Enter Amount',
                labelStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: Icon(Icons.currency_rupee, color: accentColor),
              ),
            ),
            SizedBox(height: 16.0),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                _buildAmountChip('₹500', isSelected: selectedAmount == '₹500'),
                _buildAmountChip('₹1000',
                    isSelected: selectedAmount == '₹1000'),
                _buildAmountChip('₹2000',
                    isSelected: selectedAmount == '₹2000'),
                _buildAmountChip('₹5000',
                    isSelected: selectedAmount == '₹5000'),
              ],
            ),
            SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Add Balance',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: primaryColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(String amount, {bool isSelected = false}) {
    return ChoiceChip(
      label: Text(
        amount,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedColor: accentColor,
      backgroundColor: cardColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (bool selected) {
        setState(() {
          selectedAmount = selected ? amount : null;
        });
      },
    );
  }
}
