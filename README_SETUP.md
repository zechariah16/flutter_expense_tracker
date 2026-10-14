# Setup

1. Create the project and add packages (from your terminal):

       flutter create --org com.yourname --platforms android,ios expense_tracker
       cd expense_tracker
       flutter pub add flutter_riverpod sqflite path intl uuid
       flutter pub add --dev sqflite_common_ffi

2. Delete the generated `lib/main.dart` and `test/widget_test.dart`.
3. Copy this folder's `lib/` and `test/` into the project (merge, replace when asked).
4. The package name must be `expense_tracker` (tests import `package:expense_tracker/...`).
5. Run:

       flutter pub get
       flutter analyze
       flutter test
       flutter run
