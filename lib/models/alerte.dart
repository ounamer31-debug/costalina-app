import 'beach.dart';

class Alerte {
  final String id;
  final String beachId;
  final String beachName;
  final String message;
  final String time;
  final BeachRisk risk;
  final bool read;

  const Alerte({
    this.id = '',
    required this.beachId,
    required this.beachName,
    required this.message,
    required this.time,
    required this.risk,
    this.read = false,
  });
}
