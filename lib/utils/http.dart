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


// import 'package:dio/io.dart';
// import 'package:dio/dio.dart';

// Dio createHttpClientWithCustomTLS({
//   required String trustedCertificates,
//   // String? clientCertPath,
//   // String? clientKeyPath,
// }) {
//   Dio dio = Dio();
//   (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//     // client.badCertificateCallback =
//     //     (X509Certificate cert, String host, int port) => true;

//     SecurityContext context = SecurityContext(withTrustedRoots: true);

//     context.setTrustedCertificatesBytes(utf8.encode(trustedCertificates));

//     // context.useCertificateChainBytes(clientCertificate.buffer.asUint8List());

//     // context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
//     HttpClient httpClient = HttpClient(context: context);

//     return httpClient;
//   };
//   return dio;
// }
