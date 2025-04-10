class Region {
  final String code;
  final String name;

  Region({
    required this.code,
    required this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }
}
