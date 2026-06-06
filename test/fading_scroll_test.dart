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

  testWidgets('keeps a stable ShaderMask when content fits the viewport',
      (tester) async {
    // Keep the wrapper stable even when a single short item cannot overflow the
    // 400px viewport. Toggling the wrapper disposes focused descendants when
    // content later starts or stops overflowing.
    await tester.pumpWidget(
      _wrap(
        builder: (context, controller) => ListView(
          controller: controller,
          children: const [SizedBox(height: 50, child: Text('only item'))],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('keeps text input open when content starts overflowing',
      (tester) async {
    Widget wrapTextList(int extraItemCount) {
      return _wrap(
        builder: (context, controller) => ListView(
          controller: controller,
          children: [
            const TextField(),
            for (var i = 0; i < extraItemCount; i++)
              SizedBox(height: 100, child: Text('extra item $i')),
          ],
        ),
      );
    }

    await tester.pumpWidget(wrapTextList(0));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.showKeyboard(textField);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.pumpWidget(wrapTextList(20));
    await tester.pumpAndSettle();

    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.testTextInput.isVisible, isTrue);
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
