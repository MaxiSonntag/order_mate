generate-code:
	fvm flutter gen-l10n
	fvm dart run build_runner build --delete-conflicting-outputs

build-release-android:
	fvm flutter clean
	fvm flutter pub get
	make generate-code
	fvm flutter build appbundle --release
	open build/app/outputs/bundle/release

maestro-install-ios:
	fvm flutter build ios --simulator
	fvm flutter install

maestro-store-screenshots-de-all:
	bash .maestro/run_store_screenshots_de_all.sh

maestro-store-screenshots-de-ios:
	bash .maestro/run_store_screenshots_de_ios.sh

maestro-store-screenshots-de-android:
	bash .maestro/run_store_screenshots_de_android.sh
