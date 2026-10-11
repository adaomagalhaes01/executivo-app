import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFF2B71), size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'NICE TO MEET YOU,\nADÃO !',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Montserrat',
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 48),
              
              // First Name Field
              const Text(
                'Adão',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Color(0xFF2C2C2E), thickness: 1, height: 24),
              const Text(
                'Displayed to whom you share a ride with',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              
              const SizedBox(height: 32),
              
              // Last Name Field
              Row(
                children: [
                  const Text(
                    'Magalhães',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 2),
                    width: 2,
                    height: 20,
                    color: Colors.white,
                  )
                ],
              ),
              const Divider(color: Color(0xFF2C2C2E), thickness: 1, height: 24),
              const Text(
                'Only used to generate invoices',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              
              const SizedBox(height: 48),
              
              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2B71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
