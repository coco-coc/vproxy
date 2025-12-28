import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';

const publicKey =
    'MCowBQYDK2VwAyEAoWRDZFA0w/bz2TI80fhWlw0KRYj0ae3298b9uV/hMx4=';
const uniqueIdKey = 'vx_unique_id';

Future<bool> validateLicence(Licence licence, String uniqueId) async {
  final deviceInfo = await getConstDeviceInfo(uniqueId);

  // Verify device info hash matches
  if (deviceInfo.hash() != licence.deviceInfoHash) {
    return false;
  }

  // Verify the signature using Ed25519
  try {
    // Decode the public key from base64
    final publicKeyBytes = base64Decode(publicKey);

    // For Ed25519, the public key is typically 32 bytes
    // The base64 decoded key contains ASN.1 DER encoding, extract the actual 32-byte key
    // For Ed25519 public key in X.509 SubjectPublicKeyInfo format:
    // The last 32 bytes are the actual Ed25519 public key
    final ed25519PublicKeyBytes =
        publicKeyBytes.sublist(publicKeyBytes.length - 32);

    // Create the payload that was signed
    final payload = {
      'deviceInfoHash': licence.deviceInfoHash,
      'userId': licence.userId,
    };

    // Encode the payload as JSON (same as in TypeScript)
    final payloadJson = jsonEncode(payload);
    final payloadBytes = utf8.encode(payloadJson);

    // Decode the signature from base64
    final signatureBytes = base64Decode(licence.signature);

    // Verify the signature
    // Note: You'll need to add a cryptography package that supports Ed25519
    // For now, we'll use a placeholder that needs to be implemented
    final isValid = await _verifyEd25519Signature(
      message: payloadBytes,
      signature: signatureBytes,
      publicKey: ed25519PublicKeyBytes,
    );

    return isValid;
  } catch (e) {
    // If signature verification fails for any reason, return false
    return false;
  }
}

/// Verifies an Ed25519 signature
///
/// This function verifies that the [signature] was created by signing [message]
/// with the private key corresponding to [publicKey].
///
/// Returns true if the signature is valid, false otherwise.
Future<bool> _verifyEd25519Signature({
  required List<int> message,
  required List<int> signature,
  required List<int> publicKey,
}) async {
  try {
    // Create Ed25519 algorithm instance
    final algorithm = Ed25519();

    // Create public key object
    final publicKeyObj = SimplePublicKey(publicKey, type: KeyPairType.ed25519);

    // Create signature object
    final signatureObj = Signature(signature, publicKey: publicKeyObj);

    // Verify the signature
    final isValid = await algorithm.verify(message, signature: signatureObj);

    return isValid;
  } catch (e) {
    // If verification fails for any reason, return false
    return false;
  }
}

class Licence {
  final String deviceInfoHash;
  final String userId;
  final String signature;

  Licence(
      {required this.deviceInfoHash,
      required this.userId,
      required this.signature});

  factory Licence.fromJson(Map<String, dynamic> json) {
    return Licence(
      deviceInfoHash: json['deviceInfoHash'],
      userId: json['userId'],
      signature: json['signature'],
    );
  }
}

Future<ConstantDeviceInfo> getConstDeviceInfo(String uniqueId) async {
  final deviceInfo = await DeviceInfoPlugin().deviceInfo;
  switch (deviceInfo) {
    case AndroidDeviceInfo():
      return ConstantAndroidDeviceInfo.fromAndroidDeviceInfo(
          deviceInfo, uniqueId);
    case IosDeviceInfo():
      return ConstantIosDeviceInfo.fromIosDeviceInfo(deviceInfo, uniqueId);
    case WindowsDeviceInfo():
      return ConstantWindowsDeviceInfo.fromWindowsDeviceInfo(
          deviceInfo, uniqueId);
    case MacOsDeviceInfo():
      return ConstantMacOsDeviceInfo.fromMacOsDeviceInfo(deviceInfo, uniqueId);
    case LinuxDeviceInfo():
      return ConstantLinuxDeviceInfo.fromLinuxDeviceInfo(deviceInfo, uniqueId);
    default:
      throw Exception('Unsupported device');
  }
}

