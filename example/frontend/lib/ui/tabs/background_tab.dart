import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:tether_libs/background_service/background_service.dart';
import 'package:example/database/database.dart'; // For databaseProvider
import 'package:example/database/database_native.dart'
    if (dart.library.html) 'package:example/database/database_web.dart'
    as platform_db;

class BackgroundServiceTab extends ConsumerStatefulWidget {
  const BackgroundServiceTab({super.key});

  @override
  ConsumerState<BackgroundServiceTab> createState() =>
      _BackgroundServiceTabState();
}

class _BackgroundServiceTabState extends ConsumerState<BackgroundServiceTab> {
  bool _isServiceRunning = false;
  bool _isCheckingStatus = false;
  bool _isEnqueuingJob = false;
  String? _enqueueError;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    if (!mounted) return;
    setState(() {
      _isCheckingStatus = true;
    });
    try {
      final running = await BackgroundService.isRunning();
      if (mounted) {
        setState(() {
          _isServiceRunning = running;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isServiceRunning = false; // Assume not running on error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking service status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _enqueueDummyTask() async {
    if (!mounted) return;
    setState(() {
      _isEnqueuingJob = true;
      _enqueueError = null;
    });
    try {
      final appDb = await ref.read(databaseProvider.future);
      // The 'db' getter from AppDatabase (NativeSqliteDb/WebSqliteDb) returns SqliteDatabase from sqlite_async
      final uiDbConnection = appDb.db as SqliteConnection;

      final jobId = await BackgroundService.job(
        db: uiDbConnection,
        jobKey: 'dummyTask',
        payload: {'message': 'Hello from UI at ${DateTime.now()}'},
      );
      if (mounted) {
        if (jobId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dummy task enqueued with ID: $jobId')),
          );
        } else {
          setState(() {
            _enqueueError = 'Failed to enqueue task. Check logs.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to enqueue task. Handler might not be registered yet if service just started.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _enqueueError = 'Error enqueuing task: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error enqueuing task: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnqueuingJob = false;
        });
      }
    }
  }

  Future<void> _startService() async {
    try {
      await BackgroundService.start();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background service start requested.')),
      );
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Give time for service to start
      _checkServiceStatus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting service: $e')));
    }
  }

  Future<void> _stopService() async {
    try {
      await BackgroundService.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background service stop requested.')),
      );
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Give time for service to stop
      _checkServiceStatus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error stopping service: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Background Service Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            _isCheckingStatus
                ? const CircularProgressIndicator()
                : Text(
                  _isServiceRunning ? 'RUNNING' : 'STOPPED',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isServiceRunning ? Colors.green : Colors.red,
                  ),
                ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
              onPressed: _isCheckingStatus ? null : _checkServiceStatus,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isServiceRunning ? null : _startService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                  ),
                  child: const Text('Start Service'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: !_isServiceRunning ? null : _stopService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                  ),
                  child: const Text('Stop Service'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'Enqueue Background Task',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _isEnqueuingJob
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  icon: const Icon(Icons.send_to_mobile),
                  label: const Text('Enqueue Dummy Task'),
                  onPressed: !_isServiceRunning ? null : _enqueueDummyTask,
                ),
            if (!_isServiceRunning && !_isEnqueuingJob)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Service must be running to enqueue tasks.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_enqueueError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _enqueueError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              "Note: The 'Dummy Task' simulates 15 seconds of work. Check your console/log output to see messages from the background service and job handler. The notification will also update on Android if the task completes.",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
