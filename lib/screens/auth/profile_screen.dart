// screens/auth/profile_screen.dart
import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../services/auth_manager.dart';
import '../../models/user.dart';
import '../../utils/logger.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  final AuthManager _authManager = AuthManager();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _authManager.initialize();

      if (!_authManager.isLoggedIn) {
        _navigateToLogin();
        return;
      }

      if (!_authManager.hasValidToken()) {
        Logger.logWarning('Invalid token, redirecting to login');
        UIUtils.showErrorSnackBar(context, 'Session expired. Please login again.');
        _navigateToLogin();
        return;
      }

      // Get user data
      currentUser = _authManager.user;

      // Refresh user data from server
      await _refreshUserData();

    } catch (e) {
      Logger.logError('Error initializing profile', e);
      UIUtils.showErrorSnackBar(context, 'Failed to load profile data');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    try {
      final success = await _authManager.refreshUserData();
      if (success && mounted) {
        setState(() {
          currentUser = _authManager.user;
        });
      }
    } catch (e) {
      Logger.logError('Error refreshing user data', e);
      // Don't show error for refresh - continue with cached data
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login').then((_) {
      // After returning from login, reinitialize profile
      if (mounted) {
        _initializeProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    if (!_authManager.isLoggedIn) {
      return _buildNotLoggedInView();
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: SharedWidgets.buildAppBar(
        title: 'My Profile',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppConstants.primaryColor),
            onPressed: _refreshUserData,
          ),
          SizedBox(width: AppConstants.smallPadding),
        ],
      ),
      body: isLoading
          ? LoadingWidgets.buildLoadingScreen(message: 'Loading profile...')
          : RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: SharedWidgets.buildAppBar(
        title: 'Profile',
        showBackButton: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: AppConstants.primaryColor.withOpacity(0.5),
              ),
              SizedBox(height: 20),
              Text(
                'You are not logged in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please login to view your profile',
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildProfileImage(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _navigateToEditProfile,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
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
                currentUser?.name ?? 'User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              if (currentUser?.isRetailer == true)
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
            currentUser?.email ?? 'No email',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8),
          if (currentUser?.phone != null && currentUser!.phone!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                currentUser!.phone!,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ),
          Text(
            '@${currentUser?.username ?? 'username'}',
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
              currentUser?.isRetailer == true ? 'Retailer Account' : 'Customer Account',
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

  Widget _buildProfileImage() {
    if (currentUser?.profileImage != null && currentUser!.profileImage!.isNotEmpty) {
      return Image.network(
        currentUser!.profileImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 50,
              color: AppConstants.primaryColor,
            ),
          );
        },
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        color: AppConstants.primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: 50,
          color: AppConstants.primaryColor,
        ),
      );
    }
  }

  Widget _buildProfileStats() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Orders',
              '0', // TODO: Fetch from API
              Icons.shopping_bag_outlined,
              AppConstants.primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Wishlist',
              '0', // TODO: Fetch from API
              Icons.favorite_outline,
              Colors.red,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Reviews',
              '0', // TODO: Fetch from API
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

  void _navigateToEditProfile() {
    Navigator.pushNamed(context, '/profile-update').then((result) {
      // If profile was updated successfully, refresh the data
      if (result == true) {
        _refreshUserData();
      }
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

  void _handleLogout() async {
    setState(() {
      isLoading = true;
    });

    try {
      Logger.logInfo('Starting logout process');
      await _authManager.logout();

      UIUtils.showSuccessSnackBar(context, 'Logged out successfully');

      // Navigate back to home screen instead of login
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    } catch (e) {
      Logger.logError('Logout error', e);
      UIUtils.showErrorSnackBar(context, 'Error during logout. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}