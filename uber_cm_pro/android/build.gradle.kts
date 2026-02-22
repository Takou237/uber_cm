allprojects {
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// --- AJOUT POUR FIREBASE ICI ---
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Ajout du plugin Google Services (format Kotlin)
        classpath("com.google.gms:google-services:4.4.0")
    }
}