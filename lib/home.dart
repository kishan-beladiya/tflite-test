import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? image;
  String confidence = '';
  String result = '';

  Future _openGallery(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final imageTemporary = File(image.path);

    setState(() => {this.image = imageTemporary, doImageClassification()});

    Navigator.of(context).pop();
  }

  Future _openCamera(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final imageTemporary = File(image.path);

    setState(() => {this.image = imageTemporary, doImageClassification()});

    Navigator.of(context).pop();
  }

  doImageClassification() async {
    var recognitions = await Tflite.runModelOnImage(
      path: image!.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      confidence = recognitions![0]['confidence'].toString();
      result = recognitions[0]['label'].toString();
    });

    print(recognitions);
    print(recognitions![0]['confidence']);
    print(recognitions[0]['label']);
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Make a Choice'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: const Text("Gallery"),
                    onTap: () {
                      _openGallery(ImageSource.gallery);
                    },
                  ),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: const Text("Open Camera"),
                    onTap: () {
                      _openCamera(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(model: "assets/model.tflite", labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add & Test Sample')),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Spacer(),
              image != null
                  ? Image.file(
                      image!,
                      width: 350,
                      height: 350,
                      fit: BoxFit.cover,
                    )
                  : const Text("No Image Selected"),
              ElevatedButton(
                onPressed: () {
                  _showChoiceDialog(context);
                },
                child: const Text('Select Image'),
              ),
              Spacer(),
              image != null?
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('result: $result'),
                  SizedBox(width: 16),
                  Text('confidence: $confidence'),
                ],
              ):
              SizedBox.shrink(),
              Spacer(),
              Divider(),
              ElevatedButton(
                onPressed: () {
                  doImageClassification();
                },
                child: const Text("Analyse the Image "),
              )
            ],
          ),
        ),
      ),
    );
  }
}
