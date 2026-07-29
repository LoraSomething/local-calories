import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_ai_calorie_app/model/food.dart';
import 'package:local_ai_calorie_app/services/database_service.dart';
import 'package:local_ai_calorie_app/services/image_picker_service.dart';
import 'package:local_ai_calorie_app/services/local_ai_service.dart';
import 'package:local_ai_calorie_app/widgets/reusables/app_loading.dart';
import 'package:local_ai_calorie_app/widgets/food_modal.dart';
import 'package:local_ai_calorie_app/widgets/reusables/app_notification.dart';
import 'package:local_ai_calorie_app/widgets/reusables/text_input_dialog.dart';

class FoodAddButton extends StatefulWidget {
  const FoodAddButton({super.key, required this.onFoodAdded});
  
  final VoidCallback onFoodAdded;

  @override
  State<FoodAddButton> createState() => _FoodAddButtonState();
}

class _FoodAddButtonState extends State<FoodAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOut,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) { _controller.forward(); } 
      else { _controller.reverse(); }
    });
  }

  final ImagePickerService _pickerService = ImagePickerService();

  void manualInsert() async {
    Food? newFood = await showDialog<Food>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => FoodModal(foodToEdit: null),
    );
    if (newFood != null)
    {
      await DatabaseHelper.instance.insertFood(newFood);
      widget.onFoodAdded();
    }
}

  void getLocalAiAnswerFromImage(ImageSource imageSource) async {
    Food? food;

    try {

      final InferenceModel? inferenceModel = await LocalAiService.getInferenceModel(true);
      if (inferenceModel == null) return;

      final File? croppedImage = await _pickerService.pickAndCropImage(context, imageSource);
      if (croppedImage == null) return;

      LoadingDialog.show(context, message: 'Processing image...');

      final Uint8List imageBytes = await croppedImage!.readAsBytes();
      final nutritionalValuesJson = await LocalAiService.getLabelValuesFromImage(inferenceModel!, imageBytes);

      Map<String, dynamic> jsonMap = jsonDecode(nutritionalValuesJson);
      food = Food.fromJson(jsonMap);

    } catch (e) {
        AppNotification.showError('Something went wrong: ${e.toString()}');
    } finally {
      LoadingDialog.hide();
    }

    if (food != null){
      Food? newFood = await showDialog<Food>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => FoodModal(foodToEdit: food),
      );
      if (newFood != null)
      {
        await DatabaseHelper.instance.insertFood(newFood);
        widget.onFoodAdded();
      }
    }
  }


  void getLocalAiAnswerFromText() async {
    Food? food;
    String? result;

    try {

      final InferenceModel? inferenceModel = await LocalAiService.getInferenceModel(true);
      if (inferenceModel == null) return;

      result = await InputDialog.show(
        context,
        title: 'Edit Prompt',
        hintText: 'Enter a single food name, without grams, with a lot of details',
        minLines: 5,
      );

      if (result == null || !result.isNotEmpty) {
        return;
      }
      
      LoadingDialog.show(context, message: 'Processing text...');
      final nutritionalValuesJson = await LocalAiService.getEstimatedValuesFromText(inferenceModel, result);
      Map<String, dynamic> jsonMap = jsonDecode(nutritionalValuesJson);
      food = Food.fromJson(jsonMap);

    } catch (e) {
        AppNotification.showError('Something went wrong: ${e.toString()}');
    } finally {
      LoadingDialog.hide();
    }

    if (food != null){
      food.name = result!;
      Food? newFood = await showDialog<Food>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => FoodModal(foodToEdit: food),
      );
      if (newFood != null)
      {
        await DatabaseHelper.instance.insertFood(newFood);
        widget.onFoodAdded();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Render the 4 child buttons stacked above the main FAB
          if (_isOpen) ...[
            _buildChildFab(
              icon: Icons.camera,
              label: 'AI Text',
              onPressed: () => getLocalAiAnswerFromText(),
            ),
            _buildChildFab(
              icon: Icons.photo_library,
              label: 'AI Gallery',
              onPressed: () => getLocalAiAnswerFromImage(ImageSource.gallery),
            ),
            _buildChildFab(
              icon: Icons.camera_alt,
              label: 'AI Camera',
              onPressed: () => getLocalAiAnswerFromImage(ImageSource.camera),
            ),
            _buildChildFab(
              icon: Icons.edit,
              label: 'Manual',
              onPressed: () => manualInsert(),
            ),
          ],
          const SizedBox(height: 12),
          // Main Floating Action Button
          FloatingActionButton(
            onPressed: _toggle,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.125).animate(_expandAnimation),
              child: const Icon(Icons.add),
            ),
          ),
        ],
    );
  }

  Widget _buildChildFab({required IconData icon, required String label ,required VoidCallback onPressed}) {
    return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: ScaleTransition(
      scale: _expandAnimation,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Separate text card next to the round FAB
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              _toggle();
              onPressed();
            },
            child: Icon(icon),
          ),
        ],
      ),
    ),
  );
  }

}