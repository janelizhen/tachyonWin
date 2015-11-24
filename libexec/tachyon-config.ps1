# Default tarball installation environment variables
# To use a specific environment setting, create tachyon-layout.ps1 under "common bin"
# Set-Variable -Name VERSION -Value "0.8.0" -Scope 5
$global:VERSION = "0.9.0-SNAPSHOT"
$global:TACHYON_PREFIX = "C:/Users/tachyontest1/tachyon" #"$($PSScriptRoot)\.." -replace "\\","\\"
$global:TACHYON_HOME = $global:TACHYON_PREFIX
$global:TACHYON_CONF_DIR = "$global:TACHYON_HOME/conf"
$global:TACHYON_LOGS_DIR = "$global:TACHYON_HOME/logs"
$global:TACHYON_JARS = "$global:TACHYON_HOME/assembly/target/tachyon-assemblies-$VERSION-jar-with-dependencies.jar"

# Run environment setting script
& "$global:TACHYON_CONF_DIR\tachyon-env.ps1"

# Set class path
if (-not $global:TACHYON_PREPEND_TACHYON_CLASSES)
{
    $global:CLASSPATH = "$global:TACHYON_CONF_DIR/;$global:TACHYON_JARS;$global:TACHYON_CLASSPATH"
}
else
{
    $global:CLASSPATH = "$global:TACHYON_CONF_DIR/;$global:TACHYON_CLASSPATH;$global:TACHYON_JARS"
}