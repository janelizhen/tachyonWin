function printUsage
{
    Write-Host "usage:"
}

Write-Host "args: $args"
  
if ($($args.Count) -eq 0)
{
    printUsage
}
 
$COMMAND = $args[0]
Write-Host "Command: $COMMAND"

function shift
{
    param($toshift)
    $toshift[1..($toshift.Count)]
}

$args = shift -toshift $args
Write-Host "shifted: $args"

$bin = $PSScriptRoot

function bootstrapConf
{
    if ($($args.Count) -ne 1)
    {
        Write-Host "Usage:bootstrap-conf TACHYON_MASTER_HOSTNAME" 
        exit
    }
 
    $TACHYON_CONF_DIR = "$bin\..\conf"
    <# TODO: environment setting file, psd1? #>
    if (-not (Test-Path -Path "${TACHYON_CONF_DIR}\tachyon-env.ps1" ))
    {
        # Set up env file for bootstrap configuration
        $TOTAL_MEM = # Linux get this value from /proc/meminfo file
        $TOTAL_MEM = $TOTAL_MEM / 1024
        $TOTAL_MEM = $TOTAL_MEM * 2/3 # use 2/3 of total memory
    }
  
    # Create a default config that can be overridden later
    cp ${TACHYON_CONF_DIR}/tachyon-env.ps1.template ${TACHYON_CONF_DIR}/tachyon-env.ps1
    <# TODO: replace argument values in environment setting file, Not necessary for now as the windows template is substituted version#>
    #${TACHYON_SED} $"s/TACHYON_MASTER_ADDRESS = localhost/TACHYON_MASTER_ADDRESS${TACHYON_CONF_DIR}/tachyon-env.sh 
    #${TACHYON_SED} $"s/TACHYON_WORKER_MEMORY_SIZE = 1GB/TACHYON_WORKER_MEMORY_SIZE${TACHYON_CONF_DIR}/tachyon-env.sh 
 }

if ($COMMAND -eq "bootstrap-conf")
{
    bootstrapConf $args
    exit
}

$DEFAULT_LIBEXEC_DIR = "$bin/../libexec"
$global:TACHYON_LIBEXEC_DIR = $DEFAULT_LIBEXEC_DIR

# Run basic config for tachyon home directory structure settings
& "$global:TACHYON_LIBEXEC_DIR\tachyon-config.ps1"

function runTest
{
    $Usage = "Usage: tachyon runTest <Basic|BasicNonByteBuffer|BasicRawTable> <STORE|NO_STORE> <YNC_PERSIST|NO_PERSIST>"

    if ($($args.Count) -ne 3)
    {
        Write-Host $Usage
        exit
    }

    $MASTER_ADDRESS = $global:TACHYON_MASTER_ADDRESS # defined in tachyon-env.ps1
    if ($global:TACHYON_MASTER_ADDRESS -eq $null)
    {
        $MASTER_ADDRESS = "localhost"
    }

    $file = "\default_tests_files"
    $class = ""

    switch ($args[0])
    {
        Basic {
            $file += "\BasicFile_$($args[1])_$($args[2])"
            $class = "tachyon.examples.BasicOperations"
        }

        BasicNonByteBuffer {
            $file += "\BasicNonByteBuffer_$($args[1])_$($args[2])"
            $class = "tachyon.examples.BasicNonByteBufferOperations"
        }

        BasicRawTable {
            $file += "\BasicRawTable_$($args[1])_$($args[2])"
            $class = "tachyon.examples.BasicRawTableOperations"
        }

        default {
            Write-Host "Unknown test: $($args[0]) with $($args[1]) $($args[2])"
            Write-Host $Usage
            exit
        }
    }

    <#TODO: run tests #>
    Invoke-Expression "$bin\tachyon.ps1 tfs rmr $file"
    $script = {Invoke-Expression "$global:JAVA -cp $global:CLASSPATH $global:TACHYON_JAVA_OPTS $class tachyon://$MASTER_ADDRESS:19998 $file $($args[1]) $($args[2])"}
    Start-Job -ScriptBlock $script -ErrorVariable ev

    if ($ev -ne $null)
    {
        Write-Host $ev
        exit
    }
    return
}

function journalCrashTest
{
    $MASTER_ADDRESS = $global:TACHYON_MASTER_ADDRESS
    if ($global:TACHYON_MASTER_ADDRESS -eq $null)
    {
        $MASTER_ADDRESS = "localhost"
    }

    $class = "tachyon.examples.JournalCrashTest"

    $script = {Invoke-Expression "$global:JAVA -cp $global:CLASSPATH -Dtachyon.home=$global:TACHYON_HOME -Dtachyon.master.hostname=$MASTER_ADDRESS -Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR -Dtachyon.logger.type=USER_LOGGER $global:TACHYON_JAVA_OPTS $class $args"}
    Start-Job -ScriptBlock $script -ErrorVariable ev

    if ($ev -ne $null)
    {
        Write-Host "Test process was terminated"
        exit
    }
    return
}

