import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({required FadingScrollWidgetBuilder builder}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        height: 400,
        child: FadingScroll(builder: builder),
      ),
    ),
  );
}

ListView _list(ScrollController controller, int count) {
  return ListView(
    controller: controller,
    children: List<Widget>.generate(
      count,
      (i) => SizedBox(height: 100, child: Text('item $i')),
    ),
  );
}

void main() {
  testWidgets('hands a working ScrollController to the builder',
      (tester) async {
    ScrollController? captured;
    await tester.pumpWidget(
      _wrap(
        builder: (context, controller) {
          captured = controller;
          return _list(controller, 50);
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.hasClients, isTrue);
  });

  testWidgets('inserts no ShaderMask when content fits the viewport',
      (tester) async {
    // A single short item cannot overflow the 400px viewport, so neither edge
    // fades and the mask must be skipped entirely.
    await tester.pumpWidget(
      _wrap(
        builder: (context, controller) => ListView(
          controller: controller,
          children: const [SizedBox(height: 50, child: Text('only item'))],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShaderMask), findsNothing);
  });

  testWidgets('inserts a ShaderMask when content overflows', (tester) async {
    // At the top of an overflowing list the bottom edge fades.
    await tester.pumpWidget(
      _wrap(builder: (context, controller) => _list(controller, 50)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('keeps the ShaderMask while scrolled into the middle',
      (tester) async {
    await tester.pumpWidget(
      _wrap(builder: (context, controller) => _list(controller, 50)),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    // Both edges have hidden content now, so the mask stays present.
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('does not crash when the controller is shared by two scrollables',
      (tester) async {
    // Sharing one ScrollController across multiple scroll views makes
    // `controller.position` throw (it asserts a single attached position).
    // FadingScroll must degrade gracefully instead of crashing.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FadingScroll(
            builder: (context, controller) => Row(
              children: [
                Expanded(child: _list(controller, 50)),
                Expanded(child: _list(controller, 50)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes an internally created controller without error',
      (tester) async {
    await tester.pumpWidget(
      _wrap(builder: (context, controller) => _list(controller, 50)),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
