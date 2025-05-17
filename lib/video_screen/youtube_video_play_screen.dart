import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../masterpage/masterpage.dart';
import '../utils/theam_manager.dart';
import '../utils/toast_massage.dart';
import '../utils/want_text.dart';

class FullScreenYouTubePlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenYouTubePlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  _FullScreenYouTubePlayerState createState() =>
      _FullScreenYouTubePlayerState();
}

class _FullScreenYouTubePlayerState extends State<FullScreenYouTubePlayer> {
  late YoutubePlayerController _controller;
  double _currentSpeed = 1.0;
  bool _isMuted = false;
  bool _isMirrored = false;
  bool _isSplitting = false;
  bool _showSpeedControls = false;
  List<Map<String, double>> _splitClips = [];  int? _currentPlayingSegment;

  @override
  void initState() {
    super.initState();
    String videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "";
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(disableDragSeek: true,useHybridComposition: false,
        autoPlay: true,
        mute: false,
        enableCaption: true,
        hideThumbnail: true, // Prevent showing thumbnails after the video ends
        loop: false, // Disable looping
        // forceHideAnnotation: true, // Hide "Watch Again" and suggestions
        hideControls: false, // Keep basic controls
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
      _controller.setPlaybackRate(speed);  _showSpeedControls = !_showSpeedControls;// Set playback rate dynamically
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 100);
    });
  }

  void _toggleMirror() {
    setState(() {
      _isMirrored = !_isMirrored;
    });
  }

  void _toggleSplit() {
    if (_controller == null || !_controller.value.isPlaying) return;

    setState(() {
      _isSplitting = !_isSplitting;

      if (_isSplitting) {
        final totalDuration = _controller!.value.metaData.duration.inSeconds;

        if (totalDuration < 10) {
          showToast("Video is too short", colorRed);
          return;
        }

        int numSplits = 3; // Default split into 3 parts
        if (totalDuration > 60 && totalDuration < 120) {
          numSplits = 6; // Split into 6 parts for videos between 1 to 2 minutes
        }
        if (totalDuration > 120) {
          numSplits = 9; // Split into 9 parts for videos longer than 2 minutes
        }

        _splitClips = _generateSplits(totalDuration, numSplits);
      } else {
        _splitClips.clear();
      }
    });
  }


  List<Map<String, double>> _generateSplits(int totalDuration, int parts) {
    List<Map<String, double>> clips = [];
    double clipLength = totalDuration / parts;

    for (double i = 0; i < totalDuration; i += clipLength) {
      clips.add({
        "start": i,
        "end": (i + clipLength > totalDuration) ? totalDuration.toDouble() : i + clipLength,
      });
    }
    return clips;
  }

  String _formatTime(double time) {
    return time.toStringAsFixed(0); // Round to the nearest whole second
  }


  // Widget _speedControlButtons() {
  //   List<double> speeds = [0.25, 0.5, 1.0, 1.5, 2.0];
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: speeds.map((speed) {
  //       return Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 5),
  //         child: ElevatedButton(
  //           onPressed: () => _changeSpeed(speed),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: _currentSpeed == speed ? Colors.redAccent : Colors.grey,
  //           ),
  //           child: Text('${speed}x', style: const TextStyle(color: Colors.white)),
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _speedControlButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _speedButton(0.01, '0.01x'),
          _speedButton(0.25, '0.25x'),
          _speedButton(0.5, '0.5x'),
          _speedButton(1.0, '1x'),
          _speedButton(1.5, '1.5x'),
          _speedButton(2.0, '2x'),
          _speedButton(4.0, '4x'),
          _speedButton(8.0, '8x'),
        ],
      ),
    );
  }

  Widget _speedButton(double speed, String label) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.012), // Optional spacing between buttons
      decoration: BoxDecoration(
        border: Border.all(
          color: _currentSpeed == speed ? colorRed : Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
      ),
      child: GestureDetector(
        onTap: () {
          _changeSpeed(speed);
        },
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width * 0.018,),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              textStyle: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: colorWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      ),
    );
  }

  Widget _buildSplitClips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _splitClips.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, double> clip = entry.value;
          return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildClipWidget(clip, index),
              // Clip display
              if (index < _splitClips.length - 1) _buildMergeButton(index),
              // Merge button between clips
            ],
          );
        }).toList(),
      ),
    );
  }


  Widget _buildClipWidget(Map<String, double> clip, int index) {
    return GestureDetector(
      //   onTap: () {
      //   setState(() {
      //     _currentPlayingSegment = index; // Set the current segment
      //   });
      //     _controller!.seekTo(Duration(seconds: clip['start']!.toInt()));
      //     _controller!.play();
      //
      // },
      onTap: () {
        setState(() {
          _currentPlayingSegment = index;
          _controller!.seekTo(Duration(seconds: _splitClips[index]["start"]!.toInt()));
          _controller!.play();
        });

        _controller!.addListener(() {
          if (_currentPlayingSegment != null &&
              _controller!.value.position.inSeconds >=
                  _splitClips[_currentPlayingSegment!]["end"]!.toInt()) {
            _controller!.pause();
            setState(() {
              _currentPlayingSegment = null;
            });
          }
        });
      },
      child: Container(
        // Clip container styling
        height: _splitClips.length>3?  MediaQuery.of(context).size.height * 0.065:MediaQuery.of(context).size.height * 0.04,
        decoration: BoxDecoration(border: Border.all(color: _currentPlayingSegment == index
            ? colorRed: Colors.transparent),
          borderRadius: BorderRadius.all(
              Radius.circular(MediaQuery.of(context).size.width * 0.02)),
          // color:_currentPlayingSegment == index
          //     ? colorBlack: colorSubTittle,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:_splitClips.length>3?MediaQuery.of(context).size.width * 0.01: MediaQuery.of(context).size.width * 0.05),
            child: Text(textAlign: TextAlign.center,
              _splitClips.length>3?   '${index+1}: ${_formatTime(clip['start']!)}s \n- \n${_formatTime(clip['end']!)}s':'${index+1}: ${_formatTime(clip['start']!)}s - ${_formatTime(clip['end']!)}s',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.03,
                color: colorWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _mergeClips(int index) {
    setState(() {
      // Merge the current clip with the next one
      double newEnd = _splitClips[index + 1]['end']!;
      _splitClips[index]['end'] = newEnd; // Extend the current clip's end
      _splitClips.removeAt(index + 1);   // Remove the next clip

      // Check if only one part remains
      if (_splitClips.length == 1) {setState(() {
        _isSplitting = !_isSplitting;
      });
        // Automatically disable splitting
      }
    });
  }

  Widget _buildMergeButton(int index) {
    return GestureDetector(
      child: Padding(
        padding:  EdgeInsets.all(_splitClips.length>3?MediaQuery.of(context).size.height * 0.003:MediaQuery.of(context).size.height * 0.005),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.028,
            width: MediaQuery.of(context).size.height * 0.028,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.height * 0.008),
              ),
              color: colorWhite,
            ),
            child: Icon(
              Icons.add,
              color: colorMainTheme,
              size: MediaQuery.of(context).size.height * 0.025,
            )),
      ),
      onTap: () {
        _mergeClips(index);
      },
    );
  }


  @override
  Widget build(BuildContext context) { double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return Scaffold(

    body: Container( height: double.infinity,
      width: double.infinity,color: colorBlack,
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/images/bg.png"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Column(
        children: [ SizedBox(height: height * 0.045),
          Container(
            decoration: BoxDecoration(color: colorBlack,
              // gradient: LinearGradient(
              //   colors: [
              //     Color(0xFF000000), // Instagram gradient colors
              //     Color(0xFF000000),
              //     Color(0xFF000000),
              //     Color(0xFF000000),
              //   ],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            padding: EdgeInsets.symmetric(vertical: height * 0.005),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        color: colorWhite,
                        _controller.value.isPlaying ?
                        Icons.pause
                            : Icons.play_arrow,
                        size:
                        MediaQuery.of(context).size.height * 0.035,
                      ),
                      WantText(
                          _controller.value.isPlaying ? "Pause"
                              : "Play",
                          width * 0.035,
                          FontWeight.w500,
                          colorWhite)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _toggleMute,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        color:_isMuted ?colorRed: colorWhite,
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        size:
                        MediaQuery.of(context).size.height * 0.035,
                      ),
                      WantText("Audio", width * 0.035, FontWeight.w500,
                          _isMuted ?colorRed:colorWhite)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _toggleMirror,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        color: _isMirrored
                            ?colorRed: colorWhite,
                        Icons.compare_rounded,
                        size:
                        MediaQuery.of(context).size.height * 0.035,
                      ),
                      WantText("Mirror", width * 0.035, FontWeight.w500,
                          _isMirrored
                              ?colorRed:   colorWhite)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSpeedControls = !_showSpeedControls;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        color:_showSpeedControls?colorRed: colorWhite,
                        Icons.speed,
                        size:
                        MediaQuery.of(context).size.height * 0.035,
                      ),
                      WantText("Speed", width * 0.035, FontWeight.w500,
                          _showSpeedControls?colorRed:colorWhite)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _toggleSplit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        color:_isSplitting?colorRed: colorWhite,
                        Icons.call_split,
                        size:
                        MediaQuery.of(context).size.height * 0.035,
                      ),
                      WantText('Split', width * 0.035, FontWeight.w500,
                          _isSplitting?colorRed: colorWhite)
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MasterPage(),
                        ));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        color: colorWhite,
                        Icons.home,
                        size:
                        MediaQuery.of(context).size.height * 0.035,
                      ),
                      WantText("Home", width * 0.035, FontWeight.w500,
                          colorWhite)
                    ],
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(height: height * 0.01),
          if (_showSpeedControls)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _speedControlButtons(),

              ],
            ),

          if ( _splitClips.length>1)  Column(
            children: [
              // SizedBox(
              //     height:
              //     MediaQuery.of(context).size.height * 0.01),
              Container(height:_splitClips.length>3? height*0.065:height*0.04,width: width, color: Color.fromRGBO(53, 61, 74, 1),child: Center(child: _buildSplitClips())),

            ],
          )
          ,
          // Full-screen YouTube Player
          (widget.videoUrl.contains('shorts'))  ?  Expanded(
            child: Transform.scale(
              scaleX: _isMirrored ? -1 : 1,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
            ),
          ):Stack(children: [Transform.scale(
            scaleX: _isMirrored ? -1 : 1,
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
            ),
          ),Padding(
            padding:
            EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scale(_isMirrored ? 1.0 : 1.0, 1.0, -1.0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: _isMirrored
                    ? [
                  WantText("Right", 14, FontWeight.bold,colorWhite
                  ),
                  WantText("Left", 14, FontWeight.bold,colorWhite
                  ),
                ]
                    : [
                  WantText("Left", 14, FontWeight.bold,colorWhite
                  ),
                  WantText("Right", 14, FontWeight.bold,colorWhite
                  ),
                ],
              ),
            ),
          ),],),

          // Controls Row
          // Container(
          //   color: Colors.black87,
          //   padding: const EdgeInsets.all(8),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       IconButton(
          //         icon: Icon(
          //           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          //           color: Colors.white,
          //         ),
          //         onPressed: () {
          //           setState(() {
          //             _controller.value.isPlaying
          //                 ? _controller.pause()
          //                 : _controller.play();
          //           });
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(
          //           _isMuted ? Icons.volume_off : Icons.volume_up,
          //           color: Colors.white,
          //         ),
          //         onPressed: _toggleMute,
          //       ),
          //       IconButton(
          //         icon: Icon(
          //           Icons.compare_arrows,
          //           color: _isMirrored ? Colors.redAccent : Colors.white,
          //         ),
          //         onPressed: _toggleMirror,
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.speed, color: Colors.white),
          //         onPressed: () {
          //           setState(() {
          //             _showSpeedControls = !_showSpeedControls;
          //           });
          //         },
          //       ),
          //       IconButton(
          //         icon: Icon(
          //           Icons.call_split,
          //           color: _isSplitting ? Colors.redAccent : Colors.white,
          //         ),
          //         onPressed: _toggleSplit,
          //       ),
          //     ],
          //   ),
          // ),
          //
          // // Speed Controls
          // if (_showSpeedControls) _speedControlButtons(),
          //
          // // Split Clips View
          // if (_splitClips.isNotEmpty) _buildSplitClips(),
        ],
      ),
    ),
  );
  }
}
