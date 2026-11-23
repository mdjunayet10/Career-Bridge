import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/config/app_mode.dart';
import '../../app/config/firebase_runtime_options.dart';
import '../../core/enums/user_role.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'push_route_policy.dart';

final careerBridgeNavigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> careerBridgeBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: FirebaseRuntimeOptions.currentPlatform);
  // Notification payloads are displayed by Android while the app is closed.
}

class MobilePushService extends ChangeNotifier {
  MobilePushService._();
  static final instance = MobilePushService._();
  static const channelId = 'career_bridge_jobs';
  final _local = FlutterLocalNotificationsPlugin();
  final _seen = <String>{};
  bool _attached = false;
  bool _ready = false;
  bool enabled = true;
  String? notice;
  String? _uid;
  String? _token;
  String? _pendingRoute;
  bool _navigatorReady = false;
  String? _lastOpened;
  DateTime? _lastOpenedAt;
  StreamSubscription<String>? _refresh;
  Future<void> _operations = Future.value();

  bool get supported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !AppMode.adminOnly;
  bool get available =>
      supported &&
      AuthController.instance.usesFirebase &&
      AuthController.instance.currentUser?.role == UserRole.jobSeeker;
  DocumentReference<Map<String, dynamic>> _settings(String uid) =>
      FirebaseFirestore.instance.collection('pushSubscriptions').doc(uid);
  String _tokenId(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  void attach() {
    if (_attached || !supported) return;
    _attached = true;
    AuthController.instance.addListener(_authChanged);
    if (AuthController.instance.usesFirebase) {
      _operations =
          _operations.then((_) => _initialize()).catchError((Object _) {
        notice =
            'Notification startup is unavailable. Job browsing remains available.';
      });
    }
    _authChanged();
  }

  void _authChanged() {
    _operations =
        _operations.then((_) => _syncUser()).catchError((Object error) {
      notice =
          'Job alerts are unavailable. Check notification permission and Firebase setup.';
      notifyListeners();
    });
  }

  Future<void> _syncUser() async {
    final auth = AuthController.instance;
    if (auth.status == AuthStatus.authenticating) return;
    final uid = available ? auth.currentUser!.uid : null;
    if (uid == _uid) return;
    await _removeDevice();
    _uid = uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool('job_alerts_$uid') ?? true;
    try {
      final saved =
          await _settings(uid).get().timeout(const Duration(seconds: 8));
      enabled = saved.data()?['enabled'] as bool? ?? enabled;
    } catch (_) {
      // A local opt-out is honored even if the backend has not been deployed.
    }
    notifyListeners();
    if (enabled) await _register(uid);
  }

  Future<void> _initialize() async {
    if (_ready) return;
    FirebaseMessaging.onBackgroundMessage(careerBridgeBackgroundMessage);
    await _local.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onDidReceiveNotificationResponse: (response) =>
            openJob(response.payload));
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            channelId, 'Job opportunities',
            description: 'Relevant approved jobs',
            importance: Importance.high));
    FirebaseMessaging.onMessage.listen((message) async {
      if (!available || !enabled || message.notification == null) return;
      final id = message.data['eventId'] ?? message.messageId;
      if (id != null && !_seen.add(id)) return;
      if (_seen.length > 200) _seen.remove(_seen.first);
      final route = jobRouteFromPayload(message.data['route']);
      if (route == null) return;
      await _local.show(
          (id ?? route).hashCode & 0x7fffffff,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  channelId, 'Job opportunities',
                  importance: Importance.high, priority: Priority.high)),
          payload: route);
    });
    FirebaseMessaging.onMessageOpenedApp
        .listen((message) => openJob(message.data['route']));
    _ready = true;
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      openJob(launch?.notificationResponse?.payload);
    }
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) openJob(initial.data['route']);
  }

  Future<void> _register(String uid) async {
    await _initialize();
    final permission = await FirebaseMessaging.instance.requestPermission();
    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      notice = 'Allow notifications in Android settings to receive job alerts.';
      notifyListeners();
      return;
    }
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    final token = await FirebaseMessaging.instance.getToken();
    if (_uid != uid || !enabled || !available) return;
    if (token != null) await _saveToken(uid, token);
    await _refresh?.cancel();
    _refresh = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _operations = _operations.then((_) async {
        if (_uid == uid && enabled && available) await _saveToken(uid, token);
      }).catchError((Object _) {
        notice = 'Could not refresh job alerts. Try enabling them again.';
        notifyListeners();
      });
    });
    notice = null;
    notifyListeners();
  }

  Future<void> _saveToken(String uid, String token) async {
    final previous = _token;
    final batch = FirebaseFirestore.instance.batch();
    batch.set(
        _settings(uid),
        {'enabled': enabled, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
    if (previous != null && previous != token) {
      batch
          .delete(_settings(uid).collection('devices').doc(_tokenId(previous)));
    }
    batch.set(_settings(uid).collection('devices').doc(_tokenId(token)), {
      'token': token,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp()
    });
    await batch.commit().timeout(const Duration(seconds: 8));
    _token = token;
  }

  Future<void> setEnabled(bool value) async {
    if (!available || _uid == null) return;
    enabled = value;
    notifyListeners();
    final uid = _uid!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('job_alerts_$uid', value);
    try {
      await _settings(uid).set(
          {'enabled': value, 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true)).timeout(const Duration(seconds: 8));
      if (value) {
        await _register(uid);
      } else {
        await _removeDevice(clearUid: false);
      }
    } catch (_) {
      if (!value) await _removeDevice(clearUid: false);
      notice =
          'Preference saved on this device. Server sync needs Firebase notification setup and connectivity.';
      notifyListeners();
    }
  }

  /// Called while the owner is still authenticated, before Firebase sign-out.
  Future<void> beforeSignOut() async {
    if (!supported) return;
    await _operations;
    await _removeDevice();
  }

  Future<void> _removeDevice({bool clearUid = true}) async {
    await _refresh?.cancel();
    _refresh = null;
    final uid = _uid;
    final token = _token;
    if (uid != null && token != null) {
      try {
        await _settings(uid)
            .collection('devices')
            .doc(_tokenId(token))
            .delete()
            .timeout(const Duration(seconds: 5));
      } catch (_) {/* Token invalidation below also prevents delivery. */}
    }
    if (supported && Firebase.apps.isNotEmpty && uid != null) {
      try {
        await FirebaseMessaging.instance.setAutoInitEnabled(false);
        await FirebaseMessaging.instance
            .deleteToken()
            .timeout(const Duration(seconds: 5));
        await _local.cancelAll();
      } catch (_) {/* Connectivity may delay provider-side invalidation. */}
    }
    _token = null;
    if (clearUid) _uid = null;
    _seen.clear();
  }

  void markNavigatorReady() {
    _navigatorReady = true;
    flushPendingRoute();
  }

  void openJob(String? payload) {
    final route = jobRouteFromPayload(payload);
    if (route == null || AppMode.adminOnly) return;
    final now = DateTime.now();
    if (_lastOpened == route &&
        _lastOpenedAt != null &&
        now.difference(_lastOpenedAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastOpened = route;
    _lastOpenedAt = now;
    _pendingRoute = route;
    WidgetsBinding.instance.addPostFrameCallback((_) => flushPendingRoute());
    WidgetsBinding.instance.scheduleFrame();
  }

  void flushPendingRoute() {
    final route = _pendingRoute;
    final nav = careerBridgeNavigatorKey.currentState;
    if (!_navigatorReady || route == null || nav == null) return;
    _pendingRoute = null;
    nav.pushNamed(route);
  }
}
