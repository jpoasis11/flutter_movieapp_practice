import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 1. Avatar và thông tin người dùng
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://example.com/avatar.png',
              ), // thay bằng avatar thật
            ),
            const SizedBox(height: 10),
            const Text(
              'TUANLE',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'tuanle@example.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // 2. Watch History
            sectionTitle('Watch History'),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) {
                  return watchItem('Movie ${index + 1}');
                }),
              ),
            ),
            const SizedBox(height: 20),
            // 3. Favorites
            sectionTitle('Favorites'),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(5, (index) {
                  return favoriteItem('Movie ${index + 1}');
                }),
              ),
            ),
            const SizedBox(height: 20),
            // 4. Settings
            sectionTitle('Settings'),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            const Divider(),
            // 5. Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget helper: section title
  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget helper: watch history item
  Widget watchItem(String title) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.movie)),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // Widget helper: favorite item
  Widget favoriteItem(String title) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.orange[200],
              child: const Center(child: Icon(Icons.favorite)),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
