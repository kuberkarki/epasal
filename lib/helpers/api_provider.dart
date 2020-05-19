

import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import '../labelconfig.dart';
import 'shared_pref.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show HttpHeaders, Platform;
import 'package:crypto/crypto.dart' as crypto;

import 'package:http/http.dart' as http;

class QueryString {
  static Map parse(String query) {
    var search = new RegExp('([^&=]+)=?([^&]*)');
    var result = new Map();

    // Get rid off the beginning ? in query strings.
    if (query.startsWith('?')) query = query.substring(1);
    // A custom decoder.
    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    // Go through all the matches and build the result map.
    for (Match match in search.allMatches(query)) {
      result[decode(match.group(1))] = decode(match.group(2));
    }
    return result;
  }
}

class ApiProvider {
  Dio _dio;
  Future _doneFuture;

  Future<DeviceInfoPlugin> userDeviceInfo;
  Map<String, dynamic> deviceMeta = {};

  Future get initializationDone => _doneFuture;

  Future<void> _setDeviceMeta() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String uuid;
    await getUUID().then((val) {
      if (val == null) {
        String uid = buildUUID();
        storeUUID(uid);
        uuid = uid;
      } else {
        uuid = val;
      }
    });

    if (Platform.isAndroid) {
      await deviceInfo.androidInfo.then((androidMeta) {
        deviceMeta = {
          "model": androidMeta.device,
          "brand":
              androidMeta.brand.replaceAll(new RegExp('[^\u0001-\u007F]'), '_'),
          "manufacturer": androidMeta.manufacturer,
          "version": androidMeta.version.baseOS,
          "uuid": uuid
        };
      });
    } else if (Platform.isIOS) {
      await deviceInfo.iosInfo.then((iosMeta) {
        deviceMeta = {
          "model": iosMeta.model,
          "brand": iosMeta.name.replaceAll(new RegExp('[^\u0001-\u007F]'), '_'),
          "manufacturer": "Apple",
          "version": iosMeta.systemVersion,
          "uuid": uuid
        };
      });
    }
  }

  // Future<void> _setHeaderAPI() async {
   
  // }

  ApiProvider() {
    _doneFuture = _init();
  }

  Future _init() async {
    await _setDeviceMeta();
    // await _setHeaderAPI();
  }

  void _printLog(String log) {
    print("DarazPasal LOG: $log");
  }

  getOAuthURL(String requestMethod, String endpoint) {
    // var consumerKey = consumerKey;
    // var consumerSecret = consumerSecret;

    var token = "";
    var url = app_base_url + "/wp-json/wc/v3/" + endpoint;
    var containsQueryParams = url.contains("?");

    // If website is HTTPS based, no need for OAuth, just return the URL with CS and CK as query params
    if (url.startsWith("https")) {
      return url +
          (containsQueryParams == true
              ? "&consumer_key=" + consumerKey + "&consumer_secret=" + consumerSecret
              : "?consumer_key=" + consumerKey + "&consumer_secret=" + consumerSecret);
    }

    var rand = new Random();
    var codeUnits = new List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    var nonce = new String.fromCharCodes(codeUnits);
    int timestamp = (new DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();

    var method = requestMethod;
    var parameters = "oauth_consumer_key=" +
        consumerKey +
        "&oauth_nonce=" +
        nonce +
        "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=" +
        timestamp.toString() +
        "&oauth_token=" +
        token +
        "&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap = new SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString = parameterString + Uri.encodeQueryComponent(key) + "=" + treeMap[key] + "&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);

    var baseString = method +
        "&" +
        Uri.encodeQueryComponent(containsQueryParams == true ? url.split("?")[0] : url) +
        "&" +
        Uri.encodeQueryComponent(parameterString);

    var signingKey = consumerSecret + "&" + token;

    var hmacSha1 = crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1
    var signature =hmacSha1.convert(utf8.encode(baseString));

    var finalSignature = base64Encode(signature.bytes);

    var requestUrl = "";

    if (containsQueryParams == true) {
      requestUrl = url.split("?")[0] +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    } else {
      requestUrl = url +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    }

//    print('network: $requestUrl');

    return requestUrl;
  }

  Future<dynamic> post(String url,data) async {
    // var url = this.getOAuthURL("GET", data['path']+'?page='+data['payload']['page'].toString());
    var url = this.getOAuthURL("GET", data['path']);
    // print(url);
    //  var uri =Uri.http(url,'',);
    //  final newURI = url.replace(queryParameters: data['payload']);
  
    final response = await http.get(Uri.encodeFull(url));
    // print(response.body);
    return json.decode(response.body);
  }

  Future<dynamic> postAsync(String endPoint, Map data) async {
    var url = this.getOAuthURL("POST", endPoint);

    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.contentTypeHeader] = 'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = "no-cache";
    request.body = json.encode(data);
    var response = await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);
    return dataResponse;
  }

  // POST
  Future<dynamic> post1(url, data) async {
    // print(data);
    try {
      //  String username = consumerKey;
        // String password = consumerSecret;
        // var auth = 'Basic '+base64Encode(utf8.encode('$username:$password'));
        // BaseOptions options = new BaseOptions(baseUrl: 'https://localhost/globdig/wp/wp-json/wc/v2/', headers: {
        //   // "Authorization": "Bearer 123456" ,
        //   'Authorization': auth,
        //   "Content-Type": "application/json",
        //   // "X-DMETA": json.encode(deviceMeta).toString()
        // });
        //  BaseOptions options = new BaseOptions(baseUrl: app_base_url);
        this._dio = new Dio();
       var newurl=getOAuthURL(data['type'],data['path']);
      Response response =
          await _dio.get(newurl, queryParameters:data['payload']);
      return response.data;
    } catch (error, stacktrace) {
      _printLog("$error stackTrace: $stacktrace");
      return null;
    }
  }
}