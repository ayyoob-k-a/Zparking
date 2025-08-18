import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/locator.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/view/login_page.dart';
import 'features/vehicle/bloc/vehicle_crud_bloc.dart';
import 'features/vehicle/repository/vehicle_repository.dart';
import 'features/vehicle/view/vehicle_form_page.dart';
import 'features/vehicle/view/vehicle_list_page.dart';
import 'features/vehicle/view/vehicle_create_page.dart';
import 'features/vehicle/view/vehicle_edit_page.dart';

import 'core/navigation_utils.dart';
import 'core/app_theme.dart';
import 'core/app_constants.dart';
import 'package:sizer/sizer.dart';
import 'core/theme_cubit.dart';
import 'features/splash/view/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}
  

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => sl<AuthRepository>()),
        RepositoryProvider<VehicleRepository>(create: (_) => sl<VehicleRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (ctx) => AuthBloc(ctx.read<AuthRepository>())),
          BlocProvider<VehicleCrudBloc>(create: (ctx) => VehicleCrudBloc(ctx.read<VehicleRepository>())),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return BlocProvider<ThemeCubit>(
              create: (_) => ThemeCubit(),
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  return MaterialApp(
                    title: AppStrings.appTitle,
                    theme: buildLightTheme(),
                    darkTheme: buildDarkTheme(),
                    themeMode: mode,
                    navigatorKey: NavigationUtils.navigatorKey,
                    initialRoute: SplashPage.routeName,
                    routes: {
                      SplashPage.routeName: (_) => const SplashPage(),
                      LoginPage.routeName: (_) => const LoginPage(),
                      VehicleListPage.routeName: (_) => const VehicleListPage(),
                      VehicleFormPage.routeName: (_) => const VehicleFormPage(),
                      VehicleCreatePage.routeName: (_) => const VehicleCreatePage(),
                      VehicleEditPage.routeName: (_) => const VehicleEditPage(),
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
