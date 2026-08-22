# Image loading and cache
-keep class flutter.** { *; }
-keep class image.** { *; }
-keepclassmembers class * {
    @dart.* interface <types>;
}

# Riverpod / State management (general keep)
-keep class * extends Riverpod { *; }
-keep class * implements Riverpod { *; }

# Freezed code generation
-keep class **.freezed.** { *; }

# GoRouter
-keep class com.acp.acp_router.GoRoute { *; }
-keep enum com.acp.acp_router.GoRouteType { *; }

# ACP adapter & daemon
-keep class com.acp.** { *; }
-keep class agentclientprotocol.** { *; }

# Core services
-keep class com.acp.acp_remote.** { *; }

# Websocket / channel
-keep class web_socket_channel.** { *; }
-keep class web_socket_channel.platform.** { *; }

# Mobile scanner
-keep class mobile_scanner.** { *; }
-dontwarn mobile_scanner.**

# Flex color scheme
-keep class flex_color_scheme.** { *; }
-dontwarn flex_color_scheme.**

# Intl
-keep class intl.** { *; }
-dontwarn intl.**

# Shared preferences
-keep class shared_preferences.** { *; }
-dontwarn shared_preferences.**

# Dart SDK
-keep class dart.** { *; }

# Keep application code
-keep class dev.runmote.app.** { *; }

# Needed for Flutter framework
-keep class androidx.annotation.** { *; }
-keep class kotlin.** { *; }

# Needed for Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Needed for image picking / file picking
-keep class file_picker.** { *; }
-dontwarn file_picker.**

# Needed for permission handler
-keep class permission_handler.** { *; }
-dontwarn permission_handler.**

# Keep models and freezed-generated code
-keep class dev.runmote.app.core.models.** { *; }
-keep class dev.runmote.app.shared.** { *; }
-keep class dev.runmote.app.features.** { *; }

# General keep for Dart classes
-keepclassmembers class * {
    @dartjson *;
}

# Keep Dart runtime
-keep class java.lang.String { *; }

# Allow optimization
-optimizationpasses 5

# Trust not keep if not needed
-assumenosideeffects class java.lang.Object {
    public boolean equals(java.lang.Object);
    public int hashCode();
    public java.lang.String toString();
}