extra["minSdkVersion"] = 24
extra["targetSdkVersion"] = 34
extra["compileSdkVersion"] = 34

allprojects {
    extra["minSdkVersion"] = 24
    extra["targetSdkVersion"] = 34
    extra["compileSdkVersion"] = 34
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    extra["minSdkVersion"] = 24
    afterEvaluate {
        val androidExt = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        androidExt?.apply {
            defaultConfig {
                minSdk = 24
                externalNativeBuild {
                    cmake {
                        arguments("-DCMAKE_CXX_FLAGS=-D_LIBCPP_SUPPORT_ANDROID_LOCALE_BIONIC_H")
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
