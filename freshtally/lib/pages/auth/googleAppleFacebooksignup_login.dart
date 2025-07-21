// import 'package:flutter/material.dart';
// import 'package:freshtally/pages/auth/login_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// Future<void> _signInWithGoogle() async {
//   try {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return; // cancelled

//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential = await FirebaseAuth.instance.signInWithCredential(
//       credential,
//     );

//     await _handleSocialUser(userCredential.user!, 'google');
//   } catch (e) {
//     debugPrint('Google sign-in failed: $e');
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
//   }
// }

// // Future<void> _signInWithFacebook() async {
// //   try {
// //     final LoginResult result = await FacebookAuth.instance.login();

// //     if (result.status != LoginStatus.success) {
// //       throw Exception(result.message ?? 'Facebook login cancelled.');
// //     }

// //     final OAuthCredential credential = FacebookAuthProvider.credential(
// //       result.accessToken!.token,
// //     );

// //     final userCredential = await FirebaseAuth.instance.signInWithCredential(
// //       credential,
// //     );

// //     await _handleSocialUser(userCredential.user!, 'facebook');
// //   } catch (e) {
// //     debugPrint('Facebook sign-in failed: $e');
// //     ScaffoldMessenger.of(
// //       context,
// //     ).showSnackBar(SnackBar(content: Text('Facebook Sign-In failed: $e')));
// //   }
// // }

// Future<void> _signInWithGoogle() async {
//   try {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return; // cancelled

//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     final userCredential = await FirebaseAuth.instance.signInWithCredential(
//       credential,
//     );

//     await _handleSocialUser(userCredential.user!, 'google');
//   } catch (e) {
//     debugPrint('Google sign-in failed: $e');
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
//   }
// }
