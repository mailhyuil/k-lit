import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/story_content.dart';

/// 작품 콘텐츠 로컬 캐시 관리 서비스
/// 
/// 캐시 구조 (Storage와 동일한 구조):
/// ```
/// {app_dir}/story_cache/
/// ├── metadata.json                  # 캐시 메타데이터
/// ├── {story_id}_content.txt         # 본문
/// ├── {story_id}_meta.json           # 버전 정보
/// └── ...
/// ```
class StoryCacheService {
  static const String _cacheDirectory = 'story_cache';
  static const String _metadataFile = 'metadata.json';
  static const int _maxCacheSizeBytes = 100 * 1024 * 1024; // 100MB

  /// 캐시 디렉토리 경로 가져오기
  Future<String> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDirectory');
    
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    return cacheDir.path;
  }

  /// 메타데이터 파일 경로
  Future<String> _getMetadataPath() async {
    final cacheDir = await _getCacheDirectory();
    return '$cacheDir/$_metadataFile';
  }

  /// 본문 파일 경로
  Future<String> _getContentPath(String storyId) async {
    final cacheDir = await _getCacheDirectory();
    return '$cacheDir/${storyId}_content.txt';
  }

  /// 메타 파일 경로
  Future<String> _getMetaPath(String storyId) async {
    final cacheDir = await _getCacheDirectory();
    return '$cacheDir/${storyId}_meta.json';
  }

  /// 캐시 메타데이터 로드
  Future<Map<String, CachedContentMetadata>> _loadMetadata() async {
    try {
      final metadataPath = await _getMetadataPath();
      final file = File(metadataPath);
      
      if (!await file.exists()) {
        return {};
      }

      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return json.map((key, value) => MapEntry(
        key,
        CachedContentMetadata.fromJson(value as Map<String, dynamic>),
      ));
    } catch (e) {
      debugPrint('❌ Failed to load cache metadata: $e');
      return {};
    }
  }

  /// 캐시 메타데이터 저장
  Future<void> _saveMetadata(Map<String, CachedContentMetadata> metadata) async {
    try {
      final metadataPath = await _getMetadataPath();
      final file = File(metadataPath);
      
      final json = metadata.map((key, value) => MapEntry(key, value.toJson()));
      final jsonString = jsonEncode(json);
      
      await file.writeAsString(jsonString);
      debugPrint('✅ Cache metadata saved');
    } catch (e) {
      debugPrint('❌ Failed to save cache metadata: $e');
    }
  }

  /// 콘텐츠 캐시 확인
  Future<bool> isCached(String storyId, int version) async {
    try {
      final metadata = await _loadMetadata();
      final cached = metadata[storyId];
      
      if (cached == null) return false;
      if (cached.version != version) return false;
      
      final contentPath = await _getContentPath(storyId);
      final metaPath = await _getMetaPath(storyId);
      
      return await File(contentPath).exists() && 
             await File(metaPath).exists();
    } catch (e) {
      debugPrint('❌ Failed to check cache: $e');
      return false;
    }
  }

  /// 캐시된 콘텐츠 가져오기
  Future<StoryContent?> getCachedContent(String storyId, int version) async {
    try {
      // 캐시 확인
      if (!await isCached(storyId, version)) {
        debugPrint('ℹ️ Content not cached or outdated: $storyId');
        return null;
      }

      // 1. 메타 파일 읽기
      final metaPath = await _getMetaPath(storyId);
      final metaFile = File(metaPath);
      final metaString = await metaFile.readAsString();
      final meta = StoryMeta.fromJsonString(metaString);
      
      // 버전 확인
      if (meta.version != version) {
        debugPrint('⚠️ Cache version mismatch: expected $version, got ${meta.version}');
        return null;
      }

      // 2. 본문 파일 읽기
      final contentPath = await _getContentPath(storyId);
      final contentFile = File(contentPath);
      final bodyText = await contentFile.readAsString();
      
      final content = StoryContent.fromText(bodyText, meta.version);
      debugPrint('✅ Content loaded from cache: $storyId');
      
      return content;
    } catch (e) {
      debugPrint('❌ Failed to get cached content: $e');
      return null;
    }
  }

  /// 콘텐츠 캐시에 저장
  Future<void> saveToCache(
    String storyId,
    int version,
    StoryContent content,
  ) async {
    try {
      // 1. 본문 파일 저장
      final contentPath = await _getContentPath(storyId);
      final contentFile = File(contentPath);
      await contentFile.writeAsString(content.toText());
      
      // 2. 메타 파일 저장
      final metaPath = await _getMetaPath(storyId);
      final metaFile = File(metaPath);
      final meta = StoryMeta(version: version);
      await metaFile.writeAsString(meta.toJsonString());
      
      // 3. 캐시 메타데이터 업데이트
      final metadata = await _loadMetadata();
      metadata[storyId] = CachedContentMetadata(
        storyId: storyId,
        version: version,
        cachedAt: DateTime.now(),
        sizeBytes: content.toText().length,
      );
      
      await _saveMetadata(metadata);
      
      debugPrint('✅ Content saved to cache: $storyId (version: $version)');
      
      // 4. 캐시 크기 확인 및 정리
      await _cleanupIfNeeded();
    } catch (e) {
      debugPrint('❌ Failed to save to cache: $e');
    }
  }

  /// 특정 작품 캐시 삭제
  Future<void> deleteStory(String storyId) async {
    try {
      final contentPath = await _getContentPath(storyId);
      final metaPath = await _getMetaPath(storyId);
      
      final contentFile = File(contentPath);
      final metaFile = File(metaPath);
      
      if (await contentFile.exists()) {
        await contentFile.delete();
      }
      
      if (await metaFile.exists()) {
        await metaFile.delete();
      }
      
      // 메타데이터에서 제거
      final metadata = await _loadMetadata();
      metadata.remove(storyId);
      await _saveMetadata(metadata);
      
      debugPrint('✅ Cache deleted: $storyId');
    } catch (e) {
      debugPrint('❌ Failed to delete cache: $e');
    }
  }

  /// 모든 캐시 삭제
  Future<void> clearAllCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final directory = Directory(cacheDir);
      
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
      }
      
      debugPrint('✅ All cache cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear cache: $e');
    }
  }

  /// 캐시 크기 계산
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      final directory = Directory(cacheDir);
      
      if (!await directory.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('❌ Failed to get cache size: $e');
      return 0;
    }
  }

  /// 캐시 정리 (크기 초과 시 LRU 방식으로 삭제)
  Future<void> _cleanupIfNeeded() async {
    try {
      final cacheSize = await getCacheSize();
      
      if (cacheSize <= _maxCacheSizeBytes) {
        return;
      }
      
      debugPrint('⚠️ Cache size exceeded: ${cacheSize / 1024 / 1024} MB');
      
      // LRU: 가장 오래된 캐시부터 삭제
      final metadata = await _loadMetadata();
      final sorted = metadata.entries.toList()
        ..sort((a, b) => a.value.cachedAt.compareTo(b.value.cachedAt));
      
      // 목표 크기에 도달할 때까지 삭제
      final targetSize = _maxCacheSizeBytes * 0.8; // 80%까지 정리
      int currentSize = cacheSize;
      
      for (final entry in sorted) {
        if (currentSize <= targetSize) break;
        
        await deleteStory(entry.key);
        currentSize -= entry.value.sizeBytes;
        
        debugPrint('🗑️ Cleaned up: ${entry.key}');
      }
      
      debugPrint('✅ Cache cleanup completed');
    } catch (e) {
      debugPrint('❌ Failed to cleanup cache: $e');
    }
  }

  /// 캐시 통계
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final metadata = await _loadMetadata();
      final cacheSize = await getCacheSize();
      
      return {
        'total_stories': metadata.length,
        'total_size_bytes': cacheSize,
        'total_size_mb': (cacheSize / 1024 / 1024).toStringAsFixed(2),
        'max_size_mb': (_maxCacheSizeBytes / 1024 / 1024).toStringAsFixed(0),
        'usage_percent': ((cacheSize / _maxCacheSizeBytes) * 100).toStringAsFixed(1),
      };
    } catch (e) {
      debugPrint('❌ Failed to get cache stats: $e');
      return {};
    }
  }
}
