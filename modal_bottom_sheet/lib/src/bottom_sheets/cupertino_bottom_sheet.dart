// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart'
    show
        CupertinoApp,
        CupertinoColors,
        CupertinoDynamicColor,
        CupertinoTheme,
        CupertinoThemeData,
        CupertinoUserInterfaceLevel,
        CupertinoUserInterfaceLevelData;
import 'package:flutter/material.dart'
    show
        Colors,
        MaterialLocalizations,
        Theme,
        ThemeData,
        debugCheckHasMaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

const double _kPreviousPageVisibleOffset = 10;

const Radius _kDefaultTopRadius = Radius.circular(12);
const BoxShadow _kDefaultBoxShadow =
    BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);

SystemUiOverlayStyle overlayStyleFromColor(Color color) {
  final brightness = ThemeData.estimateBrightnessForColor(color);
  return brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;
}

/// Cupertino Bottom Sheet Container
///
/// Clip the child widget to rectangle with top rounded corners and adds
/// top padding(+safe area padding). This padding [_kPreviousPageVisibleOffset]
/// is the height that will be displayed from previous route.
class _CupertinoBottomSheetContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Radius topRadius;
  final ShapeBorder? shape;
  final Clip clip;
  final BoxShadow? shadow;
  final SystemUiOverlayStyle? overlayStyle;
  final bool? expand;
  final SystemUiOverlayStyle? overlayStyle;

  const _CupertinoBottomSheetContainer({
    required this.child,
    this.backgroundColor,
    required this.topRadius,
    this.shape,
    Clip? clip,
    this.shadow,
    this.overlayStyle,
    this.expand,
  }) : clip = clip ?? Clip.antiAlias;

  @override
  Widget build(BuildContext context) {
    final scopedOverlayStyle = overlayStyle;
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = _kPreviousPageVisibleOffset + topSafeAreaPadding;

    final shadow = this.shadow ?? _kDefaultBoxShadow;
    final backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;

    Widget bottomSheetContent = Container(
      decoration: BoxDecoration(color: backgroundColor, boxShadow: [shadow]),
      width: double.infinity,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true, //Remove top Safe Area
        child: CupertinoUserInterfaceLevel(
          data: CupertinoUserInterfaceLevelData.elevated,
          child: child,
        ),
      ),
    );

    Widget bottomSheetContainer = Padding(
      padding: EdgeInsets.only(top: expand == true ? 0.0 : topPadding),
      child: shape != null
          ? ClipPath.shape(
              clipBehavior: clip,
              shape: shape!,
              child: bottomSheetContent,
            )
          : ClipRRect(
              clipBehavior: clip,
              borderRadius: BorderRadius.vertical(top: topRadius),
              child: bottomSheetContent,
            ),
    );
    if (scopedOverlayStyle != null) {
      bottomSheetContainer = AnnotatedRegion<SystemUiOverlayStyle>(
        value: scopedOverlayStyle,
        child: bottomSheetContainer,
      );
    }
    return bottomSheetContainer;
  }
}

Future<T?> showCupertinoModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool expand = false,
  AnimationController? secondAnimation,
  Curve? animationCurve,
  Curve? previousRouteAnimationCurve,
  bool useRootNavigator = false,
  bool bounce = true,
  bool? isDismissible,
  bool enableDrag = true,
  ModalBottomSheetController? modalController,
  Radius topRadius = _kDefaultTopRadius,
  Duration? duration,
  RouteSettings? settings,
  Color? transitionBackgroundColor,
  BoxShadow? shadow,
  SystemUiOverlayStyle? overlayStyle,
  double? closeProgressThreshold,
}) async {
  assert(debugCheckHasMediaQuery(context));
  final hasMaterialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) !=
          null;
  final barrierLabel = hasMaterialLocalizations
      ? MaterialLocalizations.of(context).modalBarrierDismissLabel
      : '';
  final result =
      await Navigator.of(context, rootNavigator: useRootNavigator).push(
    CupertinoModalBottomSheetRoute<T>(
      builder: builder,
      containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
        child: child,
        backgroundColor: backgroundColor,
        topRadius: topRadius,
        shape: shape,
        shadow: shadow,
        overlayStyle: overlayStyle,
        expand: expand,
      overlayStyle: overlayStyle,),
      secondAnimationController: secondAnimation,
      expanded: expand,
      closeProgressThreshold: closeProgressThreshold,
      barrierLabel: barrierLabel,
      elevation: elevation,
      bounce: bounce,
      shape: shape,
      clipBehavior: clipBehavior,
      isDismissible: isDismissible ?? expand == false ? true : false,
      modalBarrierColor: barrierColor ?? Colors.black12,
      enableDrag: enableDrag,
      modalController: modalController,
      topRadius: topRadius,
      animationCurve: animationCurve,
      previousRouteAnimationCurve: previousRouteAnimationCurve,
      duration: duration,
      settings: settings,
      transitionBackgroundColor: transitionBackgroundColor ?? Colors.black,
      overlayStyle: overlayStyle,
    ),
  );
  return result;
}

