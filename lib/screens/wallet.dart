import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'package:majdoor/screens/razorpay_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Force refresh the wallet balance when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).loadSavedBalance();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _navigateToPayment(double amount) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayPaymentScreen(amount: amount),
      ),
    );

    if (result == true) {
      // Payment was successful, refresh wallet state
      Provider.of<WalletProvider>(context, listen: false).loadSavedBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, wallet, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            title: Text(
              'Wallet',
              style: GoogleFonts.montserrat(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: wallet.isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Card
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Balance',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '₹${wallet.balance.toStringAsFixed(2)}',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Quick Add Money Options
                        Text(
                          'Quick Add Money',
                          style: GoogleFonts.montserrat(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickAddButton(context, 100),
                            _buildQuickAddButton(context, 500),
                            _buildQuickAddButton(context, 1000),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Custom Amount
                        Text(
                          'Add Custom Amount',
                          style: GoogleFonts.montserrat(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            labelText: 'Enter Amount',
                            labelStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                            prefixText: '₹ ',
                            prefixStyle: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final amount =
                                  double.tryParse(_amountController.text);
                              if (amount != null && amount > 0) {
                                _navigateToPayment(amount);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Please enter a valid amount'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              'Add Money',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Payment Methods Section
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Methods',
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildPaymentMethodIcon(
                                      context, 'assets/icons/visa.png', 'Visa'),
                                  _buildPaymentMethodIcon(
                                      context,
                                      'assets/icons/mastercard.png',
                                      'Mastercard'),
                                  _buildPaymentMethodIcon(
                                      context, 'assets/icons/upi.png', 'UPI'),
                                  _buildPaymentMethodIcon(
                                      context,
                                      'assets/icons/netbanking.jpg',
                                      'NetBanking'),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Payments are securely processed via Razorpay. Your data is encrypted and secure.',
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Secure Payment',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Transaction History Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to transaction history
                              // You can implement this screen later
                            },
                            child: Text(
                              'View Transaction History',
                              style: GoogleFonts.montserrat(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildQuickAddButton(BuildContext context, int amount) {
    return InkWell(
      onTap: () {
        _navigateToPayment(amount.toDouble());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          '₹$amount',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(
      BuildContext context, String iconPath, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
