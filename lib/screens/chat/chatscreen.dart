import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:majdoor/screens/profiles/labourprofile.dart';
import 'package:majdoor/services/labourmodel.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/providers/booking_provider.dart';
import 'package:majdoor/services/booking.dart';
import 'package:majdoor/screens/bookings.dart';
import 'dart:async';

// Define the Message class only once
class Message {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String senderName;
  final String? imageUrl;
  final bool isRead;
  final String roomId;
  final String receiverName;

  Message({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.senderName,
    this.imageUrl,
    this.isRead = false,
    required this.roomId,
    required this.receiverName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] ?? '',
      isMe: json['senderName'] == 'Me',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      senderName: json['senderName'] ?? 'Unknown',
      imageUrl: json['imageUrl'],
      isRead: json['isRead'] ?? false,
      roomId: json['roomId'] ?? '',
      receiverName: json['receiverName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'roomId': roomId,
      'receiverName': receiverName,
      'imageUrl': imageUrl,
      'isRead': isRead,
    };
  }
}

// Add this at the top level of your file, outside any class
// This will maintain a single socket instance across all chat screens
IO.Socket? _globalSocket;
bool _isGlobalSocketConnected = false;

class ChatScreen extends StatefulWidget {
  final String laborerName;
  final String laborerJob;
  final String laborerImageUrl;
  final double laborerRating;
  final int pricePerDay;

