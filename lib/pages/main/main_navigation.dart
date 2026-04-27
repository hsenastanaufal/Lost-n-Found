import 'package:flutter/material.dart';
import 'home_page.dart';
import 'notification_page.dart';
import '../reports/history_page.dart';
import 'profile_page.dart';
import '../../models/app_notification.dart';
import '../../services/firestore_service.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const MainNavigation({super.key, required this.currentUser});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(currentUser: widget.currentUser),
      NotificationPage(userEmail: widget.currentUser['email'] ?? ''),
      HistoryPage(currentUser: widget.currentUser),
      ProfilePage(currentUser: widget.currentUser),
    ];

    return StreamBuilder<List<AppNotification>>(
      stream: FirestoreService.getNotificationsStream(widget.currentUser['email'] ?? ''),
      builder: (context, snapshot) {
        final unreadCount = (snapshot.data ?? []).where((n) => !n.isRead).length;

        return Scaffold(
          body: pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _onItemTapped(index);
              if (index == 1) {
                FirestoreService.markNotificationsAsRead(widget.currentUser['email'] ?? '');
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: unreadCount > 0 ? Text('$unreadCount') : null,
                  isLabelVisible: unreadCount > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
                activeIcon: Badge(
                  label: unreadCount > 0 ? Text('$unreadCount') : null,
                  isLabelVisible: unreadCount > 0,
                  child: const Icon(Icons.notifications),
                ),
                label: 'Notifikasi',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
