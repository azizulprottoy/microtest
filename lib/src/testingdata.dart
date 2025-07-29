import 'package:flutter/material.dart';
import '../chat_module.dart';

class MyTestWidget extends StatefulWidget {
  const MyTestWidget({super.key});

  @override
  State<MyTestWidget> createState() => _MyTestWidgetState();
}

class _MyTestWidgetState extends State<MyTestWidget> {
  // We'll store the fetched data here
  String? accessToken;
  String? voipToken;
  String? fcmToken;
  bool? isLoggedIn;
  String? userId;
  String? userName; // from ChatUser (or fallback)
  bool? isFirstRun;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionData();
  }

  Future<void> _fetchSessionData() async {
    final provider = Session.provider;

    final token = await provider.getAccessToken();
    final voip = await provider.getVoipToken();
    final fcm = await provider.getFcmToken();
    final loggedIn = await provider.isLogged();
    final id = await provider.getUserId();
    final firstRun = await provider.isFirstRun();

    final currentUser = await provider.getCurrentUser();

    setState(() {
      accessToken = token;
      voipToken = voip;
      fcmToken = fcm;
      isLoggedIn = loggedIn;
      userId = id;
      isFirstRun = firstRun;
      userName = currentUser?.name ?? 'Unknown User';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          color: Colors.blue.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Widget from Package',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDataRow('Access Token', accessToken),
                _buildDataRow('Voip Token', voipToken),
                _buildDataRow('FCM Token', fcmToken),
                _buildDataRow('Is Logged In', isLoggedIn?.toString()),
                _buildDataRow('User ID', userId),
                _buildDataRow('User Name', userName),
                _buildDataRow('Is First Run', isFirstRun?.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value ?? 'N/A',
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
