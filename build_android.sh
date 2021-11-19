#!/bin/bash

echo Numero da versao \(ex: 3\)?
read versionNumber

echo Nome da versao \(ex: 1.0.1\)?
read versionName

echo Keystore password?
read keystorePassword

echo Key password?
read keyPassword

KEYSTORE=../../keys/android/cicdrn_prod.keystore KEYSTORE_PASSWORD=$keystorePassword KEY_ALIAS=cicdrn_prod KEY_PASSWORD=$keyPassword build_number=$versionNumber version_name=$versionName fastlane android build_rc
