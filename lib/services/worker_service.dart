import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:majdoor/services/worker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerService {
  // Singleton pattern
  static final WorkerService _instance = WorkerService._internal();
  factory WorkerService() => _instance;
  WorkerService._internal();

  // In-memory cache of workers
  List<Worker> _workers = [];

  // Key for storing workers in SharedPreferences
  static const String _storageKey = 'workers_data';

  // Get all workers (from cache, local storage, or API)
  Future<List<Worker>> getWorkers() async {
    // If we already have workers, return them
    if (_workers.isNotEmpty) {
      return _workers;
    }

    // Fetch from API
    try {
      final response =
          await http.get(Uri.parse('https://8402024d-94f3-49d9-a56d-2dc6043a9a34-00-2mher60iizzyr.pike.replit.dev/api/labors'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _workers = data.map((item) => Worker.fromJson(item)).toList();

        // Save to local storage
        await _saveWorkersToStorage();

        return _workers;
      } else {
        print('Failed to load workers from API: ${response.body}');
      }
    } catch (e) {
      print('Error fetching workers from API: $e');
    }

    // Fallback to local storage if API fails
    return await _loadWorkersFromStorage();
  }

  // Load workers from local storage
  Future<List<Worker>> _loadWorkersFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workersJson = prefs.getString(_storageKey);

      if (workersJson != null) {
        final List<dynamic> decoded = json.decode(workersJson);
        _workers = decoded.map((item) => Worker.fromMap(item)).toList();
        return _workers;
      }
    } catch (e) {
      print('Error loading workers from storage: $e');
    }

    return [];
  }

  // Save workers to local storage
  Future<void> _saveWorkersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workersJson = json.encode(_workers.map((w) => w.toMap()).toList());
      await prefs.setString(_storageKey, workersJson);
    } catch (e) {
      print('Error saving workers to storage: $e');
    }
  }

  // Get a specific worker by ID
  Future<Worker?> getWorkerById(String id) async {
    final workers = await getWorkers();
    try {
      return workers.firstWhere((worker) => worker.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get workers by category
  Future<List<Worker>> getWorkersByCategory(String category) async {
    final workers = await getWorkers();
    if (category == 'All') {
      return workers;
    }
    return workers.where((worker) => worker.category == category).toList();
  }

  // Search workers by name or location
  Future<List<Worker>> searchWorkers(String query) async {
    final workers = await getWorkers();
    return workers.where((worker) {
      return worker.name.toLowerCase().contains(query.toLowerCase()) ||
          worker.location.toLowerCase().contains(query.toLowerCase()) ||
          worker.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Toggle bookmark status
  Future<void> toggleBookmark(String workerId) async {
    final workers = await getWorkers();
    final index = workers.indexWhere((worker) => worker.id == workerId);

    if (index != -1) {
      final worker = workers[index];
      _workers[index] = worker.copyWith(isBookmarked: !worker.isBookmarked);
      await _saveWorkersToStorage();
    }
  }

  // Update a worker's chat information
  Future<void> updateWorkerChat(
    String workerId, {
    String? lastMessage,
    int? unreadCount,
    bool? isOnline,
  }) async {
    final workers = await getWorkers();
    final index = workers.indexWhere((worker) => worker.id == workerId);

    if (index != -1) {
      final worker = workers[index];

      _workers[index] = worker.copyWith(
        lastMessage: lastMessage,
        lastMessageTime:
            lastMessage != null ? _formatTime(DateTime.now()) : null,
        unreadCount: unreadCount,
        isOnline: isOnline,
      );

      await _saveWorkersToStorage();
    }
  }

  // Mark all messages as read for a worker
  Future<void> markAsRead(String workerId) async {
    await updateWorkerChat(workerId, unreadCount: 0);
  }

  // Format time for last message
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      // Today, show time
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (now.difference(time).inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(time).inDays < 7) {
      // Within a week
      return '${now.difference(time).inDays} days ago';
    } else {
      // More than a week
      return 'Last week';
    }
  }

  Future<List<Worker>> getFavouriteWorkers() async {
    final workers = await getWorkers();
    return workers.where((worker) => worker.isFavourite).toList();
  }

  Future<bool> isFavourite(String workerId) async {
    final workers = await getWorkers();
    final workerIndex = workers.indexWhere((w) => w.id == workerId);
    if (workerIndex != -1) {
      return workers[workerIndex].isFavourite;
    }
    return false;
  }

  Future<void> toggleFavourite(String workerId) async {
    final prefs = await SharedPreferences.getInstance();
    final workers = await getWorkers();
    final workerIndex = workers.indexWhere((w) => w.id == workerId);

    if (workerIndex != -1) {
      // Toggle the favorite status
      workers[workerIndex].isFavourite = !workers[workerIndex].isFavourite;

      // Save updated worker list
      final workersJson = workers.map((w) => w.toJson()).toList();
      await prefs.setString('workers_data', jsonEncode(workersJson));
    }
  }
}
