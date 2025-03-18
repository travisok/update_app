import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internal_app/infrastructure/network/api/api_client.dart';
import 'package:internal_app/infrastructure/network/api/dio_client.dart';
import 'package:internal_app/infrastructure/network/services/cache_helper.dart';
import 'package:internal_app/infrastructure/state_managemnt/user/user_bloc.dart';
import 'package:internal_app/splash_screen/splash_screen.dart';
import 'dart:ui' as ui; 


Future<void> main() async {
  await dotenv.load(fileName: ".env");
  print(dotenv.env);
  WidgetsFlutterBinding.ensureInitialized();

  // Warm up the shaders
  _warmUpShaders();

  final dioClient = DioClient(
    dotenv.env['BASE_URL'] ?? '',
    apiKey: dotenv.env['API_KEY'],
  );

  
  var token = CacheHelper.getToken();
  print('Loaded token at startup: $token');
  //dioClient.setAuthorizationToken(token);
  

  final apiClient = ApiClient(dioClient.dio);

  GoogleFonts.config.allowRuntimeFetching = true;
  // runApp(
  //   MultiRepositoryProvider(
  //     providers: [
  //       RepositoryProvider<ApiClient>(
  //         create: (_) => apiClient
  //       ),
  //     ],
  //     child: BlocProvider(
  //       create: (context) => UserBloc(apiClient),
  //       child: MyApp(apiClient: apiClient),
  //     ),
  //   )
  // );

  runApp(
  MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ApiClient>(
        create: (_) => apiClient, // Ensure this provides a single instance
      ),
    ],
    child: BlocProvider<UserBloc>(
      create: (context) {
        final apiClientFromContext = RepositoryProvider.of<ApiClient>(context);
        print('Initializing UserBloc with ApiClient from context: $apiClientFromContext');
        return UserBloc(apiClientFromContext);
      },
      child: MyApp(apiClient: apiClient),
    ),
  ),
);

}

void _warmUpShaders() {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // Create a dummy paint object to warm up shaders
  final paintWithShadow = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
  canvas.drawCircle(Offset(50, 50), 30, paintWithShadow);

  final gradientPaint = Paint()
    ..shader = ui.Gradient.linear(
      Offset(0, 0),
      Offset(100, 100),
      [Colors.red, Colors.yellow],
    );
  canvas.drawRect(Rect.fromLTWH(0, 0, 100, 100), gradientPaint);

  // Finalize the recording to ensure shader precompiling happens
  recorder.endRecording();
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Internal App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF29CFD6)),
        useMaterial3: true,
      
      ),
      home: SplashScreen(),
    );
  }
}
