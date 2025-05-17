import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;
import '../utils/app_const.dart';
import '../utils/string_const.dart';
import '../utils/theam_manager.dart';
import '../utils/toast_massage.dart';
import '../utils/want_text.dart';
import '../video_screen/video_screen.dart';
import '../video_screen/youtube_video_play_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _urlController = TextEditingController();
  String? _platform;
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>(); // Add Scaffold key for drawer
  final List<Map<String, String>> _lastPlayedUrls =
  []; // List to store last played URLs and timestamps
  int _searchCount = 0;

  @override
  void initState() {
    super.initState();
    _loadLastPlayedUrls();
    _loadSearchCount();
  }

  Future<void> _loadSearchCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchCount = prefs.getInt('searchCount') ?? 0;
    });
  }

  void _showEnterNameDialog(int index) {
    String newName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Name'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "Enter a name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (newName.isNotEmpty) {
                  await _saveUrl(_lastPlayedUrls[index]['url']!, name: newName);
                  Navigator.of(context).pop();

                  // Trigger UI refresh after rename
                  setState(() {
                    _loadLastPlayedUrls();
                  });
                } else {
                  showToast("Please enter a name", colorSubTittle);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _selectUrl(String url) {
    setState(() {
      _urlController.text = url;
    });
  }

// Save or update URL with an optional manual name to SharedPreferences
  Future<void> _saveUrl(String url, {String? name}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls =
        prefs.getStringList('lastPlayedUrlsWithTime') ?? [];

    // Get the current date and time
    String timestamp =
    DateFormat('MM-dd-yyyy - HH:mm:ss').format(DateTime.now());

    // Check if the URL is already saved
    int existingIndex = savedUrls.indexWhere((entry) => entry.startsWith(url));

    if (existingIndex != -1) {
      // Update both the name and timestamp
      String newEntry = '$url|$timestamp|${name ?? url}';
      savedUrls[existingIndex] = newEntry;
    } else {
      // Add a new entry if not already saved
      String newEntry = '$url|$timestamp|${name ?? url}';
      savedUrls.add(newEntry);
    }

    await prefs.setStringList('lastPlayedUrlsWithTime', savedUrls);

    // Update the UI immediately after saving
    setState(() {
      _loadLastPlayedUrls();
    });
  }

// Load URLs from SharedPreferences or fetch from API if none exist
  Future<void> _loadLastPlayedUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('lastPlayedUrlsWithTime') ?? [];

    if (savedUrls.isNotEmpty) {
      setState(() {
        _lastPlayedUrls.clear();
        _lastPlayedUrls.addAll(savedUrls.map((item) {
          var parts = item.split('|');
          return {
            'url': parts[0].trim(),
            'timestamp': parts.length > 1 ? parts[1].trim() : 'Unknown time',
            'name': parts.length > 2 ? parts[2].trim() : 'Unnamed'
          };
        }));

        // Sort the list in descending order based on the timestamp
        _lastPlayedUrls.sort((a, b) {
          DateTime dateA = DateFormat('MM-dd-yyyy - HH:mm:ss').parse(a['timestamp']!);
          DateTime dateB = DateFormat('MM-dd-yyyy - HH:mm:ss').parse(b['timestamp']!);
          return dateB.compareTo(dateA);
        });
      });
    } else {
      // If no data in SharedPreferences, fetch from API
      // await _fetchVideoLinksFromAPI();
    }
  }


  // Future<void> _fetchVideo() async {
  //   String url = _urlController.text.trim();
  //   if (url.isEmpty) {
  //     showToast("Please enter a URL", colorSubTittle);
  //     return;
  //   }
  //
  //   // Load search count and profile completion percentage
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   int searchCount = prefs.getInt('searchCount') ?? 0;
  //   double profileCompletionPercentage =
  //       prefs.getDouble('profileCompletionPercentage') ?? 0;
  //
  //   // Check if user has exceeded free fetch limit and profile is incomplete
  //   if (searchCount >= 5 && profileCompletionPercentage < 100) {
  //     showToast("Please complete your profile first", colorSubTittle);
  //     return;
  //   }
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://headstartai.genixbit.com/get_video_link'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         'url': url,
  //       }),
  //     );
  //
  //     print("Response Genixbit: ${response.statusCode}");
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       String videoUrl = data['url'];
  //
  //       if (videoUrl.isNotEmpty) {
  //         await _saveUrl(url, name: url);
  //         await _saveVideoLink(url);
  //         await _incrementSearchCount();
  //
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => VideoPlayerScreen(
  //               videoUrl: videoUrl,
  //               urlController: _urlController,
  //             ),
  //           ),
  //         );
  //       } else {
  //         showToast("Failed to fetch video URL", colorSubTittle);
  //         throw Exception("Failed to fetch video URL");
  //       }
  //     } else if (url.contains('youtu')) {
  //       await _saveUrl(url, name: url);
  //       await _saveVideoLink(url);
  //       await _incrementSearchCount();
  //
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => FullScreenYouTubePlayer(videoUrl: url),
  //         ),
  //       );
  //     } else if (url.contains('instagram')) {
  //       final instagramResponse = await http.get(
  //         Uri.parse('https://dancebuddy.io/api/extract_video_details?url=$url'),
  //       );
  //       print("Response Dancebuddy: ${response.statusCode}");
  //       if (instagramResponse.statusCode == 200) {
  //         final instagramData = json.decode(instagramResponse.body);
  //         String videoSrc = instagramData['videoSrc'];
  //
  //         if (videoSrc.isNotEmpty) {
  //           await _saveUrl(url, name: url);
  //           await _saveVideoLink(videoSrc);
  //           await _incrementSearchCount();
  //
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => VideoPlayerScreen(
  //                 videoUrl: videoSrc,
  //                 urlController: _urlController,
  //               ),
  //             ),
  //           );
  //         } else {
  //           showToast("Failed to fetch Instagram video URL", colorSubTittle);
  //           throw Exception("Failed to fetch Instagram video URL");
  //         }
  //       } else {
  //         showToast("Error fetching Instagram video", colorSubTittle);
  //         throw Exception("Error fetching Instagram video: ${instagramResponse.body}");
  //       }
  //     } else {
  //       final errorResponse = json.decode(response.body);
  //       String errorMessage = errorResponse['error'] ??
  //           "An error occurred while fetching the video";
  //
  //       showToast(errorMessage, colorSubTittle);
  //     }
  //   } catch (e) {
  //     showToast(e.toString(), colorSubTittle);
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  //
  //


  Future<void> _fetchVideo() async {
    String url = _urlController.text.trim();
    if (url.isEmpty) {
      showToast("Please enter a URL", colorSubTittle);
      return;
    }

    // Load search count and profile completion percentage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int searchCount = prefs.getInt('searchCount') ?? 0;
    double profileCompletionPercentage =
        prefs.getDouble('profileCompletionPercentage') ?? 0;

    // Check if user has exceeded free fetch limit and profile is incomplete
    if (searchCount >= 5 && profileCompletionPercentage < 100) {
      showToast("Please complete your profile first", colorSubTittle);
      return;
    }

    _determinePlatform(url);

    if (_platform == null) {
      showToast("Unsupported platform", colorSubTittle);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String videoUrl = '';

      // Attempt to fetch video URL using the primary API
      try {
        videoUrl = await _fetchOtherPlatformVideo(url);
      } catch (primaryError) {
        print("Primary API failed: $primaryError");

        // Fallback to the secondary API
        try {
          videoUrl = await _fetchSecondaryPlatformVideo(url);
        } catch (secondaryError) {
          print("Secondary API failed: $secondaryError");

          // Final fallback: Handle YouTube directly if both APIs fail
          if (url.contains("youtube.com") || url.contains("youtu.be")) {
            videoUrl = url;
            print("YouTube URL handled directly: $videoUrl");
          } else {
            throw Exception("Failed to fetch video from all sources.");
          }
        }
      }

      if (videoUrl.isNotEmpty) {
        await _saveUrl(url, name: url);
        await _saveVideoLink(url);
        await _incrementSearchCount();

        // Navigate to video player screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoUrl: videoUrl,
              urlController: _urlController,
            ),
          ),
        );
      } else {
        throw Exception("Failed to fetch video URL");
      }
    } catch (e) {
      showToast(e.toString(), colorSubTittle);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _fetchOtherPlatformVideo(String url) async {
    final String apiUrl = 'https://dancebuddy.io/api/extract_video_details?url=$url';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['videoSrc'] != null && data['videoSrc'].isNotEmpty) {
          return data['videoSrc'];
        } else {
          throw Exception('Video URL not found in the response.');
        }
      } else {
        throw Exception(
            'Failed to fetch video: HTTP ${response.statusCode}. ${response.body}');
      }
    } catch (e) {
      throw Exception("Error fetching video: $e");
    }
  }

  Future<String> _fetchSecondaryPlatformVideo(String url) async {
    final String apiUrl = 'https://headstartai.genixbit.com/get_video_link';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'url': url}),
      );

      print("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['url'] != null && data['url'].isNotEmpty) {
          return data['url'];
        } else {
          throw Exception("Video URL not found in the response.");
        }
      } else {
        throw Exception(
            'Failed to fetch video: HTTP ${response.statusCode}. ${response.body}');
      }
    } catch (e) {
      throw Exception("Error fetching video with secondary API: $e");
    }
  }


