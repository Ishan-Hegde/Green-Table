import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';

class KYCVerificationScreen extends StatefulWidget {
  const KYCVerificationScreen({super.key});

  @override
  _KYCVerificationScreenState createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  final List<File> _documents = [];
  String _selectedDocType = 'id';
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadDocuments() async {
    try {
      // ignore: unused_local_variable
      final response = await AuthService.uploadKYCDocuments(
        documents: _documents,
        docType: _selectedDocType, userId: '_id',
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _pickDocument() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _documents.add(File(file.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KYC Verification')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDocType,
              items: ['id', 'proof_of_address']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.replaceAll('_', ' ').toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDocType = value!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDocument,
              child: Text('Select Document'),
            ),
            SizedBox(height: 20),
            ..._documents.map((file) => ListTile(
                  leading: Icon(Icons.description),
                  title: Text(file.path.split('/').last),
                )),
            Spacer(),
            ElevatedButton(
              onPressed: _documents.isEmpty ? null : _uploadDocuments,
              child: Text('Submit Verification'),
            ),
          ],
        ),
      ),
    );
  }
}