import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Using debugPrint instead of print (fixes avoid_print warning)
    debugPrint('✅ Firebase initialized successfully!');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSwap - Firebase Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String firebaseStatus = 'Checking...';
  String authStatus = 'Checking...';
  String firestoreStatus = 'Checking...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkFirebaseConnection();
  }

  Future<void> checkFirebaseConnection() async {
    // Check Firebase Core
    try {
      final app = Firebase.app();
      setState(() {
        firebaseStatus = '✅ Connected\nApp: ${app.name}\nProject: ${app.options.projectId}';
      });
    } catch (e) {
      setState(() {
        firebaseStatus = '❌ Not Connected: $e';
      });
    }

    // Check Firebase Auth
    try {
      final auth = FirebaseAuth.instance;
      setState(() {
        authStatus = '✅ Auth Available\nCurrent User: ${auth.currentUser?.email ?? 'Not logged in'}';
      });
    } catch (e) {
      setState(() {
        authStatus = '❌ Auth Error: $e';
      });
    }

    // Check Firestore
    try {
      final firestore = FirebaseFirestore.instance;
      // Try to access Firestore settings (doesn't write data)
      firestore.settings;
      setState(() {
        firestoreStatus = '✅ Firestore Available';
      });
    } catch (e) {
      setState(() {
        firestoreStatus = '❌ Firestore Error: $e';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Test Firestore Write (optional - creates a test document)
  Future<void> testFirestoreWrite() async {
    // Save context before async operation (fixes use_build_context_synchronously)
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .set({
        'message': 'Firebase is working!',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Firestore write successful! Check your Firebase Console.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ Firestore write failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Firebase Connection Status',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildStatusCard('Firebase Core', firebaseStatus),
                  const SizedBox(height: 16),
                  _buildStatusCard('Firebase Auth', authStatus),
                  const SizedBox(height: 16),
                  _buildStatusCard('Cloud Firestore', firestoreStatus),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: testFirestoreWrite,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Test Firestore Write'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'If all checks show ✅, your Firebase is properly configured!\n\n'
                      'Click "Test Firestore Write" to verify database access.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    final isSuccess = status.startsWith('✅');
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isSuccess 
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.red.shade50, Colors.red.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: TextStyle(
                color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}