// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'running_release_notes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReleaseNotes _$ReleaseNotesFromJson(Map<String, dynamic> json) => ReleaseNotes(
      releases: (json['releases'] as List<dynamic>)
          .map((e) => Release.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReleaseNotesToJson(ReleaseNotes instance) =>
    <String, dynamic>{
      'releases': instance.releases,
    };

Release _$ReleaseFromJson(Map<String, dynamic> json) => Release(
      version:
          SemanticVersion.fromJson(json['version'] as Map<String, dynamic>),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ReleaseSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReleaseToJson(Release instance) => <String, dynamic>{
      'version': instance.version,
      'sections': instance.sections,
    };

SemanticVersion _$SemanticVersionFromJson(Map<String, dynamic> json) =>
    SemanticVersion(
      major: json['major'] as int,
      minor: json['minor'] as int,
      patch: json['patch'] as int,
      pre: json['pre'] as String?,
    );

Map<String, dynamic> _$SemanticVersionToJson(SemanticVersion instance) =>
    <String, dynamic>{
      'major': instance.major,
      'minor': instance.minor,
      'patch': instance.patch,
      'pre': instance.pre,
    };

ReleaseSection _$ReleaseSectionFromJson(Map<String, dynamic> json) =>
    ReleaseSection(
      name: json['name'] as String,
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => ReleaseNote.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReleaseSectionToJson(ReleaseSection instance) =>
    <String, dynamic>{
      'name': instance.name,
      'notes': instance.notes,
    };

ReleaseNote _$ReleaseNoteFromJson(Map<String, dynamic> json) => ReleaseNote(
      message: json['message'] as String,
      githubPullRequestUrls: (json['githubPullRequestUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ReleaseNoteToJson(ReleaseNote instance) =>
    <String, dynamic>{
      'githubPullRequestUrls': instance.githubPullRequestUrls,
      'message': instance.message,
    };
