import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_parking/features/vehicle/models/vehicle.dart';
import 'package:z_parking/features/vehicle/repository/vehicle_repository.dart';

sealed class VehicleCrudEvent extends Equatable {
	const VehicleCrudEvent();
	@override
	List<Object?> get props => [];
}

class VehicleCreated extends VehicleCrudEvent {
	const VehicleCreated({required this.name, required this.color, required this.vehicleNumber, this.model});
	final String name;
	final String color;
	final String vehicleNumber;
	final String? model;
}

class VehicleUpdated extends VehicleCrudEvent {
	const VehicleUpdated({required this.id, required this.name, required this.color, required this.vehicleNumber, this.model});
	final String id;
	final String name;
	final String color;
	final String vehicleNumber;
	final String? model;
}

class VehicleDeleted extends VehicleCrudEvent {
	const VehicleDeleted(this.id);
	final String id;
}

sealed class VehicleCrudState extends Equatable {
	const VehicleCrudState();
	@override
	List<Object?> get props => [];
}

class VehicleCrudInitial extends VehicleCrudState {
	const VehicleCrudInitial();
}

class VehicleCrudLoading extends VehicleCrudState {
	const VehicleCrudLoading();
}

class VehicleCrudSuccess extends VehicleCrudState {
	const VehicleCrudSuccess(this.vehicle);
	final Vehicle? vehicle;
	@override
	List<Object?> get props => [vehicle];
}

class VehicleCrudFailure extends VehicleCrudState {
	const VehicleCrudFailure(this.message);
	final String message;
	@override
	List<Object?> get props => [message];
}

class VehicleCrudBloc extends Bloc<VehicleCrudEvent, VehicleCrudState> {
	VehicleCrudBloc(this._repository) : super(const VehicleCrudInitial()) {
		on<VehicleCreated>(_onCreate);
		on<VehicleUpdated>(_onUpdate);
		on<VehicleDeleted>(_onDelete);
	}

	final VehicleRepository _repository;

	Future<void> _onCreate(VehicleCreated event, Emitter<VehicleCrudState> emit) async {
		emit(const VehicleCrudLoading());
		try {
			final vehicle = await _repository.create(
				name: event.name,
				color: event.color,
				vehicleNumber: event.vehicleNumber,
				model: event.model,
			);
			emit(VehicleCrudSuccess(vehicle));
		} catch (e) {
			emit(VehicleCrudFailure(e.toString()));
		}
	}

	Future<void> _onUpdate(VehicleUpdated event, Emitter<VehicleCrudState> emit) async {
		emit(const VehicleCrudLoading());
		try {
			final vehicle = await _repository.edit(
				id: event.id,
				name: event.name,
				color: event.color,
				vehicleNumber: event.vehicleNumber,
				model: event.model,
			);
			emit(VehicleCrudSuccess(vehicle));
		} catch (e) {
			emit(VehicleCrudFailure(e.toString()));
		}
	}

	Future<void> _onDelete(VehicleDeleted event, Emitter<VehicleCrudState> emit) async {
		emit(const VehicleCrudLoading());
		try {
			await _repository.deleteById(event.id);
			emit(const VehicleCrudSuccess(null));
		} catch (e) {
			emit(VehicleCrudFailure(e.toString()));
		}
	}
}


