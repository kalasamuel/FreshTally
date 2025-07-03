import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

class OrganizationSetupSuccessPage extends StatelessWidget {
  const OrganizationSetupSuccessPage({Key? key}) : super(key: key);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle copy to clipboard
                      Clipboard.setData(
                        const ClipboardData(text: 'Your Organization ID'),
                      ); // Replace with actual ID
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Organization ID copied to clipboard'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy ID'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
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
