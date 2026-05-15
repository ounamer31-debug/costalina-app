import 'beach.dart';

class Alerte {
  final String beachId;
  final String beachName;
  final String message;
  final String time;
  final BeachRisk risk;

  const Alerte({
    required this.beachId,
    required this.beachName,
    required this.message,
    required this.time,
    required this.risk,
  });
}
