import 'package:image_picker/image_picker.dart';

class UpdateImage {
  void onProfileTapped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
  }
}
