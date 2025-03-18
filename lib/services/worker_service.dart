import 'dart:convert';
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

    // Try to load from local storage first
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

    // If no workers in storage, use dummy data
    await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay

    _workers = [
      Worker(
        id: '1',
        name: 'Himanshu',
        location: 'Bihar, India',
        rating: 4.5,
        pricePerDay: 500,
        imageUrl: 'assets/images/1.png',
        category: 'Labourer',
        specialization: 'Heavy Lifting',
        experience: 3,
        lastMessage: 'I can start work tomorrow',
        lastMessageTime: '10:30 AM',
        unreadCount: 2,
        isOnline: true,
      ),
      Worker(
        id: '2',
        name: 'Rajesh Kumar',
        location: 'Delhi, India',
        rating: 4.7,
        pricePerDay: 600,
        imageUrl: 'assets/images/2.png',
        category: 'Electrician',
        specialization: 'Wiring & Repairs',
        experience: 5,
        lastMessage: 'The wiring needs to be replaced',
        lastMessageTime: 'Yesterday',
        unreadCount: 0,
        isOnline: false,
      ),
      Worker(
        id: '3',
        name: 'Sanm',
        location: 'Delhi, India',
        rating: 4.7,
        pricePerDay: 600,
        imageUrl: 'assets/images/3.png',
        category: 'Plumbing',
        specialization: 'Pipe Fitting',
        experience: 4,
        lastMessage: 'I fixed the leaking pipe',
        lastMessageTime: '2 days ago',
        unreadCount: 0,
        isOnline: true,
      ),
      Worker(
        id: '4',
        name: 'Chulla',
        location: 'Delhi, India',
        rating: 4.7,
        pricePerDay: 600,
        imageUrl: 'assets/images/4.png',
        category: 'Labourer',
        specialization: 'Construction',
        experience: 2,
        lastMessage: 'When do you need me to come?',
        lastMessageTime: '3 days ago',
        unreadCount: 1,
        isOnline: false,
      ),
      Worker(
        id: '5',
        name: 'Mahesh',
        location: 'Delhi, India',
        rating: 4.7,
        pricePerDay: 600,
        imageUrl: 'assets/images/5.png',
        category: 'Carpenter',
        specialization: 'Furniture Making',
        experience: 6,
        lastMessage: 'I can build that cabinet for you',
        lastMessageTime: 'Last week',
        unreadCount: 0,
        isOnline: true,
      ),
    ];

    // Save to local storage
    _saveWorkersToStorage();

    return _workers;
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
}
