import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../reusable/strings.dart';

class NoInternetView extends StatefulWidget {
  const NoInternetView({
    super.key,
    required this.msg,
    required this.showInfo,
  });
  final String msg;
  final bool showInfo;
  @override
  State<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Stack(
          children: [
            CustomPaint(
              size: size,
              painter: CornerCircle(),
            ),
            Column(
              children: [
                SizedBox(height: size.height * 0.1),
                Image.asset(
                  "assets/images/pngs/cable.png",
                  height: size.height * 0.5,
                ),
                SizedBox(height: size.height * 0.1),
                Center(
                  child: Text(
                    widget.msg,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: widget.showInfo
          ? FloatingActionButton(
              elevation: 0,
              backgroundColor: Colors.transparent,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  constraints: BoxConstraints(
                    minWidth: size.width < 400 ? size.width : 400,
                    minHeight: 300,
                    maxHeight: 300,
                    maxWidth: 400,
                  ),
                  builder: (builder) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Troubleshooting tips',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                child: const Icon(Icons.close),
                                onTap: () {
                                  Navigator.of(builder).pop();
                                },
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        const Text(
                          '1. Turn your mobile data on\n'
                          '2. Turn your wifi on\n'
                          '3. Turn your flight mode off\n'
                          '4. Clear app data from app settings\n'
                          '5. Restart your phone\n'
                          '6. Contact app administrator\n'
                          '7. Contact your network admin\n'
                          '8. Contact your ISP\n',
                          textAlign: TextAlign.left,
                        ),
                      ],
                    );
                  },
                );
              },
            )
          : const SizedBox(),
    );
  }
}

class CornerCircle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width * 0.3;
    Paint paint = Paint()
      ..color = const Color(0xFFD7FDEB)
      ..style = PaintingStyle.fill;
    Rect rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: width,
    );
    canvas.drawArc(rect, 0, 1.57, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Helper class
class NetworkHelper {
  static void observeNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      NetworkBloc().add(NetworkNotify());
    } else {
      //checking ip
      var ipFetch = await http.get(Uri.parse("https://api.ipify.org"));

      if (ipFetch.statusCode == 200) {
        String ip = ipFetch.body.toString();
        userIp = ValueNotifier(ip);
        NetworkBloc().add(NetworkNotify(isConnected: true, userIp: ip));
      } else {
        log(ipFetch.body.toString());
        NetworkBloc().add(NetworkNotify(isConnected: true, userIp: ''));
      }
    }
    Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        if (result == ConnectivityResult.none) {
          NetworkBloc().add(NetworkNotify());
        } else {
          //checking ip
          var ipFetch = await http.get(Uri.parse("https://api.ipify.org"));

          if (ipFetch.statusCode == 200) {
            String ip = ipFetch.body.toString();
            userIp = ValueNotifier(ip);
            NetworkBloc().add(NetworkNotify(isConnected: true, userIp: ip));
          } else {
            log(ipFetch.body.toString());
            NetworkBloc().add(NetworkNotify(isConnected: true, userIp: ''));
          }
        }
      },
    );
  }
}

//BLoC events
abstract class NetworkEvent {}

class NetworkObserve extends NetworkEvent {}

class NetworkNotify extends NetworkEvent {
  final bool isConnected;
  final String userIp;
  NetworkNotify({this.isConnected = false, this.userIp = ''});
}

//BLoC states
abstract class NetworkState {}

class NetworkInitial extends NetworkState {}

class NetworkSuccess extends NetworkState {
  String userIp;
  NetworkSuccess(this.userIp);
}

class NetworkFailure extends NetworkState {}

//Network BLoC
class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  NetworkBloc._() : super(NetworkInitial()) {
    on<NetworkObserve>(_observe);
    on<NetworkNotify>(_notifyStatus);
  }

  static final NetworkBloc _instance = NetworkBloc._();

  factory NetworkBloc() => _instance;

  void _observe(event, emit) {
    NetworkHelper.observeNetwork();
  }

  void _notifyStatus(NetworkNotify event, emit) {
    event.isConnected ? emit(NetworkSuccess(event.userIp)) : emit(NetworkFailure());
  }
}
