import 'package:flutter/material.dart';
import '../config/app_config.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';


class SettingsPage extends StatelessWidget {
  Future<void> escolherLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      AppConfig.logoPath = image.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personalização")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: () {
                AppConfig.primaryColor = Colors.pink;
                AppConfig.buttonColor = Colors.pinkAccent;

                Navigator.pop(context, true); // 👈 IMPORTANTE
              },
              child: Text("Tema Rosa"),
            ),

            ElevatedButton(
              onPressed: () async {
                await escolherLogo();
                Navigator.pop(context, true);
              },
              child: Text("Escolher Logo"),
            ),

            ElevatedButton(
                onPressed: () {
                  AppConfig.primaryColor = Colors.blue;
                  AppConfig.buttonColor = Colors.blueAccent;

                  Navigator.pop(context, true); // 👈 IMPORTANTE
                },
              child: Text("Tema Azul"),
            ),
          ],
        ),
      ),
    );
  }
}