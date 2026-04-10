import 'package:flutter/material.dart';

class AddMemberDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onMemberAdded;

  const AddMemberDialog({super.key, required this.onMemberAdded});

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _memberCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String _selectedGender = 'male';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _memberCodeController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final memberData = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'member_code': _memberCodeController.text.trim(),
        'address': _addressController.text.trim(),
        'emergency_contact_name': _emergencyContactController.text.trim(),
        'emergency_contact_phone': _emergencyPhoneController.text.trim(),
        'date_of_birth': _dateOfBirthController.text,
        'gender': _selectedGender,
      };

      widget.onMemberAdded(memberData);
      
      setState(() {
        _isLoading = false;
      });
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Member',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Member Code Field
                      TextFormField(
                        controller: _memberCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Member Code',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Member code is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address Field
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Emergency Contact Fields
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyContactController,
                              decoration: const InputDecoration(
                                labelText: 'Emergency Contact Name',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: TextFormField(
                              controller: _emergencyPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Emergency Phone',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date of Birth Field
                      TextFormField(
                        controller: _dateOfBirthController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 6520)), // Default to 18 years ago
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              
                              if (date != null) {
                                _dateOfBirthController.text = date.toIso8601String().split('T')[0];
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Date of birth is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Gender Field
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a gender';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Add Member'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
