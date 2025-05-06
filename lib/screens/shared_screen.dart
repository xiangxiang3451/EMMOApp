import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:emmo/services/authentication_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Visualizationnote extends StatefulWidget {
  const Visualizationnote({super.key});

  @override
  State<Visualizationnote> createState() => _VisualizationnoteState();
}

class _VisualizationnoteState extends State<Visualizationnote> {
  List<Map<String, dynamic>> records = [];
  String? pairedUserEmail;
  Future<void>? _getPairedUserFuture;
  Future<void>? _getRecordsFuture;

  @override
  void initState() {
    super.initState();
    _getPairedUser(); // Get paired user
    _getRecords(); // Get current user's records
  }

  // Get current user's records
  Future<void> _getRecords() async {
    String? userId = AuthenticationService.currentUserEmail;

    try {
      final firestore = FirebaseFirestore.instance;

      // Get current user's record collection
      final snapshot = await firestore
          .collection('record') // Record collection
          .where('userId', isEqualTo: userId) // Query by user ID
          .orderBy('time', descending: true) // Sort by time descending
          .get();

      setState(() {
        records = snapshot.docs.map((doc) {
          return {
            'expression': doc['expression'], // Expression
            'color': doc['color'], // Color
            'date': doc['date'], // Date
            'address': doc['address'], // Address
            'thoughts': doc['thoughts'], // Thoughts/notes
            'photo': doc['photo'], // Photo base64
          };
        }).toList();
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching records: $e')),
        );
      });
    }
  }

  // Get paired user
  Future<void> _getPairedUser() async {
    final email = await AuthenticationService.getPairedUserEmail();
    setState(() {
      pairedUserEmail = email;
    });
  }

  // Get paired user's mood records
  Stream<List<Map<String, dynamic>>> _getPairedUserMoods() {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('record')
        .where('userId', isEqualTo: pairedUserEmail)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'expression': doc['expression'],
          'color': doc['color'],
          'date': doc['date'],
          'address': doc['address'],
          'thoughts': doc['thoughts'],
          'photo': doc['photo'],
        };
      }).toList();
    });
  }

  @override
  void dispose() {
    // Cancel unfinished async operations
    _getPairedUserFuture?.ignore();
    _getRecordsFuture?.ignore();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _getRecords(); // Refresh current user's records
              _getPairedUser(); // Refresh paired user
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              // Navigate to pairing screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PairingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_remove),
            onPressed: () async {
              await AuthenticationService.unpairUsers();
              setState(() {
                pairedUserEmail = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unpaired successfully')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white.withOpacity(0.8),
        child: pairedUserEmail == null
            ? const Center(child: Text('No paired user'))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getPairedUserMoods(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No mood records from paired user'));
                  }

                  final pairedRecords = snapshot.data!;

                  return ListView.builder(
                    itemCount: pairedRecords.length,
                    itemBuilder: (context, index) {
                      final record = pairedRecords[index];
                      final expression = record['expression'];
                      final colorValue = record['color'];
                      final color = colorValue is int
                          ? Color(colorValue)
                          : Colors.transparent;
                      final date = record['date'];
                      final address = record['address'];
                      final thoughts = record['thoughts'];
                      final photoBase64 = record['photo'];

                      return InkWell(
                        onTap: () {
                          _showRecordDetails(context, record);
                        },
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          color: color,
                          margin: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            height: 110,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  radius: 30,
                                  child: Text(
                                    expression,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        date,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'address: $address',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'note: $thoughts',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),  
      ),
    );
  }

  // Show mood record details
  void _showRecordDetails(BuildContext context, Map<String, dynamic> record) {
    final expression = record['expression'];
    final colorValue = record['color'];
    final color = colorValue is int ? Color(colorValue) : Colors.transparent;
    final date = record['date'];
    final address = record['address'];
    final thoughts = record['thoughts'];
    final photoBase64 = record['photo'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$expression'),
        backgroundColor: color,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Date: '),
                  Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('Address: '),
                  Expanded(child: Text(address)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('Notes: '),
                  Expanded(child: Text(thoughts)),
                ],
              ),
              if (photoBase64 != null && photoBase64.isNotEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Image.memory(
                    base64Decode(photoBase64),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _pairCodeController = TextEditingController();
  bool _isLoading = false;
  String? _currentPairCode;

  @override
  void initState() {
    super.initState();
    _loadPairCode(); // Load current user's pair code
  }

  // Load current user's pair code
  Future<void> _loadPairCode() async {
    final currentUserEmail = AuthenticationService.currentUserEmail;
    if (currentUserEmail == null) return;

    final firestore = FirebaseFirestore.instance;
    final userDoc =
        await firestore.collection('users').doc(currentUserEmail).get();

    if (userDoc.exists) {
      setState(() {
        _currentPairCode = userDoc['pairCode'];
      });
    }
  }

  // Handle pairing logic
  Future<void> _pairUsers() async {
    final pairCode = _pairCodeController.text.trim();
    if (pairCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pair code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthenticationService.pairUsers(pairCode);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pairing successful!')),
        );
        Navigator.pop(context); // Return to previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pairing failed, please check pair code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pairing failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Pairing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentPairCode != null) ...[
              Text(
                'Your pair code: $_currentPairCode',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _pairCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter pair code',
                hintText: 'Please enter 6-digit pair code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _pairUsers,
                    child: const Text('Pair'),
                  ),
          ],
        ),
      ),
    );
  }
}