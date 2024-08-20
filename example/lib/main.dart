import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Fading Scroll',
      home: HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fading Scroll'),
      ),
      body: ListView(
        children: [
          ...const <ExampleWidget>[
            VerticalListViewExample(),
            PageViewExample(),
            MixedViewExample(),
          ].map(
            (example) => ListTile(
              title: Text(example.title),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(example.title),
                      ),
                      body: example,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

abstract class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  String get title;
}

class VerticalListViewExample extends ExampleWidget {
  const VerticalListViewExample({
    super.key,
    this.startColor = const Color(0xFFFF1FCE),
    this.endColor = const Color(0xFFFFBB11),
  });

  final Color startColor;
  final Color endColor;

  @override
  String get title => 'Vertical ListView';

  @override
  State<VerticalListViewExample> createState() =>
      _VerticalListViewExampleState();
}

class _VerticalListViewExampleState extends State<VerticalListViewExample>
    with AutomaticKeepAliveClientMixin<VerticalListViewExample> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FadingScroll(
      fadingSize: 200,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          children: [
            for (var i = 0; i < 100; i++)
              Card(
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color.lerp(
                        widget.startColor,
                        widget.endColor,
                        i / 100.0,
                      ),
                    ),
                  ),
                  title: Text('Color $i'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class PageViewExample extends ExampleWidget {
  const PageViewExample({
    super.key,
  });
  @override
  String get title => 'PageView';

  @override
  State<PageViewExample> createState() => _PageViewExampleState();
}

class _PageViewExampleState extends State<PageViewExample> {
  late final PageController controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadingScroll(
      controller: controller,
      builder: (context, controller) {
        return PageView(
          controller: this.controller,
          children: [
            for (var i = 0; i < 6; i++)
              Card(
                child: ListView(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Color.lerp(
                          const Color(0xFFFF1FCE),
                          const Color(0xFFFFBB11),
                          i / 6.0,
                        ),
                      ),
                    ),
                    Text(
                      'Color $i',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class MixedViewExample extends ExampleWidget {
  const MixedViewExample({
    super.key,
  });
  @override
  String get title => 'Mixed Example';

  @override
  State<MixedViewExample> createState() => _MixedViewExampleState();
}

class _MixedViewExampleState extends State<MixedViewExample> {
  late final PageController controller = PageController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadingScroll(
      fadingSize: 100,
      controller: controller,
      builder: (context, controller) {
        return PageView(
          controller: this.controller,
          children: [
            for (var i = 0; i < 6; i++) const VerticalListViewExample(),
          ],
        );
      },
    );
  }
}
