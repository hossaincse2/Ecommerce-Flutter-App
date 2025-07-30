// widgets/common/bottom_navigation_widget.dart
import 'package:flutter/material.dart';
import '../../utils/ui_utils.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  
  const BottomNavigationWidget({
    Key? key,
    this.currentIndex = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2E86AB),
      unselectedItemColor: Colors.grey[400],
      currentIndex: currentIndex,
      onTap: onTap ?? (index) => UIUtils.onBottomNavTap(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}