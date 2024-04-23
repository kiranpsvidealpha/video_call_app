import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LifeCycleObserver extends StatefulWidget {
  const LifeCycleObserver({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LifeCycleObserver> createState() => _LifeCycleObserverState();
}

class _LifeCycleObserverState extends State<LifeCycleObserver> with WidgetsBindingObserver {
  StreamSubscription? sub;
  void initUniLinks() {
    sub = linkStream.listen((String? link) {
      if (link != null) { 
        var uri = Uri.parse(link);  
           if (uri.queryParameters['path'] == 'profile') {
            // Get.to(const DemoScreen());// pending
          }
      }
    });
  }

  @override
  void initState() {
    super.initState();  
    initUniLinks();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log(state.name.toUpperCase(), name: "[App State] >>");

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class VideBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log(change.currentState.toString().split('\'')[1], name: "[Current bloc state ] >> ");
  }
}
