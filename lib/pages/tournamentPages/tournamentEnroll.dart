import 'package:flutter/material.dart';

class TournamentEnrollmentForm extends StatefulWidget {
  const TournamentEnrollmentForm({super.key});

  @override
  State<TournamentEnrollmentForm> createState() =>
      _TournamentEnrollmentFormState();
}

class _TournamentEnrollmentFormState extends State<TournamentEnrollmentForm> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();
  final TextEditingController _teamNameController = TextEditingController();

  // Selection States
  String _selectedCategory = 'Amateur';
  String _selectedGender = 'Male';
  bool _isTeamRegistration = false;
  bool _agreedToTerms = false;

  final List<String> _gender = ['Male', 'Female', 'Gay', 'Lesbian'];
  final List<String> _categories = ['Amateur', 'Intermediate', 'Professional'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gameIdController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner / Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Championship 2026',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Fill in the details below to enroll.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Registration Type Toggle
              Row(
                children: [
                  const Text(
                    'Registering For: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ChoiceChip(
                    label: const Text('Solo'),
                    selected: !_isTeamRegistration,
                    onSelected: (selected) {
                      setState(() {
                        _isTeamRegistration = false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Team'),
                    selected: _isTeamRegistration,
                    onSelected: (selected) {
                      setState(() {
                        _isTeamRegistration = true;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Team Name Field (Conditional)
              if (_isTeamRegistration) ...[
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    prefixIcon: Icon(Icons.groups),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isTeamRegistration &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter your Team Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Full Name / Captain Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _isTeamRegistration ? 'Leader Name' : 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // In-Game ID / Tag
              // TextFormField(
              //   controller: _gameIdController,
              //   decoration: const InputDecoration(
              //     labelText: 'In-Game Name / Player ID',
              //     prefixIcon: Icon(Icons.sports_esports),
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return 'Please enter your Game ID or IGN';
              //     }
              //     return null;
              //   },
              // ),
              DropdownButtonFormField(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: _gender.map((String gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Email Address
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Division / Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Terms & Rules Checkbox
              CheckboxListTile(
                value: _agreedToTerms,
                title: const Text(
                  'I agree to the tournament rules and fair-play regulations.',
                  style: TextStyle(fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT ENROLLMENT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
