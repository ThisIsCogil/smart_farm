import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late final MqttServerClient _client;
  bool _connected = false;

  // ===== STREAM STATUS AKTUATOR =====
  final _actuatorController =
      StreamController<Map<String, bool>>.broadcast();
  Stream<Map<String, bool>> get actuatorsStream =>
      _actuatorController.stream;

  // ===== STREAM SENSOR (optional) =====
  final _sensorController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get sensorsStream =>
      _sensorController.stream;

  // ===== STREAM LOG (optional) =====
  final _logController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get logStream =>
      _logController.stream;

  Future<void> connect() async {
    if (_connected) return;

    const broker = '157.10.161.24';
    const port = 1883;
    final clientId =
        'flutter-dashboard-${DateTime.now().millisecondsSinceEpoch}';

    _client = MqttServerClient(broker, clientId)
      ..port = port
      ..logging(on: false)
      ..autoReconnect = true
      ..keepAlivePeriod = 20
      ..onConnected = () {
        _connected = true;
        // print("MQTT connected");
      }
      ..onDisconnected = () {
        _connected = false;
        // print("MQTT disconnected");
      };

    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    try {
      final conn = await _client.connect();
      if (conn?.state == MqttConnectionState.connected) {
        _connected = true;

        // ✅ wildcard biar semua subtopik coffee masuk
        _client.subscribe('greenhouse/coffee/#', MqttQos.atMostOnce);

        _client.updates!.listen(_onMessage);
      } else {
        _connected = false;
      }
    } catch (_) {
      _connected = false;
      _client.disconnect();
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
  for (final rec in events) {
    final topic = rec.topic;

    final msg = rec.payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(msg.payload.message);

    // DEBUG biar kita yakin actuators masuk
    print("TOPIC MASUK: $topic");
    print("PAYLOAD MASUK: $payload");

    try {
      if (topic == 'greenhouse/coffee/actuators') {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        final result = <String, bool>{};

        bool isOn(dynamic v) {
          final s = v.toString().toUpperCase().trim();
          return s == 'ON' || s == '1' || s == 'TRUE';
        }

        if (map.containsKey('pump')) result['pump'] = isOn(map['pump']);
        if (map.containsKey('fan')) result['fan'] = isOn(map['fan']);
        if (map.containsKey('humidifier')) {
          result['humidifier'] = isOn(map['humidifier']);
        }

        print("HASIL PARSE ACTUATORS: $result"); // DEBUG

        _actuatorController.add(result);
      }

      if (topic == 'greenhouse/coffee/sensors') {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        _sensorController.add(map);
      }

      if (topic == 'greenhouse/coffee/log') {
        final map = jsonDecode(payload) as Map<String, dynamic>;
        _logController.add(map);
      }
    } catch (e) {
      print("ERROR PARSE di $topic => $e");
    }
  }
}

  // ===== PUBLISH MANUAL PER DEVICE (CONTROL ENDPOINT) =====
  Future<void> publishManualControl(String deviceId, bool isOn) async {
    if (!_connected) return;

    final topic = 'greenhouse/coffee/control/$deviceId';
    final payload = isOn ? 'ON' : 'OFF';

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);

    // print("PUBLISH MANUAL -> $topic : $payload");
  }

  void dispose() {
    _actuatorController.close();
    _sensorController.close();
    _logController.close();
    _client.disconnect();
  }
}