abstract class ConstantDeviceInfo {
  String get vxUniqueId;
  // a hash of all fields
  String hash();
}

/// Contains only the constant fields from AndroidDeviceInfo that do not change
/// over time (hardware/build-time properties).
class ConstantAndroidDeviceInfo implements ConstantDeviceInfo {
  const ConstantAndroidDeviceInfo({
    required this.vxUniqueId,
    required this.board,
    required this.brand,
    required this.device,
    required this.hardware,
    required this.host,
    required this.manufacturer,
    required this.model,
    required this.product,
    required this.serialNumber,
    required this.isPhysicalDevice,
    required this.isLowRamDevice,
    required this.physicalRamSize,
    required this.supported32BitAbis,
    required this.supported64BitAbis,
    required this.supportedAbis,
  });

  @override
  final String vxUniqueId;

  /// The name of the underlying board, like "goldfish".
  final String board;

  /// The consumer-visible brand with which the product/hardware will be associated, if any.
  final String brand;

  /// The name of the industrial design.
  final String device;

  /// The name of the hardware (from the kernel command line or /proc).
  final String hardware;

  /// Hostname.
  final String host;

  /// The manufacturer of the product/hardware.
  final String manufacturer;

  /// The end-user-visible name for the end product.
  final String model;

  /// The name of the overall product.
  final String product;

  /// Hardware serial number of the device, if available
  final String serialNumber;

  /// `false` if the application is running in an emulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// `true` if the application is running on a low-RAM device, `false` otherwise.
  final bool isLowRamDevice;

  /// Total physical RAM size of the device in megabytes
  final int physicalRamSize;

  /// An ordered list of 32 bit ABIs supported by this device.
  final List<String> supported32BitAbis;

  /// An ordered list of 64 bit ABIs supported by this device.
  final List<String> supported64BitAbis;

  /// An ordered list of ABIs supported by this device.
  final List<String> supportedAbis;

  /// Creates a ConstantAndroidDeviceInfo from an AndroidDeviceInfo instance,
  /// extracting only the constant fields.
  factory ConstantAndroidDeviceInfo.fromAndroidDeviceInfo(
    AndroidDeviceInfo deviceInfo,
    String uniqueId,
  ) {
    return ConstantAndroidDeviceInfo(
      vxUniqueId: uniqueId,
      board: deviceInfo.board,
      brand: deviceInfo.brand,
      device: deviceInfo.device,
      hardware: deviceInfo.hardware,
      host: deviceInfo.host,
      manufacturer: deviceInfo.manufacturer,
      model: deviceInfo.model,
      product: deviceInfo.product,
      serialNumber: deviceInfo.serialNumber,
      isPhysicalDevice: deviceInfo.isPhysicalDevice,
      isLowRamDevice: deviceInfo.isLowRamDevice,
      physicalRamSize: deviceInfo.physicalRamSize,
      supported32BitAbis:
          List<String>.unmodifiable(deviceInfo.supported32BitAbis),
      supported64BitAbis:
          List<String>.unmodifiable(deviceInfo.supported64BitAbis),
      supportedAbis: List<String>.unmodifiable(deviceInfo.supportedAbis),
    );
  }

  @override
  String hash() {
    final buffer = StringBuffer();
    buffer.write(vxUniqueId);
    buffer.write(board);
    buffer.write(brand);
    buffer.write(device);
    buffer.write(hardware);
    buffer.write(host);
    buffer.write(manufacturer);
    buffer.write(model);
    buffer.write(product);
    buffer.write(serialNumber);
    buffer.write(isPhysicalDevice);
    buffer.write(isLowRamDevice);
    buffer.write(physicalRamSize);
    buffer.write(supported32BitAbis.join(','));
    buffer.write(supported64BitAbis.join(','));
    buffer.write(supportedAbis.join(','));
    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}

/// Contains only the constant fields from IosDeviceInfo that do not change
/// over time (hardware/build-time properties).
class ConstantIosDeviceInfo implements ConstantDeviceInfo {
  const ConstantIosDeviceInfo({
    required this.vxUniqueId,
    required this.model,
    required this.modelName,
    this.identifierForVendor,
    required this.isPhysicalDevice,
    required this.physicalRamSize,
    required this.totalDiskSize,
    required this.isiOSAppOnMac,
    required this.utsname,
  });

