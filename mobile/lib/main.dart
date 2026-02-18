import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop_mobile/core/router/app_router.dart';
import 'package:shop_mobile/core/theme/app_theme.dart';
import 'package:shop_mobile/core/theme/theme_cubit.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shop_mobile/features/auth/presentation/bloc/auth_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final ThemeCubit _themeCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _themeCubit = ThemeCubit();
    _appRouter = AppRouter(authBloc: _authBloc);

    // Check initial auth state
    _authBloc.add(AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _authBloc),
            BlocProvider.value(value: _themeCubit),
          ],
          child: BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDark) {
              return MaterialApp.router(
                title: 'Shop',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: _appRouter.router,
              );
            },
          ),
        );
      },
    );
  }
}
