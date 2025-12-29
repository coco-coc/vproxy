import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(
      {required this.id,
      required this.email,
      this.proExpiredAt,
      required this.pro});
  final String id;
  final String email;
  final DateTime? proExpiredAt;
  
  final bool pro;

  @override
  List<Object?> get props => [id, email, proExpiredAt, pro];

  bool get isProUser {
    return pro;
  }

  bool get unlockPro => isProUser;

  bool get lifetimePro => pro && proExpiredAt == null;
}