  @override
  final String vxUniqueId;

  /// Device model according to OS
  final String model;

  /// Commercial or user-known model name
  /// Examples: `iPhone 16 Pro`, `iPad Pro 11-Inch 3`
  final String modelName;

  /// Unique UUID value identifying the current device.
  final String? identifierForVendor;

  /// `false` if the application is running in a simulator, `true` otherwise.
  final bool isPhysicalDevice;

  /// Total physical RAM size of the device in megabytes
  final int physicalRamSize;

  /// Total disk size in bytes
  final int totalDiskSize;

  /// Indicates whether the process is an iPhone or iPad app running on a Mac.
  final bool isiOSAppOnMac;

  /// Operating system information derived from `sys/utsname.h`.
  final ConstantIosUtsname utsname;

  /// Creates a ConstantIosDeviceInfo from an IosDeviceInfo instance,
  /// extracting only the constant fields.
  factory ConstantIosDeviceInfo.fromIosDeviceInfo(
    IosDeviceInfo deviceInfo,
    String uniqueId,
  ) {
    return ConstantIosDeviceInfo(
      vxUniqueId: uniqueId,
      model: deviceInfo.model,
      modelName: deviceInfo.modelName,
      identifierForVendor: deviceInfo.identifierForVendor,
      isPhysicalDevice: deviceInfo.isPhysicalDevice,
      physicalRamSize: deviceInfo.physicalRamSize,
      totalDiskSize: deviceInfo.totalDiskSize,
      isiOSAppOnMac: deviceInfo.isiOSAppOnMac,
      utsname: ConstantIosUtsname.fromIosUtsname(deviceInfo.utsname),
    );
  }

  @override
  String hash() {
    final buffer = StringBuffer();
    buffer.write(vxUniqueId);
    buffer.write(model);
    buffer.write(modelName);
    buffer.write(identifierForVendor ?? '');
    buffer.write(isPhysicalDevice);
    buffer.write(physicalRamSize);
    buffer.write(totalDiskSize);
    buffer.write(isiOSAppOnMac);
    buffer.write(utsname.sysname);
    buffer.write(utsname.nodename);
    buffer.write(utsname.machine);
    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}

/// Contains only the constant fields from IosUtsname that do not change
/// over time (hardware properties).
class ConstantIosUtsname {
  const ConstantIosUtsname({
    required this.sysname,
    required this.nodename,
    required this.machine,
  });

  /// Operating system name.
  final String sysname;

  /// Network node name.
  final String nodename;

  /// Hardware type (e.g. 'iPhone7,1' for iPhone 6 Plus).
  final String machine;

  /// Creates a ConstantIosUtsname from an IosUtsname instance,
  /// extracting only the constant fields (excluding release and version which change with OS updates).
  factory ConstantIosUtsname.fromIosUtsname(IosUtsname utsname) {
    return ConstantIosUtsname(
      sysname: utsname.sysname,
      nodename: utsname.nodename,
      machine: utsname.machine,
    );
  }
}

/// Contains only the constant fields from WindowsDeviceInfo that do not change
/// over time (hardware/build-time properties).
class ConstantWindowsDeviceInfo implements ConstantDeviceInfo {
  const ConstantWindowsDeviceInfo({
    required this.vxUniqueId,
    required this.numberOfCores,
    required this.systemMemoryInMegabytes,
    required this.platformId,
    required this.productType,
    required this.suitMask,
    required this.reserved,
    required this.digitalProductId,
    required this.editionId,
    required this.installDate,
    required this.productId,
    required this.productName,
    required this.deviceId,
  });

