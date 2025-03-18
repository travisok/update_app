import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:internal_app/infrastructure/network/api/api_client.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:internal_app/infrastructure/network/models/user_update.dart';


class PostAnUpdate extends StatefulWidget{
  final ApiClient apiClient;

  const PostAnUpdate({super.key, required this.apiClient});

  @override
  _PostAnUpdate createState() => _PostAnUpdate();
}

class _PostAnUpdate extends State<PostAnUpdate>{
  final quill.QuillController yesterdayUpdateController = quill.QuillController.basic();
  final quill.QuillController todayUpdateController = quill.QuillController.basic();
  final quill.QuillController blockersController = quill.QuillController.basic();
  Set<String> selectedTags = {};
  late int totalItems;

  final List<String> tags = [
    'User Management',
    'Talent App',
    'Client App',
    'Admin',
    'Internal App',
    'External',
    'Partnerd App'
  ];   

void _showNotification(String message, Color color) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

  Future<void> _onSubmit() async {
    print('Starting _onSubmit');
    String yesterdayUpdate = yesterdayUpdateController.document.toPlainText().trim();
    String todayUpdate = todayUpdateController.document.toPlainText().trim(); 
    String blockers = blockersController.document.toPlainText().trim();
    List<String> tagsChosen = selectedTags.toList();

    if (yesterdayUpdate.isEmpty || todayUpdate.isEmpty) {
    _showNotification("Please fill in all required fields.", Colors.red);
    return;
  }

    //setState(() => _isLoading = true);

    try {
      print("Attempting API call with tags: $tagsChosen");
      final updateData = UserUpdate(
        yesterdayUpdate: yesterdayUpdate,
        todayUpdate: todayUpdate,
        blockers: blockers,
        tagsChosen: tagsChosen,
      );


      // setState(() {
      //   totalItems = updateData['totalItems'];
      // });
      final apiClient = RepositoryProvider.of<ApiClient>(context); // Assuming you're using BLoC
      await apiClient.postUpdate(updateData);
      print('API call successful');
      
      if (mounted) {
        _showNotification('Update posted successfully!', Colors.green);
        //Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pop(context);
      }
      
    } catch (error) {
      print("API call failed: $error");
      String getErrorMessage(dynamic e) {
        if (e.toString().contains('400')) {
          return 'Invalid update. Please check your inputs.';
        } else if (e.toString().contains('Network')) {
          return 'Network error. Please try again.';
        }
        return 'Something went wrong. Please try later.';
      }

      _showNotification(getErrorMessage(error), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          toolbarHeight: 49,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 52,),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    'assets/icons/back_button.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  'Post your update',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828)
                  )
                ),
                SizedBox(height: 4),
                Text(
                  'Post your updates',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF667A81)
                  )
                ),
                SizedBox(height: 32),
                  _buildQuillEditor('What I Did Yesterday', yesterdayUpdateController),
                      SizedBox(height: 24),
                  _buildQuillEditor('What I Will Be Working on Today', todayUpdateController),
                      SizedBox(height: 24),
                  _buildQuillEditor('Blockers/Requests', blockersController),
                  SizedBox(height: 24),
                  //_buildImageUploader(),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      Builder(
                        builder: (context) {
                          return PopupMenuButton<String>(
                            onSelected: (String value) {
                              setState(() {
                                if (selectedTags.contains(value)) {
                                  selectedTags.remove(value);
                                } else {
                                  selectedTags.add(value);
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) => tags
                                .map((tag) => PopupMenuItem<String>(
                                  value: tag,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: selectedTags.contains(tag),
                                        onChanged: (bool? selected) {
                                          setState(() {
                                            selected!
                                                ? selectedTags.add(tag)
                                                : selectedTags.remove(tag);
                                          });
                                        }
                                      ),
                                      Text(tag),
                                    ],
                                  )
                                ))
                            .toList(),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/add.svg',
                                  width: 14,
                                  height: 14,
                                  fit: BoxFit.scaleDown
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Add tag',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000D12)
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedTags.map((tag) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF29CFD6),
                          borderRadius: BorderRadius.circular(16)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTags.remove(tag);
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14
                              )
                            )
                          ],
                        )
                      );
                    }).toList()
                  ),
                      SizedBox(height: (MediaQuery.of(context).size.width) / 3.53,),
                  
                      InkWell(
                      onTap: _onSubmit,
                      child: Container(
                        height: 51,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFF00141B)
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Submit Update',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF)
                            )
                          ),
                        )
                      ),
                    ),
              SizedBox(height: (MediaQuery.of(context).size.width) / 9.7,),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildQuillEditor(String label, quill.QuillController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF344054),
        ),
      ),
      SizedBox(height: 6),
      Container(
        height: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFD0D5DD), width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: quill.QuillEditor.basic(
          controller: controller,
          configurations: const quill.QuillEditorConfigurations(), // Ensure editor is editable
          // additional settings as needed
        ),
      ),
      SizedBox(height: 8),
      quill.QuillToolbar.simple(controller: controller),
    ],
  );
}

// Widget _buildImageUploader() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         "Upload your screenshots",
//         style: GoogleFonts.inter(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: Color(0xFF344054),
//         ),
//       ),
//       SizedBox(height: 6),
//       ElevatedButton(
//         onPressed: () async {
//           // Pick an image
//           FilePickerResult? result = await FilePicker.platform.pickFiles(
//             type: FileType.image,
//           );
//           if (result != null) {
//             // Handle the picked file, e.g., save to a list of uploaded images
//             PlatformFile file = result.files.first;
//             print("Picked file path: ${file.path}");
//             // Add any necessary logic to display or upload this image
//           }
//         },
//         child: Text("Select Image"),
//       ),
//       // Display uploaded images 
//       SizedBox(height: 12),
//       // Additional widget to display the list of uploaded images, 
//     ],
//   );
// }

}