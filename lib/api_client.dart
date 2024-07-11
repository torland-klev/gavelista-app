import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gaveliste_app/google_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'data/group.dart';
import 'data/user.dart';
import 'data/wish.dart';

typedef FromJson<T> = dynamic Function(Map<String, dynamic> json);

Future<T> _fromJsonHandler<T>(
    FromJson<T> fromJson, Map<String, dynamic> json) async {
  var result = fromJson(json);
  if (result is Future<T>) {
    return await result;
  } else {
    return result;
  }
}

class ApiClient {
  late final String _baseUrl;
  late final Map<String, String> _headers;

  ApiClient() {
    String? baseUrl = dotenv.env['API_URL'];
    if (baseUrl == null) {
      throw const FormatException("Missing env variable API_URL");
    }
    _baseUrl = baseUrl;
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<Response> login(GoogleSignInAccount? account) async {
    if (account == null) {
      throw const HttpException("Unable to sign in google account");
    }
    GoogleSignInAuthentication auth = await account.authentication;

    Uri uri = Uri.parse("$_baseUrl/appLogin");
    Response res = await http.post(uri,
        headers: _headers, body: jsonEncode(account.toJson(auth.accessToken)));
    if (res.statusCode != 200) {
      throw const HttpException("Unable to create or retrieve user");
    }
    if (auth.accessToken != null) {
      _headers['Authorization'] = "Bearer ${auth.accessToken!}";
      if (kDebugMode) {
        print(auth.accessToken);
      }
    }
    return res;
  }

  Future<List<T>> _fetch<T>(String endpoint, FromJson<T> fromJson) async {
    Uri uri = Uri.parse("$_baseUrl/$endpoint");
    Response res = await http.get(uri, headers: _headers);
    if (res.statusCode != 200) {
      throw const HttpException("Unable to fetch");
    }
    var content = json.decode(res.body);
    if (content is Iterable) {
      return Future.wait(
          content.map((item) => _fromJsonHandler(fromJson, item)));
    } else {
      return [await _fromJsonHandler(fromJson, content)];
    }
  }

  Future<List<User>> groupMembers(String groupId) async =>
      _fetch<User>("groups/$groupId/members", User.fromJson);

  Future<List<Group>> groups() async =>
      _fetch<Group>("groups", (groupJson) async {
        String id = groupJson['id'];
        List<User> members = await groupMembers(id);
        return Group.fromJson(groupJson, members);
      });

  Future<List<User>> getUser(String userId) async =>
      _fetch<User>("users/$userId", User.fromJson);

  Future<List<Wish>> wishes() async => _fetch<Wish>("wishes", (wishJson) async {
        String id = wishJson['userId'];
        List<User> user = await getUser(id);
        return Wish.fromJson(wishJson, user.first);
      });

  Future<String> getGroupInviteLink(String groupId) async {
    Uri uri = Uri.parse("$_baseUrl/groups/$groupId/invite");
    Response res = await http.post(uri, headers: _headers);
    if (res.statusCode > 201) {
      throw const HttpException("Unable to create invitation link");
    }
    return res.body;
  }
}
