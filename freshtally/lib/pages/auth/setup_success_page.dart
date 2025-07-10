import 'package:flutter/material.dart';
import 'package:freshtally/pages/manager/home/manager_home_screen.dart';

class OrganizationSetupSuccessPage extends StatelessWidget {
  const OrganizationSetupSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual success animation widget
    Widget successIcon = const Icon(
      Icons.check_circle, // Or any other suitable icon
      color: Colors.green,
      size: 100.0,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: Center(child: successIcon)),
              const SizedBox(height: 24.0),
              const Text(
                'Supermarket Setup Successful!',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Your supermarket has been successfully set up. You can now proceed to the dashboard.',
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ManagerDashboardPage();
                      },
                    ),
                  );
                  // Navigate to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18.0),
                ),
                child: const Text('Continue to Dashboard'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
