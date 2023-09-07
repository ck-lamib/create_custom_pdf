import 'dart:io';

import 'package:create_custom_pdf/controller.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CreatedPdf extends StatelessWidget {
  const CreatedPdf({super.key, required this.controller, required this.file});
  final CreatePdfController controller;
  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Save pdf?"),
                        content: const Text("Are you sure you want to create the pdf?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              //call save final pdf.
                              controller.finalFiles.clear();
                              controller.finalFiles.add(File(file.path));
                              print(file.path);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Save pdf",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ]),
      body: Center(
        child: SfPdfViewer.file(
          file,
          pageSpacing: 0,
          enableTextSelection: false,
        ),
      ),
    );
  }
}