class CupertinoModalBottomSheetRoute<T> extends ModalSheetRoute<T> {
  final Radius topRadius;
  final ShapeBorder? shape;
  final Clip clipBehavior;

  final Curve? previousRouteAnimationCurve;

  final BoxShadow? boxShadow;

  // Background color behind all routes
  // Black by default
  final Color? transitionBackgroundColor;
  @Deprecated(
    'Will be ignored. OverlayStyle is computed from luminance of transitionBackgroundColor',
  )
  final SystemUiOverlayStyle? overlayStyle;

  CupertinoModalBottomSheetRoute({
    required super.builder,
    super.containerBuilder,
    super.closeProgressThreshold,
    super.barrierLabel,
    double? elevation,
    this.shape,
    Clip? clipBehavior,
    super.secondAnimationController,
    super.animationCurve,
    super.modalBarrierColor,
    super.bounce = true,
    super.isDismissible,
    super.enableDrag,
    super.modalController,
    required super.expanded,
    super.duration,
    super.settings,
    super.scrollController,
    this.boxShadow = _kDefaultBoxShadow,
    this.transitionBackgroundColor,
    this.topRadius = _kDefaultTopRadius,
    this.previousRouteAnimationCurve,
    this.overlayStyle,
  }) : clipBehavior = clipBehavior ?? Clip.antiAlias;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final distanceWithScale = (paddingTop + _kPreviousPageVisibleOffset) * 0.9;
    final offsetY = secondaryAnimation.value * (paddingTop - distanceWithScale);
    final scale = 1 - secondaryAnimation.value / 10;
    return AnimatedBuilder(
      builder: (context, child) => Transform.translate(
        offset: Offset(0, offsetY),
        child: Transform.scale(
          scale: scale,
          child: child,
          alignment: Alignment.topCenter,
        ),
      ),
      child: child,
      animation: secondaryAnimation,
    );
  }

  @override
  Widget getPreviousRouteTransition(
      BuildContext context, Animation<double> secondAnimation, Widget child) {
    return _CupertinoModalTransition(
      secondaryAnimation: secondAnimation,
      body: child,
      animationCurve: previousRouteAnimationCurve,
      topRadius: topRadius,
      shape: shape,
      clip: clipBehavior,
      backgroundColor: transitionBackgroundColor ?? Colors.black,
    );
  }
}

class _CupertinoModalTransition extends StatelessWidget {
  final Animation<double> secondaryAnimation;
  final Radius topRadius;
  final ShapeBorder? shape;
  final Clip clip;
  final Curve? animationCurve;
  final Color backgroundColor;

  final Widget body;

  const _CupertinoModalTransition({
    required this.secondaryAnimation,
    required this.body,
    required this.topRadius,
    this.shape,
    Clip? clip,
    this.backgroundColor = Colors.black,
    this.animationCurve,
  }) : clip = clip ?? Clip.antiAlias;

