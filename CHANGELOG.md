## 0.9.3

* Fixed a crash (`ScrollController attached to multiple scroll views`) when the same `ScrollController` is shared across multiple scroll views. `FadingScroll` now degrades gracefully instead of asserting when more than one position is attached.

## 0.9.2

* Skip the `ShaderMask` (and its offscreen `saveLayer` pass) when neither edge is faded, improving performance for content that fits the viewport.
* Switched from `AnimatedBuilder` to `ListenableBuilder` to better reflect intent.
* Raised the minimum Flutter constraint to `>=3.10.0`.
* Added a widget test suite.

## 0.9.1

* Introduced `shaderPadding` property to apply padding to the shader, enhancing support for use cases such as [CustomScrollView] with a sticky header.

## 0.9.0

* Initial release
