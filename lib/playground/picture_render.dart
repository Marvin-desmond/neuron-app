part of 'model_playground.dart';

class PictureRender extends StatelessWidget {
  const PictureRender({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        border: Border.all(width: 1.0, color: const Color(0xFFF3F4F6)),
        color: const Color(0xFFFEFEFE),
      ),
      child: Image.network(
        "https://pbs.twimg.com/media/Fw3iyY-aUAEuC6w?format=jpg&name=large",
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
      ),
    );
  }
}
