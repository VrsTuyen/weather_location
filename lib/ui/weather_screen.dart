import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_location/app_asset/font_asset.dart';
import 'package:weather_location/models/constants.dart';
import 'package:weather_location/repository/weather_item.dart';
import 'package:weather_location/ui/detail_page.dart';
import 'package:weather_location/values/city_name.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WeatherState();
}

class _WeatherState extends State<WeatherScreen> {
  Constants myConstants = Constants();
  int temp = 0;
  int maxTemp = 0;
  int minTemp = 0;
  String weatherStateName = 'Loading...';
  int humidity = 0;

  String currentDate = "Loading...";
  String imageUrl = "";
  double windSpeed = 0;
  int woeid = 0;
  String locationMS = "";
  double speed = 0;
  String city = "Loading...";
  String value = "";
  List consolidatedWeatherList = [];
  var id;
  var lat;
  var long;

  final String _key = "f09068712f780c42148be08d5bb99c37";
  //   static const String _key = '3293b83dd1aed750355ca3c341eae9a2';

  Future<String> getCurrentLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.requestPermission();
    if (isLocationServiceEnabled == false) {
      Geolocator.requestPermission();
    }
    try {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      lat = position.latitude;
      long = position.longitude;
    } catch (e) {
      throw Geolocator.getLastKnownPosition();
    }

    var lastPositon = Geolocator.getLastKnownPosition();

    setState(() {
      print(lat);
      locationMS = 'lat=$lat&lon=$long';
      print('location: $locationMS');
    });
    return locationMS;
  }

  void getData() async {
    // print(locationMS);
    http.Response response = await http.get(Uri.parse(
        '${GetCityname.baseURL}$locationMS&appid=$_key&lang=vi&units=metric'));
    var data = jsonDecode(response.body);
    id = data['id'];
    response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?$locationMS&appid=$_key&lang=vi&units=metric'));
    try {
      var result = jsonDecode(response.body);
      var list = result['list'];
      var consolidatedWeather = await result['list'];
      setState(() {
        for (int i = 0; i < list.length; i++) {
          if (i % 8 == 0) {
            consolidatedWeather.add(consolidatedWeather[i]);
          }
        }
        temp = consolidatedWeather[0]['main']['temp'].round();
        weatherStateName =
            consolidatedWeather[0]['weather'][0]['description'].toUpperCase();
        humidity = consolidatedWeather[0]['main']['humidity'].round();
        windSpeed = consolidatedWeather[0]['wind']['speed'];
        maxTemp = consolidatedWeather[0]['main']['temp_max'].round();
        minTemp = consolidatedWeather[0]['main']['temp_min'].round();
        imageUrl = consolidatedWeather[0]['weather'][0]['main']
            .replaceAll(' ', '')
            .toLowerCase();
        city = result['city']['name'];
        consolidatedWeatherList = consolidatedWeather.toSet().toList();

        DateTime myDate = DateTime.now();
        currentDate = DateFormat('EEEE, d MMMM').format(myDate);
      });
    } catch (e) {
      getData();
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    getData();
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Container(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontFamily.helveticaNeue),
              ),
              Text(
                currentDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: size.width,
                height: 200,
                decoration: BoxDecoration(
                    color: myConstants.primaryColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: myConstants.primaryColor.withOpacity(.5),
                          offset: const Offset(0, 25),
                          blurRadius: 10,
                          spreadRadius: -12)
                    ]),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -40,
                      left: 10,
                      child: imageUrl == ''
                          ? const Text('')
                          : Image.asset(
                              'assets/images/$imageUrl.png',
                              width: 150,
                            ),
                    ),
                    Positioned(
                      child: Text(
                        weatherStateName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      bottom: 30,
                      left: 20,
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              temp.toString(),
                              style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()..shader = linearGradient),
                            ),
                          ),
                          Text('o',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = linearGradient,
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WeatherItem(
                      value: windSpeed,
                      text: 'Tốc độ gió',
                      unit: ' m/s',
                      imageUrl: 'assets/images/windspeed.png',
                      humidity: 0,
                    ),
                    WeatherItem(
                      value: 0,
                      text: 'Độ ẩm',
                      unit: ' %',
                      imageUrl: 'assets/images/humidity.png',
                      humidity: humidity,
                    ),
                    WeatherItem(
                      value: 0,
                      text: 'Cao nhất',
                      unit: ' ºC',
                      imageUrl: 'assets/images/max-temp.png',
                      humidity: maxTemp,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DetailPage(
                                    consolidatedWeatherList:
                                        consolidatedWeatherList,
                                    selectedId: 0,
                                    location: city,
                                  )));
                    },
                    child: Text(
                      'Next 5 Days',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: myConstants.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    String Today = DateTime.now().toString().substring(0, 10);
                    var selectedDay = consolidatedWeatherList[index]['dt_txt'];
                    var futureWeatherName =
                        consolidatedWeatherList[index]['weather'][0]['main'];
                    var weatherUrl =
                        futureWeatherName.replaceAll(' ', '').toLowerCase();
                    var parsedDate = DateTime.parse(
                        consolidatedWeatherList[index]['dt_txt']);

                    var newDate =
                        DateFormat('EEEE').format(parsedDate).substring(0, 3);
                    var newHour = consolidatedWeatherList[index]['dt_txt']
                        .substring(11, 13);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                      consolidatedWeatherList:
                                          consolidatedWeatherList,
                                      selectedId: index,
                                      location: city,
                                    )));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        margin: const EdgeInsets.only(
                            right: 20, bottom: 10, top: 10),
                        width: 80,
                        decoration: BoxDecoration(
                          color: selectedDay == Today
                              ? myConstants.primaryColor
                              : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 1),
                              blurRadius: 5,
                              color: selectedDay == Today
                                  ? myConstants.primaryColor
                                  : Colors.black54.withOpacity(.2),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              consolidatedWeatherList[index]['main']['temp']
                                      .round()
                                      .toString() +
                                  "ºC",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: selectedDay == Today
                                      ? Colors.white
                                      : myConstants.primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            Image.asset(
                              'assets/images/' + weatherUrl + '.png',
                              width: 30,
                            ),
                            Text(
                              newHour + ' H',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: selectedDay == Today
                                      ? Colors.white
                                      : myConstants.primaryColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              newDate,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: selectedDay == Today
                                      ? Colors.white
                                      : myConstants.primaryColor,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: consolidatedWeatherList.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
