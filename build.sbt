// This gives us a nicer handle to the root project instead of using the
// implicit one
lazy val bossaRoot = Project("bossaRoot", file("."))

lazy val commonSettings = Seq(
  organization := "edu.berkeley.cs",
  version := "1.3",
  scalaVersion := "2.12.10",
  test in assembly := {},
  scalacOptions ++= Seq("-deprecation","-unchecked","-Xsource:2.11"),
  addCompilerPlugin("org.scalamacros" % "paradise" % "2.1.1" cross CrossVersion.full),
  unmanagedBase := (bossaRoot / unmanagedBase).value,
  exportJars := true,
  resolvers ++= Seq(
    Resolver.sonatypeRepo("snapshots"),
    Resolver.sonatypeRepo("releases"),
    Resolver.mavenLocal))

// Subproject definitions begin

val chiselVersion = "3.4.1"
lazy val chiselLib = "edu.berkeley.cs" %% "chisel3" % chiselVersion

lazy val testchipip = (project in file("generators/testchipip"))
  .dependsOn(rocketchip, sifive_blocks)
  .settings(commonSettings)

lazy val rocketchip = (project in file("generators/rocket-chip"))
  .settings(commonSettings)

lazy val chipyard = (project in file("generators/chipyard"))
  .dependsOn(testchipip, rocketchip, boom, sifive_blocks, iocell)
  .settings(commonSettings)

lazy val boom = (project in file("generators/boom"))
  .dependsOn(testchipip, rocketchip)
  .settings(commonSettings)

lazy val iocell = (project in file("./tools/barstools/iocell/"))
  .settings(libraryDependencies += chiselLib)
  .settings(commonSettings)

lazy val sifive_blocks = (project in file("generators/sifive-blocks"))
  .dependsOn(rocketchip)
  .settings(commonSettings)
