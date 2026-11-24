# Flutter Engine & Plugin Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve Native and Synthetic Entry points
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Keep Flutter Generated Plugin Registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
