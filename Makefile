generate-code:
	fvm flutter gen-l10n
	fvm dart run build_runner build --delete-conflicting-outputs

build-release-android:
	fvm flutter clean
	fvm flutter pub get
	make generate-code
	fvm flutter build appbundle --release
	open build/app/outputs/bundle/release