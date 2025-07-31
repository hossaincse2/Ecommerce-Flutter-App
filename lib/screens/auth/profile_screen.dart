import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;

  // Mock user data - replace with actual user model
  final Map<String, dynamic> userProfile = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 234 567 8890',
    'profileImage': null,
    'memberSince': '2024',
    'totalOrders': 15,
    'wishlistItems': 8,
    'reviews': 12,
    'isVerified': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: SharedWidgets.buildAppBar(
        title: 'My Profile',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppConstants.primaryColor),
            onPressed: () => _navigateToEditProfile(),
          ),
          SizedBox(width: AppConstants.smallPadding),
        ],
      ),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen(message: 'Loading profile...')
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildProfileStats(),
            SizedBox(height: 20),
            _buildProfileOptions(),
            SizedBox(height: 80), // Bottom navigation padding
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                backgroundImage: userProfile['profileImage'] != null
                    ? NetworkImage(userProfile['profileImage'])
                    : null,
                child: userProfile['profileImage'] == null
                    ? Icon(
                  Icons.person,
                  size: 50,
                  color: AppConstants.primaryColor,
                )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeProfilePicture,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userProfile['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              if (userProfile['isVerified'])
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            userProfile['email'],
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userProfile['phone'],
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Member since ${userProfile['memberSince']}',
              style: TextStyle(
                fontSize: 12,
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Orders',
              '${userProfile['totalOrders']}',
              Icons.shopping_bag_outlined,
              AppConstants.primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Wishlist',
              '${userProfile['wishlistItems']}',
              Icons.favorite_outline,
              Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Reviews',
              '${userProfile['reviews']}',
              Icons.star_outline,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SharedWidgets.buildSectionHeader('Account Settings'),
          SizedBox(height: 12),
          _buildOptionsList(),
          SizedBox(height: 24),
          SharedWidgets.buildSectionHeader('Preferences'),
          SizedBox(height: 12),
          _buildPreferencesSection(),
        ],
      ),
    );
  }

  Widget _buildOptionsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        children: [
          _buildOptionItem(
            'Personal Information',
            Icons.person_outline,
                () => _navigateToEditProfile(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'My Orders',
            Icons.shopping_bag_outlined,
                () => Navigator.pushNamed(context, '/my-orders'),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Address Book',
            Icons.location_on_outlined,
                () => _navigateToAddresses(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Payment Methods',
            Icons.payment_outlined,
                () => _navigateToPaymentMethods(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Wishlist',
            Icons.favorite_outline,
                () => _navigateToWishlist(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: AppConstants.categoryShadow,
      ),
      child: Column(
        children: [
          _buildOptionItem(
            'Notifications',
            Icons.notifications_outlined,
                () => _navigateToNotifications(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Privacy & Security',
            Icons.security_outlined,
                () => _navigateToPrivacy(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Theme',
            Icons.color_lens_outlined,
                () => _navigateToThemeSettings(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Language',
            Icons.language_outlined,
                () => _navigateToLanguageSettings(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Help & Support',
            Icons.help_outline,
                () => _navigateToSupport(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'About',
            Icons.info_outline,
                () => _navigateToAbout(),
          ),
          _buildDivider(),
          _buildOptionItem(
            'Logout',
            Icons.logout,
                () => _showLogoutDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppConstants.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? Colors.red : AppConstants.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppConstants.textSecondaryColor,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 56,
    );
  }

  void _changeProfilePicture() async {
    // TODO: Implement profile picture change logic
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context, 'camera');
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context, 'gallery');
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      UIUtils.showInfoSnackBar(context, 'Profile picture updated');
      // Here you would typically upload the new image to your server
    }
  }

  void _navigateToEditProfile() {
    Navigator.pushNamed(context, '/edit-profile').then((_) {
      // Refresh profile data if needed
      setState(() {});
    });
  }

  void _navigateToAddresses() {
    Navigator.pushNamed(context, '/addresses');
  }

  void _navigateToPaymentMethods() {
    Navigator.pushNamed(context, '/payment-methods');
  }

  void _navigateToWishlist() {
    Navigator.pushNamed(context, '/wishlist');
  }

  void _navigateToNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  void _navigateToPrivacy() {
    Navigator.pushNamed(context, '/privacy-settings');
  }

  void _navigateToThemeSettings() {
    Navigator.pushNamed(context, '/theme-settings');
  }

  void _navigateToLanguageSettings() {
    Navigator.pushNamed(context, '/language-settings');
  }

  void _navigateToSupport() {
    Navigator.pushNamed(context, '/support');
  }

  void _navigateToAbout() {
    Navigator.pushNamed(context, '/about');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: AppConstants.textSecondaryColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    setState(() {
      isLoading = true;
    });

    // Simulate logout process
    Future.delayed(Duration(seconds: 1), () {
      // TODO: Implement actual logout logic (clear tokens, user data, etc.)
      UIUtils.showSuccessSnackBar(context, 'Logged out successfully');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    });
  }
}