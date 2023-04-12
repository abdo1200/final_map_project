import 'package:final_map_project/app_router.dart';
import 'package:final_map_project/helpers/location_helper.dart';
import 'package:final_map_project/provider/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'constants/my_strings.dart';

late String initialRoute;
late Position? position;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initialRoute = mapScreen;
  await LocationHelper.getCurrentLocation().then((value) {
    position = value;
  });
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => MapProvider()),
  ], child: MyApp(appRouter: AppRouter())));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: initialRoute,
    );
  }
}
