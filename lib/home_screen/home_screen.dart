import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dancebuddy/auth/login_screen/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:dancebuddy/term_and_condition_screen/term_and_condition_screen.dart';
import 'package:dancebuddy/utils/theam_manager.dart';
import 'package:dancebuddy/utils/toast_massage.dart';
import 'package:dancebuddy/utils/want_text.dart';
import 'package:dancebuddy/utils/widget/general_button/general_button.dart';
import 'package:flutter/material.dart';
import 'package:dancebuddy/utils/widget/custom_text_formfield/custom_text_form_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../utils/app_const.dart';
import '../video_screen/video_screen.dart';
import '../video_screen/youtube_video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  String? _platform;
  bool _isLoading = false;
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add Scaffold key for drawer
  final List<Map<String, String>> _lastPlayedUrls =
      []; // List to store last played URLs and timestamps
  int _searchCount = 0;

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _fetchButtonKey = GlobalKey();
  List<TargetFocus> targets = [];
  TutorialCoachMark? tutorialCoachMark;
  bool hasShownFetchTutorial = false;
  TutorialCoachMark? fetchButtonCoachMark;


  // final List<Map<String, String>> items = [
  //   {
  //     'videoUrl': 'https://youtube.com/shorts/zUbW0GsRT1k?si=fJyjymZezgAiXEnh',
  //     'imageUrl':
  //         'https://i.ytimg.com/vi/zUbW0GsRT1k/oar2.jpg?sqp=-oaymwEoCJUDENAFSFqQAgHyq4qpAxcIARUAAIhC2AEB4gEKCBgQAhgGOAFAAQ==&rs=AOn4CLDbdnhG1dqw034SaXZFDFzx8cK-mw',
  //   },
  //   {
  //     'videoUrl': 'https://youtube.com/shorts/JAeVcLPP8kI?si=-fE_fW7C1jX3W-0H',
  //     'imageUrl':
  //         'https://i.ytimg.com/vi/JAeVcLPP8kI/hq720.jpg?sqp=-oaymwEoCJUDENAFSFryq4qpAxoIARUAAIhC0AEB2AEB4gEKCBgQAhgGOAFAAQ==&rs=AOn4CLDKATIRRO_7upMGsovXxZ5gyeabbg',
  //   },
  //   // {
  //   //   'videoUrl': 'https://youtube.com/shorts/WCciYRmBJNk?si=JINZyzv4Z_f-1lTt',
  //   //   'imageUrl':
  //   //       'https://i.ytimg.com/vi/WCciYRmBJNk/oar2.jpg?sqp=-oaymwEoCJQDENAFSFqQAgHyq4qpAxcIARUAAIhC2AEB4gEKCBgQAhgGOAFAAQ==&rs=AOn4CLDp_Yl9J3DDyDpj7Ue-uKZas6GWPg',
  //   // },
  //   {
  //     'videoUrl': 'https://youtube.com/shorts/7GBm5rbr50U?si=Cjc5g_Cj3L6Nd00-',
  //     'imageUrl':
  //         'https://i.ytimg.com/vi/7GBm5rbr50U/oar2.jpg?sqp=-oaymwEoCJUDENAFSFqQAgHyq4qpAxcIARUAAIhC2AEB4gEKCBgQAhgGOAFAAQ==&rs=AOn4CLADYAiCmIyew9EC703G6l0bWGy5UQ',
  //   },
  //   {
  //     'videoUrl': 'https://youtube.com/shorts/aYgA6cIzqm8?si=3UOkPnBSGW9h5RAx',
  //     'imageUrl': 'https://i.ytimg.com/vi/aYgA6cIzqm8/oar2.jpg',
  //   },
  //   {
  //     'videoUrl': 'https://youtube.com/shorts/BF5i1bHlkyw?si=vKj_lmgu0EjLRJCI',
  //     'imageUrl':
  //         'https://i.ytimg.com/vi/BF5i1bHlkyw/oar2.jpg?sqp=-oaymwEoCJUDENAFSFqQAgHyq4qpAxcIARUAAIhC2AEB4gEKCBgQAhgGOAFAAQ==&rs=AOn4CLCSRS_9m1B4-cOsCoV9USdsb7-XAA',
  //   },
  // ];

  List<Map<String, String>> items = [];
  static const String videoUrlKeyPrefix = 'video_url_';

  @override
  void initState() {
    super.initState();
    fetchItems();
    _loadLastPlayedUrls();
    _loadSearchCount();

    // This is ShowCase widget
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      bool shown = prefs.getBool('home_showcase_shown') ?? false;

      if (!shown) {
        _createTutorialTargets();
        TutorialCoachMark(
          targets: targets,
          colorShadow: Colors.black.withOpacity(0.85),
          textSkip: "",
          hideSkip: true,
        ).show(context: context);
        prefs.setBool('home_showcase_shown', true);
      }
    });
  }

  void _createTutorialTargets() {
    targets.clear();
    targets.addAll([
      TargetFocus(
        identify: "SearchField",
        keyTarget: _searchKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const SizedBox.shrink(), // Invisible widget
          ),
        ],
      ),
    ]);
  }

  void _addFetchButtonTutorial() {
    targets.add(
      TargetFocus(
        identify: "FetchButton",
        keyTarget: _fetchButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _onUrlChanged(String value) async {
    setState(() {
      _isLoading = false;
    });

    if (value.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      bool shown = prefs.getBool('fetch_button_showcase_shown') ?? false;

      if (!shown) {
        _addFetchButtonTutorial();

        fetchButtonCoachMark = TutorialCoachMark(
          targets: [targets.last],
          colorShadow: Colors.black.withOpacity(0.95),
          textSkip: "",
          hideSkip: true,
          onClickTarget: (target) async {
            if (target.identify == "FetchButton") {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('fetch_button_showcase_shown', true);
              fetchButtonCoachMark?.finish();

              // Delay to ensure dismissal happens first
              Future.delayed(const Duration(milliseconds: 100), () {
                _fetchVideo();
              });
            }
          },
        );


        fetchButtonCoachMark?.show(context: context);

        prefs.setBool('fetch_button_showcase_shown', true); // Prevent re-show
      }

    }
  }

  Future<void> fetchItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/user/getAllVideos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final data = jsonData['data'] as List;

      // Update local storage with new data
      await _updateLocalStorage(data);

      // Clear the list before adding new data
      setState(() {
        items = data.map((item) {
          String rawUrl = item['thumbnailUrl'] as String;
          String cleanedUrl = rawUrl.split('?').first;

          return {
            'videoUrl': item['videoUrl'] as String,
            'imageUrl': cleanedUrl,
          };
        }).toList();
      });

      print("items : $items");
    } else {
      throw Exception('Failed to load media');
    }
  }

  Future<void> _updateLocalStorage(List data) async {
    final directory = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();

    for (var item in data) {
      final imageUrl = item['thumbnailUrl'] as String;
      final videoUrl = item['videoUrl'] as String;
      final fileName = imageUrl.split('/').last.split('?').first;
      final file = File('${directory.path}/$fileName');

      if (!file.existsSync()) {
        final response = await http.get(Uri.parse(imageUrl));
        file.writeAsBytesSync(response.bodyBytes);
      }

      // Save the local path of the image to SharedPreferences
      prefs.setString('$videoUrlKeyPrefix$videoUrl', file.path);
    }

    // Remove old entries from SharedPreferences
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(videoUrlKeyPrefix))
        .toList();
    for (var key in keys) {
      if (!data.any((item) => '$videoUrlKeyPrefix${item['videoUrl']}' == key)) {
        prefs.remove(key);
      }
    }
  }

  Future<String> _getLocalImagePath(String videoUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('$videoUrlKeyPrefix$videoUrl') ?? '';
  }

  // Load URLs from SharedPreferences or fetch from API if none exist
  Future<void> _loadLastPlayedUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls =
        prefs.getStringList('lastPlayedUrlsWithTime') ?? [];

    if (savedUrls.isNotEmpty) {
      // If SharedPreferences has data, load it
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
      });
    } else {
      // If no data in SharedPreferences, fetch from API
      // await _fetchVideoLinksFromAPI();
    }
  }

  Future<void> _loadSearchCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchCount = prefs.getInt('searchCount') ?? 0;
    });
  }

  Future<void> _incrementSearchCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _searchCount = prefs.getInt('searchCount') ?? 0;
    _searchCount += 1;
    await prefs.setInt('searchCount', _searchCount);
    // if (_searchCount % 5 == 0) {
    //   showToast("Please complete your profile", colorSubTittle);
    // }
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

    if (_platform == 'YouTube') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubeVideoPlayerScreen(youtubeUrl: url),
        ),
      );
      return;
    }

    if (_platform == null) {
      print("Unsupported platform");
      // showToast("Unsupported platform", colorSubTittle);
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
            builder: (context) => ShowCaseWidget(
              builder: (context) => VideoPlayerScreen(
                videoUrl: videoUrl,
                urlController: _urlController,
                showVideoShowcase: true,
              ),
            ),
          ),
        );
      } else {
        throw ("Failed to fetch video URL");
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
    final String apiUrl =
        'https://dancebuddy.io/api/extract_video_details?url=$url';

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
      String apiUrl = '$baseUrl/api/user/addVideoLink';

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
          throw (data['message']);
        }
      } else {
        throw ("Failed to save video link. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("save video : ${e.toString()}");
      // showToast(e.toString(), colorSubTittle);
    }
  }

  void _toggleDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // Logout Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Logout"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();

                // Clear all relevant data from SharedPreferences
                await prefs.clear();

                // Navigate to the LoginScreen or OnboardingScreen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreeen(),
                  ),
                  (route) => false,
                );
                // Perform logout action
              },
            ),
          ],
        );
      },
    );
  }

  // Logout Confirmation Dialog
  // void _showDeleteAccountDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Delete Account"),
  //         content: Text("Are you sure you want to Delete Account?"),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text("Cancel"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text("Delete Account"),
  //             onPressed: () async {
  //               final prefs = await SharedPreferences.getInstance();
  //
  //               // Retrieve the user's _id from SharedPreferences
  //               String? id = prefs.getString('id');
  //               String? token = prefs.getString('token');
  //
  //               if (id != null) {
  //                 // Define the API URL
  //                 final url = Uri.parse(
  //                     '$baseUrl/api/user/deleteUser');
  //
  //                 // Define the request body
  //                 final body = jsonEncode({
  //                   "_id": id,
  //                 });
  //
  //                 // Perform the DELETE request
  //                 final response = await http.post(
  //                   url,
  //                   headers: {
  //                     'Authorization': 'Bearer $token',
  //                     'Content-Type': 'application/json',
  //                   },
  //                   body: body,
  //                 );
  //
  //                 print("delete account status code: ${response.statusCode}");
  //
  //                 if (response.statusCode == 200 ||
  //                     response.statusCode == 201) {
  //                   // Clear all relevant data from SharedPreferences
  //                   await prefs.clear();
  //
  //                   // Navigate to the login screen
  //                   Navigator.pushAndRemoveUntil(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => LoginScreeen(),
  //                     ),
  //                         (route) => false,
  //                   );
  //                   showToast("Account Deleted Successfully", colorBlack);
  //                 } else {
  //                   // Handle the error case if the account deletion fails
  //                   showToast('Failed to delete account. Please try again.',
  //                       colorSubTittle);
  //                 }
  //               } else {
  //                 // If the id is not found, display an error
  //                 showToast('User ID not found.', colorSubTittle);
  //               }
  //               // Perform logout action
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _selectUrl(String url) {
    setState(() {
      _urlController.text = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey, // Assign the scaffold key
      drawer: Drawer(
        width: width * 0.6,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              opacity: 0.6,
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: colorBlack,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircleAvatar(
                        radius: width * 0.12,
                        child: CircleAvatar(
                          radius: width * 0.1,
                          child: Image.asset("assets/images/logo.png"),
                        ),
                      ),
                      // Image.asset('assets/images/hookstep.png',width: width*0.3,color: colorWhite,)
                      WantText(
                        "⁃•⦿ POP, LOCK, SLAY. ⦿•⁃",
                        width * 0.035,
                        FontWeight.w500,
                        colorWhite,
                      ),
                      // WantText(
                      //     "HookStep", width * 0.05, FontWeight.bold, colorWhite)
                    ],
                  )),
              ListTile(
                leading: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen(),
                          ));
                    },
                    child: Icon(
                      Icons.description,
                      color: colorBlack,
                    )),
                title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen(),
                          ));
                    },
                    child: WantText("Privacy Policy", width * 0.045,
                        FontWeight.w500, colorBlack)),
                onTap: () {
                  // Close drawer and do something when settings is tapped
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: colorBlack,
                ),
                title: WantText(
                    "Logout", width * 0.045, FontWeight.w500, colorBlack),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
              // ListTile(
              //   leading: Icon(
              //     Icons.delete,
              //     color: colorBlack,
              //   ),
              //   title: WantText("Delete Account", width * 0.045,
              //       FontWeight.w500, colorBlack),
              //   onTap: () {
              //     _showDeleteAccountDialog(context);
              //   },
              // ),
            ],
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.06),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: _toggleDrawer,
                            child: Icon(Icons.menu, size: height * 0.04)),
                        // SizedBox(width: width * 0.04),
                        Image.asset(
                          'assets/images/hookstep.png',
                          width: width * 0.42,
                          height: width * 0.1,
                        )
                        // GradientText(
                        //   "HookStep",
                        //   width * 0.08,
                        //   FontWeight.bold,
                        // ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: width * 0.04),
                WantText(
                    "Search URL", width * 0.035, FontWeight.w500, colorBlack),
                SizedBox(height: height * 0.01),
                Showcase(
                  key: _searchKey,
                  description: "",
                  child: CustomTextFormField(
                    onChanged: _onUrlChanged,
                    controller: _urlController,
                    hint: "Go to reel/video, copy link & paste here...",
                    input: TextInputType.url,
                    icon: Icons.search,
                    condition: (value) => value.isEmpty,
                    errorText: "Please Enter URL",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.close, color: colorGrey),
                      onPressed: () => _urlController.clear(),
                    ),
                  ),
                ),

                SizedBox(height: width * 0.06),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: !_isLoading && _urlController.text.isNotEmpty,
                      child: Showcase(
                        key: _fetchButtonKey,
                        description: '',
                        child: GeneralButton(
                          Width: width * 0.35,
                          onTap: _fetchVideo,
                          label: "Fetch Video",
                        ),
                      ),
                    )
                  ],
                ),

                Visibility(
                    visible: _isLoading,
                    child: Center(
                      child: LoadingAnimationWidget.progressiveDots(
                        color: colorBlack,
                        size: width * 0.12,
                      ),

                      //     CircularProgressIndicator(
                      //   color: colorSubTittle,
                      // ),
                    )),
                SizedBox(height: height * 0.02),
                // _lastPlayedUrls.isNotEmpty
                //     ?
                Row(
                  children: [
                    WantText(
                        "OR   ", width * 0.04, FontWeight.bold, colorBlack),
                    WantText("Learn Trending (by clicking on a thumbnail)",
                        width * 0.038, FontWeight.w500, colorBlack),
                  ],
                ),
                //     : SizedBox(),
                SizedBox(height: height * 0.01),

                SizedBox(
                  height: height * 0.33,
                  child: items.isEmpty
                      ? Center(
                          child: LoadingAnimationWidget.progressiveDots(
                            color: Colors.black,
                            size: width * 0.12,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            String videoUrl = items[index]['videoUrl']!;
                            String imageUrl = items[index]['imageUrl']!;
                            return FutureBuilder<String>(
                              future: _getLocalImagePath(videoUrl),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Error loading image'));
                                } else {
                                  String localImagePath = snapshot.data!;
                                  return GestureDetector(
                                    onTap: () {
                                      _selectUrl(videoUrl);
                                      _fetchVideo();
                                    },
                                    child: Container(
                                      width: height * 0.18,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                              // child: Image.network(
                                              //   imageUrl,
                                              //   fit: BoxFit.cover,
                                              // ),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsets.all(width * 0.02),
                                            child: Text(
                                              videoUrl,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: GoogleFonts.dmSans(
                                                fontSize: width * 0.03,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),

                Padding(
                  padding: EdgeInsets.all(width * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WantText("🎬 Welcome to HookStep! 🎬", width * 0.04,
                          FontWeight.w700, colorBlack),
                      SizedBox(height: height * 0.01),
                      Text(
                        overflow: TextOverflow.fade,
                        "Got a video link? Drop it in and let the magic begin! ✨\n🔹 Paste a URL (Drop the URL from your social media account here)\n🔹 Edit like a pro – Split, mute, mirror, reverse, speed up, or slow it down!\n🔹 Explore trending videos – Tap on examples to see HookStep in action!\nSimple. Fast. Fun. 🎥🚀 Let’s get Hooked! 😎",
                        style: GoogleFonts.dmSans(
                          color: colorGrey,
                          fontSize: width * 0.032,
                          fontWeight: FontWeight.w500,
                        ), // Set default text color as white
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
