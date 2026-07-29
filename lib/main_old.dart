// import 'dart:developer';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:flutter_gemma/flutter_gemma.dart';
// import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
// import 'package:local_ai_calorie_app/widgets/image_display_widget.dart';
// import 'package:local_ai_calorie_app/services/image_picker_service.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:file_picker/file_picker.dart';

// void main() {

//   WidgetsFlutterBinding.ensureInitialized();

//   FlutterGemma.initialize(
//     // Inference engines — add the ones whose packages you depend on:
//     inferenceEngines: [
//       LiteRtLmEngine()   // flutter_gemma_builtin_ai — Gemini Nano / Apple FM
//     ],
//     maxDownloadRetries: 10,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: .fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
  
//   String _ocrResult = "Initialize the model first.";
//   bool _isModelReady = false;
//   bool _isProcessing = false;
//   File? _selectedImage;


//   final ImagePickerService _pickerService = ImagePickerService();

//   /// Triggers the service logic and updates state
//   Future<void> _handlePickImage() async {
//     final File? croppedImage = await _pickerService.pickAndCropImage(context);

//     // Only update UI state if an image was successfully selected & cropped
//     if (croppedImage != null) {
//       setState(() {
//         _selectedImage = croppedImage;
//       });
//     }
//   }
  

//   Future<void> performLocalOcr() async {
//     setState(() {
//       _isProcessing = true;
//       _ocrResult = "Initializing model and performing OCR locally...";
//     });

//     if (_selectedImage == null) return;

//     try {

//       List<String> installedModels = await FlutterGemma.listInstalledModels();
//       debugPrint("Installed models: ${installedModels.length}");

//       if (installedModels.isEmpty) {

//         // 1. Prompt the user to tap and choose the model file from their Downloads folder
//         FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.any,
//           allowMultiple: false,
//         );

//         if (result == null || result.files.single.path == null) {
//           debugPrint("Model selection canceled.");
//           return;
//         }

//         // 2. The picker provides a valid virtual file path with full permission clearance
//         final File pickedModelFile = File(result.files.single.path!);
        
//         // 3. Setup sandbox destination
//         final Directory appDocDir = await getApplicationDocumentsDirectory();
//         final String safeSandboxPath = '${appDocDir.path}/gemma-4-E2B-it.litertlm';
//         final File safeModelFile = File(safeSandboxPath);

//         debugPrint("Copying chosen model safely into app sandbox...");
//         await pickedModelFile.copy(safeSandboxPath);

//         await FlutterGemma.installModel(
//           modelType: ModelType.gemma4,
//           fileType: ModelFileType.litertlm,
//         ).fromFile(safeModelFile.path).install();
//       }

//       final model = await FlutterGemma.getActiveModel(
//         maxTokens: 2048,
//         preferredBackend: PreferredBackend.gpu,
//         supportImage: true, 
//       );

//       // 3. Convert the File payload into Uint8List bytes required by the API.
//       final Uint8List imageBytes = await _selectedImage!.readAsBytes();
  
//       // 4. Construct the multimodal query containing both text context and target images.
//       final message = Message.withImage(
//         text: """
//           SYSTEM INSTRUCTION:
//           You are a robust data matching tool. The input image contains European nutrition tables featuring multiple languages stacked vertically inside the same row blocks. 

//           DIRECTIONS:
//           1. Output ONLY a flat JSON object. No markdown wrapping.
//           2. Ignore all languages EXCEPT Romanian or English keywords. Use them as anchors.
//           3. Once an anchor keyword is found, scan strictly to the right or immediately below its block to find the matching numeric value. 
//           4. For multiline text blocks, ignore the text height density and locate the single number assigned to that entire block group.

//           KEYWORD ANCHOR MAPPING:
//           - "calories_kcal": Search for "Valoare energetică" or "Energy". Calories are usually written in both jK and kcal, one under another or separated by slash, like "XX kJ / YY ckal". Look past the slash (/) or on the second row and extract ONLY the number before 'kcal'.
//           - "fat_g": Search for "Grăsimi". Extract the number.
//           - "saturated_fat_g": Search for "din care acizi grași saturați" or "acizi grași saturați". Extract the number.
//           - "carbohydrates_g": Search for "Glucide". Extract the number.
//           - "sugars_g": Search for "din care zaharuri" or "Zaharuri". Extract the number.
//           - "fiber_g": Search for "Fibre". Extract the number.
//           - "protein_g": Search for "Proteine". Extract the number.
//           - "salt_g": Search for "Sare". Extract the number.

//           TARGET SCHEMA:
//           {
//             "calories_kcal": 0.0,
//             "fat_g": 0.0,
//             "saturated_fat_g": 0.0,
//             "carbohydrates_g": 0.0,
//             "sugars_g": 0.0,
//             "fiber_g": 0.0,
//             "protein_g": 0.0,
//             "salt_g": 0.0
//           }
//         """,
//         imageBytes: imageBytes,
//         isUser: true,
//       );

//       // 5. Open a chat session and invoke generation natively on the user's device hardware.
//       final chat = await model.createChat(temperature: 0.0, topK: 1);
//       await chat.addQueryChunk(message);
      
//       setState(() {
//         _ocrResult = "$_ocrResult \n Starting AI parse ${DateTime.now()}";
//       });

//       final response = await chat.generateChatResponse();

//       setState(() {
//         _ocrResult = "$_ocrResult \n Finished AI parse ${DateTime.now()}";
//       });

//       setState(() {
//         _ocrResult = "$_ocrResult \n AI RESULT \n ${(response.toString() ?? "No text detected or failed to parse response.")}";
//       });
//     } catch (e) {
//       setState(() {
//         _ocrResult = "An error occurred during local OCR: $e";
//       });
//     } finally {
//       setState(() {
//         _isProcessing = false;
//       });
//     }

//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0), // Optional: adds nice breathing room on edges
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 ImageDisplayWidget(
//                   imageFile: _selectedImage,
//                   size: 260,
//                 ),

//                 // The Button
//                 ElevatedButton.icon(
//                   onPressed: performLocalOcr,
//                   icon: const Icon(Icons.star_border_rounded),
//                   label: const Text('Try OCR'),
//                 ),            
//                 const SizedBox(height: 20),
                
//                 // Wrapped text or direct text will now scroll smoothly down the screen
//                 Text(
//                   _ocrResult,
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _handlePickImage,
//         tooltip: 'Pick photo',
//         child: const Icon(Icons.photo_library),
//       ),
//     );
//   }
// }
