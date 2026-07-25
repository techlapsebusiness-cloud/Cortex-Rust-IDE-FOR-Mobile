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

// receive_sharing_intent 1.9.0 uses a `kotlin {}` DSL block but no longer applies
// the Kotlin Android plugin itself (expects Flutter "built-in Kotlin"). Apply it
// before that project's build.gradle evaluates so `kotlin {}` resolves.
subprojects {
    beforeEvaluate {
        if (name == "receive_sharing_intent") {
            pluginManager.apply("org.jetbrains.kotlin.android")
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
