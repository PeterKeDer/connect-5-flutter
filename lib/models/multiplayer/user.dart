import 'package:connect_5/helpers/multiplayer_manager.dart';
import 'package:connect_5/localization/localization.dart';
import 'package:connect_5/util.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class User {
  final String id;
  String nickname;

  User(this.id, this.nickname);

  User.fromJson(Map<String, dynamic> json) : id = guardTypeNotNull(json['id']) {
    nickname = guardType(json['nickname']);
  }

  String displayNickname(BuildContext context) {
    if (id == Provider.of<MultiplayerManager>(context).userId) {
      return localize(context, 'you');
    } else {
      return nickname ?? localize(context, 'guest');
    }
  }
}
