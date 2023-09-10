import 'dart:io';

import 'package:create_custom_pdf/extensionn.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePdfController extends GetxController {
  RxBool isSaveButtonLoading = false.obs;
  List<String> allowedFileExtension = ['png', 'jpg', 'jpeg', 'pdf'];
  final RxBool _loading = false.obs;
  bool get loading => _loading.value;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController fileNameController = TextEditingController(text: "custom_pdf");

  //for picking files
  final RxList<File> _finalFiles = <File>[].obs;
  List<File> get finalFiles => _finalFiles;
  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedFileExtension,
    );
    List<File> pickedFiles = [];
    if (result != null) {
      pickedFiles = result.paths.map((path) => File(path!)).toList();
    }

    for (var item in pickedFiles) {
      if (allowedFileExtension.contains(item.path.getFileExtension())) {
        _finalFiles.add(File(item.path));
      }
    }
  }

  removeFinalFiles(String path) {
    _finalFiles.removeWhere((element) => element.path == path);
  }

  //for picking images
  final RxList<File> _files = <File>[].obs;
  List<File> get files => _files;
  pickImages() async {
    ImagePicker imagePicker = ImagePicker();
    List<XFile> files = await imagePicker.pickMultiImage();
    for (var item in files) {
      _files.add(File(item.path));
    }
  }

  removeImage(String path) {
    _files.removeWhere((element) => element.path == path);
  }

  Future<String?> pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }

  saveFileToCustomLoaction(String directory) async {
    try {
      var permissionStatus = await Permission.storage.status;
      print(permissionStatus);
      if (permissionStatus.isGranted) {
        final filePath = '$directory/${fileNameController.text}.pdf';
        await File(finalFiles[0].path).copy(filePath);
        return filePath;
      } else {
        print("here");
        // final status = await Permission.manageExternalStorage.request();
        // if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
        //   return null;
        // } else {
        //   final filePath = '$directory/${fileNameController.text}.pdf';
        //   await File(finalFiles[0].path).copy(filePath);
        //   return filePath;
        // }

        final status = await Permission.manageExternalStorage.request();
        // await Permission.storage.request().then((value) async {
        if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
          return null;
        } else {
          final filePath = '$directory/${fileNameController.text}.pdf';
          await File(finalFiles[0].path).copy(filePath);
          return filePath;
        }
        // });
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
