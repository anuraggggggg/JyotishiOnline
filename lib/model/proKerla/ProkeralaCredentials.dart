class ProkeralaCredentials {
  final String clientId;
  final String clientSecret;

  ProkeralaCredentials({
    required this.clientId,
    required this.clientSecret,
  });

  factory ProkeralaCredentials.fromJson(Map<String, dynamic> json) {
    return ProkeralaCredentials(
      clientId: json['client_id'],
      clientSecret: json['client_secret'],
    );
  }
}
