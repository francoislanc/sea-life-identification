
## Dev

### To regenerate mobx file
```
flutter packages pub run build_runner build --delete-conflicting-outputs
```
More info: https://pub.dev/packages/mobx_codegen#-readme-tab-


### To generate bundle
```
flutter build appbundle
```
More info: https://flutter.dev/docs/deployment/android

### To check deps
```
flutter pub run dependency_validator
```
