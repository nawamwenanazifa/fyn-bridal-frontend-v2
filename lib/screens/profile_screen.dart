import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  
  // Controllers for edit form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedGender = 'female';
  bool _isEditing = false;
  
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _user = AuthService.user;
    if (_user != null) {
      _nameController.text = _user?['name'] ?? '';
      _phoneController.text = _user?['phone'] ?? '';
      _bioController.text = _user?['bio'] ?? '';
      _locationController.text = _user?['location'] ?? '';
      _selectedGender = _user?['gender'] ?? 'female';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final token = AuthService.token;
      final response = await http.put(
        Uri.parse('${ApiService.BASE_URL}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'location': _locationController.text,
          'gender': _selectedGender,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Update AuthService user data
          AuthService.user = data['user'];
          _user = data['user'];
          setState(() => _isEditing = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        
        final token = AuthService.token;
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiService.BASE_URL}/user/upload-image'),
        );
        
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));
        
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        
        if (response.statusCode == 200 && jsonData['success'] == true) {
          // Update user data
          AuthService.user?['profile_image'] = jsonData['image_url'];
          _user = AuthService.user;
          setState(() {});
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        } else {
          throw Exception('Upload failed');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gender = _user?['gender'] ?? 'female';
    final profileImage = _user?['profile_image'];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Image Section
                  _buildProfileImageSection(gender, profileImage),
                  const SizedBox(height: 24),
                  
                  // Profile Info
                  _isEditing ? _buildEditForm() : _buildProfileInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImageSection(String gender, String? profileImage) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        color: AppColors.primary.withOpacity(0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                    image: profileImage != null && profileImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage('http://localhost:8000$profileImage'),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profileImage == null || profileImage.isEmpty
                      ? _getDefaultAvatar(gender)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to change profile picture',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDefaultAvatar(String gender) {
    if (gender == 'female') {
      return ClipOval(
        child: Container(
          color: Colors.pink[100],
          child: const Icon(Icons.female, size: 60, color: Colors.pink),
        ),
      );
    } else if (gender == 'male') {
      return ClipOval(
        child: Container(
          color: Colors.blue[100],
          child: const Icon(Icons.male, size: 60, color: Colors.blue),
        ),
      );
    } else {
      return ClipOval(
        child: Container(
          color: Colors.grey[100],
          child: const Icon(Icons.person, size: 60, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildProfileInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', _user?['name'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow('Email', _user?['email'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow('Phone', _user?['phone'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow('Gender', _user?['gender'] == 'female' ? 'Female' : (_user?['gender'] == 'male' ? 'Male' : 'Not specified')),
            const Divider(),
            _buildInfoRow('Location', _user?['location'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow('Bio', _user?['bio'] ?? 'No bio yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _loadUserData();
                      setState(() => _isEditing = false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}