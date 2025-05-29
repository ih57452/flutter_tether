// import 'package:example/database/supabase_select_builders.dart';

import 'dart:async'; // For Future
import 'dart:ui'; // For DartPluginRegistrant
import 'package:example/ui/tabs/background_tab.dart';
import 'package:flutter/widgets.dart'; // For WidgetsFlutterBinding, DartPluginRegistrant
import 'package:sqlite_async/sqlite_async.dart';
import 'package:tether_libs/background_service/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart'; // For ServiceInstance
import 'package:example/database/database_native.dart'
    if (dart.library.html) 'package:example/database/database_web.dart'
    as platform_db;

import 'package:example/database/managers/user_preferences_manager.g.dart';
import 'package:example/models/preferences.dart';
import 'package:example/ui/tabs/feed_tab.dart';
import 'package:example/ui/tabs/preferences_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:example/database/database.dart';
import 'package:example/ui/tabs/search_feed_tab.dart';
import 'package:example/ui/tabs/crud_tab.dart';

// --- Background Service Initialization Callback ---
@pragma('vm:entry-point')
Future<void> _myAppBackgroundInitialization(ServiceInstance service) async {
  // IMPORTANT: This function runs in a separate isolate.
  // Ensure all necessary plugins are initialized.
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  print("BackgroundService: MyAppBackgroundInitialization - Starting...");

  // Initialize database FOR THIS ISOLATE
  // Each isolate needs its own connection.
  try {
    final appDb =
        platform_db.getDatabase(); // platform_db is from conditional import
    await appDb
        .initialize(); // This runs migrations, including for background_service_jobs
    final SqliteConnection backgroundDbConnection =
        appDb.db as SqliteConnection;
    BackgroundService.setBackgroundDbConnection(backgroundDbConnection);
    print(
      "BackgroundService: MyAppBackgroundInitialization - Background DB connection set.",
    );
  } catch (e, s) {
    print(
      "BackgroundService: MyAppBackgroundInitialization - CRITICAL ERROR initializing background DB: $e\n$s",
    );
    // If DB is critical for all jobs, consider stopping the service.
    service.stopSelf();
    return;
  }

  // Register job handlers
  BackgroundService.registerJobHandler('dummyTask', _dummyJobHandler);
  print(
    "BackgroundService: MyAppBackgroundInitialization - Job handlers registered.",
  );

  print("BackgroundService: MyAppBackgroundInitialization - Complete.");
}

// --- Dummy Job Handler ---
@pragma('vm:entry-point')
Future<void> _dummyJobHandler(
  ServiceInstance service,
  Map<String, dynamic>? payload,
  SqliteConnection db, // This is the background isolate's DB connection
) async {
  print("BackgroundService: DummyJobHandler - Started with payload: $payload");

  // Simulate work
  await Future.delayed(const Duration(seconds: 15));

  print("BackgroundService: DummyJobHandler - Finished.");

  // Optionally update notification (Android specific example)
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      service.setForegroundNotificationInfo(
        title: "Dummy Task Completed",
        content: "The background task finished successfully.",
      );
      // Revert to default notification after a few seconds
      Future.delayed(const Duration(seconds: 10), () {
        // Check if service might have stopped
        service.setForegroundNotificationInfo(
          title: "Flutter Tether Demo Service", // Use the initial title
          content: "Performing background tasks...", // Use the initial content
        );
      });
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (as before)
  await Supabase.initialize(
    url: 'http://127.0.0.1:54321',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );
  print("Main Isolate: Supabase Initialized.");

  // Initialize Background Service
  // This should be called once.
  await BackgroundService.initialize(
    appInitializationCallback: _myAppBackgroundInitialization,
    initialNotificationTitle: "Flutter Tether Demo Service",
    initialNotificationContent: "Performing background tasks...",
    // Optional: if you have a custom icon in android/app/src/main/res/drawable
    // notificationIconName: 'ic_bg_service_small', // Ensure this icon exists
  );
  print("Main Isolate: BackgroundService Configured.");

  // Ensure the service is started (if not auto-starting or to be sure)
  // BackgroundService.start(); // androidConfiguration.autoStart is true by default

  // Initialize preferences (as before, but after Supabase and BG service)
  // Using a temporary container for this pre-runApp setup if needed.
  // For robust Riverpod usage, ensure providers are available when read.
  // The databaseProvider will be properly initialized by Riverpod later.
  // For pre-runApp tasks needing the DB, direct initialization might be safer
  // or ensure the ProviderContainer is correctly set up.
  // For this example, we'll assume ensureDefaultPreferences can run with a temporary container
  // or that its dependencies are met.
  final container = ProviderContainer();
  try {
    // Ensure database is ready for preference manager if it depends on it.
    // This is a bit tricky before ProviderScope is built.
    // For simplicity, if userPreferencesManagerProvider depends on databaseProvider,
    // this might need adjustment or ensure database is initialized first.
    // The databaseProvider itself initializes the DB.
    // Let's assume ensureDefaultPreferences can handle if DB is not immediately ready
    // or it's initialized synchronously by its provider.
    // final appDb = await container.read(databaseProvider.future); // This would initialize the main DB
    // print("Main Isolate: Main DB Initialized for Prefs: ${appDb.db.path}");

    final prefsManager = container.read(userPreferencesManagerProvider);
    await prefsManager.ensureDefaultPreferences(defaultAppSettings);
    print("Main Isolate: Default preferences ensured.");
  } catch (e, s) {
    print('Main Isolate: Error ensuring default preferences: $e\n$s');
    // Handle error appropriately
  } finally {
    container.dispose(); // Dispose the temporary container
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tether Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = <Tab>[
    const Tab(text: 'Search', icon: Icon(Icons.search)),
    const Tab(text: 'Feed', icon: Icon(Icons.list_alt)),
    const Tab(text: 'CRUD', icon: Icon(Icons.edit_document)),
    const Tab(text: 'Preferences', icon: Icon(Icons.settings)),
    const Tab(text: 'Background', icon: Icon(Icons.sync_alt)), // New Tab
  ];

  final List<Widget> _tabViews = <Widget>[
    const SearchFeedTab(),
    const FeedTab(),
    const CrudTab(),
    const PreferencesTab(),
    const BackgroundServiceTab(), // New TabView
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: _tabs.length,
    ); // Ensure length matches
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Tether Demo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // Ensure the database is initialized before showing content
          final dbAsyncValue = ref.watch(databaseProvider);
          return dbAsyncValue.when(
            data:
                (_) =>
                    TabBarView(controller: _tabController, children: _tabViews),
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, stack) =>
                    Center(child: Text('Error initializing database: $err')),
          );
        },
      ),
    );
  }
}
