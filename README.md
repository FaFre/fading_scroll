# fading_scroll
## Quickstart

Add the dependency to `fading_scroll` to your `pubspec.yaml` file.

```bash
flutter pub add fading_scroll
```

Wrap your scrollable content in a `FadingScroll` widget and give the provided `ScrollController` to your scrollable widget.

```dart
@override
Widget build(BuildContext context) {
    return FadingScroll(
        builder: (context, controller) {
            return ListView(
                controller: controller,
                children: [
                    // ...
                ],
            ),
        },
    );
}
```

## Usage

### Customize fading size and scroll threshold

You can customise the effect by providing custom scroll extents and fading sizes.

```dart
@override
Widget build(BuildContext context) {
    return FadingScroll(
        fadingSize: 100,
        scrollExtent: 120,
        builder: (context, controller) {
            return ListView(
                controller: controller,
                children: [
                    // ...
                ],
            ),
        },
    );
}
```

### Using a different controller

You can also provide your own `ScrollController` to the `FadingScroll`. This may be useful for controller subclasses like the `PageController`. 

```dart
class _State_ extends State<Example> {
  late final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadingScroll(
      controller: pageController,
      builder: (context, controller) {
        return PageView(
          controller: pageController,
          children: [
              // ...
          ],
        );
      },
    );
  }
}
```
