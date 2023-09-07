import 'dart:io';

import 'package:create_custom_pdf/controller.dart';
import 'package:create_custom_pdf/view_created_pdf.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:reorderables/reorderables.dart';

import 'package:pdf/widgets.dart' as pw;

class CreatePdfPage extends StatefulWidget {
  const CreatePdfPage({
    super.key,
    required this.controller,
  });
  final CreatePdfController controller;

  @override
  State<CreatePdfPage> createState() => _CreatePdfPageState();
}

class _CreatePdfPageState extends State<CreatePdfPage> {
  void _onReorder(int oldIndex, int newIndex) {
    widget.controller.files.insert(newIndex, widget.controller.files.removeAt(oldIndex));
  }

  @override
  void initState() {
    widget.controller.files.clear();
    for (var item in widget.controller.finalFiles) {
      widget.controller.files.add(File(item.path));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 20,
        automaticallyImplyLeading: true,
        title: const Text("Create Pdf"),
        actions: [
          Obx(() => widget.controller.files.isEmpty
              ? const SizedBox.shrink()
              : Padding(
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
                      createPdf(context);
                    },
                    child: Text(
                      "Create pdf",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )),
        ],
      ),
      body: Padding(
        // padding: const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 10),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Theme.of(context).secondaryHeaderColor,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "If you want to creating a pdf then create by selecting images.\n",
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: const <TextSpan>[
                          TextSpan(
                              text: ' DRAG and DROP ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: 'to rearrange the images.'),
                        ],
                      ),
                    )),
              ),
              SizedBox(
                height: (width / (2.8 * 5)),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Obx(
                  () => ReorderableWrap(
                      alignment: WrapAlignment.start,
                      direction: Axis.horizontal,
                      maxMainAxisCount: 2,
                      minMainAxisCount: 2,
                      spacing: (width / (2.8 * 4)),
                      runSpacing: (width / (2.8 * 4)),
                      padding: const EdgeInsets.all(8),
                      onReorder: _onReorder,
                      footer: GestureDetector(
                        onTap: () {
                          widget.controller.pickImages();
                        },
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight: width / 2.8,
                              minHeight: width / 2.8,
                              maxWidth: width / 2.8,
                              minWidth: width / 2.8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      children: widget.controller.files
                          .map(
                            (file) => GestureDetector(
                              onTap: () {
                                showDialog(
                                  useSafeArea: false,
                                  context: context,
                                  builder: (context) {
                                    return Scaffold(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      appBar: AppBar(
                                        backgroundColor: Theme.of(context).primaryColor,
                                        automaticallyImplyLeading: true,
                                        title: Text(
                                          basename(file.path),
                                        ),
                                      ),
                                      body: Center(
                                          child: PhotoView(
                                        backgroundDecoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                        ),
                                        imageProvider: FileImage(file),
                                      )),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                constraints: BoxConstraints(
                                    maxHeight: width / 2.8,
                                    minHeight: width / 2.8,
                                    maxWidth: width / 2.8,
                                    minWidth: width / 2.8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(file),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    onPressed: () {
                                      widget.controller.removeImage(file.path);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createPdf(BuildContext context) async {
    {
      final pdf = pw.Document();
      for (var i = 0; i < widget.controller.files.length; i++) {
        pdf.addPage(
          pw.MultiPage(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            footer: (context) => pw.Center(
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                  pw.Text("Bimir codes", style: pw.Theme.of(context).header1),
                  pw.Text("${i + 1}", style: pw.Theme.of(context).header3),
                ])),
            build: (pw.Context contextt) => [
              pw.Center(
                child: pw.Image(
                    pw.MemoryImage(
                      File(widget.controller.files[i].path).readAsBytesSync(),
                    ),
                    height: 650),
              )
            ],
          ),
        );
      }

      try {
        final output = await getTemporaryDirectory();
        var id = DateTime.now().toString().split(' ');
        final file = File('${output.path}/${id[0]}_${id[1]}_notes.pdf');
        await file.writeAsBytes(await pdf.save());
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreatedPdf(
                controller: widget.controller,
                file: file,
              ),
            ),
          );
        }
      } catch (_) {}
    }
  }
}
