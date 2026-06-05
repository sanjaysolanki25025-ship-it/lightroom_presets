class FeedbackModel {
  final String id;
  final String feedBackCategory;
  final String description;
  final bool privacyPolicy;
  final String? referenceImage;
  final String email;

  FeedbackModel({
    this.id = '',
    required this.feedBackCategory,
    required this.description,
    required this.privacyPolicy,
    this.referenceImage,
    required this.email,
  });

  FeedbackModel copyWith({
    String? id,
    String? feedBackCategory,
    String? description,
    bool? privacyPolicy,
    String? referenceImage,
    String? email,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      feedBackCategory: feedBackCategory ?? this.feedBackCategory,
      description: description ?? this.description,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      referenceImage: referenceImage ?? this.referenceImage,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feedBackCategory': feedBackCategory,
      'description': description,
      'privacyPolicy': privacyPolicy,
      'referenceImage': referenceImage,
      'createdAt': DateTime.now(),
      'email': email,
    };
  }
}
