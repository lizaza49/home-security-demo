fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios test
```
fastlane ios test
```

### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Crashlytics Beta

This will also make sure the profile is up to date. Takes the following arguments: 


:skip_submission    do not upload Build to Crashlitycs

:skip_version_bump  skip incrementing build version
### ios apple_beta
```
fastlane ios apple_beta
```
Submit a new Beta Build to Apple Test Flight

This will also make sure the profile is up to date. Takes the following arguments: 


:skip_submission    do not upload Build to Test Flight

:skip_version_bump  skip incrementing build version

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [https://docs.fastlane.tools](https://docs.fastlane.tools).
