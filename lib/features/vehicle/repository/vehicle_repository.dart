import 'package:dio/dio.dart';
import 'package:z_parking/core/dio_client.dart';
import 'package:z_parking/features/vehicle/models/vehicle.dart';

class VehicleListPageResult {
	VehicleListPageResult({required this.items, required this.total, required this.skip, required this.limit});
	final List<Vehicle> items;
	final int total;
	final int skip;
	final int limit;
}

class VehicleRepository {
	VehicleRepository({required this.apiClient});
	final ApiClient apiClient;

	Future<VehicleListPageResult> list({required int skip, int limit = 10, String? searchingText}) async {
		// ignore: avoid_print
		print('List vehicles request: skip=' + skip.toString() + ', limit=' + limit.toString() + (searchingText != null ? ', search=' + searchingText : ''));
		final Response<dynamic> res = await apiClient.post('machine-test/list', data: {
			'skip': skip,
			'limit': limit,
			if (searchingText != null && searchingText.isNotEmpty) 'searchingText': searchingText,
		});
		// ignore: avoid_print
		print('List vehicles response: ' + res.statusCode.toString() + ' ' + res.data.toString());
		final dynamic data = res.data;
		final List<dynamic> itemsRaw = _extractList(data);
		final List<Vehicle> items = itemsRaw.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
		final int total = _extractTotal(data, 0);
		return VehicleListPageResult(items: items, total: total, skip: skip, limit: limit);
	}



	Future<Vehicle> create({
		required String name,
		required String color,
		required String vehicleNumber,
		int? modelYear,
		String? model,
	}) async {
		final Response<dynamic> res = await apiClient.post('machine-test/create', data: {
			'name': name,
			'color': color,
			'vehicleNumber': vehicleNumber,
			if (model != null) 'model': model,
			if (model == null && modelYear != null) 'model': modelYear.toString(),
		});
		final Map<String, dynamic> body = _extractItem(res.data);
		return Vehicle.fromJson(body);
	}

	Future<Vehicle> edit({
		required String id,
		required String name,
		required String color,
		required String vehicleNumber,
		int? modelYear,
		String? model,
	}) async {
		final Response<dynamic> res = await apiClient.put('machine-test/edit', data: {
			'vehicleId': id,
			'name': name,
			'color': color,
			'vehicleNumber': vehicleNumber,
			if (model != null) 'model': model,
			if (model == null && modelYear != null) 'model': modelYear.toString(),
		});
		final Map<String, dynamic> body = _extractItem(res.data);
		return Vehicle.fromJson(body);
	}

	Future<void> deleteById(String id) async {
		await apiClient.delete('machine-test/delete', data: {'vehicleId': id});
	}

	List<dynamic> _extractList(dynamic data) {
		if (data is Map<String, dynamic>) {
			final dynamic list = data['data'] ?? data['items'] ?? data['results'] ?? (data['data'] is Map<String, dynamic> ? (data['data'] as Map<String, dynamic>)['list'] : null) ?? data['list'];
			if (list is List) return list;
			if (data['data'] is Map<String, dynamic>) {
				final dynamic inner = (data['data'] as Map<String, dynamic>)['items'] ?? (data['data'] as Map<String, dynamic>)['list'];
				if (inner is List) return inner;
			}
		}
		if (data is List) return data;
		return <dynamic>[];
	}

	int _extractTotal(dynamic data, int fallback) {
		if (data is Map<String, dynamic>) {
			final dynamic t = data['total'] ?? data['count'] ?? data['totalCount'];
			if (t != null) return int.tryParse(t.toString()) ?? fallback;
		}
		return fallback;
	}

	Map<String, dynamic> _extractItem(dynamic data) {
		if (data is Map<String, dynamic>) {
			final dynamic item = data['data'] ?? data['item'] ?? data['vehicle'];
			if (item is Map<String, dynamic>) return item;
			return data;
		}
		return <String, dynamic>{};
	}
}


