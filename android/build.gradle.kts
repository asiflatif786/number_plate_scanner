allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add Google Services classpath for Firebase
        classpath("com.google.gms:google-services:4.4.1")
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
    // Standard Flutter subproject evaluation dependency
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
    }
    
    // Safely force SDK 36 on all subprojects to resolve dependency conflicts
    val forceSdkConfig = Action<Project> {
        if (hasProperty("android")) {
            val android = extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            android?.compileSdkVersion("android-36")
        }
    }

    if (state.executed) {
        forceSdkConfig.execute(this)
    } else {
        afterEvaluate(forceSdkConfig)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
