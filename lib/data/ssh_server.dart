// Copyright (C) 2026 5V Network LLC <5vnetwork@proton.me>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.


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