  @override
  Widget build(BuildContext context) {
    var startRoundCorner = 0.0;
    final paddingTop = MediaQuery.of(context).padding.top;
    if (Theme.of(context).platform == TargetPlatform.iOS && paddingTop > 20) {
      startRoundCorner = 38.5;
      //https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    }

    final curvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: animationCurve ?? Curves.easeOut,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      child: body,
      builder: (context, child) {
        final progress = curvedAnimation.value;
        final yOffset = progress * paddingTop;
        final scale = 1 - progress / 10;
        final radius = progress == 0
            ? 0.0
            : (1 - progress) * startRoundCorner + progress * topRadius.x;

        Widget content = CupertinoUserInterfaceLevel(
          data: CupertinoUserInterfaceLevelData.elevated,
          child: Builder(
            builder: (context) => CupertinoTheme(
              data: createPreviousRouteTheme(context, curvedAnimation),
              child: CupertinoUserInterfaceLevel(
                data: CupertinoUserInterfaceLevelData.base,
                child: child!,
              ),
            ),
          ),
        );

        Widget clipContainer = shape == null
            ? ClipRRect(
                clipBehavior: clip,
                borderRadius: BorderRadius.circular(radius),
                child: content,
              )
            : ClipPath.shape(
                clipBehavior: clip,
                shape: shape!,
                child: content,
              );

        return Stack(
          children: <Widget>[
            Container(color: backgroundColor),
            Transform.translate(
              offset: Offset(0, yOffset),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: clipContainer,
              ),
            ),
          ],
        );
      },
    );
  }

  CupertinoThemeData createPreviousRouteTheme(
    BuildContext context,
    Animation<double> animation,
  ) {
    final cTheme = CupertinoTheme.of(context);

    final systemBackground = CupertinoDynamicColor.resolve(
      cTheme.scaffoldBackgroundColor,
      context,
    );

    final barBackgroundColor = CupertinoDynamicColor.resolve(
      cTheme.barBackgroundColor,
      context,
    );

    var previousRouteTheme = cTheme;

    if (cTheme.scaffoldBackgroundColor is CupertinoDynamicColor) {
      final dynamicScaffoldBackgroundColor =
          cTheme.scaffoldBackgroundColor as CupertinoDynamicColor;

      /// BackgroundColor for the previous route with forced using
      /// of the elevated colors
      final elevatedScaffoldBackgroundColor =
          CupertinoDynamicColor.withBrightnessAndContrast(
        color: dynamicScaffoldBackgroundColor.elevatedColor,
        darkColor: dynamicScaffoldBackgroundColor.darkElevatedColor,
        highContrastColor:
            dynamicScaffoldBackgroundColor.highContrastElevatedColor,
        darkHighContrastColor:
            dynamicScaffoldBackgroundColor.darkHighContrastElevatedColor,
      );

      previousRouteTheme = previousRouteTheme.copyWith(
        scaffoldBackgroundColor: ColorTween(
          begin: systemBackground,
          end: elevatedScaffoldBackgroundColor.resolveFrom(context),
        ).evaluate(animation),
        primaryColor: CupertinoColors.placeholderText.resolveFrom(context),
      );
    }

    if (cTheme.barBackgroundColor is CupertinoDynamicColor) {
      final dynamicBarBackgroundColor =
          cTheme.barBackgroundColor as CupertinoDynamicColor;

      /// NavigationBarColor for the previous route with forced using
      /// of the elevated colors
      final elevatedBarBackgroundColor =
          CupertinoDynamicColor.withBrightnessAndContrast(
        color: dynamicBarBackgroundColor.elevatedColor,
        darkColor: dynamicBarBackgroundColor.darkElevatedColor,
        highContrastColor: dynamicBarBackgroundColor.highContrastElevatedColor,
        darkHighContrastColor:
            dynamicBarBackgroundColor.darkHighContrastElevatedColor,
      );

      previousRouteTheme = previousRouteTheme.copyWith(
        barBackgroundColor: ColorTween(
          begin: barBackgroundColor,
          end: elevatedBarBackgroundColor.resolveFrom(context),
        ).evaluate(animation),
        primaryColor: CupertinoColors.placeholderText.resolveFrom(context),
      );
    }

    return previousRouteTheme;
  }
}

class CupertinoScaffoldInheirted extends InheritedWidget {
  final AnimationController? animation;

  final Radius? topRadius;
  final ShapeBorder? shape;
  final Color transitionBackgroundColor;

