// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$ApiService extends ApiService {
  _$ApiService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = ApiService;

  @override
  Future<Response<dynamic>> login(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/login');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> register(Map<String, dynamic> body) {
    final Uri $url = Uri.parse('/register');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> logout(String token) {
    final Uri $url = Uri.parse('/logout');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createGreenhouse(
    String token,
    String nama,
    String alamat,
    String ukuran,
    String pemilik,
    String pengelola,
    String jenisTanamanId,
    String gambar,
    http.MultipartFile image,
  ) {
    final Uri $url = Uri.parse('iot/greenhouse');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final List<PartValue> $parts = <PartValue>[
      PartValue<String>(
        'nama',
        nama,
      ),
      PartValue<String>(
        'alamat',
        alamat,
      ),
      PartValue<String>(
        'ukuran',
        ukuran,
      ),
      PartValue<String>(
        'pemilik',
        pemilik,
      ),
      PartValue<String>(
        'pengelola',
        pengelola,
      ),
      PartValue<String>(
        'jenis_tanaman_id',
        jenisTanamanId,
      ),
      PartValue<String>(
        'gambar',
        gambar,
      ),
      PartValue<http.MultipartFile>(
        'image',
        image,
      ),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllGreenhouses(String token) {
    final Uri $url = Uri.parse('/iot/greenhouse');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateGreenhouse(
    String token,
    String nama,
    String alamat,
    String ukuran,
    String pemilik,
    String pengelola,
    String jenisTanamanId,
    String gambar,
    http.MultipartFile image,
    int id,
  ) {
    final Uri $url = Uri.parse('/iot/greenhouse/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final List<PartValue> $parts = <PartValue>[
      PartValue<String>(
        'nama',
        nama,
      ),
      PartValue<String>(
        'alamat',
        alamat,
      ),
      PartValue<String>(
        'ukuran',
        ukuran,
      ),
      PartValue<String>(
        'pemilik',
        pemilik,
      ),
      PartValue<String>(
        'pengelola',
        pengelola,
      ),
      PartValue<String>(
        'jenis_tanaman_id',
        jenisTanamanId,
      ),
      PartValue<String>(
        'gambar',
        gambar,
      ),
      PartValue<http.MultipartFile>(
        'image',
        image,
      ),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteGreenhouse(
    String token,
    int id,
  ) {
    final Uri $url = Uri.parse('/iot/greenhouse/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getAllPerangkat(String token) {
    final Uri $url = Uri.parse('/iot/perangkat');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createPerangkat(
    String token,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/iot/perangkat');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updatePerangkat(
    String token,
    int id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/iot/perangkat/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deletePerangkat(
    String token,
    int id,
  ) {
    final Uri $url = Uri.parse('/iot/perangkat/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getLatestSensorData(
    String token,
    int ghId,
  ) {
    final Uri $url = Uri.parse('/iot/sensor/${ghId}/lastest');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getGraphSensorData(
    String token,
    int ghId,
  ) {
    final Uri $url = Uri.parse('/iot/sensor/${ghId}/chart');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updatePompa(
    String token,
    int id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/iot/pompa/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getLatestPompaData(
    String token,
    int id,
  ) {
    final Uri $url = Uri.parse('/iot/pompa/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getTanaman(String token) {
    final Uri $url = Uri.parse('/iot/jenis-tanaman');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getKontrolData(
    String token,
    int id,
  ) {
    final Uri $url = Uri.parse('/iot/kontrol/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateKontrolData(
    String token,
    int id,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/iot/kontrol/${id}');
    final Map<String, String> $headers = {
      'Authorization': token,
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
