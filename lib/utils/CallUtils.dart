// ignore_for_file: file_names

import 'dart:developer';

import 'package:AstrowayCustomer/utils/global.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

class CallUtils {
  static Future<void> showIncomingCall(var body) async {
    Uuid uuid = const Uuid();
    String currentUuid = uuid.v4();

    String defaultImage = 'https://i.pravatar.cc/500';
    String? profilePic = body['profile'];

    String imageUrl;
    if (profilePic != null) {
      imageUrl = imgBaseurl + profilePic;
    } else {
      imageUrl = defaultImage;
    }
    bool calltype = body['call_type'] == 10; //11 video call or 10 audio call

    log('calltype is  $calltype');
    log('imageUrl is  $imageUrl');
    log('imageUrl is  ${body['name']}');
    log('fcmToken is  ${body['fcmToken']}');

    CallKitParams callKitParams = CallKitParams(
      id: currentUuid,
      nameCaller: body['astrologerName'] ?? 'Astrologer',
      appName: 'Astroway',
      handle: 'Astroway Partner',
      type: calltype ? 0 : 1, // 0 for audio call, 1 for video call
      textAccept: 'Accept',
      textDecline: 'Decline',
      duration: 30000,
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: <String, dynamic>{
        'astrologerId': body['astrologerId'],
        'astrologerName': body['astrologerName'],
        'call_type': body['call_type'],
        'channelName': body['channelName'],
        'callId': body['callId'],
        'profile': body['profile'],
        'token': body['token'],
        'fcmToken': body['fcmToken'],
        'call_duration': body['call_duration'],
      },
      headers: <String, dynamic>{'apiKey': 'sunil@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: "Incoming Call 1",
        isShowCallID: true, //for showing handle in incoming call notification
      ),
      ios: IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }
}
