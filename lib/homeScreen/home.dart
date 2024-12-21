import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../SharedPreferences.dart';

class JokesHomePage extends StatefulWidget {
  const JokesHomePage({Key? key}) : super(key: key);

  @override
  _JokesHomePageState createState() => _JokesHomePageState();
}

class _JokesHomePageState extends State<JokesHomePage> {
  List<Map<String, String>> jokes = [];
  bool isLoading = false;

  // Function to fetch a new joke from the API
  Future<void> fetchJoke() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Making a GET request to fetch a random joke
      final response =
          await Dio().get('https://official-joke-api.appspot.com/random_joke');

      // Extracting setup and punchline, ensuring they're in string format
      final setup = response.data['setup'].toString();
      final punchline = response.data['punchline'].toString();

      // Creating a new joke map
      final Map<String, String> newJoke = {
        'setup': setup,
        'punchline': punchline
      };

      setState(() {
        jokes.add(newJoke);
      });

      // Fetching cached jokes
      final cachedJokes = await CacheHelper.getJokes();
      cachedJokes.add(newJoke);
      await CacheHelper.saveJokes(cachedJokes);
    } catch (e) {
      print("Error fetching joke: $e");

      // Fetching and display a random cached joke
      final cachedJokes = await CacheHelper.getJokes();
      if (cachedJokes.isNotEmpty) {
        final randomJoke = cachedJokes[Random().nextInt(cachedJokes.length)];
        setState(() {
          jokes.add(
              randomJoke.map((key, value) => MapEntry(key, value.toString())));
        });
      } else {
        setState(() {
          jokes.add({
            'setup': 'Error',
            'punchline': 'Failed to fetch joke: $e',
          });
        });
      }
    } finally {
      // Resetting loading state once the operation is complete
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetch a random joke from cached jokes (offline mode)
  Future<void> fetchRandomCachedJoke() async {
    try {
      final cachedJokes = await CacheHelper.getJokes();
      if (cachedJokes.isNotEmpty) {
        final randomJoke = cachedJokes[Random().nextInt(cachedJokes.length)];
        setState(() {
          jokes.add(randomJoke);
        });
      } else {
        setState(() {
          jokes.add({
            'setup': 'No jokes available',
            'punchline':
                'Please fetch jokes online to store them for offline use.',
          });
        });
      }
    } catch (e) {
      // Handle any errors while fetching cached jokes
      print("Error fetching cached joke: $e");
      setState(() {
        jokes.add({
          'setup': 'Error',
          'punchline': 'Failed to fetch cached joke: $e',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Daily Laughs',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 121, 231, 145),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchJoke,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text("Fetch Jokes"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              shadowColor: Colors.black,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchRandomCachedJoke,
            child: const Text("Offline Jokes"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
              shadowColor: Colors.black,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Displaying the jokes in a ListView
          ...jokes.map((joke) => _buildJokeCard(
                joke['setup']!,
                joke['punchline']!,
                Colors.blue[100]!,
              )),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search jokes...',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  // Function to build a joke card widget for displaying jokes
  Widget _buildJokeCard(String setup, String punchline, Color backgroundColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              setup,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              punchline,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
