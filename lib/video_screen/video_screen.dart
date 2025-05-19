import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dancebuddy/masterpage/masterpage.dart';
import 'package:dancebuddy/utils/theam_manager.dart';
import 'package:dancebuddy/utils/want_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:video_player/video_player.dart';
import '../utils/toast_massage.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  TextEditingController urlController;
  final bool showVideoShowcase;

  VideoPlayerScreen(
      {required this.videoUrl,
        required this.urlController,
        this.showVideoShowcase = false});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isSplitting = false;
  double _currentPosition = 0.0;
  List<Map<String, double>> _splitClips = [];
  double _currentSpeed = 1.0;
  bool isSpeedChange = false;
  bool _isMuted = false;
  bool _isMirrored = false;
  int? _currentPlayingSegment;
  int _retryCount = 0;
  final int _maxRetries = 3;
  final GlobalKey splitButtonKey = GlobalKey();
  final GlobalKey speedButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  List<TargetFocus> targets = [];
  TutorialCoachMark? tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    _controller?.addListener(_updatePosition);
    _controller?.addListener(() {
      if (_controller!.value.hasError) {
        print('Video player error: ${_controller!.value.errorDescription}');
        if (_controller!.value.errorDescription!.contains("Source error")) {
          print("Unsupported video format or invalid URL");
          // showToast("Unsupported video format or invalid URL", colorSubTittle);
        } else {
          print("An error occurred while playing the video");
          // showToast("An error occurred while playing the video", colorSubTittle);
        }
        _retryInitialization();
      }
    });
  }

  void initTargets() {
    targets.clear();

    // Split button step
    targets.add(
      TargetFocus(
        identify: "SplitButton",
        keyTarget: splitButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              child: AnimatedTextKit(
                key: ValueKey('split_text_animation'),
                animatedTexts: [
                  TypewriterAnimatedText(
                    "Tap here to split the video based on its duration into smaller parts.",
                    speed: Duration(milliseconds: 50),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
              ),
            ),
          ),
        ],
      ),
    );

    // Speed button step
    targets.add(
      TargetFocus(
        identify: "SpeedButton",
        keyTarget: speedButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              child: AnimatedTextKit(
                key: ValueKey('speed_text_animation'),
                animatedTexts: [
                  TypewriterAnimatedText(
                    "Use this button to adjust playback speed.",
                    speed: Duration(milliseconds: 50),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) async {
          _controller?.setLooping(true);
          setState(() {
            _controller?.play();
          });

          if (widget.showVideoShowcase) {
            final prefs = await SharedPreferences.getInstance();
            bool alreadyShown = prefs.getBool('video_showcase_shown') ?? false;

            if (!alreadyShown && mounted) {
              initTargets();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                tutorialCoachMark = TutorialCoachMark(
                  targets: targets,
                  onClickTarget: (target) async {
                    if (target.identify == "SplitButton") {
                      tutorialCoachMark?.finish();
                      await Future.delayed(Duration(milliseconds: 300));
                      _toggleSplit();
                      await Future.delayed(Duration(seconds: 2));

                      tutorialCoachMark = TutorialCoachMark(
                        targets: [targets.firstWhere((t) => t.identify == "SpeedButton")],
                        colorShadow: Colors.black87,
                        opacityShadow: 0.85,
                        paddingFocus: 10,
                        hideSkip: true,
                        onFinish: () {},
                        onClickTarget: (target) async {
                          if (target.identify == "SpeedButton") {
                            tutorialCoachMark?.finish();

                            // print("Speed button target clicked");
                            // showToast("Speed button pressed", Colors.white);

                            await Future.delayed(Duration(milliseconds: 300));
                            if (mounted) {
                              setState(() {
                                isSpeedChange = true;
                              });
                            }
                          }
                        },
                      );

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        tutorialCoachMark?.show(context: context);
                      });

                    } else if (target.identify == "SpeedButton") {
                      tutorialCoachMark?.finish();

                      // print("Speed button target clicked");
                      // showToast("Speed button pressed", Colors.white);

                      await Future.delayed(Duration(seconds: 1));
                      if (mounted) {
                        setState(() {
                          isSpeedChange = true;
                        });
                      }
                    }
                  },
                  colorShadow: Colors.black87,
                  opacityShadow: 0.85,
                  paddingFocus: 10,
                  hideSkip: true,
                  onFinish: () async {
                    await prefs.setBool('video_showcase_shown', true);
                  },
                );

                tutorialCoachMark?.show(context: context);
              });
            }
          }
        }).catchError((error) {
          // Log the error if initialization fails
          print('Error initializing video: $error');
          // showToast("Error initializing video", colorSubTittle);
          _retryInitialization();
        });
    } catch (e) {
      print('Error in _initializePlayer: $e');
      // showToast("Error initializing video player", colorSubTittle);
      _retryInitialization();
    }
  }

  void _retryInitialization() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      Future.delayed(Duration(seconds: 2), () {
        _initializePlayer();
      });
    } else {
      print('Max retries reached. Could not initialize video player.');
      // showToast("Max retries reached. Could not initialize video player", colorSubTittle);
    }
  }

  void _updatePosition() {
    setState(() {
      _currentPosition =
          _controller?.value.position.inSeconds.toDouble() ?? 0.0;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _changeSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
      _controller?.setPlaybackSpeed(speed);
      isSpeedChange = !isSpeedChange;
    });
  }

  void _toggleSplit() {
    if (_controller == null) return;

    setState(() {
      _isSplitting = !_isSplitting;

      if (_isSplitting) {
        final totalDuration = _controller!.value.duration.inSeconds;

        if (totalDuration < 10) {
          showToast("Video is too short", colorSubTittle);
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
        "end": (i + clipLength > totalDuration)
            ? totalDuration.toDouble()
            : i + clipLength,
      });
    }
    return clips;
  }

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
          color: _currentSpeed == speed ? colorSubTittle : Colors.transparent,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
      ),
      child: GestureDetector(
        onTap: () {
          _changeSpeed(speed);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.018,
          ),
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

  Widget _splitClipView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _splitClips.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, double> clip = entry.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      onTap: () {
        setState(() {
          _currentPlayingSegment = index;
          _controller!
              .seekTo(Duration(seconds: _splitClips[index]["start"]!.toInt()));
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
        height: _splitClips.length > 3
            ? MediaQuery.of(context).size.height * 0.065
            : MediaQuery.of(context).size.height * 0.04,
        decoration: BoxDecoration(
          border: Border.all(
              color: _currentPlayingSegment == index
                  ? colorSubTittle
                  : Colors.transparent),
          borderRadius: BorderRadius.all(
              Radius.circular(MediaQuery.of(context).size.width * 0.02)),
          // color:_currentPlayingSegment == index
          //     ? colorBlack: colorSubTittle,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: _splitClips.length > 3
                    ? MediaQuery.of(context).size.width * 0.01
                    : MediaQuery.of(context).size.width * 0.05),
            child: Text(
              textAlign: TextAlign.center,
              _splitClips.length > 3
                  ? '${index + 1}: ${_formatTime(clip['start']!)}s \n- \n${_formatTime(clip['end']!)}s'
                  : '${index + 1}: ${_formatTime(clip['start']!)}s - ${_formatTime(clip['end']!)}s',
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

// merge button
  Widget _buildMergeButton(int index) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(_splitClips.length > 3
            ? MediaQuery.of(context).size.height * 0.003
            : MediaQuery.of(context).size.height * 0.005),
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

  void _mergeClips(int index) {
    setState(() {
      // Merge the current clip with the next one
      double newEnd = _splitClips[index + 1]['end']!;
      _splitClips[index]['end'] = newEnd; // Extend the current clip's end
      _splitClips.removeAt(index + 1); // Remove the next clip

      // Check if only one part remains
      if (_splitClips.length == 1) {
        setState(() {
          _isSplitting = !_isSplitting;
        });
        // Automatically disable splitting
      }
    });
  }

  String _formatTime(double time) {
    return time.toStringAsFixed(0); // Round to the nearest whole second
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  // Toggle Mirror Functionality
  void _toggleMirror() {
    setState(() {
      _isMirrored = !_isMirrored;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Video Player'),
      // ),
        body: Container(
          height: double.infinity,
          width: double.infinity, color: colorBlack,
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage("assets/images/bg.png"),
          //     fit: BoxFit.cover,
          //   ),
          // ),
          child: _controller != null && _controller!.value.isInitialized
              ? SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height * 0.045),
                Container(
                  color: colorBlack,
                  padding: EdgeInsets.symmetric(vertical: height * 0.005),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              color: colorWhite,
                              _controller!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size:
                              MediaQuery.of(context).size.height * 0.035,
                            ),
                            WantText(
                                _controller!.value.isPlaying
                                    ? "Pause"
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
                              color: _isMuted ? colorSubTittle : colorWhite,
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              size:
                              MediaQuery.of(context).size.height * 0.035,
                            ),
                            WantText("Audio", width * 0.035, FontWeight.w500,
                                _isMuted ? colorSubTittle : colorWhite)
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleMirror,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              color:
                              _isMirrored ? colorSubTittle : colorWhite,
                              Icons.compare_rounded,
                              size:
                              MediaQuery.of(context).size.height * 0.035,
                            ),
                            WantText("Mirror", width * 0.035, FontWeight.w500,
                                _isMirrored ? colorSubTittle : colorWhite)
                          ],
                        ),
                      ),
                      Container(
                        key: speedButtonKey,
                        child: GestureDetector(
                          onTap: () {
                            if (tutorialCoachMark?.isShowing ?? false) return;
                            setState(() {
                              isSpeedChange = !isSpeedChange;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                color: isSpeedChange
                                    ? colorSubTittle
                                    : colorWhite,
                                Icons.speed,
                                size: MediaQuery.of(context).size.height *
                                    0.035,
                              ),
                              WantText(
                                  "Speed",
                                  width * 0.035,
                                  FontWeight.w500,
                                  isSpeedChange ? colorSubTittle : colorWhite)
                            ],
                          ),
                        ),
                      ),
                      Container(
                        key: splitButtonKey,
                        child: GestureDetector(
                          onTap: _toggleSplit,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.call_split,
                                color: Colors.white,
                                size: MediaQuery.of(context).size.height *
                                    0.035,
                              ),
                              Text(
                                'Split',
                                style: TextStyle(
                                  fontSize:
                                  MediaQuery.of(context).size.width *
                                      0.035,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
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
                isSpeedChange == true
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _speedControlButtons(),
                  ],
                )
                    : SizedBox(),
                _splitClips.length > 1
                    ? Column(
                  children: [
                    Container(
                        height: _splitClips.length > 3
                            ? height * 0.065
                            : height * 0.04,
                        width: width,
                        color: Color.fromRGBO(53, 61, 74, 1),
                        child: Align(
                            alignment: _splitClips.length < 3
                                ? Alignment.centerLeft
                                : Alignment.center,
                            child: _splitClipView())),
                  ],
                )
                    : SizedBox(),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(_isMirrored ? -1.0 : 1.0, 1.0, 1.0),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..scale(
                                        _isMirrored ? -1.0 : 1.0, 1.0, 1.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: _isMirrored
                                        ? [
                                      WantText("Right", 14,
                                          FontWeight.bold, colorWhite),
                                      WantText("Left", 14,
                                          FontWeight.bold, colorWhite),
                                    ]
                                        : [
                                      WantText("Left", 14,
                                          FontWeight.bold, colorWhite),
                                      WantText("Right", 14,
                                          FontWeight.bold, colorWhite),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, VideoPlayerValue value, child) {
                    final position = value.position.inMilliseconds.toDouble();
                    final duration = value.duration.inMilliseconds.toDouble();

                    return SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3, // Set custom height here
                        thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        min: 0,
                        max: duration,
                        value: position.clamp(0, duration),
                        activeColor: Colors.redAccent,
                        inactiveColor: Colors.white24,
                        onChanged: (newValue) {
                          _controller!.seekTo(
                              Duration(milliseconds: newValue.toInt()));
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          )
              : Center(
            child: LoadingAnimationWidget.progressiveDots(
              color: colorWhite,
              size: width * 0.12,
            ),
          ),
        ));
  }
}
