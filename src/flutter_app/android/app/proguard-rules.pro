# Flutter engine and plugins (Java/Kotlin side only; Dart code lives in libapp.so)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.text.** { *; }
-keep class io.flutter.plugin.* { *; }
-dontwarn io.flutter.**

# App entry point
-keep class com.acp.acp_remote.MainActivity { *; }

# Only keep specific needed classes from plugins, not entire packages
# file_picker - keep plugin classes un-obfuscated so Play pre-launch reports
# show readable names (package renamed from com.baseflow in v11+)
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn org.apache.tika.**
-dontwarn com.mr.flutter.plugin.filepicker.**

# mobile_scanner - keep only needed components
-keep class dev.steenbakker.mobile_scanner.ScanActivity { *; }
-keep class dev.steenbakker.mobile_scanner.* { *; }
-dontwarn dev.steenbakker.mobile_scanner.**

# mobile_scanner: R8 full mode strips ML Kit classes that are only reached
# reflectively, causing "Attempt to invoke virtual method '...' on a null
# object reference" at camera start in release builds (upstream fix:
# juliansteenbakker/mobile_scanner#1726)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.libraries.barhopper.** { *; }
-keep class com.google.photos.** { *; }
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.libraries.barhopper.**

# permission_handler - keep only needed components
-keep class com.baseflow.permissionhandler.PermissionHandler { *; }
-dontwarn com.baseflow.permissionhandler.**

# Preserve annotations used by plugins
-keepattributes *Annotation*