  const ChatScreen({
    Key? key,
    required this.laborerName,
    required this.laborerJob,
    required this.laborerImageUrl,
    this.laborerRating = 4.8,
    required this.pricePerDay,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showEmoji = false;
  ThemeMode _themeMode = ThemeMode.light;

  // Add this at the class level
  String _chatRoomId = '';

  // Add this at the class level (inside _ChatScreenState)
  final String serverUrl =
      'https://8402024d-94f3-49d9-a56d-2dc6043a9a34-00-2mher60iizzyr.pike.replit.dev';

  // Initialize _messages as an empty list
  late List<Message> _messages = [];

  bool isConnected = false;

  // Add this field
  bool _isBooked = false;

  @override
  void initState() {
    super.initState();
    _chatRoomId = _generateChatRoomId(widget.laborerName);

    // Add periodic connection check
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (!isConnected && mounted) {
        print('🔄 Attempting periodic reconnection...');
        _reconnectSocket();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _connectToSocket();
    _loadPastMessages(); // Load past messages from the server

    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Generate a consistent chat room ID
  String _generateChatRoomId(String laborerName) {
    final currentUserId = "current_user_123";
    final laborerId = laborerName.replaceAll(' ', '_').toLowerCase();
    List<String> ids = [currentUserId, laborerId];
    ids.sort(); // Sort to ensure same ID regardless of order
    return ids.join('_');
  }

  void _connectToSocket() {
    try {
      if (_globalSocket != null) {
        if (_globalSocket!.connected) {
          print('✅ Using existing socket connection');
          _globalSocket!.emit('leaveRoom', _chatRoomId);
          _globalSocket!.emit('joinRoom', _chatRoomId);
          setState(() => isConnected = true);
          _setupSocketListeners();
          return;
        } else {
          _globalSocket!.disconnect();
          _globalSocket = null;
        }
      }

      _globalSocket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'forceNew': true,
      });

      _globalSocket!.onConnect((_) {
        print('✅ Connected to chat server');
        _isGlobalSocketConnected = true;
        if (mounted) {
          setState(() => isConnected = true);
        }
        _globalSocket!.emit('joinRoom', _chatRoomId);
        print('Joined room: $_chatRoomId');
      });

      _setupSocketListeners();
      _globalSocket!.connect();
    } catch (e) {
      print('❌ Socket initialization error: $e');
      setState(() => isConnected = false);
    }
  }

  // Separate method to set up message-specific listeners
  void _setupSocketListeners() {
    _globalSocket?.off('newMessage');

    _globalSocket?.on('newMessage', (data) {
      print('📩 Received message: $data');

      if (data['roomId'] == _chatRoomId && data['senderName'] != 'Me') {
        if (mounted) {
          setState(() {
            _messages.add(Message(
              text: data['text'] ?? '',
              isMe: false,
              timestamp: DateTime.parse(
                  data['timestamp'] ?? DateTime.now().toIso8601String()),
              senderName: data['senderName'] ?? widget.laborerName,
              roomId: _chatRoomId,
              receiverName: 'Me',
            ));
          });
          _scrollToBottom();
        }
      }
    });

    _globalSocket?.on('messageError', (error) {
      print('❌ Message error: $error');
      _showConnectionError();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // Don't disconnect the socket, just leave the room
    if (_globalSocket != null && _globalSocket!.connected) {
      _globalSocket!.emit('leaveRoom', _chatRoomId);
      print('Left chat room: $_chatRoomId');

      // Remove listeners specific to this screen
      _globalSocket!.off('newMessage');
    }

    _animationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleEmoji() {
    setState(() {
      _showEmoji = !_showEmoji;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final now = DateTime.now();

    final messageData = {
      'text': messageText,
      'senderName': 'Me',
      'timestamp': now.toIso8601String(),
      'roomId': _chatRoomId,
      'receiverName': widget.laborerName,
    };

    if (_globalSocket?.connected ?? false) {
      try {
        _globalSocket!.emit('sendMessage', messageData);
        print('📤 Message sent: $messageData');

        // Add message to local state
        setState(() {
          _messages.add(Message(
            text: messageText,
            isMe: true,
            timestamp: now,
            senderName: 'Me',
            roomId: _chatRoomId,
            receiverName: widget.laborerName,
          ));
        });

        _scrollToBottom();
      } catch (e) {
        print('❌ Error sending message: $e');
        _showConnectionError();
      }
    } else {
      print('⚠️ Socket not connected');
      _reconnectSocket();
    }

    _messageController.clear();
  }

  Future<void> _loadPastMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/messages?roomId=$_chatRoomId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages = data.map((msg) => Message.fromJson(msg)).toList();
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        });
      } else {
        print('❌ Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading messages: $e');
    }
    _scrollToBottom();
  }

  Future<void> _handleAttachment() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  // Add image picker functionality here
                  final ImagePicker _picker = ImagePicker();
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (image != null) {
                    // Handle the selected image
                    _sendImageMessage(image.path);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.file_copy),
                title: Text('Document'),
                onTap: () async {
                  Navigator.pop(context);
                  // Add file picker functionality here
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    // Handle the selected file
                    _sendFileMessage(result.files.single.path!);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Location'),
                onTap: () {
                  Navigator.pop(context);
                  // Add location sharing functionality
                  _shareLocation();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (photo != null) {
      // Handle the captured image
      _sendImageMessage(photo.path);
    }
  }

  void _sendImageMessage(String imagePath) {
    // Add logic to send image message
    final now = DateTime.now();
    setState(() {
      _messages.add(Message(
        text: '',
        isMe: true,
        timestamp: now,
        senderName: "Me",
        imageUrl: imagePath,
        roomId: _chatRoomId,
        receiverName: widget.laborerName,
      ));
    });

    // Emit message to server if connected
    if (isConnected && _globalSocket != null) {
      // Add logic to upload image and send message
    }

    _scrollToBottom();
  }

  void _sendFileMessage(String filePath) {
    final fileName = path.basename(filePath);
    final extension = path.extension(filePath).toLowerCase();
    IconData fileIcon;

    // Determine file type icon
    switch (extension) {
      case '.pdf':
        fileIcon = Icons.picture_as_pdf;
        break;
      case '.doc':
      case '.docx':
        fileIcon = Icons.description;
        break;
      case '.xls':
      case '.xlsx':
        fileIcon = Icons.table_chart;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
    }

    final now = DateTime.now();
    setState(() {
      _messages.add(Message(
        text: '',
        isMe: true,
        timestamp: now,
        senderName: "Me",
        imageUrl: filePath, // Store the file path
        roomId: _chatRoomId,
        receiverName: widget.laborerName,
      ));
    });

    // Add a clickable file message
    setState(() {
      _messages.add(Message(
        text: 'File: $fileName',
        isMe: true,
        timestamp: now,
        senderName: "Me",
        roomId: _chatRoomId,
        receiverName: widget.laborerName,
      ));
    });

    _scrollToBottom();
  }

  void _shareLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final now = DateTime.now();
      setState(() {
        _messages.add(Message(
          text: 'Location: ${position.latitude}, ${position.longitude}',
          isMe: true,
          timestamp: now,
          senderName: "Me",
          roomId: _chatRoomId,
          receiverName: widget.laborerName,
        ));
      });

      _scrollToBottom();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Replace the current _checkBookingStatus method with this:
  void _checkBookingStatus() {
    // Use Provider.of with listen: true to rebuild when bookings change
    final bookingProvider = Provider.of<BookingProvider>(context, listen: true);
    setState(() {
      _isBooked = bookingProvider.bookings.any((booking) =>
          booking.workerName == widget.laborerName &&
          (booking.status == 'pending' || booking.status == 'confirmed'));
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkBookingStatus(); // Add this line at the start of build
    final isDark = _themeMode == ThemeMode.dark;

    // Define theme colors
    final primaryColor = const Color(0xFF6C63FF);
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final secondaryBackgroundColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F9FC);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtleTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final bubbleColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final myBubbleColor = primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: widget.laborerImageUrl.isNotEmpty
                    ? Image.network(
                        widget.laborerImageUrl,
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                              'Error loading image: ${widget.laborerImageUrl}');
                          return Icon(Icons.person, size: 30);
                        },
                      )
                    : Icon(Icons.person, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.laborerName,
                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isBooked)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Online now",
                        style: GoogleFonts.poppins(
                          color: subtleTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected ? Colors.green : Colors.red,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              color: textColor,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile info card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipOval(
                    child: widget.laborerImageUrl.isNotEmpty
                        ? Image.network(
                            widget.laborerImageUrl,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  'Error loading image: ${widget.laborerImageUrl}');
                              return Icon(Icons.person, size: 30);
                            },
                          )
                        : Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.laborerJob,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.yellow, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              widget.laborerRating.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "• ₹${widget.pricePerDay}/day",
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_isBooked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Create a new booking
                          final booking = Booking(
                            id: DateTime.now().toString(),
                            workerName: widget.laborerName,
                            workerType: widget.laborerJob,
                            bookingDate: DateTime.now(),
                            price: widget.pricePerDay.toDouble(),
                            status: 'pending',
                          );

                          // Add the booking using the provider
                          Provider.of<BookingProvider>(context, listen: false)
                              .addBooking(booking);

                          // Update local state
                          setState(() {
                            _isBooked = true;
                          });

                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Booking confirmed for ${widget.laborerName}'),
                              backgroundColor: Colors.green,
                              action: SnackBarAction(
                                label: 'View Bookings',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BookingsScreen()),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Book Now",
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Booked",
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Chat messages
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        "No messages yet",
                        style: TextStyle(color: subtleTextColor),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final showDate = index == 0 ||
                            !DateUtils.isSameDay(message.timestamp,
                                _messages[index - 1].timestamp);

                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    DateFormat('MMMM d, yyyy')
                                        .format(message.timestamp),
                                    style: GoogleFonts.poppins(
                                      color: primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            _buildMessageBubble(
                              message,
                              primaryColor,
                              myBubbleColor,
                              bubbleColor,
                              textColor,
                              subtleTextColor,
                              isDark,
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Message input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: secondaryBackgroundColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            color: _showEmoji ? primaryColor : subtleTextColor,
                          ),
                          onPressed: _toggleEmoji,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: secondaryBackgroundColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.poppins(
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              hintStyle: GoogleFonts.poppins(
                                color: subtleTextColor,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.attach_file,
                                        color: subtleTextColor),
                                    onPressed: _handleAttachment,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt,
                                        color: subtleTextColor),
                                    onPressed: _handleCamera,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send,
                              color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                  if (_showEmoji)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: secondaryBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          final List<String> emojis = [
                            "😀",
                            "😃",
                            "😄",
                            "😁",
                            "😆",
                            "😅",
                            "😂",
                            "🤣",
                            "😊",
                            "😇",
                            "🙂",
                            "🙃",
                            "😉",
                            "😌",
                            "😍",
                            "🥰",
                          ];
                          return InkWell(
                            onTap: () {
                              if (index < emojis.length) {
                                _messageController.text += emojis[index];
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                index < emojis.length ? emojis[index] : "😀",
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    Message message,
    Color primaryColor,
    Color myBubbleColor,
    Color bubbleColor,
    Color textColor,
    Color? subtleTextColor,
    bool isDark,
  ) {
    // Handle file messages
    if (message.text.startsWith('File: ')) {
      return GestureDetector(
        onTap: () => _openFile(message.imageUrl!),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: message.isMe ? myBubbleColor : bubbleColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileIcon(message.text),
                color: message.isMe ? Colors.white : textColor,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.text.substring(6), // Remove 'File: ' prefix
                  style: TextStyle(
                    color: message.isMe ? Colors.white : textColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle regular messages and images
    return Padding(
      padding: EdgeInsets.only(
        left: message.isMe ? 50.0 : 10.0,
        right: message.isMe ? 10.0 : 50.0,
        top: 5.0,
        bottom: 5.0,
      ),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Card(
          color: message.isMe ? myBubbleColor : bubbleColor,
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.imageUrl != null) ...[
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      maxHeight: 200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: message.imageUrl!.startsWith('http')
                          ? Image.network(
                              message.imageUrl!,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 150,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.error_outline),
                                  ),
                                );
                              },
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      backgroundColor: Colors.black,
                                      appBar: AppBar(
                                        backgroundColor: Colors.black,
                                        iconTheme:
                                            IconThemeData(color: Colors.white),
                                      ),
                                      body: Center(
                                        child: Image.file(
                                          File(message.imageUrl!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Image.file(
                                File(message.imageUrl!),
                                fit: BoxFit.cover,
                                width: 200,
                                height: 150,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error_outline),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : textColor,
                      fontSize: 14.0,
                    ),
                  ),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp),
                      style: TextStyle(
                        color: message.isMe ? Colors.white70 : Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    if (message.isMe)
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 12.0,
                        color:
                            message.isRead ? Colors.blue[100] : Colors.white70,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getFileIcon(String text) {
    final extension = path.extension(text).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
        ),
      );
    }
  }

  // Add a reconnection method
  void _reconnectSocket() {
    if (_globalSocket != null) {
      _globalSocket!.disconnect();
      _globalSocket = null;
    }
    _connectToSocket();
  }

  // Add a method to show connection error
  void _showConnectionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Connection issue. Trying to reconnect...'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _reconnectSocket,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }
}

// Modify the LaborMarketplaceApp class to be a simple widget that returns ChatScreen
// This will be used for testing only
class LaborMarketplaceApp extends StatelessWidget {
  const LaborMarketplaceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ChatScreen(
      laborerName: "Alex Johnson",
      laborerJob: "Moving Specialist",
      laborerImageUrl: "https://picsum.photos/100/100",
      pricePerDay: 500,
      laborerRating: 4.8,
    );
  }
}
