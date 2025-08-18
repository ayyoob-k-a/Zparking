import 'package:dio/dio.dart';
import 'package:z_parking/core/dio_client.dart';
import 'package:z_parking/core/local_storage.dart';
import 'package:z_parking/core/locator.dart';

class AuthRepository {
	AuthRepository({required this.apiClient, required this.tokenSink});

	final ApiClient apiClient;
	final TokenSink tokenSink;

	Future<void> login({required String mobileNumber, required String otp}) async {
		try {
			// Debug print
			// ignore: avoid_print
			print('Login request payload: ' + {'mobileNumber': mobileNumber, 'otp': otp}.toString());
			final Response<dynamic> res = await apiClient.post(
				'machine-test/login',
				data: {
					'mobile': mobileNumber,
					'password': otp,
				},

			);
			// ignore: avoid_print
			print('Login response: ' + res.statusCode.toString() + ' ' + res.data.toString());
			final dynamic body = res.data;
			final String? token = _extractToken(body);
			if (token == null || token.isEmpty) {
				throw Exception('Login succeeded but token missing in response');
			}
			await tokenSink.saveToken(token);
			// Save basic user info if present
			try {
				if (body is Map<String, dynamic>) {
					final user = body['user'];
					if (user is Map<String, dynamic>) {
						final String? name = (user['_name'] ?? user['name'])?.toString();
						final String? mobile = (user['_mobileNumber'] ?? user['mobileNumber'])?.toString();
						final storage = sl<LocalStorage>();
						if (name != null && name.isNotEmpty) { await storage.saveUserName(name); }
						if (mobile != null && mobile.isNotEmpty) { await storage.saveUserMobile(mobile); }
					}
				}
			} catch (_) {}
		} on DioException catch (e) {
			final msg = e.response?.data is Map<String, dynamic>
				? (e.response!.data['message']?.toString() ?? 'Login failed')
				: e.message ?? 'Login failed';
			throw Exception(msg);
		}
	}

	String? _extractToken(dynamic body) {
		if (body == null) return null;
		if (body is Map<String, dynamic>) {
			if (body['token'] is String) return body['token'] as String;
			if (body['accessToken'] is String) return body['accessToken'] as String;
			final data = body['data'];
			if (data is Map<String, dynamic>) {
				if (data['token'] is String) return data['token'] as String;
				if (data['accessToken'] is String) return data['accessToken'] as String;
			}
		}
		return null;
	}
}


