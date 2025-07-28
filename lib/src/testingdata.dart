import 'package:flutter/material.dart';

import '../chat_module.dart';

class MyTestWidget extends StatelessWidget {
  const MyTestWidget({super.key});

  Future<String?> _getToken() async {
    return await Session.provider.getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.blue.shade50,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FutureBuilder<String?>(
            future: _getToken(),
            builder: (context, snapshot) {
              final token = snapshot.data;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Test Widget from Package',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<UserModel?>(
                  future: Session.provider.getUser(),
                  builder: (context, snapshot) {
                  final user = snapshot.data;
                  return Text("User name: ${user?.name ?? 'No user'}");
                  },
                  );

                  const SizedBox(height: 12),
                  Text(
                    'Token: ${snapshot.connectionState == ConnectionState.waiting ? "Loading..." : token ?? "No token"}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
