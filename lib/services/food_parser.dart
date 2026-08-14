import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'dart:convert';

import 'package:local_ai_calorie_app/services/local_ai_service.dart';

class FoodParserService {
  late final OnDeviceTranslator _roToEnTranslator;
  late final OnDeviceTranslator _enToRoTranslator;
  final OnDeviceTranslatorModelManager _modelManager = OnDeviceTranslatorModelManager();

  bool _isInitialized = false;

  /// Initialize ML Kit models (Downloads translation models if not local)
  Future<void> initialize() async {
    // 1. Ensure Romanian and English models are downloaded
    final roDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.romanian.bcpCode);
    final enDownloaded = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);

    if (!roDownloaded) {
      await _modelManager.downloadModel(TranslateLanguage.romanian.bcpCode);
    }
    if (!enDownloaded) {
      await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }

    // 2. Initialize ML Kit Translators
    _roToEnTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.romanian,
      targetLanguage: TranslateLanguage.english,
    );

    _enToRoTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.romanian,
    );

    _isInitialized = true;
  }

  /// Process the food input string
  Future<List<Map<String, dynamic>>> parseFoodInput(String rawInput) async {
    if (!_isInitialized) await initialize();

    // Split input string into items (e.g., "150g orez fiert", "1 tbs sugar")
    final List<String> rawItems = rawInput.split(',').map((e) => e.trim()).toList();
    final List<Map<String, dynamic>> results = [];

    for (var item in rawItems) {
      // 1. Detect language / translate using ML Kit
      // ML Kit handles translation in ~20ms on-device
      final String englishText = await _roToEnTranslator.translateText(item);
      final String romanianText = await _enToRoTranslator.translateText(item);

      // 2. Try parsing simple units locally using Regex (instant, 100% accurate)
      final double? parsedGrams = _tryExtractGramsLocally(item);

      if (parsedGrams != null) {
        // Simple "g" unit detected! No need for Gemma.
        results.add({
          "romanian": _cleanName(romanianText),
          "english": _cleanName(englishText),
          "grams": parsedGrams,
        });
      } else {
        // 3. Complex unit (tbsp, cups, ml). Use Gemma strictly for density estimation.
        final double estimatedGrams = await _askGemmaForGrams(englishText);
        
        results.add({
          "romanian": _cleanName(romanianText),
          "english": _cleanName(englishText),
          "grams": estimatedGrams,
        });
      }
    }

    return results;
  }

  /// Extracts standard weight directly if written in grams (e.g. "150g" or "150 g" or "1.5 g")
  double? _tryExtractGramsLocally(String input) {
    try {
      final RegExp regExp = RegExp(r'(\d+(?:\.\d+)?)(?!\s*/)\s*g\b', caseSensitive: false);
      final match = regExp.firstMatch(input);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
      return null;
    }
    catch(ex) {
      return null;
    }
  }

  /// Simplified Gemma prompt: ONLY does weight estimation
  Future<double> _askGemmaForGrams(String ingredientWithQuantity) async {
    final prompt = '''
    Convert the weight of this food item to numeric grams. Return ONLY a single number.
    Item: "$ingredientWithQuantity"
    Grams:''';

    final inferenceModel = await LocalAiService.getInferenceModel(false);

    final chat = await inferenceModel!.createChat(
      temperature: 0.0,
      topK: 1,
    );

    final message = Message.text(
      text: prompt,
      isUser: true
    );

    await chat.addQueryChunk(message);

    final response = await chat.generateChatResponse();

    // Extract raw number from response
    final numRegExp = RegExp(r'\d+(?:\.\d+)?');
    final match = numRegExp.firstMatch(response.toString() ?? '');
    
    return double.tryParse(match?.group(0) ?? '0') ?? 0.0;
  }

  /// Strip quantities out of the translated strings
  String _cleanName(String text) {
    String cleaned = text;

    // 1. Remove all numbers and decimals (e.g., "100", "5.5", "1")
    cleaned = cleaned.replaceAll(RegExp(r'\d+(?:\.\d+)?'), '');

    // 2. Remove unit labels and common size descriptors (English + Romanian)
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(g|gram|grams|gr|grame|ml|l|tbs|tbsp|tsp|cup|cups|oz|small|medium|large|mic|mica|medie|mediu|mare|pahar|glass)\b',
        caseSensitive: false,
      ),
      '',
    );

    // 3. Clean up extra spaces left behind
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned.toLowerCase();
  }

  void dispose() {
    _roToEnTranslator.close();
    _enToRoTranslator.close();
  }

  
}