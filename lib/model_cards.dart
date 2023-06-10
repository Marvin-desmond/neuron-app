import 'package:flutter_native/global.dart';

class ModelCards extends StatelessWidget {
  ModelCards({super.key});

  final List<InputCard> cards = [
    InputCard("assets/cards/classification.png", "Image Classification",
        "classification"),
    InputCard("assets/cards/detection.png", "Image Detection", "detection"),
    InputCard(
        "assets/cards/segmentation.png", "Image Segmentation", "segmentation")
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(15.0),
          decoration: const BoxDecoration(
            color: Color(0XFFFAFDFE),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 20),
                  child: Text(
                    "Computer vision",
                    style:
                        TextStyle(fontSize: 35.0, fontFamily: 'SourceSansPro'),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                          // width: MediaQuery.of(context).size.width * 0.7,
                          width: MediaQuery.of(context).size.width * 1.0,
                          child: const Text(
                            "This section is the playground for Vision models for TensorFlow and PyTorch",
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'SourceSansPro'),
                          )),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: GridView.builder(
                    itemCount: cards.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 15.0,
                      crossAxisSpacing: 15.0,
                      childAspectRatio: 0.8,
                      crossAxisCount: 2,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                            ScreenPaths.modelPlayground,
                            queryParameters: {
                              'icon': cards[index].cardIcon,
                              'tag': cards[index].tag,
                              'playground': cards[index].cardName
                            });
                      },
                      child: ModelCard(
                          icon: cards[index].cardIcon,
                          name: cards[index].cardName),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.pop();
          },
          child: const Icon(Icons.skip_previous),
        ),
      ),
    );
  }
}

class ModelCard extends StatelessWidget {
  final String icon;
  final String name;
  const ModelCard({super.key, required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(width: 1.0, color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8.0,
            spreadRadius: 1.0,
          )
        ],
      ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 35.0),
          Image.asset(
            icon,
            width: 40.0,
            height: 40.0,
          ),
          const SizedBox(height: 15.0),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 21.0,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SourceSansPro'),
            ),
          ),
        ],
      ),
    );
  }
}

class InputCard {
  final String cardIcon;
  final String cardName;
  final String tag;
  InputCard(this.cardIcon, this.cardName, this.tag);
}
