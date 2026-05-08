import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keyProps = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(f.inputStream())
}

android {
    namespace = "com.shayshankrathore.ireland_visa_embassy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProps["keyAlias"] as String
            keyPassword = keyProps["keyPassword"] as String
            storeFile = file(keyProps["storeFile"] as String)
            storePassword = keyProps["storePassword"] as String
        }
    }

    defaultConfig {
        applicationId = "com.shayshankrathore.ireland_visa_embassy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "embassy"
    productFlavors {
        create("newdelhi") {
            dimension = "embassy"
            applicationId = "com.shayshankrathore.irelandvisa.newdelhi"
            resValue("string", "app_name", "Ireland Visa - New Delhi")
        }
        create("beijing") {
            dimension = "embassy"
            applicationId = "com.shayshankrathore.irelandvisa.beijing"
            resValue("string", "app_name", "Ireland Visa - Beijing")
        }
        create("abuja") {
            dimension = "embassy"
            applicationId = "com.shayshankrathore.irelandvisa.abuja"
            resValue("string", "app_name", "Ireland Visa - Abuja")
        }
        create("abudhabi") {
            dimension = "embassy"
            applicationId = "com.shayshankrathore.irelandvisa.abudhabi"
            resValue("string", "app_name", "Ireland Visa - Abu Dhabi")
        }
        create("ankara") {
            dimension = "embassy"
            applicationId = "com.shayshankrathore.irelandvisa.ankara"
            resValue("string", "app_name", "Ireland Visa - Ankara")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