  const CupertinoScaffoldInheirted({
    this.animation,
    required super.child,
    this.topRadius,
    this.shape,
    required this.transitionBackgroundColor,
  }) : super();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

// Support
class CupertinoScaffold extends StatefulWidget {
  static CupertinoScaffoldInheirted? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CupertinoScaffoldInheirted>();

  final Widget body;
  final Radius topRadius;
  final ShapeBorder? shape;
  final Clip clipBehavior;
  final Color transitionBackgroundColor;
  final SystemUiOverlayStyle? overlayStyle;

  const CupertinoScaffold({
    super.key,
    required this.body,
    this.topRadius = _kDefaultTopRadius,
    this.shape,
    this.transitionBackgroundColor = Colors.black,
    this.overlayStyle,
    Clip? clipBehavior,
  }) : clipBehavior = clipBehavior ?? Clip.antiAlias;

  @override
  State<StatefulWidget> createState() => _CupertinoScaffoldState();

  static Future<T?> showCupertinoModalBottomSheet<T>({
    required BuildContext context,
    double? closeProgressThreshold,
    required WidgetBuilder builder,
    Curve? animationCurve,
    Curve? previousRouteAnimationCurve,
    Color? backgroundColor,
    Color? barrierColor,
    bool expand = false,
    bool useRootNavigator = false,
    bool bounce = true,
    bool? isDismissible,
    bool enableDrag = true,
    ModalBottomSheetController? modalController,
    Duration? duration,
    RouteSettings? settings,
    BoxShadow? shadow,
    @Deprecated(
      'Will be ignored. OverlayStyle is computed from luminance of transitionBackgroundColor',
    )
    SystemUiOverlayStyle? overlayStyle,
  }) async {
    assert(debugCheckHasMediaQuery(context));
    final isCupertinoApp =
        context.findAncestorWidgetOfExactType<CupertinoApp>() != null;
    var barrierLabel = '';
    if (!isCupertinoApp) {
      assert(debugCheckHasMaterialLocalizations(context));
      barrierLabel = MaterialLocalizations.of(context).modalBarrierDismissLabel;
    }
    final topRadius = CupertinoScaffold.of(context)!.topRadius;
    final shape = CupertinoScaffold.of(context)!.shape;
    final transitionBackgroundColor =
        CupertinoScaffold.of(context)!.transitionBackgroundColor;
    final overlayStyle = overlayStyleFromColor(transitionBackgroundColor);
    final result = await Navigator.of(context, rootNavigator: useRootNavigator)
        .push(CupertinoModalBottomSheetRoute<T>(
      closeProgressThreshold: closeProgressThreshold,
      builder: builder,
      secondAnimationController: CupertinoScaffold.of(context)!.animation,
      containerBuilder: (context, _, child) => _CupertinoBottomSheetContainer(
        child: child,
        backgroundColor: backgroundColor,
        topRadius: topRadius ?? _kDefaultTopRadius,
        shape: shape,
        shadow: shadow,
        expand: expand,
        overlayStyle: overlayStyle,
      ),
      expanded: expand,
      barrierLabel: barrierLabel,
      bounce: bounce,
      isDismissible: isDismissible ?? expand == false ? true : false,
      modalBarrierColor: barrierColor ?? Colors.black12,
      enableDrag: enableDrag,
      modalController: modalController,
      topRadius: topRadius ?? _kDefaultTopRadius,
      shape: shape,
      animationCurve: animationCurve,
      previousRouteAnimationCurve: previousRouteAnimationCurve,
      duration: duration,
      settings: settings,
    ));
    return result;
  }
}

class _CupertinoScaffoldState extends State<CupertinoScaffold>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(duration: Duration(milliseconds: 350), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffoldInheirted(
      animation: animationController,
      topRadius: widget.topRadius,
      shape: widget.shape,
      transitionBackgroundColor: widget.transitionBackgroundColor,
      child: _CupertinoModalTransition(
        secondaryAnimation: animationController,
        body: widget.body,
        topRadius: widget.topRadius,
        shape: widget.shape,
        clip: widget.clipBehavior,
        backgroundColor: widget.transitionBackgroundColor,
      ),
    );
  }
}
