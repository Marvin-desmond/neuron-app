import 'package:flutter_native/global.dart';

class DownloadProgress extends StatefulWidget {
  const DownloadProgress(
      {super.key,
      required this.name,
      required this.url,
      this.updateData,
      this.closeProgress});
  final String name;
  final String url;
  final Function()? updateData;
  final Function()? closeProgress;

  @override
  State<DownloadProgress> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  double downloadProgress = 0;
  int receivedBytes = 0;
  int totalBytes = 0;

  downloadFile(String name, String url, BuildContext context) {
    setState(() {
      downloadProgress = 0;
    });

    getRemoteFile(name, url).then((result) {
      if (result.download) {
        getFileFromName(name).then((file) {
          getFileDownload(file, url, (received, total, progress) {
            setState(() {
              receivedBytes = received;
              totalBytes = total;
              downloadProgress = progress;
            });
            if (progress >= 1.0) {
              setState(() {
                if (widget.closeProgress != null) {
                  widget.closeProgress!();
                }
                if (widget.updateData != null) {
                  widget.updateData!();
                }
              });
            }
          });
        });
      } else {}
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text(result.message),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {},
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext context = this.context;
      downloadFile(widget.name, widget.url, context);
    });
    print("DOWNLOAD PROGRESS INIT");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: downloadProgress,
                  ),
                ),
              ),
              Text(
                "${(downloadProgress * 100).toInt()}%...",
                style:
                    const TextStyle(fontSize: 18.0, fontFamily: "IBMPlexMono"),
              )
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 8.0),
              child: Text(
                getSizeInMB(receivedBytes),
                style: const TextStyle(
                    fontFamily: 'SourceSansPro', fontSize: 18.0),
              ))
        ],
      ),
    );
  }
}
