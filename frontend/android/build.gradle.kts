allprojects {
    repositories {
        google()
        mavenCentral()
        mavenLocal()
        // Published Flutter SDK 3.2.3 still resolves its Android artifact on JitPack.
        maven {
            url = uri("https://jitpack.io")
            content { includeGroup("com.github.PayHereDevs") }
        }
        maven { url = uri("https://repo.repsy.io/mvn/payhere/payhere-mobilesdk-android/") }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
