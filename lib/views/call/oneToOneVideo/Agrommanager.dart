import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
class AgoraManager {
  static final AgoraManager _instance = AgoraManager._internal();
  factory AgoraManager() {
    return _instance;
  }
  AgoraManager._internal();
  Future<RtcEngine> initializeAgora(String appID) async {
    await [Permission.microphone, Permission.camera].request();
    //create an instance of the Agora engine
    RtcEngine agoraEngine = createAgoraRtcEngine();
    try {
      await agoraEngine.initialize(RtcEngineContext(appId: appID));
      log('init agora appID- $appID ');
    } catch (e) {
      log(e.toString());
    }
    return agoraEngine;
  }
  void joinChannel(
      String token, String channelName, RtcEngine agoraEngine) async {
    log('joinchannel');
    // Set channel options
    ChannelMediaOptions options;
    // Set channel profile and client role
    options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.startPreview();
    await agoraEngine.enableVideo();
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: 0,
    );
  }
  void leave(RtcEngine agoraEngine,
      {required void Function(bool isLiveEnded) onchannelLeaveCallback}) async {
    try {
      await agoraEngine.leaveChannel();
      await agoraEngine.release();
      onchannelLeaveCallback(true);
    } on Exception catch (e) {
      log('Exception leaving channel-> $e.toString()');
      onchannelLeaveCallback(false);
    }
  }
  void muteVideoCall(
      bool flag,
      RtcEngine agoraEngine,
      ) async {
    try {
      agoraEngine.muteLocalAudioStream(flag);
    } catch (e) {
      log(e.toString());
    }
  }
  void onVolume(
      bool isSpeaker,
      RtcEngine agoraEngine,
      ) async {
    try {
      await agoraEngine.setEnableSpeakerphone(isSpeaker);
    } catch (e) {
      log(e.toString());
    }
  }
}


