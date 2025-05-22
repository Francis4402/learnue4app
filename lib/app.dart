import 'package:flutter/material.dart';
import 'package:learnue4app/services/api_service.dart';
import 'package:learnue4app/utils/channel_model.dart';
import 'package:learnue4app/utils/video_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Channel? _channel;
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  Future<void> _initChannel() async {
    setState(() {
      _isLoading = true;
    });

    Channel channel = await APIService.instance.fetchChannel(channelId: 'UCrHLGHxIEFGIKOwaPwaqjtg');

    setState(() {
      _channel = channel;
      _isLoading = false;
    });
  }

  Future<void> _openVideoOnYouTube(String videoId) async {
    final Uri youtubeAppUri = Uri.parse('vnd.youtube://watch?v=$videoId');
    final Uri youtubeWebUri = Uri.parse('https://www.youtube.com/watch?v=$videoId');

    if (await canLaunchUrl(youtubeAppUri)) {
      await launchUrl(youtubeAppUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(youtubeWebUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildVideo(Video video) {
    return GestureDetector(
      onTap: () => _openVideoOnYouTube(video.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        padding: const EdgeInsets.all(10.0),
        height: 320,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                video.thumbnailUrl,
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 25.0),
            Expanded(
              child: Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMoreVideos() async {
    if (_channel == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    List<Video> moreVideos = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: _channel!.uploadPlaylistId);

    setState(() {
      _channel!.videos.addAll(moreVideos);
      _isLoading = false;
    });
  }

  List<Video> get _filteredVideos {
    if (_searchQuery.isEmpty) {
      return _channel?.videos ?? [];
    }
    return _channel!.videos
        .where((video) => video.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _isSearching
              ? TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search videos...',
              hintStyle: TextStyle(color: Colors.white60),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          )
              : const Text('Learn UE4'),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          // if(isLoggedIn)
          //   PopupMenuButton<String>(
          //     icon: const Icon(Icons.person),
          //     onSelected: (value) {
          //       if (value == 'profile') {
          //         Get.to(() => const ProfilePage());
          //       } else if (value == 'logout') {
          //         AuthService().signOut(context);
          //       }
          //     },
          //     itemBuilder: (context) => [
          //       const PopupMenuItem<String>(
          //         value: 'profile',
          //         child: Text('Profile'),
          //       ),
          //       const PopupMenuItem<String>(
          //         value: 'logout',
          //         child: Text('Logout'),
          //       ),
          //     ],
          //   ),
        ],
      ),
      body: _channel == null || _isLoading
          ? ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return Skeletonizer(
            enabled: true,
            child: _buildVideo(Video(
              id: '',
              title: 'Loading...',
              thumbnailUrl: 'https://res.cloudinary.com/dse9babc4/image/upload/v1741417182/forthumbnailloading_www8jv.png', channelTitle: 'learn ue4',
            )),
          );
        },
      )
          : NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollDetails) {
          if (!_isLoading &&
              _channel!.videos.length !=
                  int.parse(_channel!.videoCount) &&
              scrollDetails.metrics.pixels ==
                  scrollDetails.metrics.maxScrollExtent) {
            _loadMoreVideos();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: _filteredVideos.length,
          itemBuilder: (BuildContext context, int index) {
            Video video = _channel!.videos[index];
            return _buildVideo(video);
          },
        ),
      ),
    );
  }
}
