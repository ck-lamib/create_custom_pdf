import 'package:create_custom_pdf/controller.dart';
import 'package:create_custom_pdf/create_pdf.dart';
import 'package:create_custom_pdf/custom_snackbar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final CreatePdfController c = Get.put(CreatePdfController());

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create Pdf Demo"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SafeArea(
            child: SizedBox(
              child: Center(
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          color: Theme.of(context).secondaryHeaderColor,
                          child: Text(
                            "Create your custom Pdf",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                    ),
                    SizedBox(
                      height: height / 20,
                    ),
                    DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: const [8, 2, 8, 8],
                      radius: const Radius.circular(12),
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: SizedBox(
                          height: height / 3,
                          width: width / 2,
                          child: Obx(
                            () => c.finalFiles.isEmpty
                                ? InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => CreatePdfPage(
                                            controller: c,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 40,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        useSafeArea: false,
                                        context: context,
                                        builder: (context) {
                                          return Scaffold(
                                            appBar: AppBar(
                                                backgroundColor: Theme.of(context).primaryColor,
                                                automaticallyImplyLeading: true,
                                                title: Text(
                                                  basename(c.finalFiles[0].path),
                                                )),
                                            body: Center(
                                              child: SfPdfViewer.file(
                                                c.finalFiles[0],
                                                pageSpacing: 0,
                                                enableTextSelection: false,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: const DecorationImage(
                                          image: AssetImage('assets/pdf_file_icon.png'),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Obx(
                      () => c.finalFiles.isEmpty
                          ? const SizedBox.shrink()
                          : ElevatedButton(
                              onPressed: () {
                                c.finalFiles.clear();
                              },
                              child: const Text("Delete pdf"),
                            ),
                    ),
                    SizedBox(
                      height: height / 50,
                    ),
                    Obx(
                      () => c.finalFiles.isEmpty
                          ? const SizedBox.shrink()
                          : c.isSaveButtonLoading.value
                              ? ElevatedButton(
                                  onPressed: () {},
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(8.0),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: () async {
                                    await savePdfFile(context);
                                  },
                                  child: const Text("Save pdf to file location"),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> savePdfFile(BuildContext context) async {
    {
      c.isSaveButtonLoading.value = true;
      String? directoryPath = await c.pickDirectory();
      bool reNameSuccess = false;
      if (context.mounted && directoryPath != null) {
        try {
          reNameSuccess = await showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              "Enter the name of file",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Form(
                              key: c.formKey,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: c.fileNameController,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text("Cancel")),
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text("Save File"))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } catch (e) {
          reNameSuccess = false;
        }
      }
      if (reNameSuccess) {
        //save file.
        String? finalPath = await c.saveFileToCustomLoaction(directoryPath!);
        if (finalPath == null) {
          CustomSnackBar.error(
            title: "Failed",
            message: "Failed to save pdf.",
          );
        } else {
          c.finalFiles.clear();
          c.files.clear();
          CustomSnackBar.success(
            title: "Save pdf success",
            message: "The file is successfully saved to: $finalPath",
          );
        }
      } else {
        CustomSnackBar.error(
          title: "Failed",
          message: "Failed to save pdf.",
        );
      }
      c.isSaveButtonLoading.value = false;
    }
  }
}
