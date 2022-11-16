import 'dart:convert';
import 'dart:io';

import 'package:contact_management/src/app_module.dart';
import 'package:contact_management/src/home/home_bloc.dart';
import 'package:contact_management/src/home/home_module.dart';
import 'package:contact_management/src/home/home_page.dart';
import 'package:contact_management/src/shared/repository/contact_repository.dart';
import 'package:contact_management/src/shared/widgets/ContactList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masked_text/masked_text.dart';

class EditPage extends StatefulWidget {
  static String tag = 'edit-page';
  final Map contact;

  EditPage({Key? key, required this.contact}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final _cName = TextEditingController();
  final _cNickName = TextEditingController();
  final _cWork = TextEditingController();
  final _cPhoneNumber = TextEditingController();
  final _cEmail = TextEditingController();
  final _cWebSite = TextEditingController();
  late String imageString;
  XFile? _image;
  String?  base64Image;
  late HomeBloc bloc;
  late ContactRepository contactRepository;
  bool _isCatche = false;

  @override
  void initState() {
    bloc = HomeModule.to.getBloc<HomeBloc>();
    contactRepository = AppModule.to.getDependency<ContactRepository>();
    _cName.text = widget.contact['name'];
    _cNickName.text = widget.contact['nickName'];
    _cWork.text = widget.contact['work'];
    _cPhoneNumber.text = widget.contact['phoneNumber'];
    _cEmail.text = widget.contact['email'];
    _cWebSite.text = widget.contact['webSite'];
    imageString = widget.contact['image'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextFormField inputName = TextFormField(
      controller: _cName,
      inputFormatters: [
        LengthLimitingTextInputFormatter(45),
      ],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Name',
        icon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );

    TextFormField inputNickName = TextFormField(
      controller: _cNickName,
      inputFormatters: [
        LengthLimitingTextInputFormatter(25),
      ],
      keyboardType: TextInputType.text,
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
      mask: "(xxx) xxxxx.xxxx",
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

    Column picture = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: [
            imageString!=null? CircleAvatar(
                radius: 80,
                backgroundImage: MemoryImage(Base64Decoder().convert(imageString))
            ):CircleAvatar(
              child: Text(
                _cName.text.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 26, color: Colors.white60),
              ),
            ),

            _image != null ? CircleAvatar(
                radius: 70,
                backgroundImage: FileImage(File(_image!.path))):Container(),
            Positioned(
              bottom: 1,
              right: 1,
              child: GestureDetector(
                onTap: () {
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
      ],
    );

    ListView body = ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        SizedBox(height: 20),
        picture,
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              inputName,
              inputNickName,
              inputWork,
              inputPhoneNumber,
              inputEmail,
              inputWebSite,
            ],
          ),
        )
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
          title: Text("Edit contact"),
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
                    contactRepository.update(
                      {
                        'name': _cName.text,
                        'nickName': _cNickName.text,
                        'work': _cWork.text,
                        'phoneNumber': _cPhoneNumber.text,
                        'email': _cEmail.text,
                        'webSite': _cWebSite.text,
                        'image': base64Image
                      },
                      widget.contact!['id'],
                    ).then((saved) {
                      Map contact = {
                        'name': _cName.text,
                        'nickName': _cNickName.text,
                        'work': _cWork.text,
                        'phoneNumber': _cPhoneNumber.text,
                        'email': _cEmail.text,
                        'favorite': widget.contact['favorite'],
                        'webSite': _cWebSite.text,
                        'image': imageString,
                      };
                      bloc.setContact(contact);
                      bloc.getListContact();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  HomePage()),
                              (Route<dynamic> route) => route.isFirst);
                    });
                  }
                },
              ),
            )
          ],
        ),
        body: body);
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
        _isCatche = true;
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
