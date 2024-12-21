import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jork_app/SharedPreferences.dart';

class JokesHomePage extends StatefulWidget {
  const JokesHomePage({Key? key}) : super(key: key);

  @override
  _JokesHomePageState createState() => _JokesHomePageState();
}

class _JokesHomePageState extends State<JokesHomePage> {
  List<Map<String, String>> jokes = [];
  bool isLoading = false;

  // Function to fetch a joke
  Future<void> fetchJoke() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch a new joke from the API
      final response =
          await Dio().get('https://official-joke-api.appspot.com/random_joke');
      final setup = response.data['setup'];
      final punchline = response.data['punchline'];

      // Update UI with the fetched joke
      setState(() {
        jokes.add({'setup': setup, 'punchline': punchline});
      });

      // Cache the fetched joke
      await cacheJoke(setup, punchline);
    } catch (e) {
      // If fetching fails, check for cached data
      String? cachedSetup = await CacheHelper.getData('setup');
      String? cachedPunchline = await CacheHelper.getData('punchline');

      if (cachedSetup != null && cachedPunchline != null) {
        // Show cached joke if available
        print('Loaded from cache: $cachedSetup - $cachedPunchline');
        setState(() {
          jokes.add({'setup': cachedSetup, 'punchline': cachedPunchline});
        });
      } else {
        // Show error message if no cache or API fails
        setState(() {
          jokes.add({
            'setup': 'Error',
            'punchline': 'Failed to fetch joke: $e',
          });
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  //Functon to cache the data
  Future<void> cacheJoke(String setup, String punchline) async {
    await CacheHelper.saveData('setup', setup);
    await CacheHelper.saveData('punchline', punchline);
  }

  Future<void> fetchCachedJoke() async {
    String? cachedSetup = await CacheHelper.getData('setup');
    String? cachedPunchline = await CacheHelper.getData('punchline');
    if (cachedSetup != null && cachedPunchline != null) {
      print('Cached joke: $cachedSetup - $cachedPunchline');
    } else {
      print('No joke in cache');
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
