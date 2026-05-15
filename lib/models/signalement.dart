class Signalement {
  final String id;
  final String beachId;
  final String userId;
  final String type;
  final String message;
  final String photoUrl;
  final String status;
  final String when;

  const Signalement({
    required this.id,
    required this.beachId,
    required this.userId,
    required this.type,
    required this.message,
    required this.photoUrl,
    required this.status,
    required this.when,
  });

  factory Signalement.fromJson(Map<String, dynamic> j) {
    return Signalement(
      id:       j['_id']      as String,
      beachId:  j['beachId']  as String,
      userId:   j['userId']   as String? ?? '',
      type:     j['type']     as String,
      message:  j['message']  as String? ?? '',
      photoUrl: j['photoUrl'] as String? ?? '',
      status:   j['status']   as String? ?? 'pending',
      when:     _timeAgo(j['createdAt'] as String?),
    );
  }

  // keep a thumbUrl getter so existing _SignalementRow code still compiles
  String get thumbUrl => photoUrl;

  static String _timeAgo(String? iso) {
    if (iso == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours   < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays    == 1) return 'Hier';
    return 'Il y a ${diff.inDays} j';
  }
}