// Future<void> _fetchVideo() async {
//   String url = _urlController.text.trim();
//   if (url.isEmpty) {
//     showToast("Please enter a URL", colorSubTittle);
//     return;
//   }
//
//   // Load search count and profile completion percentage
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   int searchCount = prefs.getInt('searchCount') ?? 0;
//   double profileCompletionPercentage =
//       prefs.getDouble('profileCompletionPercentage') ?? 0;
//
//   // Check if user has exceeded free fetch limit and profile is incomplete
//   if (searchCount >= 5 && profileCompletionPercentage < 100) {showToast( "Please complete your profile first", colorSubTittle)
//    ;
//
//     return;
//   }
//
//   _determinePlatform(url);
//
//   if (_platform == null) {
//     showToast("Unsupported platform", colorSubTittle);
//     return;
//   }
//
//   setState(() {
//     _isLoading = true;
//   });
//
//   try {
//     String videoUrl;
//
//     switch (_platform) {
//       case 'YouTube':
//         videoUrl = url;
//         break;
//       case 'Instagram':
//         videoUrl = await _fetchOtherPlatformVideo(url);
//         break;
//       case 'Facebook':
//         videoUrl = await _fetchOtherPlatformVideo(url);
//         break;
//       case 'TikTok':
//         videoUrl = await _fetchOtherPlatformVideo(url);
//         break;
//       default:
//         throw Exception("Unsupported platform");
//     }
//
//     if (videoUrl.isNotEmpty) {
//       await _saveUrl(url, name: url);
//       await _saveVideoLink(url);
//
//       await _incrementSearchCount();
//
//       if (_platform == 'YouTube') {
//         // Navigate to FullScreenYouTubePlayer if the platform is YouTube
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FullScreenYouTubePlayer(videoUrl: videoUrl),
//           ),
//         );
//       } else {
//         // Navigate to VideoPlayerScreen for other platforms
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoPlayerScreen(
//               videoUrl: videoUrl,
//               urlController: _urlController,
//             ),
//           ),
//         );
//       }
//     } else {
//       throw Exception("Failed to fetch video URL");
//     }
//   } catch (e) {
//     showToast(e.toString(), colorSubTittle);
//   } finally {
//     setState(() {
//       _isLoading = false;
//     });
//   }
// }

  Future<void> _incrementSearchCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _searchCount = prefs.getInt('searchCount') ?? 0;
    _searchCount += 1;
    await prefs.setInt('searchCount', _searchCount);
    // if (_searchCount % 5 == 0) {
    //   showToast("Please complete your profile", colorSubTittle);
    // }
  }

  void _determinePlatform(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      _platform = 'YouTube';
    } else if (url.contains('instagram.com')) {
      _platform = 'Instagram';
    } else if (url.contains('facebook.com')) {
      _platform = 'Facebook';
    } else if (url.contains('tiktok.com')) {
      _platform = 'TikTok';
    } else {
      _platform = null;
    }
  }

