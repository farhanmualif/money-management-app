import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_app_new/models/profile.dart';
import 'package:money_app_new/providers/auth_provider.dart';
import 'package:money_app_new/providers/profile_provider.dart';
import 'package:money_app_new/themes/themes.dart';

class FormUpdateProfileScreen extends StatefulWidget {
  const FormUpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _FormUpdateProfileScreenState createState() =>
      _FormUpdateProfileScreenState();
}

class _FormUpdateProfileScreenState extends State<FormUpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameAccountController = TextEditingController();
  final _emailAccountController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      _nameAccountController.text = "${profile.firstName} ${profile.lastName}";
      _emailAccountController.text = profile.email;
      _phoneNumberController.text = profile.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameAccountController.dispose();
    _emailAccountController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        centerTitle: true,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return Center(
            child: SingleChildScrollView(
              child: profileProvider.isLoading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildProfileForm(context, profileProvider),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileForm(
      BuildContext context, ProfileProvider profileProvider) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameAccountController, "Name", (value) {
                if (value == null || value.isEmpty) {
                  return "Name is required";
                }
                return null;
              }),
              const SizedBox(height: 10),
              _buildTextField(_emailAccountController, "Email", (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return "Enter a valid email";
                }
                return null;
              }),
              const SizedBox(height: 10),
              _buildTextField(_phoneNumberController, "Phone", (value) {
                if (value == null || value.isEmpty) {
                  return "Phone number is required";
                }
                if (!RegExp(r'^\+?[0-9]{10,14}$').hasMatch(value)) {
                  return "Enter a valid phone number";
                }
                return null;
              }),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _handleSubmit(context, profileProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child:
                    const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
      validator: validator,
    );
  }

  void _handleSubmit(
      BuildContext context, ProfileProvider profileProvider) async {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final names = _nameAccountController.text.split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

    final updatedProfile = Profile(
      id: profileProvider.profile!.id,
      firstName: firstName,
      lastName: lastName,
      email: _emailAccountController.text,
      phoneNumber: _phoneNumberController.text,
      totalBalance: profileProvider.profile!.totalBalance,
      totalIncome: profileProvider.profile!.totalIncome,
      totalExpenses: profileProvider.profile!.totalExpenses,
      description: profileProvider.profile!.description,
      createdAt: profileProvider.profile!.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      accountId: profileProvider.profile!.accountId,
    );
    profileProvider
        .updateProfile(updatedProfile: updatedProfile)
        .then((_) async {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop();
        await profileProvider.fetchProfile();
        await authProvider.authenticated();
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    });
  }
}
