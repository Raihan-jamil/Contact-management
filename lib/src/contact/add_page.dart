
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:contact_management/src/home/home_bloc.dart';
import 'package:contact_management/src/home/home_module.dart';
import 'package:contact_management/src/shared/repository/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masked_text/masked_text.dart';

import '../app_module.dart';

class AddPage extends StatefulWidget {
  static String tag = 'add-page';
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _cName = TextEditingController();
  final _cNickName = TextEditingController();
  final _cWork = TextEditingController();
  final _cPhoneNumber = TextEditingController();
  final _cEmail = TextEditingController();
  final _cWebSite = TextEditingController();
  late HomeBloc bloc;
  late ContactRepository contactRepository;
  Uint8List? _bytesImage;
  XFile? _image;
  String?  base64Image;

  @override
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    contactRepository = AppModule.to.getDependency<ContactRepository>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextFormField inputName = TextFormField(
      controller: _cName,
      autofocus: true,
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(45),
      ],
      decoration: InputDecoration(
        labelText: 'Name',
        icon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Mandatory';
        }
        return null;
      },
    );

    TextFormField inputNickName = TextFormField(
      controller: _cNickName,
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(25),
      ],
      decoration: InputDecoration(
        labelText: 'Surname',
        icon: Icon(Icons.person),
      ),
    );

    TextFormField inputWork = TextFormField(
      controller: _cWork,
      inputFormatters: [
        LengthLimitingTextInputFormatter(45),
      ],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Job',
        icon: Icon(Icons.work),
      ),
    );

    MaskedTextField inputPhoneNumber = new MaskedTextField(
      maskedTextFieldController: _cPhoneNumber,
      mask: "(xxx0) xxxx-xxxxxx",
      maxLength: 16,
      keyboardType: TextInputType.phone,
      inputDecoration: new InputDecoration(
        labelText: "Mobile",
        icon: Icon(Icons.phone),
      ),
    );

    TextFormField inputEmail = TextFormField(
      controller: _cEmail,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'E-mail',
        icon: Icon(Icons.email),
      ),
    );

    TextFormField inputWebSite = TextFormField(
      controller: _cWebSite,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Website',
        icon: Icon(Icons.web),
      ),
    );

    final picture = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: [
            _image != null? CircleAvatar(
              radius: 70,
              backgroundImage: new FileImage(File(_image!.path))
              /*Image.file(
                File(_image!.path),
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),*/
            ):
            CircleAvatar(
              radius: 75,
              backgroundColor: Colors.grey.shade200,
              child: CircleAvatar(
                radius: 70,
                child: Icon(
                  Icons.person,
                  size: 80,
                ),)
            ),
            Positioned(
              bottom: 1,
              right: 1,
              child: GestureDetector(
                onTap:() {
                  _showPicker(context);
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(Icons.add_a_photo, color: Colors.black),
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          50,
                        ),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(2, 4),
                          color: Colors.black.withOpacity(
                            0.3,
                          ),
                          blurRadius: 3,
                        ),
                      ]),
                ),
              ),
            ),
          ],
        )
       /* Container(
          width: 120.0,
          height: 120.0,
          child: CircleAvatar(
            child: Icon(
              Icons.camera_alt,
            ),
          ),
        ),*/
      ],
    );

    ListView content = ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        SizedBox(height: 20),
        picture,
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              inputName,
              inputNickName,
              inputWork,
              inputPhoneNumber,
              inputEmail,
              inputWebSite,
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("Create new contact"),
        actions: <Widget>[
          Container(
            width: 80,
            child: IconButton(
              icon: Text(
                'TO SAVE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  contactRepository.insert({
                    'name': _cName.text,
                    'nickName': _cNickName.text,
                    'work': _cWork.text,
                    'phoneNumber': _cPhoneNumber.text,
                    'email': _cEmail.text,
                    'webSite': _cWebSite.text,
                    'favorite': 0,
                    'created': DateTime.now().toString(),
                    'image':base64Image
                  }).then((saved) {
                    bloc.getListContact();
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          )
        ],
      ),
      body: content,
    );
  }
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    print('capturing image from camera');
    var pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        // List<int> imageBytes = await _image!.readAsBytes();
        // String base64Image = base64Encode(imageBytes);
        // print(imageBytes);
        //base64Image = base64Encode(imageBytes);
        _addImageasObject();
      });
    } else
      print('no image selected from camera');
  }
  _addImageasObject() async {
    List<int> imageBytes = await _image!.readAsBytes();
    base64Image = base64Encode(imageBytes);
    print(base64Image);
  }

  _imgFromGallery() async {
    print('selecting image from gallery');
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _addImageasObject();
      });
    } else
      print('no image selected from gallery');

    print("path: ");
    print(_image);
  }
}
