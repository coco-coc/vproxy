// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ssh_server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SshServerSecureStorage _$SshServerSecureStorageFromJson(
        Map<String, dynamic> json) =>
    SshServerSecureStorage(
      port: (json['port'] as num?)?.toInt() ?? 22,
      user: json['user'] as String? ?? '',
      password: json['password'] as String?,
      sshPassword: json['sshPassword'] as String?,
      sshKey: json['sshKey'] as String?,
      sshKeyPath: json['sshKeyPath'] as String?,
      passphrase: json['passphrase'] as String?,
      pubKey: json['pubKey'] as String?,
      globalSshKeyName: json['globalSshKeyName'] as String?,
    );

Map<String, dynamic> _$SshServerSecureStorageToJson(
        SshServerSecureStorage instance) =>
    <String, dynamic>{
      'port': instance.port,
      'user': instance.user,
      'password': instance.password,
      'sshPassword': instance.sshPassword,
      'sshKey': instance.sshKey,
      'sshKeyPath': instance.sshKeyPath,
      'passphrase': instance.passphrase,
      'pubKey': instance.pubKey,
      'globalSshKeyName': instance.globalSshKeyName,
    };

CommonSshKeySecureStorage _$CommonSshKeySecureStorageFromJson(
        Map<String, dynamic> json) =>
    CommonSshKeySecureStorage(
      sshKey: json['sshKey'] as String?,
      sshKeyPath: json['sshKeyPath'] as String?,
      passphrase: json['passphrase'] as String?,
    );

Map<String, dynamic> _$CommonSshKeySecureStorageToJson(
        CommonSshKeySecureStorage instance) =>
    <String, dynamic>{
      'sshKey': instance.sshKey,
      'sshKeyPath': instance.sshKeyPath,
      'passphrase': instance.passphrase,
    };
