import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_client.dart';
import '../models/story_content.dart';

/// Supabase Storage에서 작품 콘텐츠 다운로드 서비스
///
/// Storage 구조:
/// story-contents/
/// └── arabic/{story_name}/
///     ├── content.txt      ← 본문
///     └── _meta.json       ← {"version": 1}
class StoryStorageService {
  static const String _bucketName = 'story-contents';

  /// Storage에서 콘텐츠 다운로드
  ///
  /// contentUrl 형식: 'arabic/lucky_day' (폴더 경로)
  Future<StoryContent> downloadContent(String contentUrl) async {
    try {
      debugPrint('📥 Downloading content from Storage: $contentUrl');

      // 1. 메타데이터 다운로드 (_meta.json)
      final metaPath = '$contentUrl/_meta.json';
      final metaBytes = await SupabaseService.instance.storage.from(_bucketName).download(metaPath);

      final metaString = utf8.decode(metaBytes);
      final meta = StoryMeta.fromJsonString(metaString);

      debugPrint('✅ Meta downloaded: version ${meta.version}');

      // 2. 본문 다운로드 (content.txt)
      final contentPath = '$contentUrl/content.txt';
      final contentBytes = await SupabaseService.instance.storage
          .from(_bucketName)
          .download(contentPath);

      final bodyText = utf8.decode(contentBytes);

      debugPrint('✅ Content downloaded: ${contentBytes.length} bytes');

      // 3. StoryContent 생성
      final content = StoryContent.fromText(bodyText, meta.version);
      return content;
    } catch (e) {
      debugPrint('❌ Failed to download content: $e');
      rethrow;
    }
  }

  /// Storage에 콘텐츠 업로드 (Admin 전용)
  ///
  /// contentUrl 형식: 'arabic/lucky_day' (폴더 경로)
  Future<String> uploadContent(String contentUrl, StoryContent content) async {
    try {
      debugPrint('📤 Uploading content to Storage: $contentUrl');

      // 1. 본문 업로드 (content.txt)
      final contentPath = '$contentUrl/content.txt';
      final contentBytes = utf8.encode(content.toText());

      await SupabaseService.instance.storage
          .from(_bucketName)
          .uploadBinary(
            contentPath,
            Uint8List.fromList(contentBytes),
            fileOptions: const FileOptions(contentType: 'text/plain; charset=utf-8', upsert: true),
          );

      debugPrint('✅ Content uploaded: $contentPath');

      // 2. 메타데이터 업로드 (_meta.json)
      final metaPath = '$contentUrl/_meta.json';
      final meta = StoryMeta(version: content.version);
      final metaBytes = utf8.encode(meta.toJsonString());

      await SupabaseService.instance.storage
          .from(_bucketName)
          .uploadBinary(
            metaPath,
            Uint8List.fromList(metaBytes),
            fileOptions: const FileOptions(contentType: 'application/json', upsert: true),
          );

      debugPrint('✅ Meta uploaded: $metaPath');

      return contentUrl;
    } catch (e) {
      debugPrint('❌ Failed to upload content: $e');
      rethrow;
    }
  }

  /// Storage에서 콘텐츠 삭제 (Admin 전용)
  Future<void> deleteContent(String contentUrl) async {
    try {
      debugPrint('🗑️ Deleting content from Storage: $contentUrl');

      // 폴더 내 모든 파일 삭제
      await SupabaseService.instance.storage.from(_bucketName).remove([
        '$contentUrl/content.txt',
        '$contentUrl/_meta.json',
      ]);

      debugPrint('✅ Content deleted: $contentUrl');
    } catch (e) {
      debugPrint('❌ Failed to delete content: $e');
      rethrow;
    }
  }

  /// 콘텐츠 파일의 Public URL 가져오기
  String getPublicUrl(String contentUrl) {
    return SupabaseService.instance.storage
        .from(_bucketName)
        .getPublicUrl('$contentUrl/content.txt');
  }

  /// 콘텐츠 파일 존재 여부 확인
  Future<bool> exists(String contentUrl) async {
    try {
      // content.txt 파일 존재 여부 확인
      final pathParts = contentUrl.split('/');
      final parentPath = pathParts.sublist(0, pathParts.length - 1).join('/');
      final folderName = pathParts.last;

      final files = await SupabaseService.instance.storage
          .from(_bucketName)
          .list(path: parentPath.isEmpty ? null : parentPath);

      // 폴더가 존재하는지 확인
      return files.any((file) => file.name == folderName);
    } catch (e) {
      debugPrint('❌ Failed to check file existence: $e');
      return false;
    }
  }

  /// 파일 크기 가져오기 (바이트)
  Future<int?> getFileSize(String contentUrl) async {
    try {
      final contentPath = '$contentUrl/content.txt';
      final pathParts = contentPath.split('/');
      final parentPath = pathParts.sublist(0, pathParts.length - 1).join('/');
      final fileName = pathParts.last;

      final files = await SupabaseService.instance.storage.from(_bucketName).list(path: parentPath);

      final file = files.firstWhere(
        (file) => file.name == fileName,
        orElse: () => throw Exception('File not found'),
      );

      return file.metadata?['size'] as int?;
    } catch (e) {
      debugPrint('❌ Failed to get file size: $e');
      return null;
    }
  }

  /// 메타데이터만 다운로드
  Future<StoryMeta> downloadMeta(String contentUrl) async {
    try {
      final metaPath = '$contentUrl/_meta.json';
      final metaBytes = await SupabaseService.instance.storage.from(_bucketName).download(metaPath);

      final metaString = utf8.decode(metaBytes);
      return StoryMeta.fromJsonString(metaString);
    } catch (e) {
      debugPrint('❌ Failed to download meta: $e');
      rethrow;
    }
  }
}
