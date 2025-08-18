class Vehicle {
	Vehicle({
		required this.id,
		required this.name,
		required this.color,
		required this.vehicleNumber,
		this.model,
		this.modelYear,
		this.createdAt,
	});

	final String id;
	final String name;
	final String color;
	final String vehicleNumber;
	final String? model;
	final int? modelYear;
	final DateTime? createdAt;

	factory Vehicle.fromJson(Map<String, dynamic> json) {
		String id = (json['id'] ?? json['_id'] ?? json['vehicleId'] ?? json['uuid'] ?? '').toString();
		String name = (json['name'] ?? json['_name'] ?? json['vehicleName'] ?? '').toString();
		String color = (json['color'] ?? json['_color'] ?? '').toString();
		String vehicleNumber = (json['vehicleNumber'] ?? json['_number'] ?? json['vehicle_number'] ?? json['number'] ?? '').toString();
		String? model = (json['model'] ?? json['_model'] ?? json['vehicleModel'])?.toString();
		int? modelYear;
		final dynamic my = json['modelYear'] ?? json['model_year'] ?? json['year'];
		if (my != null) {
			modelYear = int.tryParse(my.toString());
		}
		DateTime? createdAt;
		final dynamic ca = json['createdAt'] ?? json['_createdAt'] ?? json['created_at'] ?? json['createdDate'];
		if (ca != null) {
			if (ca is num) {
				createdAt = DateTime.fromMillisecondsSinceEpoch(ca.toInt());
			} else {
				createdAt = DateTime.tryParse(ca.toString());
			}
		}
		return Vehicle(
			id: id,
			name: name,
			color: color,
			vehicleNumber: vehicleNumber,
			model: model,
			modelYear: modelYear,
			createdAt: createdAt,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'color': color,
			'vehicleNumber': vehicleNumber,
			'model': model ?? (modelYear != null ? modelYear.toString() : null),
			'modelYear': modelYear,
			'createdAt': createdAt?.toIso8601String(),
		};
	}
}


