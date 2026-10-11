fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android build

```sh
[bundle exec] fastlane android build
```

Flutter 앱 빌드 (AAB, 릴리스 서명)

### android internal

```sh
[bundle exec] fastlane android internal
```

내부 테스트 트랙에 배포 (첫 출시 전 draft 앱은 DRAFT=1)

### android alpha

```sh
[bundle exec] fastlane android alpha
```

비공개 테스트 트랙에 배포

### android production

```sh
[bundle exec] fastlane android production
```

프로덕션에 배포

### android listing

```sh
[bundle exec] fastlane android listing
```

스토어 등록정보 전체(10개 언어 제목·설명·그래픽·스크린샷) 업로드. 앱 빌드는 올리지 않는다

### android iap

```sh
[bundle exec] fastlane android iap
```

인앱 상품 5개 생성/갱신 (Play Developer API, 소모·비소모 동일하게 관리형 상품)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