  @override
  final String vxUniqueId;

  /// Number of CPU cores on the local machine
  final int numberOfCores;

  /// The physically installed memory in the computer.
  /// This may not be the same as available memory.
  final int systemMemoryInMegabytes;

  /// The operating system platform. For Win32 on NT-based operating systems,
  /// RtlGetVersion returns the value `VER_PLATFORM_WIN32_NT`.
  final int platformId;

  /// The product type. This member contains additional information about the
  /// system.
  final int productType;

  /// The product suites available on the system.
  final int suitMask;

  /// Reserved for future use.
  final int reserved;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\DigitalProductId` registry key.
  final Uint8List digitalProductId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\EditionID` registry key.
  final String editionId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\InstallDate` registry key.
  final DateTime installDate;

  /// Displayed as "Product ID" in Windows Settings. Value of the
  /// `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ProductId` registry key. For example:
  /// `00000-00000-0000-AAAAA`.
  final String productId;

  /// Value of `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
  /// NT\CurrentVersion\ProductName` registry key. For example: `Windows 10 Home
  /// Single Language`.
  final String productName;

  /// Displayed as "Device ID" in Windows Settings. Value of
  /// `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SQMClient\MachineId` registry key.
  final String deviceId;

  /// Creates a ConstantWindowsDeviceInfo from a WindowsDeviceInfo instance,
  /// extracting only the constant fields.
  factory ConstantWindowsDeviceInfo.fromWindowsDeviceInfo(
    WindowsDeviceInfo deviceInfo,
    String uniqueId,
  ) {
    return ConstantWindowsDeviceInfo(
      vxUniqueId: uniqueId,
      numberOfCores: deviceInfo.numberOfCores,
      systemMemoryInMegabytes: deviceInfo.systemMemoryInMegabytes,
      platformId: deviceInfo.platformId,
      productType: deviceInfo.productType,
      suitMask: deviceInfo.suitMask,
      reserved: deviceInfo.reserved,
      digitalProductId: deviceInfo.digitalProductId,
      editionId: deviceInfo.editionId,
      installDate: deviceInfo.installDate,
      productId: deviceInfo.productId,
      productName: deviceInfo.productName,
      deviceId: deviceInfo.deviceId,
    );
  }

  @override
  String hash() {
    final buffer = StringBuffer();
    buffer.write(vxUniqueId);
    buffer.write(numberOfCores);
    buffer.write(systemMemoryInMegabytes);
    buffer.write(platformId);
    buffer.write(productType);
    buffer.write(suitMask);
    buffer.write(reserved);
    buffer.write(digitalProductId);
    buffer.write(editionId);
    buffer.write(installDate.millisecondsSinceEpoch);
    buffer.write(productId);
    buffer.write(productName);
    buffer.write(deviceId);
    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}

/// Contains only the constant fields from MacOsDeviceInfo that do not change
/// over time (hardware/build-time properties).
class ConstantMacOsDeviceInfo implements ConstantDeviceInfo {
  const ConstantMacOsDeviceInfo({
    required this.vxUniqueId,
    required this.arch,
    required this.model,
    required this.modelName,
    required this.memorySize,
    required this.cpuFrequency,
    this.systemGUID,
  });

  @override
  final String vxUniqueId;

  /// Machine cpu architecture
  /// Note, that on Apple Silicon Macs can return `x86_64` if app runs via Rosetta
  final String arch;

  /// Device model identifier
  /// Examples: `MacBookPro18,3`, `Mac16,2`.
  final String model;

  /// Device model name
  /// Examples: `MacBook Pro (16-inch, 2021)`, `iMac (24-inch, 2024)`.
  final String modelName;

  /// Machine's memory size
  final int memorySize;

  /// Device CPU Frequency
  final int cpuFrequency;

  /// Device GUID
  final String? systemGUID;

