import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/plantas/domain/entities/planta.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // Registrar adaptadores de Planta
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PlantaAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TipoLuzAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(FrecuenciaRiegoAdapter());
  }

  // Abrir la caja de plantas
  await Hive.openBox<Planta>('plantas');

  runApp(const ProviderScope(child: ViveroApp()));
}

class ViveroApp extends StatelessWidget {
  const ViveroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Vivero de Plantas',
      theme: AppTheme.light,
    );
  }
}
