import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing scheme:
//
// If `android/key.properties` exists, the release build type is signed with a
// dedicated upload keystore described by that file (storeFile/storePassword/
// keyAlias/keyPassword). This is the config used for Play Store uploads.
//
// If `android/key.properties` does NOT exist (the default for fresh clones —
// secrets are never committed), the release build falls back to the debug
// keystore so contributors can still assemble and run release builds.
// A build signed this way MUST NOT be published.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

// Reads a mandatory entry from key.properties. A missing entry fails the build
// with an actionable message instead of an obscure NPE further down the line.
fun requiredKeystoreProperty(name: String): String =
    keystoreProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }
        ?: throw GradleException(
            "android/key.properties is present but has no usable '$name' entry. " +
                "Either add '$name=<value>' to android/key.properties or delete the " +
                "file to fall back to debug signing.",
        )

android {
    namespace = "de.gewerber.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "de.gewerber.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                storeFile = file(requiredKeystoreProperty("storeFile"))
                storePassword = requiredKeystoreProperty("storePassword")
                keyAlias = requiredKeystoreProperty("keyAlias")
                keyPassword = requiredKeystoreProperty("keyPassword")
            }
            // Fail fast if the keystore itself is missing; otherwise the error
            // only surfaces late during the actual signing step.
            if (!signingConfigs.getByName("release").storeFile!!.exists()) {
                throw GradleException(
                    "Keystore not found at '${signingConfigs.getByName("release").storeFile}' " +
                        "(from android/key.properties 'storeFile'). Relative paths are " +
                        "resolved against android/app/.",
                )
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                logger.lifecycle(
                    "WARNING: android/key.properties not found - signing release " +
                        "with the DEBUG keystore. Fine for local builds, NOT for publishing.",
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
