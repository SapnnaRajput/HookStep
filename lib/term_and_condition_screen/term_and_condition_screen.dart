import 'package:dancebuddy/utils/theam_manager.dart';
import 'package:dancebuddy/utils/want_text.dart'; // You can still keep WantText for other uses.
import 'package:dancebuddy/utils/widget/general_button/general_button.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isAgreed = false;

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
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.06),

              // Custom Title using WantText
              Row(
                children: [GestureDetector(onTap: () {
                  Navigator.pop(context);
                },child: Icon(Icons.arrow_back_ios,size: width*0.04 ,),),SizedBox(width: width*0.04,),
                  WantText(
                    "Privacy Policy",
                    width * 0.06,
                    FontWeight.bold,
                    colorSubTittle,
                  ),
                ],
              ),
              SizedBox(height: height * 0.01),

              // Subtitle
              WantText(
                "Please Read the Privacy Policy",
                width * 0.045,
                FontWeight.bold,
                colorBlack,
              ),
              SizedBox(height: height * 0.02),

              // Scrollable Privacy Policy using Text widget
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '''
HookStep built the HookStep app as a free app. This SERVICE is provided by HookStep at no cost and is intended for use as is.

This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information for anyone who decides to use our Service.

**Information Collection and Use**

For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information. While using our Service, we do not directly collect any personal information that can identify you. However, we may utilize third-party services that collect information used to identify you for providing a better user experience. This includes, but is not limited to, video search services from Instagram, Facebook, and YouTube APIs.

**Third-Party Services**

Our app uses third-party services that may collect information to help us deliver our Service, such as showing videos from public accounts. The following third-party services are used:

- Instagram API (for searching and displaying Instagram videos)
- Facebook API (for searching and displaying Facebook videos)
- YouTube API (for searching and displaying YouTube videos)

By using these services, you agree to their respective privacy policies and terms of use. We do not store or share your search data with any other parties, except as necessary to display the video results and enhance your experience.

**Audio, Video, and Download Management**

HookStep provides features for managing video playback, including:
- Audio mute/unmute functionality.
- Splitting and mirroring video functionality.
- Speed adjustment for video playback.
- Downloading public videos for personal use.

Users are responsible for ensuring that their use of video content complies with the terms of service of the respective platforms (Instagram, Facebook, YouTube). Downloading and sharing videos must align with the content creator’s and platform’s guidelines.

**Security**

We value your trust in using our Service, and we strive to protect your data to the best of our abilities. However, we do not guarantee absolute security, as no method of transmission over the internet is 100% secure. While we use commercially acceptable means to protect your personal information, we cannot ensure its absolute security.

**Links to Other Sites**

Our Service may contain links to other sites, such as Instagram, Facebook, and YouTube. If you click on a third-party link, you will be directed to that site. We strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.

**Children’s Privacy**

Our app does not specifically target anyone under the age of 13. We do not knowingly collect personal information from children. If we discover that a child under 13 has provided us with personal information, we will take steps to delete such information.

**Changes to This Privacy Policy**

We may update our Privacy Policy from time to time. You are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page.

**Contact Us**

If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@hookstep.net
                    ''',
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),

              // Checkbox and Agreement Text
              // Row(
              //   children: [
              //     Checkbox(
              //       value: _isAgreed,
              //       activeColor: Colors.blueAccent,
              //       onChanged: (bool? value) {
              //         setState(() {
              //           _isAgreed = value ?? false;
              //         });
              //       },
              //     ),
              //     Flexible(
              //       child: Text(
              //         "I agree to the Privacy Policy",
              //         style: TextStyle(fontSize: 16, color: Colors.black),
              //       ),
              //     ),
              //   ],
              // ),
              //
              // SizedBox(height: height * 0.02),
              // GeneralButton(
              //   onTap: _isAgreed
              //       ? () {
              //     // Proceed after agreement
              //     Navigator.pop(context);
              //   }
              //       : null,
              //   Width: width,
              //   label: 'Continue',
              //   isSelected: !_isAgreed,
              // ),

              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
