import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_parking/features/vehicle/models/vehicle.dart';
import 'package:z_parking/features/vehicle/repository/vehicle_repository.dart';

sealed class VehicleListEvent extends Equatable {
	const VehicleListEvent();
	@override
	List<Object?> get props => [];
}

class VehicleListRefreshed extends VehicleListEvent {
	const VehicleListRefreshed();
}

class VehicleListNextPageRequested extends VehicleListEvent {
	const VehicleListNextPageRequested();
}

sealed class VehicleListState extends Equatable {
	const VehicleListState();
	@override
	List<Object?> get props => [];
}

class VehicleListInitial extends VehicleListState {
	const VehicleListInitial();
}

class VehicleListLoading extends VehicleListState {
	const VehicleListLoading();
}

class VehicleListLoaded extends VehicleListState {
	const VehicleListLoaded({required this.items, required this.hasMore});
	final List<Vehicle> items;
	final bool hasMore;
	@override
	List<Object?> get props => [items, hasMore];
}

class VehicleListFailure extends VehicleListState {
	const VehicleListFailure(this.message);
	final String message;
	@override
	List<Object?> get props => [message];
}

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
	VehicleListBloc(this._repository) : super(const VehicleListInitial()) {
		on<VehicleListRefreshed>(_onRefresh);
		on<VehicleListNextPageRequested>(_onNextPage);
	}

	final VehicleRepository _repository;
	int _page = 1;
	final int _pageSize = 10;
	bool _isLoading = false;
	bool _hasMore = true;
	final List<Vehicle> _items = <Vehicle>[];

	Future<void> _onRefresh(VehicleListRefreshed event, Emitter<VehicleListState> emit) async {
		_page = 1;
		_hasMore = true;
		_items.clear();
		emit(const VehicleListLoading());
		await _loadPage(emit);
	}

	Future<void> _onNextPage(VehicleListNextPageRequested event, Emitter<VehicleListState> emit) async {
		if (_isLoading || !_hasMore) return;
		await _loadPage(emit);
	}

	Future<void> _loadPage(Emitter<VehicleListState> emit) async {
		_isLoading = true;
		try {
			final int skip = (_page - 1) * _pageSize;
			final result = await _repository.list(skip: skip, limit: _pageSize);
			_items.addAll(result.items);
			final int loaded = _items.length;
			final int total = result.total;
			if (total > 0) {
				_hasMore = loaded < total && result.items.isNotEmpty;
			} else {
				_hasMore = result.items.length == _pageSize;
			}
			_page += 1;
			emit(VehicleListLoaded(items: List<Vehicle>.unmodifiable(_items), hasMore: _hasMore));
		} catch (e) {
			emit(VehicleListFailure(e.toString()));
		} finally {
			_isLoading = false;
		}
	}
}


