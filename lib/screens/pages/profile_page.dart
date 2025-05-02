import 'package:flutter/material.dart';
import 'package:money_app_new/providers/auth_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/screens/splash_screen.dart';
import 'package:money_app_new/themes/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameAccountController = TextEditingController();
  final TextEditingController _emailAccountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<ProfileProvider>(context, listen: false).profile ==
          null) {
        Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Consumer2<ProfileProvider, AuthProvider>(
      builder: (context, profileProvider, authProvider, child) {
        final profile = profileProvider.profile;
        if (profile != null) {
          _nameAccountController.text =
              "${profile.firstName} ${profile.lastName}";
          _emailAccountController.text = profile.email;
          _phoneNumberController.text = profile.phoneNumber;
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: RefreshIndicator(
            onRefresh: () => _refreshProfile(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(context, profile, isSmallScreen),
                        Transform.translate(
                          offset: Offset(0, isSmallScreen ? -40 : -60),
                          child: _buildProfileForm(
                              context, profileProvider, isSmallScreen),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshProfile(BuildContext context) async {
    await Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
  }

  Widget _buildHeader(
      BuildContext context, dynamic profile, bool isSmallScreen) {
    return Container(
      height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.3 : 0.35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 8 : 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 10 : 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: isSmallScreen ? 40 : 50,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: Text(
                  profile?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 32 : 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context,
      ProfileProvider profileProvider, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          _buildInfoField(Icons.person, 'Full Name',
              _nameAccountController.text, isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildInfoField(Icons.email, 'Email', _emailAccountController.text,
              isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildInfoField(
              Icons.phone, 'Phone', _phoneNumberController.text, isSmallScreen),
          SizedBox(height: isSmallScreen ? 20 : 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed("/form_update_profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
      IconData icon, String label, String value, bool isSmallScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: AppColors.textColor.withOpacity(0.6),
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColors.primaryColor, size: isSmallScreen ? 18 : 20),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              child: const Text("Tidak"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Ya"),
              onPressed: () async {
                await _deleteCache();

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Periksa apakah cache benar-benar terhapus
      final allKeys = prefs.getKeys();
      if (allKeys.isEmpty) {
        print("Cache berhasil dihapus. Tidak ada key yang tersisa.");
      } else {
        print("Peringatan: Masih ada ${allKeys.length} key dalam cache.");
      }
    } catch (e) {
      print("Error saat menghapus cache: $e");
    }
  }
}