// Function to save video link to the server
  Future<void> _saveVideoLink(String videoLink) async {
    try {
      // Get the saved _id and token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('id');

      if (id == null || token == null) {
        throw Exception("User is not authenticated.");
      }

      // Define the API URL
      String apiUrl =
          '$baseUrl/api/user/addVideoLink';

      // Create the body for the POST request
      Map<String, dynamic> body = {
        "_id": id,
        "videoLink": videoLink,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      // Check for a successful response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // showToast("Video link added successfully", Colors.green);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
            "Failed to save video link. Status code: ${response.statusCode}");
      }
    } catch (e) {
      showToast(e.toString(), colorSubTittle);
    }
  }


  Future<void> _deleteUrl(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls =
        prefs.getStringList('lastPlayedUrlsWithTime') ?? [];

    if (index >= 0 && index < savedUrls.length) {
      savedUrls.removeAt(index);
      await prefs.setStringList('lastPlayedUrlsWithTime', savedUrls);

      // Manually remove the URL from _lastPlayedUrls to update the UI immediately
      setState(() {
        _lastPlayedUrls.removeAt(index);
      });
    } else {
      showToast("Unable to delete URL", colorSubTittle);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.6,
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.02),
            _lastPlayedUrls.isNotEmpty
                ? Padding(
              padding:
              EdgeInsets.only(left: width * 0.04, top: height * 0.04),
              child: WantText("Recently Played URLs", width * 0.05,
                  FontWeight.bold, colorBlack),
            )
                : SizedBox(),
            SizedBox(height: height * 0.01),
            Visibility(
                visible: _isLoading,
                child: Center(
                  child: LoadingAnimationWidget.progressiveDots(
                    color: colorBlack,
                    size: width * 0.12,
                  ),)),
            Expanded(
              child: _lastPlayedUrls.isNotEmpty
                  ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _lastPlayedUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final history = _lastPlayedUrls[index];
                            _selectUrl(_lastPlayedUrls[index]['url']!);
                            _fetchVideo();
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: width * 0.05,
                                backgroundImage:
                                AssetImage("assets/images/logo.png"),
                              ),
                              SizedBox(
                                width: width * 0.03,
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width * 0.68,
                                    child: WantText(
                                        _lastPlayedUrls[index]['name'] ??
                                            _lastPlayedUrls[index]
                                            ['url']!,
                                        width * 0.04,
                                        FontWeight.w500,
                                        colorSubTittle),
                                  ),
                                  WantText(
                                      'Played on: ${_lastPlayedUrls[index]['timestamp']}',
                                      width * 0.036,
                                      FontWeight.w500,
                                      colorGrey),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTapDown: (TapDownDetails details) {
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                                details.globalPosition.dx + 1,
                                details.globalPosition.dy + 1,
                              ),
                              items: [
                                PopupMenuItem(
                                  child: Text('Change Name'),
                                  value: 'change_name',
                                ),
                                PopupMenuItem(
                                  child: Text('Delete'),
                                  value: 'delete',
                                ),
                              ],
                            ).then((value) {
                              if (value == 'change_name') {
                                // Handle Enter Name action
                                _showEnterNameDialog(index);
                              } else if (value == 'delete') {
                                // Handle Delete action
                                _deleteUrl(index);
                              }
                            });
                          },
                          child: Icon(
                            Icons.more_vert,
                            color: colorBlack,
                            size: width * 0.06,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : Center(
                child: Text("No recently played videos."),
              ),
            )
          ],
        ),
      ),
    );
  }
}
