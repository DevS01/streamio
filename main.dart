import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
      home: MovieList(),
    );
  }
}

class MovieList extends StatefulWidget {
  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final String tmdbApiKey =
      '2641c693538f9a030d30e9de74a61434'; // Replace with your TMDb API key
  final String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  final String tmdbPopularEndpoint = '/movie/popular';

  late List<Movie> movies;

  @override
  void initState() {
    super.initState();
    fetchPopularMovies();
  }

  Future<void> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$tmdbBaseUrl$tmdbPopularEndpoint?api_key=$tmdbApiKey'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      movies = data
          .map((movie) => Movie(
                title: movie['title'],
                posterPath:
                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                tmdbCode: movie['id'],
              ))
          .toList();

      setState(() {});
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Movies'),
      ),
      body: movies == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(movies[index].title),
                  leading: Image.network(movies[index].posterPath),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoviePlayer(movie: movies[index]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class MoviePlayer extends StatefulWidget {
  final Movie movie;

  MoviePlayer({required this.movie});

  @override
  _MoviePlayerState createState() => _MoviePlayerState();
}

class _MoviePlayerState extends State<MoviePlayer> {
  final String vidsrcBaseUrl = 'https://vidsrc.to/embed/movie/';
  late String videoUrl;

  @override
  void initState() {
    super.initState();
    videoUrl = '$vidsrcBaseUrl${widget.movie.tmdbCode}';
  }

  void launchURL(url) async {
    final Uri url = Uri.parse(videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'TMDB Code: ${widget.movie.tmdbCode}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            'Video URL: $videoUrl',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                launchURL(videoUrl);
              },
              child: Text('Launch URL')),
        ],
      ),
    );
  }
}
