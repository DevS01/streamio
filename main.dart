import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(MyApp());

class Movie {
  String title;
  String posterPath;
  int tmdbCode;

  Movie(
      {required this.title, required this.posterPath, required this.tmdbCode});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Streaming App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Montserrat',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String tmdbApiKey = '2641c693538f9a030d30e9de74a61434';
  final String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  final String tmdbSearchEndpoint = '/search/movie';
  final TextEditingController _searchController = TextEditingController();
  late List<Movie> searchResults;
  bool isScrolled = false;

  @override
  void initState() {
    super.initState();
    searchResults = [];
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      _searchMovies(query);
    } else {
      setState(() {
        searchResults.clear();
      });
    }
  }

  Future<void> _searchMovies(String query) async {
    final response = await http.get(
      Uri.parse(
          '$tmdbBaseUrl$tmdbSearchEndpoint?api_key=$tmdbApiKey&query=$query'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      searchResults = data
          .map((movie) => Movie(
                title: movie['title'],
                posterPath:
                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                tmdbCode: movie['id'],
              ))
          .toList();
    } else {
      throw Exception('Failed to load search results');
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Stream.Dev',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto Mono',
                  ),
                ),
                background: Container(
                  color: Colors.purple, // Set the background color here
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for movies',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      searchResults[index].title,
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Image.network(searchResults[index].posterPath),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyWebView(movie: searchResults[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyWebView extends StatefulWidget {
  final Movie movie;

  MyWebView({Key? key, required this.movie}) : super(key: key);

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  InAppWebViewController? _webViewController;
  late String videoUrl;

  @override
  void initState() {
    super.initState();
    videoUrl = 'https://vidsrc.to/embed/movie/${widget.movie.tmdbCode}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(videoUrl)),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}
