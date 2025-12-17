
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
