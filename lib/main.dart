import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/plantas/domain/entities/planta.dart';
import 'features/artesanias/domain/entities/artesania.dart';
import 'features/sustratos/domain/entities/sustrato.dart';
import 'features/categorias/domain/entities/categoria.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive
  await Hive.initFlutter();

  // Registrar adaptadores - Plantas
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PlantaAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TipoLuzAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(FrecuenciaRiegoAdapter());
  }

  // Registrar adaptadores - Artesanías
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(ArtesaniaAdapter());
  }

  // Registrar adaptadores - Sustratos
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(SustratoAdapter());
  }

  // Registrar adaptadores - Categorías
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(CategoriaAdapter());
  }

  // Abrir cajas
  await Hive.openBox<Planta>('plantas');
  await Hive.openBox<Artesania>('artesanias');
  await Hive.openBox<Sustrato>('sustratos');
  await Hive.openBox<Categoria>('categorias');

  runApp(const ProviderScope(child: ViveroApp()));
}

class ViveroApp extends StatelessWidget {
  const ViveroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Vivero Balam',
      theme: AppTheme.light,
    );
  }
}

