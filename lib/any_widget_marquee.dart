library any_widget_marquee;

import 'dart:async';

import 'package:flutter/material.dart';

class AnyMargueeSpeed {
  static const double NORMAL_SPEED = 150.0;
}

class AnyMargueeWidget extends StatefulWidget {
  AnyMargueeWidget({
    @required this.child,
    Key key,
    this.marginLeft,
    this.betweenSpacing,
    this.width,
    this.height,
    this.speedRate = 1,
    this.scrollFromEnd = true,
    this.delayedStart = const Duration(seconds: 0),
  }) : super(key: key);

  double marginLeft;
  double betweenSpacing;
  final Widget child;
  double width;
  double height;
  final double speedRate;
  bool scrollFromEnd;
  Duration delayedStart;

  @override
  _AnyMargueeWidgetState createState() => _AnyMargueeWidgetState();
}

class _AnyMargueeWidgetState extends State<AnyMargueeWidget> {
  Timer _anyMargueeTimer;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(widget.delayedStart);
      startTimer();
    });
  }

  void startTimer() {
    _anyMargueeTimer = Timer.periodic(Duration(microseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        final distance = _scrollController.offset ?? 0;
        _scrollController.jumpTo(distance + (1 / AnyMargueeSpeed.NORMAL_SPEED) * widget.speedRate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScrollNotificationInterceptor(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final biggestWidth = constraints.biggest.width;
          final biggestHeight = constraints.biggest.height;
          widget.marginLeft ??= biggestWidth;
          widget.betweenSpacing ??= biggestWidth;
          widget.width ??= biggestWidth;
          widget.height ??= biggestHeight;

          return Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment.center,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: double.maxFinite.toInt(),
              itemBuilder: (context, index) {
                final distance = (index == 0 ? widget.marginLeft : widget.betweenSpacing);
                return Container(
                  padding: EdgeInsets.only(left: widget.scrollFromEnd ? distance : 0),
                  alignment: Alignment.center,
                  child: widget.child,
                );
              },
              controller: _scrollController,
              physics: NeverScrollableScrollPhysics(),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _anyMargueeTimer?.cancel();
    super.dispose();
    _scrollController?.dispose();
  }
}

class ScrollNotificationInterceptor extends StatelessWidget {
  final Widget child;

  ScrollNotificationInterceptor({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        return true;
      },
      child: this.child,
    );
  }
}
