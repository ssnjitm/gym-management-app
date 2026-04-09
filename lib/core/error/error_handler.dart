// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'failure.dart';

// class ErrorHandler {
//   static Failure handleError(dynamic error) {
//     if (error is AuthException) {
//       return AuthFailure(message: error.message);
//     } else if (error is PostgrestException) {
//       return ServerFailure(
//         message: error.message,
//         statusCode: error.code,
//       );
//     } else if (error is StorageException) {
//       return ServerFailure(message: error.message);
//     } else if (error is SocketException || error is TimeoutException) {
//       return NetworkFailure(message: 'No internet connection. Please check your network.');
//     } else if (error is FormatException) {
//       return ServerFailure(message: 'Invalid data format');
//     } else {
//       return ServerFailure(message: error.toString());
//     }
//   }
// }