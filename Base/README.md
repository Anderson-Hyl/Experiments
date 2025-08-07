# Base

Base layer code with minimal external dependencies. Can be used by all packages/targets in the app.

## Local dependencies

 - 

## External dependencies

- RxSwift, RxCocoa, RxRelay, swift-algorithms

## Note

This package should not contain UI dependent code with the exception of RxCocoa extensions.
When adding extension to RxCocoa the code should be flag using `#if os(iOS)` because this package is also used by the AppleWatch app.
