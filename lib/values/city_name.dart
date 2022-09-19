import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class GetCityname {
  static const String _key = 'f09068712f780c42148be08d5bb99c37';
  static String baseURL = 'https://api.openweathermap.org/data/2.5/weather?';

  static Future<String> City(String locationMS) async {
    Response response =
        await http.get(Uri.parse('$baseURL' '$locationMS&appid=$_key'));
    var data = jsonDecode(response.body);
    // print(data['id']);
    response = await http
        .get(Uri.parse('$baseURL' 'id=${data['id']}&appid=$_key&lang=VI'));
    data = jsonDecode(response.body);
    var city = data['name'];
    return city;
  }
}
