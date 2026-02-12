import 'dart:async';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'movie.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<Movie> _results = [];
  bool _loading = false;
  String _error = '';
  int _requestId = 0; // prevent stale async updates

  @override
  void initState() {
    super.initState();
    _loadPopular();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _requestId++; // invalidate any pending callbacks
    super.dispose();
  }

  void _scheduleSearch(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = raw.trim();
      if (query.isEmpty) {
        _loadPopular();
      } else {
        _runSearch(query);
      }
    });
  }

  Future<void> _loadPopular() async {
    await _runRequest(() => _api.getPopularMovies());
  }

  Future<void> _runSearch(String query) async {
    await _runRequest(() => _api.searchMovies(query));
  }

  Future<void> _runRequest(Future<List<Movie>> Function() work) async {
    final int token = ++_requestId;
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final movies = await work();
      if (!_isActive(token)) return;
      setState(() {
        _results = movies;
      });
    } catch (e) {
      if (!_isActive(token)) return;
      setState(() {
        _error = e.toString();
        _results = [];
      });
    } finally {
      if (!_isActive(token)) return;
      setState(() {
        _loading = false;
      });
    }
  }

  bool _isActive(int token) => mounted && token == _requestId;

  Future<void> _reloadCurrent() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      await _loadPopular();
    } else {
      await _runSearch(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: hasText
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          _scheduleSearch('');
                          setState(() {}); // refresh suffix icon state
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                _scheduleSearch(value);
              },
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(minHeight: 3),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadCurrent,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error.isNotEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Có lỗi xảy ra:\n$_error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _reloadCurrent,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_results.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 40),
          Center(child: Text('No results')),
        ],
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final movie = _results[index];
        return ListTile(
          leading: movie.posterPath.isNotEmpty
              ? Image.network(
                  'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.image_not_supported),
          title: Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            movie.overview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
          ),
        );
      },
    );
  }
}