function killAll
{
    if ($($args.Count) -ne 1)
    {
        Write-Host "Usage: tachyon killAll <WORD>"
        exit
    }

    $keyword = $args[0]
    $count = 0
    $ids = @()

    do
    {
        $javaprocess = ps | where {$_.ProcessName -eq 'java'}
        foreach ($process in $javaprocess)
        {
            $commandLine = Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)" | select CommandLine
            if ($commandLine.CommandLine.Contains($keyword))
            {
                $ids += $process.Id
            }
        }
        while ($ids.Count -ne 0)
        {
            foreach ($id in $ids)
            {
                kill -Id $id -Force
                $count++
            }
            $ids.Clear()
        }
    } while ($javaprocess -ne $null)

    Write-Host "Killed $count processes on $env:COMPUTERNAME"
}

function copyDir
{
    if ($($args.Count) -ne 1)
    {
        Write-Host "Usage: tachyon copyDir <path>"
        return
    }

    <# TODO #>
}

$PARAMETER = ""

Write-Host "$args"

if ($COMMAND -eq "format")
{
    if ($($args.Count) -eq 1)
    {
        if ("$args" -eq "-s")
        {
            if (($global:TACHYON_UNDERFS_ADDRESS -ne $null) -and (Test-Path -Path $global:TACHYON_UNDERFS_ADDRESS))
            {
                exit
            }
            else
            {
                $schemes = ("hdfs", "s3", "s3n", "glusterfs", "swift")
                foreach ($scheme in $schemes)
                {
                    if ($global:TACHYON_UNDERFS_ADDRESS -eq "$scheme`://*")
                    {
                        return
                    }
                }

                $args = shift -toshift $args
                Write-Host "shifted: $args"
            }
        }
        else
        {
            Write-Host "{Usage} $($MyInvocation.MyCommand.Name) format [-s]"
            exit
        }
    }
    elseif ($($args.Count) -gt 1)
    {
        Write-Host "{Usage} $($MyInvocation.MyCommand.Name) format [-s]"
        exit
    }

    if ($global:TACHYON_MASTER_ADDRESS -eq $null)
    {
        $global:TACHYON_MASTER_ADDRESS = "localhost"
    }

    & "$bin\tachyon-workers.ps1" "$bin\tachyon.ps1" formatWorker

    Write-Host "Formatting Tachyon Master @ $global:TACHYON_MASTER_ADDRESS"

    $CLASS = "tachyon.Format"
    $PARAMETER = "master"
}
elseif ($COMMAND -eq "formatWorker")
{
    Write-Host "Formatting Tachyon Worker @ $env:COMPUTERNAME"
    $CLASS = "tachyon.Format"
    $PARAMETER = "worker"
}
elseif ($COMMAND -eq "tfs")
{
    $CLASS = "tachyon.shell.TfsShell"
}
elseif ($COMMAND -eq "loadufs")
{
    $CLASS = "tachyon.client.UfsUtils"
}
elseif ($COMMAND -eq "runTest")
{
    runTest $args
    exit
}
elseif ($COMMAND -eq "runTests")
{
    $tachyonStorageTypes = ("STORE", "NO_STORE")
    $ufsStorageTypes = ("SYNC_PERSIST", "NO_PERSIST")

    $failed = 0 <#TODO: detect java job failure#>
    foreach ($storage in $tachyonStorageTypes)
    {
        foreach ($ufs in $ufsStorageTypes)
        {
            if (($storage -eq "NO_STORE") -and  ($ufs -eq "NO_PERSIST"))
            {
                continue
            }
            foreach ($example in ("Basic", "BasicNonByteBuffer", "BasicRawTable"))
            {
                $cmd = "$bin\tachyon.ps1 runTest $example $tachyonStorageType $ufsStorageType"
                Write-Host "Invoke-Expression $cmd -ErrorVariable ev"
                $job = Invoke-Expression $cmd -ErrorVariable ev

                if ($ev -ne $null)
                {
                    Write-Host "Test process was terminated"
                    exit
                }
            }
        }
    }

    if ($failed -gt 0)
    {
        Write-Host "Number of failed tests: $failed"
    }
    exit
}
elseif ($COMMAND -eq "journalCrashTest")
{
    journalCrashTest $args
    exit
}
elseif ($COMMAND -eq "killAll")
{
    killAll $args
    exit
}
elseif ($COMMAND -eq "copyDir")
{
    copyDir $args
    exit
}
elseif ($COMMAND -eq "thriftGen")
{
    <#TODO: thriftGen#>
    Write-Host "thriftGen is not available yet"
    exit
}
elseif ($COMMAND -eq "clearCache")
{
    <#TODO: clearCache#>
    Write-Host "clearCache is not available yet"
    exit
}
elseif ($COMMAND -eq "version")
{
    $CLASS = "tachyon.Version"
}
elseif ($COMMAND -eq "validateConf")
{
    $CLASS = "tachyon.ValidateConf"
}
else
{
    printUsage
    exit
}

