
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_shorts/youtube_shorts.dart';
class VideoData {
  final String thumbnailUrl;
  final String videoUrl;

  VideoData({required this.thumbnailUrl, required this.videoUrl});
}

List<VideoData> videoListMockData = [
  // VideoData(
  //   thumbnailUrl: 'https://example.com/thumbnail1.jpg',
  //   videoUrl: 'https://example.com/video1.mp4',
  // ),
  VideoData(
    thumbnailUrl: 'https://storage.googleapis.com/download/storage/v1/b/iron-sight/o/undefined%2FT1%2FThumbnail?generation=1714575296929642&alt=media',
    videoUrl: 'https://www.youtube.com/shorts/hVh7Z2qgy_4',
  ),
  // Add more VideoData objects as needed
];

class VideoShortPlayer extends StatefulWidget {
  final VideoData videoData;

  const VideoShortPlayer({Key? key, required this.videoData}) : super(key: key);

  @override
  _VideoShortPlayerState createState() => _VideoShortPlayerState();
}

class _VideoShortPlayerState extends State<VideoShortPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoData.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Short'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

class VideoThumbnailGrid extends StatelessWidget {
  final List<VideoData> videoList= videoListMockData;

   VideoThumbnailGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of videos per row
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: videoList.length,
      itemBuilder: (context, index) {
        final videoData = videoList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoShortPlayer(videoData: videoData),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: videoData.thumbnailUrl,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

