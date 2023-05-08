import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacePredictions {
  late String secondaryText;
  late String mainText;
  late String placeId;

  PlacePredictions(
      {required this.secondaryText,
      required this.mainText,
      required this.placeId});

  PlacePredictions.fromJson(Map<String, dynamic> json) {
    placeId = json["place_id"] ?? "";
    mainText = json["structured_formatting"]["main_text"] ?? "";
    secondaryText = json["structured_formatting"]["secondary_text"] ?? "";
  }

  static Future<List<PlacePredictions>> getPlacePredictions(String input) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=AIzaSyAT8pCVh8o7Q9IoYxBRJ7WJ3ndmw1NZCAk&sessiontoken=1234567890';
    var response = await http.get(Uri.parse(url));
    List<PlacePredictions> predictions = [];
    if (response.statusCode == 200) {
      var jsonResult = jsonDecode(response.body);
      if (jsonResult['predictions'] != null) {
        for (var prediction in jsonResult['predictions']) {
          predictions.add(PlacePredictions.fromJson(prediction));
        }
      }
    } else {
      throw Exception('Failed to load predictions');
    }
    return predictions;
  }
}
