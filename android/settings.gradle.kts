pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()

        maven {
           url= uri("https://phonepe.mycloudrepo.io/public/repositories/phonepe-intentsdk-android")
        }
    }
}

//plugins {
//    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
////    id("com.android.application") version "8.7.0" apply false
//    id("com.android.application") version "8.6.0" apply false
////    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
//    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
//    id ("com.google.gms.google-services") version "4.4.2" apply false
//}

//plugins {
//    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
//    id("com.android.application") version "8.6.0" apply false
//    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
//    id("com.google.gms.google-services") version "4.4.2" apply false
//}

//plugins {
//    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
//    id("com.android.application") version "8.6.0" apply false   // ye theek hai, ya agar chaaho to 8.7.0/8.8.0 try kar sakte ho lekin 8.6.0 safe hai Flutter ke saath
//    id("org.jetbrains.kotlin.android") version "2.3.20" apply false   // ← YAHAN CHANGE KAR DO (latest stable)
//    id("com.google.gms.google-services") version "4.4.2" apply false
//}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}


include(":app")
