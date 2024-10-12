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
    return Consumer2<ProfileProvider, AuthProvider>(
      builder: (context, profileProvider, authProvider, child) {
        final profile = profileProvider.profile;
        if (profile != null) {
          _nameAccountController.text =
              "${profile.firstName} ${profile.lastName}";
          _emailAccountController.text = profile.email;
          _phoneNumberController.text = profile.phoneNumber;
        }
        return authProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Scaffold(
                body: RefreshIndicator(
                  onRefresh: () => _refreshProfile(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          _buildHeader(context, authProvider),
                          _buildProfileForm(context, profileProvider),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  Future<void> _refreshProfile(BuildContext context) async {
    await Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color.fromARGB(255, 55, 60, 160),
            Color(0xFF1F2462),
          ],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _showLogoutDialog(context, authProvider),
                ),
              ],
            ),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 60),
                  Text(
                    _nameAccountController.text,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm(
      BuildContext context, ProfileProvider profileProvider) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Transform.translate(
            offset: const Offset(0, -60),
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(_nameAccountController, "Nama"),
                      const SizedBox(height: 10),
                      _buildTextField(_emailAccountController, "Email"),
                      const SizedBox(height: 10),
                      _buildTextField(_phoneNumberController, "Phone"),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () =>
                            _handleSubmit(context, profileProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Update',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(hintText: hint),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
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
                await authProvider.logout();
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

  void _handleSubmit(BuildContext context, ProfileProvider profileProvider) {
    // Implement the submit logic here
    Navigator.of(context).pushNamed("/form_update_profile");
    // You should update the profile information here
    // For example: profileProvider.updateProfile(name, email, phone);
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
