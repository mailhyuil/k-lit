import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    print('Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file');
    exit(1);
  }

  // Initialize Supabase client
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final supabase = Supabase.instance.client;
  const bucket = 'story-contents';

  // Define file paths
  final contentFile = File(
    'supabase/sample_contents/arabic/lucky_day/content.txt',
  );
  final metaFile = File('supabase/sample_contents/arabic/lucky_day/_meta.json');

  final remoteContentPath = 'arabic/lucky_day/content.txt';
  final remoteMetaPath = 'arabic/lucky_day/_meta.json';

  // --- Upload content.txt ---
  try {
    print('Uploading content.txt...');
    final content = await contentFile.readAsString();
    await supabase.storage
        .from(bucket)
        .upload(
          remoteContentPath,
          contentFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true, // Overwrite if it exists
          ),
        );
    print('✅ Successfully uploaded content.txt');
  } catch (e) {
    print('❌ Error uploading content.txt: $e');
    exit(1);
  }

  // --- Upload _meta.json ---
  try {
    print('Uploading _meta.json...');
    await supabase.storage
        .from(bucket)
        .upload(
          remoteMetaPath,
          metaFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true, // Overwrite if it exists
          ),
        );
    print('✅ Successfully uploaded _meta.json');
  } catch (e) {
    print('❌ Error uploading _meta.json: $e');
    exit(1);
  }

  print('🎉 All files uploaded successfully!');
}
