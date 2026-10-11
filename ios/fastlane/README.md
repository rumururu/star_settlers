fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios register_id

```sh
[bundle exec] fastlane ios register_id
```

Apple Developer 에 번들 ID 등록 + 인앱 결제 기능 (API 키, 웹 로그인 불필요)

### ios sync_profile

```sh
[bundle exec] fastlane ios sync_profile
```

배포용 프로비저닝 프로필 받기 (수동 서명)

### ios build

```sh
[bundle exec] fastlane ios build
```

IPA 빌드

### ios beta

```sh
[bundle exec] fastlane ios beta
```

TestFlight 업로드

### ios release

```sh
[bundle exec] fastlane ios release
```

App Store 빌드 업로드 (심사 제출은 수동)

### ios listing

```sh
[bundle exec] fastlane ios listing
```

App Store 등록정보(10개 언어 이름·부제·설명·키워드·스크린샷)만 업로드. 빌드·심사 제출 없음

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
