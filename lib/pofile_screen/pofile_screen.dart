import 'dart:convert';
import 'dart:io';
import 'package:dancebuddy/masterpage/masterpage.dart';
import 'package:dancebuddy/utils/theam_manager.dart';
import 'package:dancebuddy/utils/want_text.dart';
import 'package:dancebuddy/utils/widget/custom_text_formfield/custom_text_form_field.dart';
import 'package:dancebuddy/utils/widget/general_button/general_button.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_const.dart';
import '../utils/gradient_text.dart';
import 'package:dancebuddy/utils/toast_massage.dart'; // Ensure you have this import for showToast

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();
  String countryCode = '+1';

  // Selected Values
  DateTime? selectedDateOfBirth;
  String? selectedGender;
  String? selectedRelationshipStatus;

  String? selectedDanceStyle;
  String? selectedSkillLevel;
  List<dynamic> countries = [];
  List<dynamic> states = [];
  List<dynamic> cities = [];
  String? countryValue;
  String? stateValue;
  String? cityValue;

  String? selectedOccupation;

  // State Variables
  bool isLoading = true;
  bool isEmailLoad = false;
  double profileCompletionPercentage = 0;
  File? _profileImage;
  String? _profileImageUrl;
  bool isMobileEditable = true; // Determines if mobile fields are editable
  bool isProfileCompleted = false;
  bool isOTPSent = false;
  bool isVerifyOTP = false; // Toggle between Send OTP and Verify button
  String? otpFromServer;
  // List<Map<String, String>> occupations = [];
  bool isPhoneNumberValid = false;
  PhoneNumber? number = PhoneNumber(isoCode: "+1");

  // Dropdown Options
  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> relationshipStatusOptions = [
    'Single',
    'In a Relationship',
    'Married',
    'Other'
  ];

  final List<String> danceStyles = [
    'Hip-Hop',
    'Salsa',
    'Contemporary',
    'Jazz',
    'Ballet',
    'Tango',
    'Other'
  ];
  final List<String> skillLevels = ['Beginner', 'Intermediate', 'Advanced'];

  final List<String> occupations = [
    'Student',
    'Businessman',
    'Artist',
    'Doctor',
    'Engineer',
    'Teacher',
    'Lawyer',
    'Developer',
    'Designer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _fetchUserData();
    await fetchCountries();
    // await fetchOccupations();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }



  // Fetch User Data from API
  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    String? token = prefs.getString('token');

    if (id == null || token == null) {
      // User is not authenticated; handle accordingly
      showToast("User is not authenticated.", colorSubTittle);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/user/getDetailsByID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'_id': id}),
      );

      print("id :::: $id");
      print("Load init user data  :::: ${response.statusCode}");
      print("Load init user data  :::: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> userData = jsonDecode(response.body)['data'];
        _populateUserDetails(userData);
      } else {
        print('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        showToast('Error fetching user data: $e', colorSubTittle);
      }
    }
  }

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse(
        '$baseUrl/api/user/getAllCountries'));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          countries = jsonDecode(response.body)['allCountries'];
        });
      }
    } else {
      throw Exception('Failed to load countries');
    }
  }

  // Function to fetch and set states based on countryId
  Future<void> fetchStates(String countryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('state'); // Clear state from preferences
    await prefs.remove('city'); // Clear city from preferences

    setState(() {
      states = [];
      cities = [];
      stateValue = null;
      cityValue = null;
    });

    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/api/user/getStatesByCountry/$countryId'));
      if (response.statusCode == 200) {
        setState(() {
          states = jsonDecode(response.body)['states'];
        });
      } else {
        throw ('Failed to load states');
      }
    } catch (e) {
      print('Error loading states: $e');
    }
  }

  // Function to fetch and set cities based on selected stateId
  Future<void> fetchCities(String stateId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('city'); // Clear city from preferences

    setState(() {
      cities = [];
      cityValue = null;
    });

    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/api/user/getCitiesByState/$stateId'));
      if (response.statusCode == 200) {
        setState(() {
          cities = jsonDecode(response.body)['cities'];
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      showToast('Error loading cities: $e', Colors.red);
      print('Error loading cities: $e');
    }
  }

  void _populateUserDetails(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profileImagePath');
    String apiPhoneNumber =
        "${userData['mobileCode'] ?? prefs.getString('mobileCode') ??
        '+1'}${userData['mobile'] ?? prefs.getString('mobile') ?? ''}";
    PhoneNumber phoneNumber =
    await PhoneNumber.getRegionInfoFromPhoneNumber(apiPhoneNumber);

    setState(() {
      fullNameController.text =
          userData['name'] ?? prefs.getString('name') ?? '';
      emailController.text =
          userData['email'] ?? prefs.getString('email') ?? '';
      number = phoneNumber;
      mobileController.text = phoneNumber.phoneNumber ?? "";
      DateFormat format = DateFormat("MM-dd-yyyy");
      selectedDateOfBirth = userData['dateOfBirth'] != null
          ? DateFormat("yyyy-MM-dd").parse(userData['dateOfBirth'])
          : null;
      selectedGender = userData['gender'] ?? prefs.getString('gender');
      selectedOccupation =
          userData['occupation'] ?? prefs.getString('occupation');
      selectedRelationshipStatus = userData['relationshipStatus'] ??
          prefs.getString('relationshipStatus');
      countryValue =
          userData['country']?.toString() ?? prefs.getString('country');
      selectedDanceStyle = userData['favoriteDanceStyle'] ??
          prefs.getString('favoriteDanceStyle');
      selectedSkillLevel =
          userData['skillLevel'] ?? prefs.getString('skillLevel');
      if (savedImagePath != null && File(savedImagePath).existsSync()) {
        _profileImage = File(savedImagePath);
        _profileImageUrl = null;
      } else if (userData['profileImage'] != null &&
          userData['profileImage'].isNotEmpty) {
        _profileImageUrl = userData['profileImage'];
        _profileImage = null;
      } else if (prefs.getString('profileImage') != null &&
          prefs.getString('profileImage')!.isNotEmpty) {
        _profileImageUrl = prefs.getString('profileImage');
        _profileImage = null;
      } else {
        _profileImageUrl = null;
        _profileImage = null;
      }
    });

    if (countryValue != null) {
      await fetchStates(countryValue!);
      setState(() {
        stateValue = states.firstWhere(
              (state) => state['id'].toString() == userData['state']?.toString(),
          // orElse: () => null,
        )?['id']?.toString() ?? prefs.getString('state');
      });
    }

    if (stateValue != null) {
      await fetchCities(stateValue!);
      setState(() {
        cityValue = cities.firstWhere(
              (city) => city['id'].toString() == userData['city']?.toString(),
          // orElse: () => null,
        )?['id']?.toString() ?? prefs.getString('city');
      });
    }

    print("Country ::::::  ${countryValue}");
    print("State ::::::  ${stateValue}");
    print("City ::::::  ${cityValue}");
    _calculateProfileCompletion(userData);
  }
  // Calculate Profile Completion Percentage
  void _calculateProfileCompletion(Map<String, dynamic> userData) {
    int totalFields =
    13; // You can adjust this number based on the actual fields required
    int filledFields = 0;

    // Check all fields and count filled ones
    if ((userData['name'] ?? '').isNotEmpty) filledFields++;
    if ((userData['email'] ?? '').isNotEmpty) filledFields++;
    if ((userData['mobileCode'] ?? '').isNotEmpty) filledFields++;
    if ((userData['mobile'] ?? '').isNotEmpty) filledFields++;
    if ((userData['occupation'] ?? '').isNotEmpty) filledFields++;
    if ((userData['city'] ?? '').isNotEmpty) filledFields++;
    if ((userData['state'] ?? '').isNotEmpty) filledFields++;
    if ((userData['country'] ?? '').isNotEmpty) filledFields++;
    if ((userData['gender'] ?? '').isNotEmpty) filledFields++;
    if ((userData['favoriteDanceStyle'] ?? '').isNotEmpty) filledFields++;
    if ((userData['skillLevel'] ?? '').isNotEmpty) filledFields++;
    if ((userData['relationshipStatus'] ?? '').isNotEmpty) filledFields++;
    if (userData['dateOfBirth'] != null &&
        userData['dateOfBirth']
            .toString()
            .isNotEmpty) filledFields++;

    double completionPercentage = (filledFields / totalFields) * 100;
    setState(() {
      profileCompletionPercentage = completionPercentage;
    });

    _saveProfileCompletion(completionPercentage); // Save the updated percentage
  }

  Future<void> _saveProfileCompletion(double percentage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('profileCompletionPercentage', percentage);
  }

  // Save User Data to SharedPreferences and Update Server
  Future<void> _saveUserDataToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProfileCompleted', true);

    if (_profileImage != null) {
      await prefs.setString('profileImagePath', _profileImage!.path);
    }

    print('Profile Saved Successfully!');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MasterPage()),
    );

    await _updateProfileOnServer();
  }

  // Save User Data to SharedPreferences and Update Server
  Future<void> _saveUserDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userData = {
      'name': fullNameController.text,
      'email': emailController.text,
      'mobileCode': countryCode,
      'mobile': mobileController.text,
      'dateOfBirth': selectedDateOfBirth?.toIso8601String() ?? '',
      'gender': selectedGender,
      'occupation': selectedOccupation,
      'relationshipStatus': selectedRelationshipStatus,
      'city': cityValue,
      'state': stateValue,
      'country': countryValue,
      'favoriteDanceStyle': selectedDanceStyle,
      'skillLevel': selectedSkillLevel,
      'profileImage': _profileImageUrl ?? '',
    };
    prefs.setString('userData', jsonEncode(userData));

    _calculateProfileCompletion(userData);
    await _updateProfileOnServer();
  }

  // Function to update profile data on the server
  Future<void> _updateProfileOnServer() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('id');

      if (id == null || token == null) {
        throw Exception("User is not authenticated.");
      }
      String? profileImageUrl = _profileImageUrl;

      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(_profileImage!);
      }

      String apiUrl = '$baseUrl/api/user/updateUserdeatils';

      Map<String, dynamic> body = {
        "_id": id,
      };
      // add changes field to body
      // Conditionally add only non-null, non-empty values
      if (fullNameController.text.isNotEmpty) body["name"] = fullNameController.text;
      if (emailController.text.isNotEmpty) body["email"] = emailController.text;
      if (selectedDateOfBirth != null) {
        body["dateOfBirth"] = DateFormat('yyyy-MM-dd').format(selectedDateOfBirth!);
      }
      if (selectedGender != null && selectedGender!.isNotEmpty) body["gender"] = selectedGender;
      if (selectedOccupation != null && selectedOccupation!.isNotEmpty) body["occupation"] = selectedOccupation;
      if (selectedRelationshipStatus != null && selectedRelationshipStatus!.isNotEmpty)
        body["relationshipStatus"] = selectedRelationshipStatus;
      if (cityValue != null && cityValue!.isNotEmpty) body["city"] = cityValue;
      if (stateValue != null && stateValue!.isNotEmpty) body["state"] = stateValue;
      if (countryValue != null && countryValue!.isNotEmpty) body["country"] = countryValue;
      if (selectedDanceStyle != null && selectedDanceStyle!.isNotEmpty) body["favoriteDanceStyle"] = selectedDanceStyle;
      if (selectedSkillLevel != null && selectedSkillLevel!.isNotEmpty) body["skillLevel"] = selectedSkillLevel;
      if (mobileController.text.isNotEmpty) body["mobile"] = mobileController.text;
      if (countryCode != null && countryCode!.isNotEmpty) body["mobileCode"] = countryCode;
      if (profileImageUrl != null && profileImageUrl.isNotEmpty) body["profileImage"] = profileImageUrl;


      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          print("Profile updated successfully");
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
            "Failed to update profile. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  // Optional: Function to upload profile image to server and get URL
  Future<String> _uploadProfileImage(File imageFile) async {
    return 'https://example.com/profile.jpg';
  }

  // Select Date of Birth
  void _selectDateOfBirth(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDateOfBirth) {
      setState(() {
        selectedDateOfBirth = pickedDate;
        _calculateProfileCompletion({
          'name': fullNameController.text,
          'email': emailController.text,
          'mobileCode': countryCode,
          'mobile': mobileController.text,
          'dateOfBirth': selectedDateOfBirth?.toIso8601String() ?? '',
          'gender': selectedGender,
          'occupation': selectedOccupation,
          'relationshipStatus': selectedRelationshipStatus,
          'city': cityValue,
          'state': stateValue,
          'country': countryValue,
          'favoriteDanceStyle': selectedDanceStyle,
          'skillLevel': selectedSkillLevel,
        });
      });
    }
  }

  // Pick Profile Image from Gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        _profileImageUrl = null;
      });
    }
  }

  // Get Color Based on Completion Percentage
  Color _getCompletionColor() {
    if (profileCompletionPercentage >= 76) return Colors.green;
    if (profileCompletionPercentage >= 51) return Colors.yellow[700]!;
    if (profileCompletionPercentage >= 26) return Colors.orange;
    return Colors.red;
  }

  // Build Profile Completion Indicator
  Widget _buildProfileCompletionIndicator() {
    return Stack(alignment: Alignment.center, children: [
      SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.2,
        height: MediaQuery
            .of(context)
            .size
            .width * 0.2,
        child: CircularProgressIndicator(
          value: profileCompletionPercentage / 100,
          strokeWidth: 5.0,
          valueColor: AlwaysStoppedAnimation<Color>(_getCompletionColor()),
          backgroundColor: colorLightGrey,
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${profileCompletionPercentage.toStringAsFixed(0)}%",
            style: TextStyle(
                fontSize: MediaQuery
                    .of(context)
                    .size
                    .width * 0.045,
                fontWeight: FontWeight.bold,
                color: _getCompletionColor()),
          ),
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .width * 0.01),
          WantText("Done", MediaQuery
              .of(context)
              .size
              .width * 0.04,
              FontWeight.w500, colorBlack)
        ],
      ),
    ]);
  }

  // Build Profile Picture Section
  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : (_profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                : AssetImage('assets/images/person.png')) as ImageProvider,
            backgroundColor: Colors.grey[200],
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                decoration: BoxDecoration(
                  color: _getCompletionColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.06,
      width: MediaQuery
          .of(context)
          .size
          .width,
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(MediaQuery
            .of(context)
            .size
            .width * 0.02),
        border: Border.all(color: colorGrey),
        image: DecorationImage(
          opacity: 0.6,
          image: AssetImage("assets/images/textFormFieldBG.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Hint text
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery
                        .of(context)
                        .size
                        .width *
                        0.04), // Adjust left padding for hint text
                child: Text(
                  value == null ? hintText : '',
                  // Show hint only if no value is selected
                  style: GoogleFonts.dmSans(
                    color: colorGrey,
                    fontSize: MediaQuery
                        .of(context)
                        .size
                        .width * 0.04,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Dropdown button
          DropdownButton2<String>(
            iconStyleData: IconStyleData(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: colorBlack,
                    size: MediaQuery
                        .of(context)
                        .size
                        .width * 0.065,
                  ),
                )),
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            items: items
                .map((String item) =>
                DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                        MediaQuery
                            .of(context)
                            .size
                            .width * 0.04),
                    child: Text(
                      item,
                      style: GoogleFonts.dmSans(
                        color: colorBlack,
                        fontSize: MediaQuery
                            .of(context)
                            .size
                            .width * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
                .toList(),
            onChanged: (selectedValue) {
              onChanged(selectedValue);
            },
            dropdownStyleData: DropdownStyleData(
              maxHeight: MediaQuery
                  .of(context)
                  .size
                  .width * 0.5,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colordropdown,
              ),
              offset: const Offset(0, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.06),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: width * 0.02,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: width * 0.04,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientText(
                              "Manage Profile",
                              width * 0.065,
                              FontWeight.bold,
                            ),
                            SizedBox(height: width * 0.005),
                            WantText(
                                "Complete Profile To Fetch\nUnlimited Videos",
                                width * 0.035,
                                FontWeight.w500,
                                colorBlack)
                          ],
                        ),
                      ],
                    ),
                    _buildProfileCompletionIndicator(),
                  ],
                ),
              ),
              isLoading
                  ? Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: colorBlack,
                  size: width * 0.12,
                ),
              )
                  : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      _buildProfilePictureSection(),
                      SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(width * 0.02)),
                          border: Border.all(color: colorGrey),
                          image: DecorationImage(
                            opacity: 0.6,
                            image: AssetImage(
                                "assets/images/textFormFieldBG.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText("Basic Information", width * 0.052,
                                  FontWeight.bold, colorBlack),
                              SizedBox(height: width * 0.04),
                              CustomTextFormField(
                                controller: fullNameController,
                                hint: 'Full Name',
                                input: TextInputType.name,
                                icon: Icons.person,
                                condition: (value) => value.length < 3,
                                errorText: "Please Enter Valid Name",
                                onChanged: (value) {
                                  setState(() {
                                    _calculateProfileCompletion({
                                      'name': value,
                                      'email': emailController.text,
                                      'mobileCode': countryCode,
                                      'mobile': mobileController.text,
                                      'dateOfBirth': selectedDateOfBirth
                                          ?.toIso8601String() ??
                                          '',
                                      'gender': selectedGender,
                                      'occupation': selectedOccupation,
                                      'relationshipStatus':
                                      selectedRelationshipStatus,
                                      'city': cityValue,
                                      'state': stateValue,
                                      'country': countryValue,
                                      'favoriteDanceStyle':
                                      selectedDanceStyle,
                                      'skillLevel': selectedSkillLevel,
                                    });
                                  });
                                },
                              ),
                              SizedBox(height: width * 0.04),
                              _buildDropdownField(
                                hintText: 'Occupation',
                                value: selectedOccupation,
                                items: occupations,
                                onChanged: (newValue) {
                                  selectedOccupation = newValue;
                                  setState(() {
                                    _calculateProfileCompletion({
                                      'name': fullNameController.text,
                                      'email': emailController.text,
                                      'mobileCode': countryCode,
                                      'mobile': mobileController.text,
                                      'dateOfBirth': selectedDateOfBirth
                                          ?.toIso8601String() ??
                                          '',
                                      'gender': selectedGender,
                                      'occupation': newValue ?? "",
                                      'relationshipStatus':
                                      selectedRelationshipStatus,
                                      'city': cityValue,
                                      'state': stateValue,
                                      'country': countryValue,
                                      'favoriteDanceStyle':
                                      selectedDanceStyle,
                                      'skillLevel': selectedSkillLevel,
                                    });
                                  });
                                },
                              ),
                              SizedBox(height: width * 0.04),
                              GestureDetector(
                                onTap: () => _selectDateOfBirth(context),
                                child: AbsorbPointer(
                                  child: CustomTextFormField(
                                    controller: TextEditingController(

                                          text: selectedDateOfBirth != null
                                              ? DateFormat('MM-dd-yyyy').format(selectedDateOfBirth!)
                                          : '',
                                    ),
                                    hint: 'Date of Birth',
                                    input: TextInputType.datetime,
                                    icon: Icons.calendar_month,
                                    condition: (value) => value.isEmpty,
                                    errorText: "Please Select DOB",
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDateOfBirth = DateFormat('yyyy-MM-dd').parse(value);
                                        print("selected date :::: $selectedDateOfBirth");
                                        _calculateProfileCompletion({
                                          'name': fullNameController.text,
                                          'email': emailController.text,
                                          'mobileCode': countryCode,
                                          'mobile': mobileController.text,
                                          'dateOfBirth':
                                          selectedDateOfBirth ?? '',
                                          'gender': selectedGender,
                                          'occupation':
                                          selectedOccupation,
                                          'relationshipStatus':
                                          selectedRelationshipStatus,
                                          'city': cityValue,
                                          'state': stateValue,
                                          'country': countryValue,
                                          'favoriteDanceStyle':
                                          selectedDanceStyle,
                                          'skillLevel':
                                          selectedSkillLevel,
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: width * 0.04),
                              _buildDropdownField(
                                hintText: 'Gender',
                                value: selectedGender,
                                items: genders,
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                    _calculateProfileCompletion({
                                      'name': fullNameController.text,
                                      'email': emailController.text,
                                      'mobileCode': countryCode,
                                      'mobile': mobileController.text,
                                      'dateOfBirth': selectedDateOfBirth
                                          ?.toIso8601String() ??
                                          '',
                                      'gender': value ?? "",
                                      'occupation': selectedOccupation,
                                      'relationshipStatus':
                                      selectedRelationshipStatus,
                                      'city': cityValue,
                                      'state': stateValue,
                                      'country': countryValue,
                                      'favoriteDanceStyle':
                                      selectedDanceStyle,
                                      'skillLevel': selectedSkillLevel,
                                    });
                                  });
                                },
                              ),
                              SizedBox(height: width * 0.04),
                              _buildDropdownField(
                                hintText: 'Relationship Status',
                                value: selectedRelationshipStatus,
                                items: relationshipStatusOptions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRelationshipStatus = value;
                                    _calculateProfileCompletion({
                                      'name': fullNameController.text,
                                      'email': emailController.text,
                                      'mobileCode': countryCode,
                                      'mobile': mobileController.text,
                                      'dateOfBirth': selectedDateOfBirth
                                          ?.toIso8601String() ??
                                          '',
                                      'gender': selectedGender,
                                      'occupation': selectedOccupation,
                                      'relationshipStatus': value ?? "",
                                      'city': cityValue,
                                      'state': stateValue,
                                      'country': countryValue,
                                      'favoriteDanceStyle':
                                      selectedDanceStyle,
                                      'skillLevel': selectedSkillLevel,
                                    });
                                  });
                                },
                              ),
                              SizedBox(height: width * 0.02),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: width * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(width * 0.02)),
                          border: Border.all(color: colorGrey),
                          image: DecorationImage(
                            opacity: 0.6,
                            image: AssetImage(
                                "assets/images/textFormFieldBG.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText("Location Details", width * 0.052,
                                  FontWeight.bold, colorBlack),
                              SizedBox(height: width * 0.04),
                              Column(
                                children: [
                                  Column(
                                    children: [
                                      SearchableCSCDropdown(
                                        title: "Country",
                                        initialValue: countryValue != null
                                            ? countries.firstWhere((country) =>
                                        country['id'].toString() ==
                                            countryValue)['name']
                                            .toString()
                                            : null,
                                        items: countries
                                            .map((country) =>
                                            country['name'].toString())
                                            .toList(),
                                        hintText: "Select a country",
                                        onChanged: (option) async {
                                          setState(() {

                                              countryValue =
                                                  countries.firstWhere((
                                                      country) =>
                                                  country['name'] ==
                                                      option)['id']
                                                      .toString();
                                              stateValue = null;
                                              cityValue = null;
                                              states = [];
                                              cities = [];


                                          });

                                          if (countryValue != null) {
                                            print(
                                                "countryValue ::::: $countryValue");
                                            await fetchStates(countryValue!);
                                          }
                                        },
                                      ),
                                      SizedBox(height: width * 0.04),
                                      SearchableCSCDropdown(
                                        title: "State",
                                        initialValue: stateValue != null
                                            ? states.firstWhere((state) =>
                                        state['id']
                                            .toString() ==
                                            stateValue)['name']
                                            .toString()
                                            : null,
                                        items: countryValue == null
                                            ? ['All']
                                            : states.map((state) =>
                                            state['name']
                                                .toString()).toList(),
                                        hintText: "Select a state",
                                        onChanged: (option) async {
                                          setState(() {

                                              stateValue = states.firstWhere((
                                                  state) =>
                                              state['name'] ==
                                                  option)['id']
                                                  .toString();
                                              cityValue = null;
                                              cities = [];
                                          });

                                          if (stateValue != null) {
                                            print(
                                                "stateValue ::::: $stateValue");
                                            await fetchCities(stateValue!);
                                          }
                                        },
                                      ),
                                      SizedBox(height: width * 0.04),
                                      SearchableCSCDropdown(
                                        title: "City",
                                        initialValue: cityValue != null
                                            ? cities.firstWhere((city) =>
                                        city['id'].toString() ==
                                            cityValue)['name']
                                            .toString()
                                            : null,
                                        items: cities
                                            .map((city) =>
                                            city['name'].toString())
                                            .toList(),
                                        hintText: "Select a city",
                                        onChanged: (option) {
                                          setState(() {

                                              cityValue = cities.firstWhere((
                                                  city) =>
                                              city['name'] ==
                                                  option)['id']
                                                  .toString();
                                              print(
                                                  "cityValue ::::: $cityValue");

                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                              SizedBox(height: width * 0.02),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: width * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(width * 0.02)),
                          border: Border.all(color: colorGrey),
                          image: DecorationImage(
                            opacity: 0.6,
                            image: AssetImage(
                                "assets/images/textFormFieldBG.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText("Contact Details", width * 0.052,
                                  FontWeight.bold, colorBlack),
                              SizedBox(height: width * 0.04),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.83,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(width * 0.02),
                                          ),
                                          border: Border.all(
                                              color: colorGrey),
                                          image: DecorationImage(
                                            opacity: 0.6,
                                            image: AssetImage(
                                                "assets/images/textFormFieldBG.png"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child:
                                        InternationalPhoneNumberInput(
                                          onInputChanged:
                                              (PhoneNumber number) {
                                            setState(() {
                                              countryCode =
                                                  number.dialCode ?? '+1';
                                            });
                                          },
                                          onInputValidated: (bool value) {
                                            setState(() {
                                              isPhoneNumberValid = value;
                                            });
                                            print(value
                                                ? 'Valid'
                                                : 'Invalid');
                                          },
                                          selectorConfig: SelectorConfig(
                                            leadingPadding: width * 0.04,
                                            trailingSpace: false,
                                            setSelectorButtonAsPrefixIcon:
                                            true,
                                            selectorType:
                                            PhoneInputSelectorType
                                                .DIALOG,
                                            useEmoji: false,
                                          ),
                                          selectorTextStyle:
                                          GoogleFonts.dmSans(
                                            color: colorBlack,
                                            fontSize: width * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          ignoreBlank: false,
                                          autoValidateMode:
                                          AutovalidateMode.disabled,
                                          initialValue: number,
                                          textFieldController:
                                          mobileController,
                                          formatInput: false,
                                          keyboardType: TextInputType
                                              .numberWithOptions(
                                            signed: true,
                                            decimal: true,
                                          ),
                                          inputBorder: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                          onSaved: (PhoneNumber number) {
                                            String formattedNumber =
                                                number.phoneNumber
                                                    ?.replaceFirst(
                                                    '+', '') ??
                                                    '';
                                            print(
                                                'On Saved: $formattedNumber');
                                          },
                                          cursorColor: colorBlack,
                                          textStyle: GoogleFonts.dmSans(
                                            textStyle: TextStyle(
                                              fontSize: width * 0.04,
                                              color: colorBlack,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          inputDecoration:
                                          InputDecoration(
                                            fillColor: colorWhite,
                                            isDense: true,
                                            hintText:
                                            'Enter Phone Number',
                                            hintStyle: GoogleFonts.dmSans(
                                              textStyle: TextStyle(
                                                fontSize:
                                                height * 0.01566,
                                                fontWeight:
                                                FontWeight.w400,
                                                color: colorGrey,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                            EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 5,
                                            ),
                                            prefixIconConstraints:
                                            BoxConstraints(
                                              minWidth: 0,
                                              minHeight: 0,
                                            ),
                                            suffixIconConstraints:
                                            BoxConstraints(
                                              minWidth: 40,
                                              minHeight: 40,
                                            ),
                                            errorMaxLines: 3,
                                            counterText: "",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: width * 0.04),
                              CustomTextFormField(
                                readOnly: true,
                                controller: emailController,
                                hint: 'Email',
                                input: TextInputType.emailAddress,
                                icon: Icons.email,
                                condition: (value) => value.length < 3,
                                errorText: "Please Enter Valid Email",
                                onChanged: (value) {
                                  _calculateProfileCompletion({
                                    'name': fullNameController.text,
                                    'email': value ?? "",
                                    'mobileCode': countryCode,
                                    'mobile': mobileController.text,
                                    'dateOfBirth': selectedDateOfBirth
                                        ?.toIso8601String() ??
                                        '',
                                    'gender': selectedGender,
                                    'occupation': selectedOccupation,
                                    'relationshipStatus':
                                    selectedRelationshipStatus,
                                    'city': cityValue,
                                    'state': stateValue,
                                    'country': countryValue,
                                    'favoriteDanceStyle':
                                    selectedDanceStyle,
                                    'skillLevel': selectedSkillLevel,
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: width * 0.04),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(width * 0.02)),
                          border: Border.all(color: colorGrey),
                          image: DecorationImage(
                            opacity: 0.6,
                            image: AssetImage(
                                "assets/images/textFormFieldBG.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WantText(
                                  "Interests & Preferences",
                                  width * 0.052,
                                  FontWeight.bold,
                                  colorBlack),
                              SizedBox(height: width * 0.04),
                              _buildDropdownField(
                                hintText: 'Favorite Dance Style',
                                value: selectedDanceStyle,
                                items: danceStyles,
                                onChanged: (value) {
                                  setState(() {
                                    selectedDanceStyle = value;
                                    _calculateProfileCompletion({
                                      'name': fullNameController.text,
                                      'email': emailController.text,
                                      'mobileCode': countryCode,
                                      'mobile': mobileController.text,
                                      'dateOfBirth': selectedDateOfBirth
                                          ?.toIso8601String() ??
                                          '',
                                      'gender': selectedGender,
                                      'occupation': selectedOccupation,
                                      'relationshipStatus':
                                      selectedRelationshipStatus,
                                      'city': cityValue,
                                      'state': stateValue,
                                      'country': countryValue,
                                      'favoriteDanceStyle': value ?? "",
                                      'skillLevel': selectedSkillLevel,
                                    });
                                  });
                                },
                              ),
                              SizedBox(height: width * 0.04),
                              _buildDropdownField(
                                hintText: 'Skill Level',
                                value: selectedSkillLevel,
                                items: skillLevels,
                                onChanged: (value) {
                                  setState(() {
                                    selectedSkillLevel = value;
                                    _calculateProfileCompletion({
                                      'name': fullNameController.text,
                                      'email': emailController.text,
                                      'mobileCode': countryCode,
                                      'mobile': mobileController.text,
                                      'dateOfBirth': selectedDateOfBirth
                                          ?.toIso8601String() ??
                                          '',
                                      'gender': selectedGender,
                                      'occupation': selectedOccupation,
                                      'relationshipStatus':
                                      selectedRelationshipStatus,
                                      'city': cityValue,
                                      'state': stateValue,
                                      'country': countryValue,
                                      'favoriteDanceStyle':
                                      selectedDanceStyle,
                                      'skillLevel': value ?? "",
                                    });
                                  });
                                },
                              ),
                              SizedBox(height: width * 0.02),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: width * 0.08),
                      isProfileCompleted == true
                          ? SizedBox()
                          : GeneralButton(
                        Width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        label: "Save Profile",
                        onTap: () async {
                          if (countryValue == null) {
                            showToast("Please select a country",
                                colorSubTittle);
                            return;
                          }
                          if (stateValue == null) {
                            showToast("Please select a state",
                                colorSubTittle);
                            return;
                          }
                          if (cityValue == null) {
                            showToast("Please select a city",
                                colorSubTittle);
                            return;
                          }

                          if (isPhoneNumberValid) {
                            await _saveUserDataToPreferences();
                          } else {
                            showToast("Please enter a valid mobile number", colorSubTittle);
                          }


                        },
                      ),
                      isVerifyOTP ? SizedBox() : SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SearchableCSCDropdown extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(String) onChanged;
  final String hintText;
  final String? initialValue;

  const SearchableCSCDropdown({
    Key? key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.hintText = "Select an option",
  }) : super(key: key);

  @override
  _SearchableCSCDropdownState createState() => _SearchableCSCDropdownState();
}

class _SearchableCSCDropdownState extends State<SearchableCSCDropdown> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<String> _filteredItems = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    print("Initial value: ${widget.initialValue}");
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _filteredItems = widget.items;

    // Open dropdown when the field is clicked
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _filteredItems = widget.items; // Reset list when clicked
          _isDropdownOpen = true;
        });
      } else {
        setState(() {
          _isDropdownOpen = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SearchableCSCDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
      _filteredItems = widget.items;
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items; // Show full list when empty
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Toggle dropdown open/close when suffix icon is clicked
  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Field
        SizedBox(
          height: height * 0.062,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            style: GoogleFonts.inter(
              color: colorMainTheme,
              fontSize: width * 0.03733,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.inter(
                color: colorGrey,
                fontSize: width * 0.03733,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide: BorderSide(color: colorGrey), // Grey color
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(width * 0.0266),
                ),
                borderSide: BorderSide(color: colorMainTheme), // Blue color
              ),
              suffixIcon: GestureDetector(
                onTap: _toggleDropdown, // Close or open dropdown on click
                child: _isDropdownOpen == false
                    ? Icon(
                  Icons.keyboard_arrow_down,
                  color: colorGrey,
                  size: MediaQuery.of(context).size.width * 0.065,
                )
                    : Icon(
                  Icons.keyboard_arrow_up,
                  color: colorMainTheme,
                  size: MediaQuery.of(context).size.width * 0.065,
                ),
              ),
            ),
            onChanged: _filterItems,
            onTap: () {
              setState(() {
                _filteredItems = widget.items; // Reset filtered list when tapped
                _isDropdownOpen = true;
              });
            },
          ),
        ),

        // Dropdown Menu (Appears when _isDropdownOpen is true)
        if (_isDropdownOpen && _filteredItems.isNotEmpty)
          Container(
            height: _filteredItems.length >= 4
                ? height * 0.25
                : _filteredItems.length >= 3
                ? height * 0.185
                : _filteredItems.length >= 2
                ? height * 0.125
                : height * 0.065,
            // margin: EdgeInsets.only(top: height * 0.01),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.0266),
              color: colordropdown,boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
              // border: Border.all(color: colorGrey),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _controller.text = _filteredItems[index];
                        _isDropdownOpen = false; // Close dropdown on select
                        _focusNode.unfocus(); // Close keyboard
                      });
                      widget.onChanged(_filteredItems[index]);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: width * 0.028, horizontal: width * 0.035),
                      child: Text(
                        _filteredItems[index],
                        style: GoogleFonts.dmSans(
                          color: colorBlack,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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