import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../secrets/supabase_secrets.dart';
import '../../init_dependencies.dart';

Future<bool> initializeApp() async {

  // //for manual testing to see how app handles the case of init failure
  //  try {
  //   throw Exception('Forced failure for manual test');
  //   // ...existing initialization code...
  // } catch (e) {
  //   // Log the error if needed
  //   debugPrint('Initialization failed: $e');
  //   return false;
  // }

  // handling error init with try/catch

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseSecrets.projectUrl,
      anonKey: SupabaseSecrets.anonKey,
    );
    
    // Initialize dependencies
    await initDependencies();
    
    return true;
  } catch (e) {
    // Log the error if needed
    debugPrint('Initialization failed: $e');
    return false;
  }
}