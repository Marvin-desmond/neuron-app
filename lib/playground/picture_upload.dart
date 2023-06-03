part of './model_playground.dart';

class PictureUpload extends StatefulWidget {
  const PictureUpload(
      {Key? key, required this.widget, required this.setImagePicked})
      : super(key: key);
  final Function(XFile?) setImagePicked;

  final ModelPlayground widget;

  @override
  State<PictureUpload> createState() => _PictureUploadState();
}

class _PictureUploadState extends State<PictureUpload> {
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        XFile? image = await picker.pickImage(source: ImageSource.gallery);
        widget.setImagePicked(image);
      },
      child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white),
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            const Text(
              "Click to upload",
              style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic),
            ),
            Positioned(
                top: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(7.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 2.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.widget.icon,
                        width: 25.0,
                      ),
                      const SizedBox(width: 5.0),
                      const Text("Image file"),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
