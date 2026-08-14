import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

class LocalAiService {

  static Future<InferenceModel?> getInferenceModel(bool supportImage) async {
    List<String> installedModels = await FlutterGemma.listInstalledModels();

    if (installedModels.isEmpty) {

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: "Pick AI model",
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      final File pickedModelFile = File(result.files.single.path!);
      
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String safeSandboxPath = '${appDocDir.path}/gemma-4-E2B-it.litertlm';
      final File safeModelFile = File(safeSandboxPath);

      await pickedModelFile.copy(safeSandboxPath);

      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(safeModelFile.path).install();
    }

    return await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.gpu,
      supportImage: supportImage, 
    );
  }

  static Future<String> getLabelValuesFromImage (InferenceModel inferenceModel, Uint8List imageBytes) async {

    final message = Message.withImage(
      text: getLabelInstruction(),
      imageBytes: imageBytes,
      isUser: true
    );

    final chat = await inferenceModel.createChat(temperature: 0.8, topK: 1, isThinking: false);
    await chat.addQueryChunk(message);

    final response = await chat.generateChatResponse();
    // String response = "";

    // final textStream = chat
    // .generateChatResponseAsync()
    // .where((response) => response is TextResponse)
    // .map((response) => (response as TextResponse).token);

    // await for (final textToken in textStream) {
    //   response += textToken;
    // }
    
    RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
    Match? match = jsonRegex.firstMatch(response.toString());

    if (match != null) {
        return match.group(0)!;
    } else {
      return('{}');
    }
  }

  static Future<String> getEstimatedValuesFromText (InferenceModel inferenceModel, String foods) async {

    final message = Message.text(
      text: getFoodEstimationFromTextInstruction(foods),
      isUser: true
    );

    // final chat = await inferenceModel.createChat(temperature: 0.8, topK: 1, isThinking: true);
    // await chat.addQueryChunk(message);

    // String response = "";

    // final textStream = chat
    // .generateChatResponseAsync()
    // .where((response) => response is TextResponse)
    // .map((response) => (response as TextResponse).token);

    // await for (final textToken in textStream) {
    //   response += textToken;
    // }

    final chat = await inferenceModel.createChat(temperature: 0.8, topK: 1, isThinking: false);
    await chat.addQueryChunk(message);

    final response = await chat.generateChatResponse();

    return response.toString().replaceAll(RegExp(r'[^0-9.,]'), '');
  }



  static Future<String> getDiaryEntriesFromText (InferenceModel inferenceModel, String foods) async {

    final message = Message.text(
      text: getFreeTextDiaryInstruction(foods),
      isUser: true
    );

    //THINKING
    // final chat = await inferenceModel.createChat(temperature: 0.8, topK: 1, isThinking: true);
    // await chat.addQueryChunk(message);

    // String response = "";

    // final textStream = chat
    // .generateChatResponseAsync()
    // .where((response) => response is TextResponse)
    // .map((response) => (response as TextResponse).token);

    // await for (final textToken in textStream) {
    //   response += textToken;
    // }

    //NOT THINKING
    final chat = await inferenceModel.createChat(
      temperature: 0.1,
      topK: 1, 
      topP: 0.1, 
      isThinking: false);
    await chat.addQueryChunk(message);

    final response = await chat.generateChatResponse();

    return response.toString();

    RegExp jsonRegex = RegExp(r'^\s*\[[\s\S]*\]\s*$');
    Match? match = jsonRegex.firstMatch(response.toString());

    if (match != null) {
        return match.group(0)!;
    } else {
      return('{}');
    }
  }


  /// Simplified Gemma prompt: ONLY does weight estimation
  // static Future<double> _askGemmaForGrams(String ingredientWithQuantity) async {
  //   final prompt = '''
  //   Convert the weight of this food item to numeric grams. Return ONLY a single number.
  //   Item: "$ingredientWithQuantity"
  //   Grams:''';

  //   final response = await inferenceModel.createChat(
  //     prompt: prompt,
  //     temperature: 0.0,
  //     topK: 1,
  //   );

  //   // Extract raw number from response
  //   final numRegExp = RegExp(r'\d+(?:\.\d+)?');
  //   final match = numRegExp.firstMatch(response ?? '');
    
  //   return double.tryParse(match?.group(0) ?? '0') ?? 0.0;
  // }

  static String getLabelInstruction(){
    return
    """
      SYSTEM INSTRUCTION:
      You are a robust data matching tool. The input image contains European nutrition tables featuring multiple languages stacked vertically inside the same row blocks. 

      DIRECTIONS:
      1. Output ONLY a flat JSON object. No markdown wrapping.
      2. Ignore all languages EXCEPT Romanian or English keywords. Use them as anchors.
      3. Once an anchor keyword is found, scan strictly to the right or immediately below its block to find the matching numeric value. 
      4. For multiline text blocks, ignore the text height density and locate the single number assigned to that entire block group.

      KEYWORD ANCHOR MAPPING:
      - "calories_kcal": Search for "Valoare energetică" or "Energy". Calories are usually written in both jK and kcal, one under another or separated by slash, like "XX kJ / YY ckal". Look past the slash (/) or on the second row and extract ONLY the number before 'kcal'.
      - "fat_g": Search for "Grăsimi". Extract the number.
      - "saturated_fat_g": Search for "din care acizi grași saturați" or "acizi grași saturați". Extract the number.
      - "carbohydrates_g": Search for "Glucide". Extract the number.
      - "sugars_g": Search for "din care zaharuri" or "Zaharuri". Extract the number.
      - "fiber_g": Search for "Fibre". Extract the number.
      - "protein_g": Search for "Proteine". Extract the number.
      - "salt_g": Search for "Sare". Extract the number.

      TARGET SCHEMA:
      {
        "calories_kcal": 0.0,
        "carbohydrates_g": 0.0,
        "sugars_g": 0.0,
        "fiber_g": 0.0,
        "fat_g": 0.0,
        "saturated_fat_g": 0.0,
        "protein_g": 0.0
      }
    """;
  }


  static String getFoodEstimationFromTextInstruction(String foods){

    return """
      Provide standard raw nutrition facts PER 100 GRAMS (USDA base value). 
      Do NOT estimate per whole item/serving size.

      Format: CALORIES,CARBS,SUGARS,FIBER,FAT,SATURATED FAT,PROTEIN
      Return ONLY 7 numbers separated by commas.

      Example 1 (Vegetable):
      Item: "carrots, raw"
      Output: 41,9.6,4.7,2.8,0.2,0.0,0.9

      Example 2 (Fruit):
      Item: "banana"
      Output: 89,22.8,12.2,2.6,0.3,0.1,1.1

      Example 3 (Meat):
      Item: "chicken breast, grilled"
      Output: 165,0.0,0.0,0.0,3.6,1.0,31.0

      Item: "$foods"
      Output:""";
  }


  static String getFreeTextDiaryInstruction(String foods){
    return
    """
      Parse food inputs to JSON array.
      Keys: "romanian", "english", "grams" (numeric weight). Convert all numeric values to grams.

      Example:
      Input: "150g orez fiert, 1 tbs sugar"
      Output: [{"romanian":"orez fiert","english":"boiled rice","grams":150},{"romanian":"zahar","english":"sugar","grams":12.5}]

      Input: "$foods"
      Output: [
    """;
  }


  // Future<void> performLocalOcr() async {

  //   try {

  //     List<String> installedModels = await FlutterGemma.listInstalledModels();

  //     if (installedModels.isEmpty) {

  //       // 1. Prompt the user to tap and choose the model file from their Downloads folder
  //       FilePickerResult? result = await FilePicker.platform.pickFiles(
  //         type: FileType.any,
  //         allowMultiple: false,
  //       );

  //       if (result == null || result.files.single.path == null) {
  //         return;
  //       }

  //       // 2. The picker provides a valid virtual file path with full permission clearance
  //       final File pickedModelFile = File(result.files.single.path!);
        
  //       // 3. Setup sandbox destination
  //       final Directory appDocDir = await getApplicationDocumentsDirectory();
  //       final String safeSandboxPath = '${appDocDir.path}/gemma-4-E2B-it.litertlm';
  //       final File safeModelFile = File(safeSandboxPath);

  //       debugPrint("Copying chosen model safely into app sandbox...");
  //       await pickedModelFile.copy(safeSandboxPath);

  //       await FlutterGemma.installModel(
  //         modelType: ModelType.gemma4,
  //         fileType: ModelFileType.litertlm,
  //       ).fromFile(safeModelFile.path).install();
  //     }

  //     final model = await FlutterGemma.getActiveModel(
  //       maxTokens: 2048,
  //       preferredBackend: PreferredBackend.gpu,
  //       supportImage: true, 
  //     );

  //     // 3. Convert the File payload into Uint8List bytes required by the API.
  //     final Uint8List imageBytes = await _selectedImage!.readAsBytes();
  
  //     // 4. Construct the multimodal query containing both text context and target images.
  //     final message = Message.withImage(
  //       text: "",
  //       imageBytes: imageBytes,
  //       isUser: true,
  //     );

  //     // 5. Open a chat session and invoke generation natively on the user's device hardware.
  //     final chat = await model.createChat(temperature: 0.0, topK: 1);
  //     await chat.addQueryChunk(message);
      
  //     setState(() {
  //       _ocrResult = "$_ocrResult \n Starting AI parse ${DateTime.now()}";
  //     });

  //     final response = await chat.generateChatResponse();

  //     setState(() {
  //       _ocrResult = "$_ocrResult \n Finished AI parse ${DateTime.now()}";
  //     });

  //     setState(() {
  //       _ocrResult = "$_ocrResult \n AI RESULT \n ${(response.toString() ?? "No text detected or failed to parse response.")}";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _ocrResult = "An error occurred during local OCR: $e";
  //     });
  //   } finally {
  //     setState(() {
  //       _isProcessing = false;
  //     });
  //   }

  // }
}