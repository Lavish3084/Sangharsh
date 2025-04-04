import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<NotificationItem> _notifications = demoNotifications;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleUnreadFilter() {
    setState(() {
      _showUnreadOnly = !_showUnreadOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final displayedNotifications = _showUnreadOnly
        ? _notifications.where((n) => !n.isRead).toList()
        : _notifications;

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120.0,
              backgroundColor: isDark
                  ? colorScheme.surfaceVariant
                  : colorScheme.primary.withOpacity(0.1),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    color: isDark ? Colors.white : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -20,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: -40,
                      bottom: -30,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: colorScheme.secondary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _showUnreadOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
                    color: isDark ? Colors.white : colorScheme.primary,
                  ),
                  onPressed: _toggleUnreadFilter,
                  tooltip: 'Show unread only',
                ),
                if (unreadCount > 0)
                  IconButton(
                    icon: Icon(
                      Icons.done_all,
                      color: isDark ? Colors.white : colorScheme.primary,
                    ),
                    onPressed: _markAllAsRead,
                    tooltip: 'Mark all as read',
                  ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (displayedNotifications.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 80,
                              color: colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showUnreadOnly
                                  ? 'No unread notifications'
                                  : 'No notifications yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...displayedNotifications.map((notification) {
                    final animation = CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    );

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: NotificationCard(
                          notification: notification,
                          onTap: () {
                            setState(() {
                              notification.isRead = true;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = DateFormat('h:mm a').format(notification.time);
    final date = _formatDate(notification.time);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead
            ? null
            : colorScheme.primaryContainer.withOpacity(0.3),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: notification.isRead
              ? BorderSide.none
              : BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: notification.typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          notification.typeIcon,
                          color: notification.typeColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 62.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month) {
      if (date.day == now.day) {
        return 'Today';
      } else if (date.day == now.day - 1) {
        return 'Yesterday';
      }
    }
    return DateFormat('MMM d').format(date);
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final IconData typeIcon;
  final Color typeColor;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.typeIcon,
    required this.typeColor,
    this.isRead = false,
  });
}

// Demo data
final List<NotificationItem> demoNotifications = [
  NotificationItem(
    id: '1',
    title: 'New Message',
    message: 'Alex sent you a message: "Hey, are we still meeting today?"',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
    typeIcon: Icons.message,
    typeColor: Colors.blue,
    isRead: false,
  ),
  NotificationItem(
    id: '2',
    title: 'Payment Successful',
    message: 'Your payment of \$49.99 has been processed successfully.',
    time: DateTime.now().subtract(const Duration(hours: 2)),
    typeIcon: Icons.payment,
    typeColor: Colors.green,
    isRead: false,
  ),
  NotificationItem(
    id: '3',
    title: 'New Feature Available',
    message: 'Check out our new dark mode feature! Tap to enable it in settings.',
    time: DateTime.now().subtract(const Duration(hours: 5)),
    typeIcon: Icons.star,
    typeColor: Colors.amber,
    isRead: true,
  ),
  NotificationItem(
    id: '4',
    title: 'Account Security',
    message: 'We noticed a login from a new device. Please verify if this was you.',
    time: DateTime.now().subtract(const Duration(days: 1)),
    typeIcon: Icons.security,
    typeColor: Colors.red,
    isRead: false,
  ),
  NotificationItem(
    id: '5',
    title: 'Weekly Summary',
    message: 'Your activity summary for last week is now available. Tap to view details.',
    time: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    typeIcon: Icons.insights,
    typeColor: Colors.purple,
    isRead: true,
  ),
  NotificationItem(
    id: '6',
    title: 'Event Reminder',
    message: 'Your scheduled event "Team Meeting" starts in 30 minutes.',
    time: DateTime.now().subtract(const Duration(days: 2)),
    typeIcon: Icons.event,
    typeColor: Colors.orange,
    isRead: true,
  ),
  NotificationItem(
    id: '7',
    title: 'Friend Request',
    message: 'Sarah Johnson sent you a friend request.',
    time: DateTime.now().subtract(const Duration(days: 3)),
    typeIcon: Icons.person_add,
    typeColor: Colors.teal,
    isRead: true,
  ),
  NotificationItem(
    id: '8',
    title: 'Limited Offer',
    message: 'Exclusive offer: Get 50% off on premium subscription for the next 24 hours!',
    time: DateTime.now().subtract(const Duration(days: 3, hours: 7)),
    typeIcon: Icons.local_offer,
    typeColor: Colors.deepPurple,
    isRead: false,
  ),
];
