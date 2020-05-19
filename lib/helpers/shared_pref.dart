

/* import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
} */




import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:core';
import 'dart:math';

Future<String> getUserApiKey() async {
  return "123456";
}

Future<void> storeUserApiKey(String apiKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("DEFAULT_KEY", apiKey);
}

Future<String> getUUID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String uuid = prefs.getString("DEFAULT_UUID");
  return uuid;
}

storeUUID(String uuid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("DEFAULT_UUID", uuid.toString());
}

String buildUUID() {
  var uuid = new Uuid();
  String idD = uuid.v1();
  return idD + "_" + randomStr(5);
}

String randomStr(int strLen) {
  const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
  Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  String result = "";
  for (var i = 0; i < strLen; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }
  return result;
}


class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
} 
