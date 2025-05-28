import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_const.dart';

class HomeController extends GetxController {
  final urlController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final searchKey = GlobalKey();
  final fetchButtonKey = GlobalKey();

  var isLoading = true.obs;
  var isUrlLoading = false.obs;
  var platform = RxnString();
  var searchCount = 0.obs;
  var items = <Map<String, String>>[].obs;
  var lastPlayedUrls = <Map<String, String>>[].obs;

  TutorialCoachMark? tutorialCoachMark;
  TutorialCoachMark? fetchButtonCoachMark;
  List<TargetFocus> targets = [];
  bool hasShownFetchTutorial = false;

  static const String videoUrlKeyPrefix = 'video_url_';

  @override
  void onInit() {
    super.onInit();
    fetchItems();
    loadLastPlayedUrls();
    loadSearchCount();
    initTutorial();
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/user/getAllVideos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = jsonData['data'] as List;

        // Update local storage
        await _updateLocalStorage(data);

        // Update the observable list
        items.value = data.map((item) {
          String rawUrl = item['thumbnailUrl'] as String;
          String cleanedUrl = rawUrl.split('?').first;

          return {
            'videoUrl': item['videoUrl'] as String,
            'imageUrl': cleanedUrl,
          };
        }).toList();

        print("items : $items");
      } else {
        throw Exception('Failed to load media');
      }
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateLocalStorage(List data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_videos', jsonEncode(data));
  }


  Future<void> loadLastPlayedUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Only keys that belong to cached video URLs
    final videoKeys = keys.where((key) => key.startsWith(videoUrlKeyPrefix)).toList();

    final List<Map<String, String>> loadedList = [];

    for (final key in videoKeys) {
      final videoUrl = key.replaceFirst(videoUrlKeyPrefix, '');
      final imagePath = prefs.getString(key);

      if (imagePath != null) {
        final file = File(imagePath);

        if (await file.exists()) {
          loadedList.add({
            'videoUrl': videoUrl,
            'imageUrl': imagePath,
          });
        } else {
          // Clean up the reference if the file is missing
          await prefs.remove(key);
        }
      }
    }

    lastPlayedUrls.assignAll(loadedList);
  }


  Future<void> loadSearchCount() async {
    final prefs = await SharedPreferences.getInstance();
    searchCount.value = prefs.getInt('search_count') ?? 0;
  }

  Future<void> initTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    bool shown = prefs.getBool('home_showcase_shown') ?? false;

    if (!shown) {
      createTutorialTargets();
      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        colorShadow: Colors.black.withOpacity(0.85),
        textSkip: "",
        hideSkip: true,
      )..show(context: Get.context!);
      prefs.setBool('home_showcase_shown', true);
    }
  }

  void createTutorialTargets() {
    targets.clear();
    targets.add(TargetFocus(
      identify: "SearchField",
      keyTarget: searchKey,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const SizedBox.shrink(),
        ),
      ],
    ));
  }

  void addFetchButtonTutorial() {
    targets.add(TargetFocus(
      identify: "FetchButton",
      keyTarget: fetchButtonKey,
      shape: ShapeLightFocus.RRect,
      radius: 12,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const SizedBox.shrink(),
        ),
      ],
    ));
  }

  Future<void> onUrlChanged(String value) async {
    isUrlLoading.value = false;

    if (value.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      bool shown = prefs.getBool('fetch_button_showcase_shown') ?? false;

      if (!shown) {
        addFetchButtonTutorial();

        fetchButtonCoachMark = TutorialCoachMark(
          targets: [targets.last],
          colorShadow: Colors.black.withOpacity(0.95),
          textSkip: "",
          hideSkip: true,
          onClickTarget: (target) async {
            if (target.identify == "FetchButton") {
              await prefs.setBool('fetch_button_showcase_shown', true);
            }
          },
        )..show(context: Get.context!);
      }
    }
  }
}
