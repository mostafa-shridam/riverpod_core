import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing values live in the untracked android/key.properties (see tool/release/README.md).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.example.riverpod_core"
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.riverpod_core"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { rootProject.file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Real signing only. Without android/key.properties a release build is refused
            // (see the taskGraph check below); the debug key is never used for a release artifact.
            signingConfig = if (hasReleaseKey) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

// Release artifacts (assemble/bundle/package ...Release) require android/key.properties.
// Debug/profile builds (flutter run) are unaffected.
gradle.taskGraph.whenReady {
    if (!hasReleaseKey) {
        val releaseTask = allTasks.firstOrNull {
            it.project == project && Regex("^(assemble|bundle|package)(.*)Release$").matches(it.name)
        }
        if (releaseTask != null) {
            throw GradleException(
                "Release build requires android/key.properties (not found). " +
                    "Copy android/key.properties.example to android/key.properties and fill it in; " +
                    "see tool/release/README.md. Release builds are never signed with the debug key."
            )
        }
    }
}
dependencies {

    // مهم جداً: لازم يكون قبل أي dependencies ثانية
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")

    // Flutter will inject its dependencies automatically
}

// هذا السطر مهم جداً جداً لكي لا يعطي Flutter خطأ في KTS
configurations.all {
    resolutionStrategy {
        force("com.android.tools:desugar_jdk_libs:2.0.4")
    }
}
flutter {
    source = "../.."
}
