import 'dart:convert';

class PostProcessor {
  static Map<int, double> getTopK(List<double> values, int topK) {
    var probabilities = Map<int, double>.fromEntries(values.asMap().entries);
    var sortedEntries = probabilities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var topKresults = sortedEntries.take(topK);
    return Map<int, double>.fromEntries(topKresults);
  }

  static Map<int, double> postTagProcessor(
      var predictions, bool imagenet, String tag) {
    Map<int, double> processedPredictions = {};
    var listPredictions = jsonDecode(predictions);
    if (imagenet == true) {
      Map<int, double> resultMap = {};
      listPredictions.forEach((map) {
        int index = map["index"];
        double score = double.parse(map["score"].toStringAsFixed(2));
        resultMap[index] = score;
      });
      processedPredictions = resultMap;
    } else if (tag == "classification") {
      List<double> listDoublePredictions = List<double>.from(listPredictions);
      processedPredictions = PostProcessor.getTopK(listDoublePredictions, 5);
    }
    return processedPredictions;
  }
}
