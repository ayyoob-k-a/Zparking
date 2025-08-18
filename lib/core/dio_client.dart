import 'package:dio/dio.dart';

abstract class TokenProvider { String? get token; }
abstract class TokenSink { Future<void> saveToken(String token); Future<void> clearToken(); }

class InMemoryTokenStore implements TokenProvider, TokenSink {
	String? _token;

	@override
	String? get token => _token;

	@override
	Future<void> saveToken(String token) async { _token = token; }

	@override
	Future<void> clearToken() async { _token = null; }
}

class LocalTokenStore implements TokenProvider, TokenSink {
	LocalTokenStore(this._read, this._write, this._clear) {
		_token = _read();
	}
	final String? Function() _read;
	final Future<void> Function(String token) _write;
	final Future<void> Function() _clear;
	String? _token;
	@override
	String? get token => _token;
	@override
	Future<void> saveToken(String token) async { _token = token; await _write(token); }
	@override
	Future<void> clearToken() async { _token = null; await _clear(); }
}

class ApiClient {
	ApiClient({required Dio dio, required this.tokenProvider}) : _dio = dio {
		_dio.options = _dio.options.copyWith(
			connectTimeout: const Duration(seconds: 15),
			receiveTimeout: const Duration(seconds: 15),
			headers: {
				'Content-Type': 'application/json',
				'Accept': 'application/json',
			},
		);
		_dio.interceptors.add(
			InterceptorsWrapper(
				onRequest: (options, handler) {
					final token = tokenProvider.token;
					if (token != null && token.isNotEmpty) {
						options.headers['Authorization'] = 'Bearer ' + token;
					}
					handler.next(options);
				},
				onError: (error, handler) {
					handler.next(error);
				},
			),
		);
	}

	final Dio _dio;
	final TokenProvider tokenProvider;

	Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
		return _dio.get(path, queryParameters: query);
	}

	Future<Response<dynamic>> post(String path, {Object? data, Map<String, dynamic>? query}) {
		return _dio.post(path, data: data, queryParameters: query);
	}

	Future<Response<dynamic>> put(String path, {Object? data}) {
		return _dio.put(path, data: data);
	}

	Future<Response<dynamic>> delete(String path, {Object? data, Map<String, dynamic>? query}) {
		return _dio.delete(path, data: data, queryParameters: query);
	}
}


