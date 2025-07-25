import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Freshtally/pages/auth/create_supermarket_page.dart';
import 'package:Freshtally/pages/auth/customer_signup_page.dart';
import 'package:Freshtally/pages/auth/staff_signup_page.dart';
import 'package:Freshtally/pages/customer/home/customer_home_page.dart';
import 'package:Freshtally/pages/manager/home/manager_home_screen.dart';
import 'package:Freshtally/pages/shelfStaff/home/shelf_staff_home_screen.dart';
import 'package:Freshtally/pages/storeManager/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class IconTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const IconTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
  });