  /// Creates a ConstantMacOsDeviceInfo from a MacOsDeviceInfo instance,
  /// extracting only the constant fields.
  factory ConstantMacOsDeviceInfo.fromMacOsDeviceInfo(
    MacOsDeviceInfo deviceInfo,
    String uniqueId,
  ) {
    return ConstantMacOsDeviceInfo(
      vxUniqueId: uniqueId,
      arch: deviceInfo.arch,
      model: deviceInfo.model,
      modelName: deviceInfo.modelName,
      memorySize: deviceInfo.memorySize,
      cpuFrequency: deviceInfo.cpuFrequency,
      systemGUID: deviceInfo.systemGUID,
    );
  }

  @override
  String hash() {
    final buffer = StringBuffer();
    buffer.write(vxUniqueId);
    buffer.write(arch);
    buffer.write(model);
    buffer.write(modelName);
    buffer.write(memorySize);
    buffer.write(cpuFrequency);
    buffer.write(systemGUID ?? '');
    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}

/// Contains only the constant fields from LinuxDeviceInfo that do not change
/// over time (hardware/build-time properties).
class ConstantLinuxDeviceInfo implements ConstantDeviceInfo {
  const ConstantLinuxDeviceInfo({
    required this.vxUniqueId,
    required this.name,
    required this.id,
    this.idLike,
    this.variantId,
    this.buildId,
    this.machineId,
  });

  @override
  final String vxUniqueId;

  /// A string identifying the operating system, without a version component,
  /// and suitable for presentation to the user.
  /// Examples: 'Fedora', 'Debian GNU/Linux'.
  final String name;

  /// A lower-case string identifying the operating system, excluding any
  /// version information and suitable for processing by scripts or usage in
  /// generated filenames.
  /// Examples: 'fedora', 'debian'.
  final String id;

  /// A space-separated list of operating system identifiers in the same syntax
  /// as the [id] value. It lists identifiers of operating systems that are
  /// closely related to the local operating system in regards to packaging
  /// and programming interfaces.
  /// Examples: an operating system with [id] 'centos', would list 'rhel' and
  /// 'fedora', and an operating system with [id] 'ubuntu' would list 'debian'.
  final List<String>? idLike;

  /// A lower-case string identifying a specific variant or edition of the
  /// operating system. This may be interpreted in order to determine a
  /// divergent default configuration.
  /// Examples: 'server', 'embedded'.
  final String? variantId;

  /// A string uniquely identifying the system image used as the origin for a
  /// distribution (it is not updated with system updates). The field can be
  /// identical between different [versionId]s as `buildId` is an only a unique
  /// identifier to a specific version.
  /// Examples: '2013-03-20.3', '201303203'.
  final String? buildId;

  /// A unique machine ID of the local system that is set during installation or
  /// boot. The machine ID is hexadecimal, 32-character, lowercase ID. When
  /// decoded from hexadecimal, this corresponds to a 16-byte/128-bit value.
  final String? machineId;

  /// Creates a ConstantLinuxDeviceInfo from a LinuxDeviceInfo instance,
  /// extracting only the constant fields.
  factory ConstantLinuxDeviceInfo.fromLinuxDeviceInfo(
    LinuxDeviceInfo deviceInfo,
    String uniqueId,
  ) {
    return ConstantLinuxDeviceInfo(
      vxUniqueId: uniqueId,
      name: deviceInfo.name,
      id: deviceInfo.id,
      idLike: deviceInfo.idLike != null
          ? List<String>.unmodifiable(deviceInfo.idLike!)
          : null,
      variantId: deviceInfo.variantId,
      buildId: deviceInfo.buildId,
      machineId: deviceInfo.machineId,
    );
  }

  @override
  String hash() {
    final buffer = StringBuffer();
    buffer.write(vxUniqueId);
    buffer.write(name);
    buffer.write(id);
    buffer.write(idLike?.join(',') ?? '');
    buffer.write(variantId ?? '');
    buffer.write(buildId ?? '');
    buffer.write(machineId ?? '');
    return sha256.convert(utf8.encode(buffer.toString())).toString();
  }
}
