
import 'package:json_annotation/json_annotation.dart';

part 'ssh_server.g.dart';

@JsonSerializable()
class SshServerSecureStorage {
  int port;
  String user;
  String? password;
  // deprecated
  String? sshPassword;
  String? sshKey;
  String? sshKeyPath;
  String? passphrase;
  String? pubKey;
  String? globalSshKeyName;

  SshServerSecureStorage({
    this.port = 22,
    this.user = '',
    this.password,
    this.sshPassword,
    this.sshKey,
    this.sshKeyPath,
    this.passphrase,
    this.pubKey,
    this.globalSshKeyName,
  });

  factory SshServerSecureStorage.fromJson(Map<String, dynamic> json) =>
      _$SshServerSecureStorageFromJson(json);

  Map<String, dynamic> toJson() => _$SshServerSecureStorageToJson(this);
}

@JsonSerializable()
class CommonSshKeySecureStorage {
  String? sshKey;
  String? sshKeyPath;
  String? passphrase;

  CommonSshKeySecureStorage({
    this.sshKey,
    this.sshKeyPath,
    this.passphrase,
  });

  factory CommonSshKeySecureStorage.fromJson(Map<String, dynamic> json) =>
      _$CommonSshKeySecureStorageFromJson(json);

  Map<String, dynamic> toJson() => _$CommonSshKeySecureStorageToJson(this);
}
