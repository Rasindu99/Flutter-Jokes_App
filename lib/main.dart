import 'package:flutter/material.dart';
import 'joke_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const JokeListPage(),
    );
  }
}

class JokeListPage extends StatefulWidget {
  const JokeListPage({super.key});

  @override
  _JokeListPageState createState() => _JokeListPageState();
}

class _JokeListPageState extends State<JokeListPage> {
  final JokeService _jokeService = JokeService();
  List<Map<String, dynamic>> _jokesRaw = [];
  bool _isLoading = false;

  Future<void> _fetchJokes() async {
    setState(() => _isLoading = true);
    try {
      _jokesRaw = await _jokeService.fetchJokesRaw();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jokes: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke App'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome to the Joke App!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  shadows: [Shadow(color: Colors.white, blurRadius: 2)],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Click the button to fetch random jokes!',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchJokes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isLoading ? 'Loading...' : 'Fetch Jokes',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildJokeList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJokeList() {
    if (_jokesRaw.isEmpty) {
      return const Center(
        child: Text(
          'No jokes fetched yet',
          style: TextStyle(fontSize: 18, color: Colors.deepPurple),
        ),
      );
    }
    return ListView.builder(
      itemCount: _jokesRaw.length,
      itemBuilder: (context, index) {
        final jokeJson = _jokesRaw[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 6, // Adds shadow effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.deepPurple.shade200, width: 1.5),
          ),
          color: Colors.deepPurple.shade50, // Card background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                Text(
                  'Joke ${index + 1}', // Title for each joke
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const Divider(
                  color: Colors.deepPurple,
                  thickness: 1.0,
                  height: 20.0,
                ),
                // Joke Content
                Text(
                  jokeJson['type'] == 'twopart'
                      ? '${jokeJson['setup']}\n\n${jokeJson['delivery']}'
                      : jokeJson['joke'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // Footer Section
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    jokeJson['type'] == 'twopart'
                        ? 'Category: Two-part'
                        : 'Category: Single',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
