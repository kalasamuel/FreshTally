import 'package:Freshtally/pages/auth/role_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Re-using IconTextField from your other files
class IconTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const IconTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        counterText: '',
      ),
    );
  }
}

class StaffVerificationPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final String userId;

  const StaffVerificationPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.userId,
  });

  @override
  State<StaffVerificationPage> createState() => _StaffVerificationPageState();
}

class _StaffVerificationPageState extends State<StaffVerificationPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();

  String? _selectedSupermarketId;
  String? _selectedSupermarketName;
  String? _selectedSupermarketLocation;
  List<DocumentSnapshot> _supermarketSearchResults = [];

  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  // --- Supermarket Search Logic ---
  Future<void> _onSearchChanged() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      setState(() {
        _supermarketSearchResults = [];
        _selectedSupermarketId = null;
        _selectedSupermarketName = null;
        _selectedSupermarketLocation = null;
        _errorMessage = null;
      });
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('supermarkets')
          .orderBy('name_lower')
          .startAt([searchText.toLowerCase()])
          .endAt(['${searchText.toLowerCase()}\uf8ff'])
          .get();

      setState(() {
        _supermarketSearchResults = querySnapshot.docs;
        if (_selectedSupermarketId != null &&
            !_supermarketSearchResults.any(
              (doc) => doc.id == _selectedSupermarketId,
            )) {
          _selectedSupermarketId = null;
          _selectedSupermarketName = null;
          _selectedSupermarketLocation = null;
        }
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error searching supermarkets: ${e.toString()}";
        });
      }
    }
  }

  void _selectSupermarket(DocumentSnapshot supermarketDoc) {
    setState(() {
      _selectedSupermarketId = supermarketDoc.id;
      _selectedSupermarketName =
          (supermarketDoc.data() as Map<String, dynamic>?)?['name'] ??
          'Unnamed Supermarket';
      _selectedSupermarketLocation =
          (supermarketDoc.data() as Map<String, dynamic>?)?['location'] ??
          'No location';
      _supermarketSearchResults = [];
      _searchController.text = _selectedSupermarketName!;
      _errorMessage = null;
    });
    FocusScope.of(context).unfocus();
  }

  // --- Join Code Verification and Account Creation Logic ---
  Future<void> _verifyJoinCodeAndCreateStaffAccount() async {
    if (_selectedSupermarketId == null) {
      setState(() {
        _errorMessage = 'Please select a supermarket first.';
      });
      return;
    }

    final enteredJoinCode = _joinCodeController.text.trim();

    if (enteredJoinCode.length != 6) {
      setState(() {
        _errorMessage = 'Join code must be exactly 6 digits.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final joinCodeDoc = await _firestore
          .collection('supermarkets')
          .doc(_selectedSupermarketId!)
          .collection('meta')
          .doc('join_code')
          .get();

      if (!joinCodeDoc.exists) {
        throw Exception("No join code found for this supermarket.");
      }

      final joinCodeData = joinCodeDoc.data();
      final storedCode = joinCodeData?['code'];
      final expiresAtTimestamp = joinCodeData?['expiresAt'] as Timestamp?;

      if (storedCode == null || storedCode != enteredJoinCode) {
        throw Exception("Invalid join code.");
      }
      if (expiresAtTimestamp != null &&
          expiresAtTimestamp.toDate().isBefore(DateTime.now())) {
        throw Exception("Join code has expired.");
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );
      final user = userCredential.user;

      if (user == null) {
        throw Exception("User creation failed. No user object returned.");
      }

      final String uid = user.uid;

      await _firestore
          .collection('supermarkets')
          .doc(_selectedSupermarketId!)
          .collection('users')
          .doc(uid)
          .set({
            'uid': uid,
            'firstName': widget.firstName,
            'lastName': widget.lastName,
            'email': widget.email,
            'phone': widget.phone,
            'role': 'unassigned',
            'supermarketId': _selectedSupermarketId!,
            'supermarketName': _selectedSupermarketName,
            'joinedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          });

      await _firestore
          .collection('supermarkets')
          .doc(_selectedSupermarketId!)
          .update({'staffCount': FieldValue.increment(1)});

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification successful! Proceed to role selection.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSelectionPage(
            supermarketId: _selectedSupermarketId!,
            // The role passed here is just a placeholder, the actual role
            // selection happens inside RoleSelectionPage.
            role: 'unassigned',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _getAuthErrorMessage(e.code);
      });
      debugPrint(
        'FirebaseAuthException during staff verification: ${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint('Error during staff verification (general catch): $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Signup failed: $code. Please try again.';
    }
  }

  // --- QR Code Scanning Logic ---
  Future<void> _scanQrCode() async {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result != null && result.isNotEmpty) {
      if (result.length == 6 && int.tryParse(result) != null) {
        _joinCodeController.text = result;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Join code scanned. Please select your supermarket above.',
            ),
          ),
        );
      } else {
        _searchController.text = result;
        await _onSearchChanged();

        if (_supermarketSearchResults.isNotEmpty) {
          final matchedDoc = _supermarketSearchResults.firstWhere(
            (doc) =>
                doc.id == result ||
                (doc.data() as Map<String, dynamic>?)?['name']?.toLowerCase() ==
                    result.toLowerCase(),
            orElse: () => _supermarketSearchResults
                .first, // Fallback to first if exact ID/name not found
          );
          _selectSupermarket(matchedDoc);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Supermarket "${_selectedSupermarketName!}" pre-filled. Enter join code.',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Scanned QR code: "$result" did not match any supermarket. Please search manually.',
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR scan cancelled or no data found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Join Supermarket',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Find your Supermarket and enter the Join Code.",
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),

              // --- Supermarket Search Field ---
              IconTextField(
                hintText: 'Search Supermarket Name',
                icon: Icons.store,
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
              ),
              const SizedBox(height: 10),

              // --- Supermarket Search Results (dynamic height) ---
              if (_supermarketSearchResults.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _supermarketSearchResults.length,
                    itemBuilder: (context, index) {
                      final doc = _supermarketSearchResults[index];
                      final name =
                          (doc.data() as Map<String, dynamic>?)?['name'] ??
                          'Unnamed Supermarket';
                      final location =
                          (doc.data() as Map<String, dynamic>?)?['location'] ??
                          'No location';
                      return ListTile(
                        title: Text(name),
                        subtitle: Text(location),
                        onTap: () => _selectSupermarket(doc),
                        selected: _selectedSupermarketId == doc.id,
                        selectedTileColor: Colors.green.withOpacity(0.1),
                      );
                    },
                  ),
                )
              else if (_searchController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No supermarkets found matching your search.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 20),

              // --- Display Selected Supermarket & Join Code Input ---
              if (_selectedSupermarketId != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selected: ${_selectedSupermarketName!} (${_selectedSupermarketLocation!})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Enter the 6-digit Join Code provided by your manager:",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    IconTextField(
                      hintText: 'Enter 6-digit Join Code',
                      icon: Icons.lock_open,
                      controller: _joinCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Join code is required';
                        }
                        if (value.length != 6) {
                          return 'Code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _verifyJoinCodeAndCreateStaffAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 17.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.0),
                        ),
                        elevation: 1,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Verify & Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20.0),

                    TextButton(
                      onPressed: _isLoading ? null : _scanQrCode,
                      child: Text(
                        'Scan QR Code Instead',
                        style: TextStyle(color: Colors.blue[700], fontSize: 16),
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Start typing above to find your supermarket.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- New QRScannerPage for the QR code functionality ---
class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();

  // We need to store the current state of torch and camera facing locally
  // and update them after each toggle operation.
  // Initialize with reasonable defaults.
  bool _isTorchOn = false;
  CameraFacing _currentCameraFacing = CameraFacing.back;

  // This flag helps prevent multiple pop calls if a barcode is detected rapidly
  bool _isScanCompleted = false;

  @override
  void initState() {
    super.initState();
    // It's good practice to try and get the initial state,
    // though cameraController.start() might be required first.
    // For this use case, we'll assume default off and back.
    // The state will primarily be updated by calling toggleTorch/switchCamera.
    _initializeCameraState();
  }

  Future<void> _initializeCameraState() async {
    // This part is tricky with mobile_scanner 7.x.x
    // There isn't a direct way to *read* the current torchState or cameraFacingState
    // from the controller *before* an event or interaction.
    // The most reliable way is to track it ourselves based on button presses
    // and rely on the default initial states of the camera.
    // We'll update the local state when the user toggles.

    // A more robust solution for getting initial state might involve
    // checking permissions and then starting the camera,
    // then potentially querying internal camera properties if exposed by the plugin.
    // For now, we'll assume default starting states.
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.grey,
            ),
            onPressed: () async {
              // Toggle torch and update local state
              await cameraController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(
              _currentCameraFacing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
            ),
            onPressed: () async {
              // Switch camera and update local state
              await cameraController.switchCamera();
              setState(() {
                _currentCameraFacing =
                    _currentCameraFacing == CameraFacing.front
                    ? CameraFacing.back
                    : CameraFacing.front;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            // onStart: (arguments) {
            //   // Use onStart to get the initial camera facing if needed,
            //   // but torch state is not part of MobileScannerArguments.
            //   if (mounted) {
            //     setState(() {
            //       _currentCameraFacing = arguments.cameraFacing;
            //       // _isTorchOn cannot be directly read here.
            //     });
            //   }
            // },
            onDetect: (capture) {
              if (!_isScanCompleted) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final barcode = barcodes.first;
                  if (barcode.rawValue != null) {
                    _isScanCompleted = true; // Prevent multiple detections
                    Navigator.pop(context, barcode.rawValue);
                  }
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.qr_code_scanner, size: 80, color: Colors.white70),
                  Text(
                    'Scan Supermarket QR Code',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
