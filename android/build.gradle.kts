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
        // removed google-services classpath
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
    
    afterEvaluate {
        val project = this
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            if (android is com.android.build.gradle.BaseExtension) {
                // Force Compile SDK to 36 for all plugins to ensure compatibility
                android.compileSdkVersion("android-36")
                
                if (android is com.android.build.gradle.LibraryExtension) {
                    val manifestFile = project.file("src/main/AndroidManifest.xml")
                    if (manifestFile.exists()) {
                        val content = manifestFile.readText()
                        
                        // 1. Extract namespace from manifest if not already set in build.gradle
                        if (android.namespace == null) {
                            val match = Regex("package=\"([^\"]*)\"").find(content)
                            if (match != null) {
                                android.namespace = match.groupValues[1]
                            }
                        }
                        
                        // 2. AGP 8.0+ fails if 'package' attribute is present in Manifest source.
                        // We strip it here to satisfy the strict check.
                        if (content.contains("package=")) {
                            try {
                                val updatedContent = content.replace(Regex("\\s+package=\"[^\"]*\""), "")
                                                           .replace(Regex("package=\"[^\"]*\""), "")
                                manifestFile.writeText(updatedContent)
                                logger.lifecycle("Successfully patched manifest for plugin: ${project.name}")
                            } catch (e: Exception) {
                                logger.warn("Failed to patch manifest for ${project.name}: ${e.message}")
                            }
                        }
                    }
                    
                    // Final fallback for namespace
                    if (android.namespace == null) {
                        android.namespace = "com.example.${project.name.replace("-", "_")}"
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
