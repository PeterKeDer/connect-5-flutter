import 'package:connect_5/util.dart';

class User {
  final String id;
  String nickname;

  User(this.id, this.nickname);

  User.fromJson(Map<String, dynamic> json) : id = guardTypeNotNull(json['id']) {
    nickname = guardType(json['nickname']);
  }
}
