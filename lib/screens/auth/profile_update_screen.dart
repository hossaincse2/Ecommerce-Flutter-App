// screens/auth/profile_update_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_constants.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/common/loading_widgets.dart';
import '../../services/auth_manager.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../utils/logger.dart';

class ProfileUpdateScreen extends StatefulWidget {
  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthManager _authManager = AuthManager();
  bool _isLoading = false;
  bool _isUploadingImage = false;
  User? _currentUser;
  File? _selectedImage;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    _currentUser = _authManager.user;
    if (_currentUser != null) {
      _nameController.text = _currentUser!.name;
      _emailController.text = _currentUser!.email;
      _phoneController.text = _currentUser!.phone ?? '';
      _currentProfileImageUrl = _currentUser!.profileImage;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Upload image immediately after selection
        await _uploadProfileImage();
      }
    } catch (e) {
      Logger.logError('Error picking image', e);
      UIUtils.showErrorSnackBar(context, 'Failed to select image');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Upload image immediately after taking
        await _uploadProfileImage();
      }
    } catch (e) {
      Logger.logError('Error taking photo', e);
      UIUtils.showErrorSnackBar(context, 'Failed to take photo');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final avatarUrl = await _authManager.uploadAvatar(_selectedImage!.path);

      if (avatarUrl != null) {
        setState(() {
          _currentProfileImageUrl = avatarUrl;
          _currentUser = _currentUser?.copyWith(profileImage: avatarUrl);
        });

        UIUtils.showSuccessSnackBar(context, 'Profile picture updated successfully!');
      }
    } on AuthException catch (e) {
      Logger.logError('Failed to upload profile image', e);
      UIUtils.showErrorSnackBar(context, e.message);
    } catch (e) {
      Logger.logError('Unexpected error uploading image', e);
      UIUtils.showErrorSnackBar(context, 'Failed to upload profile picture');
    } finally {
      setState(() {
        _isUploadingImage = false;
        _selectedImage = null;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Logger.logInfo('Starting profile update process');

      final success = await _authManager.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      if (success) {
        Logger.logSuccess('Profile update completed successfully');
        UIUtils.showSuccessSnackBar(context, 'Profile updated successfully!');

        // Refresh user data to ensure UI is updated
        await _authManager.refreshUserData();

        // Small delay to show success message
        await Future.delayed(Duration(milliseconds: 500));

        Navigator.pop(context, true); // Return true to indicate success
      } else {
        Logger.logWarning('Profile update returned false');
        UIUtils.showErrorSnackBar(context, 'Failed to update profile. Please try again.');
      }
    } on AuthException catch (e) {
      Logger.logError('Profile update failed with AuthException', e);

      // Check if the error message actually indicates success
      if (e.message.toLowerCase().contains('successfully')) {
        Logger.logInfo('Profile update actually succeeded despite AuthException');
        UIUtils.showSuccessSnackBar(context, 'Profile updated successfully!');

        // Refresh user data
        try {
          await _authManager.refreshUserData();
        } catch (refreshError) {
          Logger.logWarning('Failed to refresh user data after successful update', refreshError);
        }

        Navigator.pop(context, true);
      } else {
        UIUtils.showErrorSnackBar(context, e.message);
      }
    } catch (e) {
      Logger.logError('Unexpected error updating profile', e);
      UIUtils.showErrorSnackBar(context, 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppConstants.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Update Profile'),
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.primaryColor,
          elevation: 1,
        ),
        body: LoadingWidgets.buildLoadingScreen(message: 'Loading profile...'),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Update Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.primaryColor,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileImageSection(),
              SizedBox(height: 32),
              _buildProfileForm(),
              SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
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
              if (_isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _showImagePicker,
                  child: Container(
                    padding: EdgeInsets.all(8),
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
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Tap to change profile picture',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty) {
      return Image.network(
        _currentProfileImageUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 60,
              color: AppConstants.primaryColor,
            ),
          );
        },
      );
    } else {
      return Container(
        color: AppConstants.primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: 60,
          color: AppConstants.primaryColor,
        ),
      );
    }
  }

  Widget _buildProfileForm() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildNameField(),
          SizedBox(height: 16),
          _buildEmailField(),
          SizedBox(height: 16),
          _buildPhoneField(),
          SizedBox(height: 16),
          _buildUsernameField(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email address',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Phone Number (Optional)',
        hintText: 'Enter your phone number',
        prefixIcon: Icon(Icons.phone_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: AppConstants.primaryColor),
        ),
      ),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
          return 'Please enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      initialValue: _currentUser!.username,
      enabled: false,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Username cannot be changed',
        prefixIcon: Icon(Icons.alternate_email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        fillColor: Colors.grey.shade50,
        filled: true,
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        disabledBackgroundColor: AppConstants.primaryColor.withOpacity(0.6),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        'Update Profile',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}