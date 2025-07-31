// models/user.dart
class User {
  final String name;
  final String email;
  final String username;
  final String retailerRoleYn;
  final String? phone;
  final String? profileImage;

  User({
    required this.name,
    required this.email,
    required this.username,
    required this.retailerRoleYn,
    this.phone,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      retailerRoleYn: json['retailer_role_yn'] ?? 'no',
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      profileImage: json['profile_image'] ?? json['avatar'] ?? json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'retailer_role_yn': retailerRoleYn,
      if (phone != null) 'phone': phone,
      if (profileImage != null) 'profile_image': profileImage,
    };
  }

  bool get isRetailer => retailerRoleYn.toLowerCase() == 'yes';

  // Create a copy with updated fields
  User copyWith({
    String? name,
    String? email,
    String? username,
    String? retailerRoleYn,
    String? phone,
    String? profileImage,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      retailerRoleYn: retailerRoleYn ?? this.retailerRoleYn,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  String toString() {
    return 'User(name: $name, email: $email, username: $username, retailerRoleYn: $retailerRoleYn, phone: $phone, profileImage: $profileImage)';
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final String expiredAt;
  final User user;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.expiredAt,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      expiredAt: json['expired_at'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'expired_at': expiredAt,
      'user': user.toJson(),
    };
  }
}