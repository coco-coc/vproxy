#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors
# Feel free to reuse and adapt this script for your own projects

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'staging' or 'production'."
  exit 1
fi

case $1 in
  staging)
    flutterfire config \
      --project=vproxy-1407e-staging \
      --out=lib/firebase_options_staging.dart \
      --ios-bundle-id=com.5vnetwork.x.staging \
      --ios-out=ios/flavors/staging/GoogleService-Info.plist \
      --android-package-name=com5vnetwork.vproxy.staging \
      --android-out=android/app/src/staging/google-services.json \
      --macos-bundle-id=com.5vnetwork.x.staging \
      --macos-out=macos/Runner/staging/GoogleService-Info.plist 
    ;;
  production)
    flutterfire config \
      --project=umivpn \
      --out=lib/firebase_options.dart \
      --ios-bundle-id=com.umivpn \
      --ios-out=ios/flavors/production/GoogleService-Info.plist \
      --android-package-name=com5vnetwork.umi \
      --android-out=android/app/src/production/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'staging' or 'production'."
    exit 1
    ;;
esac