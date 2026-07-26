import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';
import 'debug_sql.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer & Debug Tools'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'DATABASE TOOLS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.terminal, color: Colors.deepOrange),
            title: const Text('SQL Console & Schema Inspector'),
            subtitle: const Text('View table definitions and run raw SQL queries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // 1. Get the active SQLite database instance
              final Database db = await DatabaseHelper.instance.database;

              if (context.mounted) {
                // 2. Navigate to your SQL Console
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SqlConsoleWidget(db: db),
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Wipe Local Database', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Deletes all rows and resets schema on restart'),
            onTap: () => _confirmDatabaseWipe(context),
          ),
        ],
      ),
    );
  }

  void _confirmDatabaseWipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wipe Database?'),
        content: const Text('This will delete all local foods and diary entries.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final dbPath = await getDatabasesPath();
              await deleteDatabase('$dbPath/app_database.db'); // Match your DB filename
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database wiped! Please restart the app.')),
                );
              }
            },
            child: const Text('Wipe Data'),
          ),
        ],
      ),
    );
  }
}