import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ReportType { erosion, pollution, wildlife, infrastructure, photo, other }

extension ReportTypeX on ReportType {
  String get apiValue {
    switch (this) {
      case ReportType.erosion:        return 'erosion';
      case ReportType.pollution:      return 'pollution';
      case ReportType.wildlife:       return 'wildlife';
      case ReportType.infrastructure: return 'infrastructure';
      case ReportType.photo:          return 'photo';
      case ReportType.other:          return 'other';
    }
  }

  String get label {
    switch (this) {
      case ReportType.erosion:        return 'Érosion';
      case ReportType.pollution:      return 'Pollution';
      case ReportType.wildlife:       return 'Faune';
      case ReportType.infrastructure: return 'Infrastructure';
      case ReportType.photo:          return 'Photo';
      case ReportType.other:          return 'Autre';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.erosion:        return LucideIcons.waves;
      case ReportType.pollution:      return LucideIcons.trash2;
      case ReportType.wildlife:       return LucideIcons.fish;
      case ReportType.infrastructure: return LucideIcons.construction;
      case ReportType.photo:          return LucideIcons.camera;
      case ReportType.other:          return LucideIcons.helpCircle;
    }
  }

  static ReportType fromApi(String? v) {
    switch (v) {
      case 'erosion':        return ReportType.erosion;
      case 'pollution':      return ReportType.pollution;
      case 'wildlife':       return ReportType.wildlife;
      case 'infrastructure': return ReportType.infrastructure;
      case 'photo':          return ReportType.photo;
      default:               return ReportType.other;
    }
  }
}