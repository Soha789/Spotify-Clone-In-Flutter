import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Non-functional demo UI of a music streaming app:
/// - No Firebase
/// - No backend
/// - No real audio
/// Just dummy data + state in memory.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Streaming Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// ---------------------- MODELS ----------------------

class Song {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
  });
}

class Playlist {
  final String id;
  final String name;
  final List<String> songIds;

  Playlist({
    required this.id,
    required this.name,
    List<String>? songIds,
  }) : songIds = songIds ?? [];
}

// ---------------------- HOME SCREEN (STATE HOLDER) ----------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Dummy songs
  final List<Song> _songs = const [
    Song(
      id: '1',
      title: 'Chill Vibes',
      artist: 'Lo-Fi Artist',
      imageUrl:
          'https://images.pexels.com/photos/164745/pexels-photo-164745.jpeg',
    ),
    Song(
      id: '2',
      title: 'Upbeat Energy',
      artist: 'EDM Artist',
      imageUrl:
          'https://images.pexels.com/photos/164716/pexels-photo-164716.jpeg',
    ),
    Song(
      id: '3',
      title: 'Soft Piano',
      artist: 'Piano Artist',
      imageUrl:
          'https://images.pexels.com/photos/164743/pexels-photo-164743.jpeg',
    ),
  ];

  final Set<String> _favoriteIds = {};
  final List<Playlist> _playlists = [];

  Song? _currentSong;
  bool _isPlaying = false; // sirf UI ke liye
  String _searchQuery = '';

  // ----- helpers -----

  List<Song> get _browseSongs => _songs;

  List<Song> get _searchResults {
    if (_searchQuery.trim().isEmpty) return _songs;
    final lower = _searchQuery.toLowerCase();
    return _songs
        .where((s) =>
            s.title.toLowerCase().contains(lower) ||
            s.artist.toLowerCase().contains(lower))
        .toList();
  }

  List<Song> get _favoriteSongs =>
      _songs.where((s) => _favoriteIds.contains(s.id)).toList();

  List<Song> songsForPlaylist(Playlist playlist) {
    return playlist.songIds
        .map((id) => _songs.firstWhere((s) => s.id == id))
        .toList();
  }

  // ----- actions -----

  void _toggleFavorite(String songId) {
    setState(() {
      if (_favoriteIds.contains(songId)) {
        _favoriteIds.remove(songId);
      } else {
        _favoriteIds.add(songId);
      }
    });
  }

  void _playSong(Song song) {
    setState(() {
      _currentSong = song;
      _isPlaying = true; // koi real audio nahi, sirf icon change
    });
  }

  void _togglePlayPause() {
    if (_currentSong == null) return;
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _createPlaylist(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _playlists.add(
        Playlist(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
        ),
      );
    });
  }

  void _addSongToPlaylist(String playlistId, String songId) {
    setState(() {
      final playlist =
          _playlists.firstWhere((p) => p.id == playlistId, orElse: () => throw Exception('Playlist not found'));
      if (!playlist.songIds.contains(songId)) {
        playlist.songIds.add(songId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      BrowsePage(
        songs: _browseSongs,
        favoriteIds: _favoriteIds,
        onToggleFavorite: _toggleFavorite,
        onPlaySong: _playSong,
      ),
      SearchPage(
        query: _searchQuery,
        results: _searchResults,
        favoriteIds: _favoriteIds,
        onQueryChanged: _updateSearch,
        onToggleFavorite: _toggleFavorite,
        onPlaySong: _playSong,
      ),
      LibraryPage(
        allSongs: _songs,
        favoriteSongs: _favoriteSongs,
        playlists: _playlists,
        onCreatePlaylist: _createPlaylist,
        onAddSongToPlaylist: _addSongToPlaylist,
        onPlaySong: _playSong,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Streaming (UI Demo)'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Guest User',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          NowPlayingBar(
            song: _currentSong,
            isPlaying: _isPlaying,
            onPlayPause: _togglePlayPause,
          ),
          Expanded(
            child: pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}

// ---------------------- NOW PLAYING BAR ----------------------

class NowPlayingBar extends StatelessWidget {
  final Song? song;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const NowPlayingBar({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    if (song == null) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(song!.imageUrl),
        ),
        title: Text(song!.title),
        subtitle: Text(song!.artist),
        trailing: IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: onPlayPause,
        ),
      ),
    );
  }
}

// ---------------------- BROWSE PAGE ----------------------

class BrowsePage extends StatelessWidget {
  final List<Song> songs;
  final Set<String> favoriteIds;
  final void Function(String songId) onToggleFavorite;
  final void Function(Song song) onPlaySong;

  const BrowsePage({
    super.key,
    required this.songs,
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.onPlaySong,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isFav = favoriteIds.contains(song.id);
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(song.imageUrl),
            ),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : null,
                  ),
                  onPressed: () => onToggleFavorite(song.id),
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => onPlaySong(song),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------- SEARCH PAGE ----------------------

class SearchPage extends StatelessWidget {
  final String query;
  final List<Song> results;
  final Set<String> favoriteIds;
  final ValueChanged<String> onQueryChanged;
  final void Function(String songId) onToggleFavorite;
  final void Function(Song song) onPlaySong;

  const SearchPage({
    super.key,
    required this.query,
    required this.results,
    required this.favoriteIds,
    required this.onQueryChanged,
    required this.onToggleFavorite,
    required this.onPlaySong,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search for songs or artists',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: onQueryChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final song = results[index];
              final isFav = favoriteIds.contains(song.id);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.imageUrl),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : null,
                        ),
                        onPressed: () => onToggleFavorite(song.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => onPlaySong(song),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------- LIBRARY PAGE ----------------------

class LibraryPage extends StatefulWidget {
  final List<Song> allSongs;
  final List<Song> favoriteSongs;
  final List<Playlist> playlists;
  final void Function(String playlistName) onCreatePlaylist;
  final void Function(String playlistId, String songId) onAddSongToPlaylist;
  final void Function(Song song) onPlaySong;

  const LibraryPage({
    super.key,
    required this.allSongs,
    required this.favoriteSongs,
    required this.playlists,
    required this.onCreatePlaylist,
    required this.onAddSongToPlaylist,
    required this.onPlaySong,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _playlistNameCtrl = TextEditingController();

  @override
  void dispose() {
    _playlistNameCtrl.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Playlist'),
          content: TextField(
            controller: _playlistNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Playlist name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playlistNameCtrl.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _playlistNameCtrl.text;
                if (name.trim().isNotEmpty) {
                  widget.onCreatePlaylist(name.trim());
                }
                _playlistNameCtrl.clear();
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showAddToPlaylistDialog(Song song) {
    if (widget.playlists.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No playlists'),
          content: const Text('Create a playlist first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add to playlist'),
          children: widget.playlists
              .map(
                (p) => SimpleDialogOption(
                  onPressed: () {
                    widget.onAddSongToPlaylist(p.id, song.id);
                    Navigator.pop(context);
                  },
                  child: Text(p.name),
                ),
              )
              .toList(),
        );
      },
    );
  }

  List<Song> _songsForPlaylist(Playlist playlist) {
    return playlist.songIds
        .map((id) => widget.allSongs.firstWhere((s) => s.id == id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = widget.favoriteSongs;
    final playlists = widget.playlists;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        ListTile(
          title: const Text(
            'Favorites',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${favoriteSongs.length} songs'),
        ),
        if (favoriteSongs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('No favorites yet. Tap the heart icon on a song.'),
          )
        else
          ...favoriteSongs.map(
            (song) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(song.imageUrl),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => widget.onPlaySong(song),
                ),
                onLongPress: () => _showAddToPlaylistDialog(song),
              ),
            ),
          ),
        const Divider(),
        ListTile(
          title: const Text(
            'Playlists',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
          ),
        ),
        if (playlists.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('No playlists yet. Create your first playlist.'),
          )
        else
          ...playlists.map(
            (p) => ExpansionTile(
              title: Text(p.name),
              children: [
                ..._songsForPlaylist(p).map(
                  (song) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(song.imageUrl),
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artist),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => widget.onPlaySong(song),
                    ),
                  ),
                ),
                if (_songsForPlaylist(p).isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('No songs in this playlist yet.'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
