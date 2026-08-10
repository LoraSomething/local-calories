import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SqlConsoleWidget extends StatefulWidget {
  final Database db;

  const SqlConsoleWidget({super.key, required this.db});

  @override
  State<SqlConsoleWidget> createState() => _SqlConsoleWidgetState();
}

class _SqlConsoleWidgetState extends State<SqlConsoleWidget> {
  final TextEditingController _queryController = TextEditingController(
    text: '''
      SELECT 
        date(diary_entries.date) as date,
        SUM(diary_entries.calories) as calories,
        SUM(diary_entries.carbs) as carbs,
        SUM(diary_entries.sugars) as sugars,
        SUM(diary_entries.fiber) as fiber,
        SUM(diary_entries.fat) as fat,
        SUM(diary_entries.saturated_fat) as saturatedFat,
        SUM(diary_entries.protein) as protein
      FROM diary_entries
      WHERE date(diary_entries.date) >= ? AND date(diary_entries.date) < ?
      GROUP BY date(diary_entries.date)
      ORDER BY date ASC;
    ''',
  );
  String _resultOutput = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _executeQuery([String? sqlToRun]) async {
    final sql = (sqlToRun ?? _queryController.text).trim();
    if (sql.isEmpty) return;

    setState(() {
      _isLoading = true;
      _resultOutput = '';
    });

    try {
      final lowerSql = sql.toLowerCase();
      
      // READ Queries (SELECT, PRAGMA, EXPLAIN)
      if (lowerSql.startsWith('select') || lowerSql.startsWith('pragma')) {
        final List<Map<String, dynamic>> results = await widget.db.rawQuery(sql);
        
        if (results.isEmpty) {
          _resultOutput = 'Query executed successfully. Result set is empty.';
        } else {
          // Format list of maps as clean JSON/Text format
          final buffer = StringBuffer();
          buffer.writeln('Returned ${results.length} row(s):\n');
          for (var i = 0; i < results.length; i++) {
            buffer.writeln('--- Row ${i + 1} ---');
            results[i].forEach((key, value) {
              buffer.writeln('  $key: $value');
            });
            buffer.writeln();
          }
          _resultOutput = buffer.toString();
        }
      } 
      // WRITE/SCHEMA Queries (CREATE, INSERT, UPDATE, DELETE, ALTER, DROP)
      else {
        final affected = await widget.db.rawInsert(sql);
        _resultOutput = 'Query executed successfully.\nAffected Rows / Last Insert ID: $affected';
      }
    } catch (e) {
      _resultOutput = '❌ SQL ERROR:\n$e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setPresetQuery(String query) {
    _queryController.text = query;
    _executeQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Console'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. QUERY INPUT TEXTBOX
            const Text(
              'Enter SQL Query:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _queryController,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'WRITE YOUR SQL HERE...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 8),

            // 2. RUN BUTTON & SHORTCUT CHIPS
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _executeQuery(),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('Execute'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          label: const Text('All Tables'),
                          onPressed: () => _setPresetQuery("SELECT name FROM sqlite_master WHERE type='table';"),
                        ),
                        const SizedBox(width: 6),
                        ActionChip(
                          label: const Text('All Schemas'),
                          onPressed: () => _setPresetQuery("SELECT name, sql FROM sqlite_master WHERE type='table';"),
                        ),
                        const SizedBox(width: 6),
                        ActionChip(
                          label: const Text('Foods Columns'),
                          onPressed: () => _setPresetQuery("PRAGMA table_info(foods);"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. RESULTS OUTPUT TEXTBOX
            const Text(
              'Query Results:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                width: double.infinity,
                child: SingleChildScrollView(
                  child: SelectableText(
                    _resultOutput.isEmpty
                        ? 'Results will appear here...'
                        : _resultOutput,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: _resultOutput.startsWith('❌')
                          ? Colors.redAccent
                          : Colors.greenAccent[100],
                    ),
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