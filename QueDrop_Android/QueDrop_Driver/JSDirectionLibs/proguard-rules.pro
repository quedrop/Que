# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Applications/ADT/sdk/tools/proguard/proguard-android.txt
# You can ic_edit_pen the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Retrofit library
-dontwarn retrofit.**
-keep class retrofit.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# Parcel library
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

-keep class org.parceler.Parceler$$Parcels