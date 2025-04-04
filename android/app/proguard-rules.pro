# Razorpay
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Google Pay
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.apps.nbu.paisa.inapp.** { *; }

# Keep Annotations
-keep @interface proguard.annotation.Keep
-keep @proguard.annotation.Keep class *
-keepclassmembers class * {
    @proguard.annotation.Keep *;
}