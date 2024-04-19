class PosterRequests{
  String imageUrl;
  String location;
  String timestamp;

  PosterRequests({
    required this.imageUrl,
    required this.location,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }

  factory PosterRequests.fromMap(Map<String, dynamic> map) {
    return PosterRequests(
      location: map['location'],
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'],
    );
  }
}