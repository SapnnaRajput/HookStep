import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../home_screen/home_screen.dart';
import '../utils/theam_manager.dart';
import '../utils/want_text.dart';
import 'package:google_fonts/google_fonts.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  final String youtubeUrl;

  const YoutubeVideoPlayerScreen({required this.youtubeUrl});

  @override
  _YoutubeVideoPlayerScreenState createState() => _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isMuted = false;
  bool _isMirrored = false;
  double _currentSpeed = 1.0;
  List<Map<String, double>> _splitClips = [];
  int? _currentPlayingSegment;
  bool _isSplitting = false;
  bool isSpeedChange = false;

  @override
  void initState() {
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        disableDragSeek: false,
        isLive: false,
        forceHD: true,
        hideControls: true,
        hideThumbnail: true,
        loop: true,
        showLiveFullscreenButton: false,
        controlsVisibleAtStart: true,
      ),
    );

    _controller.addListener(() {
      if (_isSplitting && _currentPlayingSegment != null) {
        final position = _controller.value.position.inSeconds;
        final end = _splitClips[_currentPlayingSegment!]['end']!.toInt();
        if (position >= end) {
          _controller.pause();
          setState(() {
            _currentPlayingSegment = null;
          });
        }
      }
    });
    super.initState();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _isMuted ? _controller.mute() : _controller.unMute();
    });
  }

  void _toggleMirror() {
    setState(() {
      _isMirrored = !_isMirrored;
    });
  }

  void _changeSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
      _controller.setPlaybackRate(speed);
    });
  }

  void _toggleSplit() async {
    final duration = _controller.metadata.duration.inSeconds;
    if (duration < 10) return;
    setState(() {
      _isSplitting = !_isSplitting;
      _splitClips = [];
      if (_isSplitting) {
        int parts = 3;
        double clipLength = duration / parts;
        for (double i = 0; i < duration; i += clipLength) {
          _splitClips.add({
            'start': i,
            'end': (i + clipLength > duration) ? duration.toDouble() : i + clipLength,
          });
        }
      }
    });
  }

  void _mergeClips(int index) {
    setState(() {
      double newEnd = _splitClips[index + 1]['end']!;
      _splitClips[index]['end'] = newEnd;
      _splitClips.removeAt(index + 1);
      if (_splitClips.length == 1) _isSplitting = false;
    });
  }

  void _playClip(int index) {
    final start = Duration(seconds: _splitClips[index]['start']!.toInt());
    _controller.seekTo(start);
    _controller.play();
    setState(() {
      _currentPlayingSegment = index;
    });
  }

  String _formatTime(double time) => time.toStringAsFixed(0);

  Widget _speedControlButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _speedButton(0.25, '0.25x'),
          _speedButton(0.5, '0.5x'),
          _speedButton(1.0, '1x'),
          _speedButton(1.5, '1.5x'),
          _speedButton(2.0, '2x'),
        ],
      ),
    );
  }

  Widget _speedButton(double speed, String label) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _currentSpeed == speed ? colorSubTittle : Colors.transparent),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GestureDetector(
        onTap: () => _changeSpeed(speed),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              textStyle: TextStyle(
                fontSize: 14,
                color: colorWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _splitClipView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _splitClips.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, double> clip = entry.value;
          return Row(
            children: [
              _buildClipWidget(clip, index),
              if (index < _splitClips.length - 1) _buildMergeButton(index),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClipWidget(Map<String, double> clip, int index) {
    return GestureDetector(
      onTap: () => _playClip(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: _currentPlayingSegment == index ? colorSubTittle : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white10,
        ),
        child: Text(
          '${index + 1}: ${_formatTime(clip['start']!)}s - ${_formatTime(clip['end']!)}s',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMergeButton(int index) {
    return GestureDetector(
      onTap: () => _mergeClips(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.add, color: colorWhite),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    IconButton(icon: Icon( _controller.value.isPlaying ? Icons.play_arrow : Icons.pause, color: colorWhite), onPressed: () {
                      setState(() {
                        _controller.value.isPlaying ? _controller.pause() : _controller.play();
                      });
                    },),
                    Text(_controller.value.isPlaying ? "Play" : "Pause",
                      style: TextStyle(color: Colors.white),)
                  ],
                ),
                Column(
                  children: [
                    IconButton(icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: colorWhite), onPressed: _toggleMute),
                    Text("Audio", style: TextStyle(color: Colors.white),)
                  ],
                ),
                Column(
                  children: [
                    IconButton(icon: Icon(Icons.compare, color: _isMirrored ? colorSubTittle : colorWhite), onPressed: _toggleMirror),
                    Text("Mirror", style: TextStyle(color: Colors.white),)
                  ],
                ),
                Column(
                  children: [
                    IconButton(icon: Icon(Icons.speed, color: isSpeedChange ? colorSubTittle : colorWhite), onPressed: () => setState(() => isSpeedChange = !isSpeedChange)),
                    Text("Speed", style: TextStyle(color: Colors.white),)
                  ],
                ),
                Column(
                  children: [
                    IconButton(icon: Icon(Icons.call_split, color: colorWhite), onPressed: _toggleSplit),
                    Text("Split", style: TextStyle(color: Colors.white),)
                  ],
                ),
                Column(
                  children: [
                    IconButton(icon: Icon(Icons.home, color: colorWhite), onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                    }),
                    Text("Home", style: TextStyle(color: Colors.white),)
                  ],
                ),
              ],
            ),
            if (isSpeedChange) _speedControlButtons(),
            if (_isSplitting && _splitClips.isNotEmpty) _splitClipView(),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(_isMirrored ? 3.1416 : 0),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned.fill(
                        child: YoutubePlayer(
                          controller: _controller,
                          showVideoProgressIndicator: false,
                          progressIndicatorColor: Colors.transparent,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _customProgressBar(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _customProgressBar() {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        final duration = _controller.metadata.duration;
        final position = value.position;

        double progress = 0.0;
        if (duration.inMilliseconds > 0) {
          progress = position.inMilliseconds / duration.inMilliseconds;
        }

        return Slider(
          value: progress.clamp(0.0, 1.0),
          onChanged: (newValue) {
            final newDuration = duration * newValue;
            _controller.seekTo(newDuration);
          },
          activeColor: Colors.red,
          inactiveColor: Colors.white24,
        );
      },
    );
  }
}
