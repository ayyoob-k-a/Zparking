import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:z_parking/core/app_constants.dart';
import 'package:z_parking/core/navigation_utils.dart';
import 'package:z_parking/features/vehicle/bloc/vehicle_crud_bloc.dart';
import 'package:z_parking/features/vehicle/models/vehicle.dart';

class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key});

  static const String routeName = '/vehicle-form';

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Vehicle? _editing;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Vehicle && _editing == null) {
      _editing = args;
      _nameController.text = args.name;
      _colorController.text = args.color;
      _numberController.text = args.vehicleNumber;
      _modelController.text = args.model ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _colorController.dispose();
    _numberController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      // Add haptic feedback for validation errors
      HapticFeedback.lightImpact();
      return;
    }
    
    HapticFeedback.mediumImpact();
    final String? model = _modelController.text.trim().isEmpty 
        ? null 
        : _modelController.text.trim();
    final bloc = context.read<VehicleCrudBloc>();
    
    if (_editing == null) {
      bloc.add(VehicleCreated(
        name: _nameController.text.trim(),
        color: _colorController.text.trim(),
        vehicleNumber: _numberController.text.trim(),
        model: model,
      ));
    } else {
      bloc.add(VehicleUpdated(
        id: _editing!.id,
        name: _nameController.text.trim(),
        color: _colorController.text.trim(),
        vehicleNumber: _numberController.text.trim(),
        model: model,
      ));
    }
  }

  Future<void> _onDelete() async {
    if (_editing == null) return;
    
    HapticFeedback.lightImpact();
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, 
                 color: Theme.of(context).colorScheme.error, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Vehicle'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    HapticFeedback.mediumImpact();
    context.read<VehicleCrudBloc>().add(VehicleDeleted(_editing!.id));
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool optional = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label + (optional ? ' (Optional)' : ''),
          prefixIcon: Icon(icon, size: 22),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final bool isEditing = _editing != null;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isEditing ? Icons.edit_rounded : Icons.add_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Update Vehicle' : 'Add New Vehicle',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing 
                          ? 'Make changes to your vehicle details'
                          : 'Enter your vehicle information below',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _editing != null;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          if (isEditing)
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: _onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      body: BlocConsumer<VehicleCrudBloc, VehicleCrudState>(
        listener: (context, state) {
          if (state is VehicleCrudSuccess) {
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(isEditing ? 'Vehicle updated successfully!' : 'Vehicle created successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
            NavigationUtils.pop(true);
          }
          if (state is VehicleCrudFailure) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is VehicleCrudLoading;
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: AbsorbPointer(
                      absorbing: isLoading,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              
                              // Vehicle Name Field
                              _buildFormField(
                                controller: _nameController,
                                label: AppStrings.name,
                                icon: Icons.directions_car_rounded,
                                validator: (v) => (v == null || v.trim().isEmpty) 
                                    ? 'Vehicle name is required' 
                                    : null,
                              ),
                              
                              // Color Field
                              _buildFormField(
                                controller: _colorController,
                                label: AppStrings.color,
                                icon: Icons.palette_rounded,
                                validator: (v) => (v == null || v.trim().isEmpty) 
                                    ? 'Vehicle color is required' 
                                    : null,
                              ),
                              
                              // Vehicle Number Field
                              _buildFormField(
                                controller: _numberController,
                                label: AppStrings.vehicleNumber,
                                icon: Icons.confirmation_number_rounded,
                                keyboardType: TextInputType.text,
                                validator: (v) => (v == null || v.trim().isEmpty) 
                                    ? 'Vehicle number is required' 
                                    : null,
                              ),
                              
                              // Model Field (Optional)
                              _buildFormField(
                                controller: _modelController,
                                label: AppStrings.modelOptional,
                                icon: Icons.info_outline_rounded,
                                optional: true,
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Submit Button
                              Container(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _onSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: isLoading ? 0 : 2,
                                    shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  ),
                                  child: isLoading
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Theme.of(context).colorScheme.onPrimary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              isEditing ? 'Updating...' : 'Creating...',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isEditing 
                                                  ? Icons.update_rounded 
                                                  : Icons.add_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isEditing ? AppStrings.update : AppStrings.create,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              
                              // Bottom spacing for safe area
                              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}