// submit_rating_request.dart

class SubmitRatingRequest {
  final String driverId;
  final int rating;
  final String comment;

  SubmitRatingRequest({
    required this.driverId,
    required this.rating,
    required this.comment,
  });

  // JSON → Dart Object
  factory SubmitRatingRequest.fromJson(Map<String, dynamic> json) {
    return SubmitRatingRequest(
      driverId: json['driverId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '', // null safe
    );
  }

  // Dart Object → JSON (API ke liye)
  Map<String, dynamic> toJson() {
    return {
      "driverId": driverId,
      "rating": rating,
      "comment": comment,
    };
  }

  // For pretty printing (debug)
  @override
  String toString() {
    return 'SubmitRatingRequest(driverId: $driverId, rating: $rating, comment: $comment)';
  }
}