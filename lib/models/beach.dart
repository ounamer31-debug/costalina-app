enum BeachRisk { stable, modere, eleve }

extension BeachRiskX on BeachRisk {
  String get label {
    switch (this) {
      case BeachRisk.stable:
        return 'Stable';
      case BeachRisk.modere:
        return 'Risque modéré';
      case BeachRisk.eleve:
        return 'Risque élevé';
    }
  }

  String get short {
    switch (this) {
      case BeachRisk.stable:
        return 'Stable';
      case BeachRisk.modere:
        return 'Modéré';
      case BeachRisk.eleve:
        return 'Élevé';
    }
  }
}

class Beach {
  final String id;
  final String name;
  final String city;
  final String photoUrl;
  final BeachRisk risk;
  final String lastUpdate;
  final double erosionMeters;
  final double lat;
  final double lng;

  const Beach({
    required this.id,
    required this.name,
    required this.city,
    required this.photoUrl,
    required this.risk,
    required this.lastUpdate,
    required this.erosionMeters,
    required this.lat,
    required this.lng,
  });
}
