import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majdoor/screens/chat/chatscreen.dart';
import 'package:flutter/services.dart';
import 'package:majdoor/services/worker_service.dart';
import 'package:majdoor/services/worker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({Key? key}) : super(key: key);

  @override
  _ChatDashboardState createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final WorkerService _workerService = WorkerService();
  List<Worker> _workers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://sangharsh-backend.onrender.com/api/labors'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> workersJson = json.decode(response.body);
        _workers = workersJson.map((json) => Worker.fromJson(json)).toList();
      } else {
        print('Error loading workers: ${response.body}');
      }
    } catch (e) {
      print('Error loading workers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Worker> get filteredWorkers {
    if (_searchController.text.isEmpty) {
      return _workers;
    }
    return _workers.where((worker) {
      return worker.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          worker.category
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F9FC);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtleTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: backgroundColor,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(color: textColor),
                decoration: InputDecoration(
                  hintText: "Search workers...",
                  hintStyle: GoogleFonts.poppins(color: subtleTextColor),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                autofocus: true,
              )
            : Text(
                "Chats",
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: textColor,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: textColor,
            ),
            onPressed: _loadWorkers,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: primaryColor,
              unselectedLabelColor: subtleTextColor,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: "All Chats"),
                Tab(text: "Unread"),
                Tab(text: "Active"),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                // All Chats Tab
                _buildChatList(
                  filteredWorkers,
                  backgroundColor,
                  cardColor,
                  textColor,
                  subtleTextColor,
                  primaryColor,
                ),

                // Unread Chats Tab
                _buildChatList(
                  filteredWorkers
                      .where((worker) => worker.unreadCount > 0)
                      .toList(),
                  backgroundColor,
                  cardColor,
                  textColor,
                  subtleTextColor,
                  primaryColor,
                ),

                // Active Chats Tab
                _buildChatList(
                  filteredWorkers.where((worker) => worker.isOnline).toList(),
                  backgroundColor,
                  cardColor,
                  textColor,
                  subtleTextColor,
                  primaryColor,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          // Start a new chat
        },
      ),
    );
  }

  Widget _buildChatList(
    List<Worker> chatList,
    Color backgroundColor,
    Color cardColor,
    Color textColor,
    Color? subtleTextColor,
    Color primaryColor,
  ) {
    if (chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: subtleTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              "No chats found",
              style: GoogleFonts.poppins(
                color: subtleTextColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        final worker = chatList[index];
        return _buildChatTile(
          worker,
          backgroundColor,
          cardColor,
          textColor,
          subtleTextColor,
          primaryColor,
        );
      },
    );
  }

  Widget _buildChatTile(
    Worker worker,
    Color backgroundColor,
    Color cardColor,
    Color textColor,
    Color? subtleTextColor,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          // Navigate to chat screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                laborerName: worker.name,
                laborerJob: worker.category,
                laborerImageUrl: worker.imageUrl,
                laborerRating: worker.rating,
                pricePerDay: worker.pricePerDay,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'avatar_${worker.name}',
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.5),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(worker.imageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (worker.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: backgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            worker.name,
                            style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            worker.lastMessageTime ?? 'No messages',
                            style: GoogleFonts.poppins(
                              color: subtleTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              worker.category,
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            worker.rating.toString(),
                            style: GoogleFonts.poppins(
                              color: subtleTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              worker.lastMessage ?? 'No message',
                              style: GoogleFonts.poppins(
                                color: worker.unreadCount > 0
                                    ? textColor
                                    : subtleTextColor,
                                fontSize: 13,
                                fontWeight: worker.unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (worker.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                worker.unreadCount.toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
