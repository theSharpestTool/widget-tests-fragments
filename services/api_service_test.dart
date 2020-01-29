import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddocs_flutter_app/main.dart';
import 'package:fooddocs_flutter_app/services/api.service.dart';
import 'package:fooddocs_flutter_app/services/store.service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';

class MockStorage extends Mock implements FlutterSecureStorage {}

class MockNavigatorKey extends Mock implements GlobalKey<NavigatorState> {}

class MockNavigatorState extends NavigatorState {
  @override
  bool canPop() {
    print('canPop');
    return true;
  }

  @override
  Future<T> pushNamed<T extends Object>(String routeName, {Object arguments}) {
    return Future.value();
  }

  @override
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
      String newRouteName, predicate,
      {Object arguments}) {
    return Future.value();
  }
}

void main() {
  final testUrl = 'testurl';
  final testToken = 'test_token';
  final testHeaders = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.authorizationHeader: "Bearer $testToken"
  };
  final testHeadersWithCharset = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.authorizationHeader: "Bearer $testToken",
  };
  final testRequest = '/test_request';
  final testResponseBody = "{'body': 'test_response'}";
  final testRequestBody = {'body': 'test_request'};
  final testPlatform = 'platform=unknown';
  final testNavigatorKey = MockNavigatorKey();
  final testNavigatorState = MockNavigatorState();
  final client = ApiClient(testUrl);

  group('test all api', () {
    setUpAll(() {
      nock.defaultBase = testUrl;
      nock.init();
      final storage = MockStorage();

      when(storage.read(key: 'token')).thenAnswer((_) async => 'test_token');
      when(testNavigatorKey.currentState).thenReturn(testNavigatorState);

      StoreService.storage = storage;
    });

    tearDownAll(() {
      navigatorKey = GlobalKey<NavigatorState>();
      StoreService.storage = FlutterSecureStorage();
      nock.cleanAll();
    });

    group('get', () {
      test('status code == 200', () async {
        final interceptor = nock.get("$testRequest?$testPlatform")
          ..headers(testHeaders)
          ..replay(200, testResponseBody);

        final response = await client.get(testRequest);

        expect(response.statusCode, 200);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);
      });

      test('status code == 401', () async {
        navigatorKey = testNavigatorKey;
        final interceptor = nock.get("$testRequest?$testPlatform")
          ..headers(testHeaders)
          ..replay(401, testResponseBody);

        final response = await client.get(testRequest);

        expect(response.statusCode, 401);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);

        verify(testNavigatorKey.currentState).called(3);

        navigatorKey = GlobalKey<NavigatorState>();
      });

      test('status code == error', () async {
        final interceptor = nock.get("$testRequest?$testPlatform")
          ..headers(testHeaders)
          ..replay(100, testResponseBody);

        expect(client.get(testRequest), throwsException);
        expect(interceptor.isDone, false);
      });
    });

    group('post', () {
      test('status code == 200', () async {
        final interceptor =
            nock.post("$testRequest&$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(200, testResponseBody);

        final response = await client.post(testRequest, body: testRequestBody);

        expect(response.statusCode, 200);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);
      });

      test('status code == 401', () async {
        navigatorKey = testNavigatorKey;
        final interceptor =
            nock.post("$testRequest&$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(401, testResponseBody);

        final response = await client.post(testRequest, body: testRequestBody);

        expect(response.statusCode, 401);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);

        verify(testNavigatorKey.currentState).called(3);
        navigatorKey = GlobalKey<NavigatorState>();
      });

      test('status code == error', () async {
        final interceptor =
            nock.post("$testRequest&$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(100, testResponseBody);

        expect(
            client.post(testRequest, body: testRequestBody), throwsException);
        expect(interceptor.isDone, false);
      });
    });

    group('post for login', () {
      test('status code == 200', () async {
        final interceptor =
            nock.post("$testRequest?$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(200, testResponseBody);

        final response =
            await client.postForLogin(testRequest, body: testRequestBody);

        expect(response.statusCode, 200);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);
      });

      test('status code == 401', () async {
        navigatorKey = testNavigatorKey;
        final interceptor =
            nock.post("$testRequest?$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(200, testResponseBody);

        final response =
            await client.postForLogin(testRequest, body: testRequestBody);

        expect(response.statusCode, 200);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);

        verify(testNavigatorKey.currentState).called(1);
        navigatorKey = GlobalKey<NavigatorState>();
      });

      test('status code == error', () async {
        final interceptor =
            nock.post("$testRequest?$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(100, testResponseBody);

        final response =
            await client.postForLogin(testRequest, body: testRequestBody);

        expect(response.statusCode, 100);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);
      });
    });

    group('put', () {
      test('status code == 200', () async {
        final interceptor =
            nock.put("$testRequest?$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(200, testResponseBody);

        final response = await client.put(testRequest, body: testRequestBody);

        expect(response.statusCode, 200);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);
      });

      test('status code == 401', () async {
        navigatorKey = testNavigatorKey;
        final interceptor =
            nock.put("$testRequest?$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(401, testResponseBody);

        final response = await client.put(testRequest, body: testRequestBody);

        expect(response.statusCode, 401);
        expect(response.body, testResponseBody);
        expect(interceptor.isDone, true);

        verify(testNavigatorKey.currentState).called(3);
        navigatorKey = GlobalKey<NavigatorState>();
      });

      test('status code == error', () async {
        final interceptor =
            nock.put("$testRequest?$testPlatform", testRequestBody)
              ..headers(testHeadersWithCharset)
              ..replay(100, testResponseBody);

        expect(client.put(testRequest, body: testRequestBody), throwsException);
        expect(interceptor.isDone, false);
      });
    });
  });
}
