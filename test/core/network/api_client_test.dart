import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jobfy/core/network/api_client.dart';
import 'package:jobfy/core/network/api_exception.dart';

void main() {
  group('ApiClient', () {
    test('decodes a successful JSON response', () async {
      final client = ApiClient(
        baseUrl: 'http://test',
        httpClient: MockClient((request) async {
          expect(request.url.toString(), 'http://test/ping');
          return http.Response(jsonEncode({'ok': true}), 200);
        }),
      );

      final result = await client.get('/ping');

      expect(result, {'ok': true});
    });

    test('sends the auth token once set', () async {
      final client = ApiClient(
        baseUrl: 'http://test',
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer abc123');
          return http.Response('{}', 200);
        }),
      );

      client.setAuthToken('abc123');
      await client.get('/me');
    });

    test('throws ApiStatusException with the server message on 4xx/5xx', () async {
      final client = ApiClient(
        baseUrl: 'http://test',
        httpClient: MockClient((request) async {
          return http.Response(jsonEncode({'message': 'invalid credentials'}), 401);
        }),
      );

      await expectLater(
        client.post('/auth/login', body: {'email': 'a', 'password': 'b'}),
        throwsA(isA<ApiStatusException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'invalid credentials')),
      );
    });

    test('throws ApiUnreachableException when the transport fails', () async {
      final client = ApiClient(
        baseUrl: 'http://test',
        httpClient: MockClient((request) async {
          throw http.ClientException('connection refused');
        }),
      );

      await expectLater(
        client.get('/ping'),
        throwsA(isA<ApiUnreachableException>()),
      );
    });
  });
}
