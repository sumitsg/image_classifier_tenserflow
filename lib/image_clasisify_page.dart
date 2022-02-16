import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
// import 'package:tflite/tflite.dart';

class ImageClassifierPage extends StatefulWidget {
  const ImageClassifierPage({Key? key}) : super(key: key);

  @override
  _ImageClassifierPageState createState() => _ImageClassifierPageState();
}

class _ImageClassifierPageState extends State<ImageClassifierPage> {
  List _output = [];
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
      numThreads: 1,
    );

    // final interpreter = await tfl.Interpreter.fromAsset('model_unquant.tflite');
  }

  // ! image classifying here
  classifyImage(File? image) async {
    var output = await Tflite.runModelOnImage(
      path: image!.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.6,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      _output = output!;
      print(output);
    });
  }

  // ! picking image from gallery
  pickImage() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
      _loading = false;
    });
    classifyImage(_image);
  }

  // ! picking image from gallery
  clickImage() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
      _loading = false;
    });
    classifyImage(_image);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Image Classification ',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loading
                ? Container(
                    child: const CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _image == null
                            ? Container()
                            : Container(
                                height: 500,
                                width: 500,
                                child: Image.file(_image!)),
                        const SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container()
                            : _output != null
                                ? Text(
                                    'This is :- ${_output[0]['label']}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  )
                                : Container(
                                    child: const Text('NO Image'),
                                  ),
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            tooltip: 'Click Image using Camera',
            onPressed: clickImage,
            child: const Icon(
              Icons.add_a_photo_rounded,
              size: 20,
              color: Colors.white,
            ),
            backgroundColor: Colors.purple[400],
          ),
          FloatingActionButton(
            tooltip: 'Pick Image from gallery',
            onPressed: pickImage,
            child: const Icon(
              Icons.folder,
              size: 20,
              color: Colors.white,
            ),
            backgroundColor: Colors.purple[400],
          ),
        ],
      ),
    );
  }
}