#Write-Host "$global:JAVA" -cp $global:CLASSPATH "-Dtachyon.home=$global:TACHYON_HOME" "-Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR" "-Dtachyon.master.hostname=$global:TACHYON_MASTER_ADDRESS" "-Dtachyon.logger.type=USER_LOGGER" $global:TACHYON_JAVA_OPTS $CLASS $PARAMETER $args
Write-Host "$global:JAVA" `
-cp $global:CLASSPATH `
"-Dtachyon.home=/C/Users/tachyontest1/tachyon" `
"-Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR" `
"-Dtachyon.master.hostname=$global:TACHYON_MASTER_ADDRESS" `
"-Dtachyon.logger.type=USER_LOGGER" `
$global:TACHYON_JAVA_OPTS_LOG4J `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL_MAX `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_ALIAS `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_DIRS_PATH `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_DIRS_QUOTA `
$global:TACHYON_JAVA_OPTS_UNDERFS_ADDRESS `
$global:TACHYON_JAVA_OPTS_WORKER_MEMEORY_SIZE `
$global:TACHYON_JAVA_OPTS_MASTER_HOSTNAME `
$global:TACHYON_JAVA_OPTS_DISABLEJSR199 `
$global:TACHYON_JAVA_OPTS_PREFERIPV4STACK `
$CLASS `
$PARAMETER `
$args

& "$global:JAVA" `
-cp $global:CLASSPATH `
"-Dtachyon.home=/C/Users/tachyontest1/tachyon" `
"-Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR" `
"-Dtachyon.master.hostname=$global:TACHYON_MASTER_ADDRESS" `
"-Dtachyon.logger.type=USER_LOGGER" `
$global:TACHYON_JAVA_OPTS_LOG4J `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL_MAX `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_ALIAS `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_DIRS_PATH `
$global:TACHYON_JAVA_OPTS_WORKER_TIEREDSTORE_LEVEL0_DIRS_QUOTA `
$global:TACHYON_JAVA_OPTS_UNDERFS_ADDRESS `
$global:TACHYON_JAVA_OPTS_WORKER_MEMEORY_SIZE `
$global:TACHYON_JAVA_OPTS_MASTER_HOSTNAME `
$global:TACHYON_JAVA_OPTS_DISABLEJSR199 `
$global:TACHYON_JAVA_OPTS_PREFERIPV4STACK `
$CLASS `
$PARAMETER `
$args

#Start-Job -ScriptBlock $script -ErrorVariable ev

<#
C:\Program Files (x86)\Java\jre1.8.0_65\bin\java.exe -cp C:\Users\tachyontest1\tachyon\libexec\..\conf\;C:\Users\tachyontest1\tachyon\libexec\..\assembly\target\tachyon-assemblies-0.9.0-SNAPSHOT-jar-with-dependencies.jar;
  -Dtachyon.home=C:\Users\tachyontest1\tachyon\libexec\..
  -Dtachyon.logs.dir=C:\Users\tachyontest1\tachyon\libexec\..\logs
  -Dtachyon.master.hostname=localhost -Dtachyon.logger.type=USER_LOGGER 
  -Dlog4j.configuration=file:C:\\Users\tachyontest1\log4j.properties 
  -Dtachyon.worker.tieredstore.level.max=1 
  -Dtachyon.worker.tieredstore.level0.alias=MEM 
  -Dtachyon.worker.tieredstore.level0.dirs.path=C:\Users\tachyontest1\tachyon\libexec\..\ram 
  -Dtachyon.worker.tieredstore.level0.dirs.quota=1MB 
  -Dtachyon.underfs.address=C:\Users\TACHYO~1\AppData\Local\Temp\2 
  -Dtachyon.worker.memory.size=1MB 
  -Dtachyon.master.hostname=localhost 
  -Dorg.apache.jasper.compiler.disablejsr199=true
  -Djava.net.preferIPv4Stack=true
 tachyon.Format master 
#>

