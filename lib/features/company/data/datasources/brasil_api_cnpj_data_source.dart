import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jobfy/core/network/api_exception.dart';
import '../../domain/entities/company_entity.dart';

/// The CNPJ isn't registered at Receita Federal (or is invalid).
class CnpjNotFoundException implements Exception {
  const CnpjNotFoundException();
}

/// Looks up a company by CNPJ on BrasilAPI (public data from Receita
/// Federal): https://brasilapi.com.br/docs#tag/CNPJ
class BrasilApiCnpjDataSource {
  final http.Client _client;

  BrasilApiCnpjDataSource([http.Client? client]) : _client = client ?? http.Client();

  /// [cnpj] must have 14 digits.
  Future<CnpjDataEntity> lookup(String cnpj) async {
    final http.Response response;
    try {
      response = await _client
          .get(Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cnpj'))
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiUnreachableException('BrasilAPI did not answer in time.');
    } catch (e) {
      throw ApiUnreachableException(e.toString());
    }

    // 404 = not found, 400 = invalid CNPJ.
    if (response.statusCode == 404 || response.statusCode == 400) {
      throw const CnpjNotFoundException();
    }
    if (response.statusCode != 200) {
      throw ApiStatusException(response.statusCode, response.body);
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    String? str(String key) {
      final v = json[key]?.toString().trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    // "Rua X, 123 - Bairro"
    final street = [str('descricao_tipo_de_logradouro'), str('logradouro')]
        .whereType<String>()
        .join(' ')
        .replaceFirstMapped(RegExp(r'^(\w+) \1 '), (m) => '${m[1]} ');
    final address = [
      [if (street.isNotEmpty) street, str('numero')].whereType<String>().join(', '),
      str('bairro'),
    ].whereType<String>().where((s) => s.isNotEmpty).join(' - ');

    return CnpjDataEntity(
      cnpj: cnpj,
      legalName: str('razao_social') ?? '',
      tradeName: str('nome_fantasia'),
      phone: _formatPhone(str('ddd_telefone_1')),
      businessArea: str('cnae_fiscal_descricao'),
      zipCode: str('cep')?.replaceAll(RegExp(r'\D'), ''),
      address: address.isEmpty ? null : address,
      city: str('municipio'),
      state: str('uf'),
      status: str('descricao_situacao_cadastral'),
    );
  }

  /// "6134939002" -> "(61) 3493-9002", "11987654321" -> "(11) 98765-4321".
  static String? _formatPhone(String? digits) {
    final d = digits?.replaceAll(RegExp(r'\D'), '');
    if (d == null || d.length < 10) return d;
    final ddd = d.substring(0, 2), rest = d.substring(2);
    final split = rest.length - 4;
    return '($ddd) ${rest.substring(0, split)}-${rest.substring(split)}';
  }
}
