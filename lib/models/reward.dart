class Reward {
  final String id;
  final String name;
  final String description;
  final int cost;
  final String category;
  final String imageUrl;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.category,
    required this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> j) => Reward(
        id:          j['_id']         as String,
        name:        j['name']        as String,
        description: j['description'] as String? ?? '',
        cost:        (j['cost']       as num?)?.toInt() ?? 0,
        category:    j['category']    as String? ?? 'experience',
        imageUrl:    j['imageUrl']    as String? ?? '',
      );
}

class Redemption {
  final String id;
  final String rewardName;
  final int cost;
  final String code;
  final String status;
  final DateTime createdAt;

  const Redemption({
    required this.id,
    required this.rewardName,
    required this.cost,
    required this.code,
    required this.status,
    required this.createdAt,
  });

  factory Redemption.fromJson(Map<String, dynamic> j) => Redemption(
        id:         j['_id']        as String,
        rewardName: j['rewardName'] as String,
        cost:       (j['cost']      as num?)?.toInt() ?? 0,
        code:       j['code']       as String,
        status:     j['status']     as String? ?? 'pending',
        createdAt:  DateTime.parse(j['createdAt'] as String),
      );
}