import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../reusable/colors.dart';
import '../../mixins/chat_mixin.dart';

class AudioMessageBox extends StatefulWidget {
  final String url;
  final CrossAxisAlignment crossAxisAlignment;

  const AudioMessageBox({
    super.key,
    required this.url,
    required this.crossAxisAlignment,
  });

  @override
  AudioMessageBoxState createState() => AudioMessageBoxState();
}

class AudioMessageBoxState extends State<AudioMessageBox> with ChatMixin {
  Timer? timer;
  String audioFileName = '';
  Duration duration = const Duration();
  Duration position = const Duration();
  AudioPlayer audioPlayer = AudioPlayer();
  Rx<PlayerState> rxAudioPlayerState = PlayerState.stopped.obs;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (rxAudioPlayerState.value != state) {
        rxAudioPlayerState.value = state;
      }
    });

    audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => duration = d);
    });

    startTimer();
  }

  @override
  void dispose() {
    audioPlayer.stop();
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (rxAudioPlayerState.value == PlayerState.playing) {
        audioPlayer.getCurrentPosition().then((value) {
          setState(() => position = value ?? const Duration());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width / 1.5,
      height: 20,
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              try {
                if (rxAudioPlayerState.value == PlayerState.playing) {
                  audioPlayer.pause();
                } else if (rxAudioPlayerState.value == PlayerState.paused) {
                  audioPlayer.resume();
                  await audioPlayer.play(UrlSource(widget.url));
                } else {
                  await audioPlayer.play(UrlSource(widget.url));
                }
              } catch (e) {
                log('audio_message_box.dart', name: "Error playing audio", error: e);
              }
            },
            child: Obx(
              () => Icon(
                rxAudioPlayerState.value == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                color: black,
              ),
            ),
          ),
          Builder(
            builder: (context) => Text(
              '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: black),
            ),
          ),
          Expanded(
            child: Slider(
              min: 0.0,
              onChanged: (double value) => audioPlayer.seek(Duration(milliseconds: value.toInt())),
              value: position.inMilliseconds.toDouble(),
              max: duration.inMilliseconds.toDouble(),
            ),
          ),
          Text(
            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: black),
          ),
        ],
      ),
    );
  }
}
