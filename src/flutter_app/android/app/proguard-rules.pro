# Flutter engine and plugins (Java/Kotlin side only; Dart code lives in libapp.so)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.text.** { *; }
-keep class io.flutter.plugin.* { *; }
-dontwarn io.flutter.**

# App entry point
-keep class com.acp.acp_remote.MainActivity { *; }

# Only keep specific needed classes from plugins, not entire packages
# file_picker - keep only what's actually used
-keep class com.baseflow.filepicker.** { *; }
-dontwarn org.apache.tika.**
-dontwarn com.baseflow.filepicker.**

# mobile_scanner - keep only needed components
-keep class dev.steenbakker.mobile_scanner.ScanActivity { *; }
-keep class dev.steenbakker.mobile_scanner.* { *; }
-dontwarn dev.steenbakker.mobile_scanner.**

# permission_handler - keep only needed components
-keep class com.baseflow.permissionhandler.PermissionHandler { *; }
-dontwarn com.baseflow.permissionhandler.**

# Preserve annotations used by plugins
-keepattributes *Annotation*
