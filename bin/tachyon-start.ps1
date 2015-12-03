# start up tachyon
function shift
{
    param($toshift)
    $toshift[1..($toshift.Count)]
}

$Usage = "Usage: tachyon-start.ps1 [-hN] WHAT [MOPT] [-f] `n `
Where WHAT is one of: `n `
  all MOPT`t`tStart master and all workers. `n `
  local`t`t`tStart a master and worker locally `n `
  master`t`tStart the master on this node `n `
  safe`t`t`tScript will run continuously and start the master if it's not running `n `
  worker MOPT`t`tStart a worker on this node `n `
  workers MOPT`t`tStart workers on worker nodes `n `
  restart_worker`tRestart a failed worker on this node `n `
  restart_workers`tRestart any failed workers on worker node `n `
`n `
MOPT is one of: `n `
  Mount`t`t`tMount the configured RamFS `n `
  SudoMount`t`tMount the configured RamFS using sudo `n `
  NoMount`t`tDo not mount the configured RamFS `n `
`n `
-f format Journal, UnderFS Data and Workers Folder on master `n `
-N Do not try to kill prior running masters and/or workers in all or local `n `
-h display this help."

$bin = $PSScriptRoot

function ensure_dirs
{
    if (-not (Test-Path -Path $global:TACHYON_LOGS_DIR -PathType Container))
    {
        Write-Host "TACHYON_LOGS_DIR: $global:TACHYON_LOGS_DIR"
        mkdir $global:TACHYON_LOGS_DIR
    }
}

function get_env
{
    $DEFAULT_LIBEXEC_DIR = "$bin/../libexec"
    $TACHYON_LIBEXEC_DIR = @{$true=$DEFAULT_LIBEXEC_DIR;$false=$global:TACHYON_LIBEXEC_DIR}[$global:TACHYON_LIBEXEC_DIR -eq $null]
    & "TACHYON_LIBEXEC_DIR\tachyon-config.ps1"
}

function check_mount_mode
{
    switch ($args[0])
    {
        {"Mount", "SudoMount", "NoMount"} {}
        default {
            if ($args[0] -eq $null)
            {
                Write-Host "This command requires a mount mode be specified"
            }
            else
            {
                Write-Host "Invalid mount mode: $args[0]"
            }
            Write-Host $Usage
            exit
        }
    }
}

function do_mount
{
    $MOUNT_FAILED = $null
    switch ($args[0])
    {
        "Mount" {
            & "$bin\tachyon-mount.ps1" $args[0]
            $MOUNT_FAILED = $Error
        }
        "SudoMount" {
            & "$bin\tachyon-mount.ps1" $args[0]
            $MOUNT_FAILED = $Error
        }
        "NoMount" {}
        default {
            Write-Host "This command requires a mount mode be specified"
            Write-Host $Usage
            exit
        }
    }
}

function stop
{
    & "$bin\tachyon-stop.ps1"
}

function start_master
{
    $MASTER_ADDRESS = $global:TACHYON_MASTER_ADDRESS
    if ($global:TACHYON_MASTER_ADDRESS -eq $null)
    {
        $MASTER_ADDRESS = "localhost"
    }

    if ($global:TACHYON_MASTER_JAVA_OPTS -eq $null)
    {
        $TACHYON_MASTER_JAVA_OPTS = $global:TACHYON_JAVA_OPTS
    }

    if ($args[0] -eq "-f")
    {
        & "$bin\tachyon" format
    }

    $CLASS = "tachyon.master.TachyonMaster"

    Write-Host "Starting master @ $MASTER_ADDRESS"
    & "$global:JAVA" `
    -cp $global:CLASSPATH `
    "-Dtachyon.home=$global:TACHYON_HOME" `
    "-Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR" `
    "-Dtachyon.master.hostname=$global:TACHYON_MASTER_ADDRESS" `
    "-Dtachyon.logger.type=MASTER_LOGGER" `
    "-Dtachyon.accesslogger.type=MASTER_ACCESS_LOGGER" `
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
    > $global:TACHYON_LOGS_DIR\master.out 2>&1
}

function start_worker
{
    do_mount $args[0]

    if ($MOUNT_FAILED -ne 0)
    {
        Write-Host "Mount failed, not starting worker"
        exit
    }

    if ($global:TACHYON_WORKER_JAVA_OPTS -eq $null)
    {
        $global:TACHYON_WORKER_JAVA_OPTS = $global:TACHYON_JAVA_OPTS
    }

    $CLASS = "tachyon.worker.TachyonWorker"

    Write-Host "Starting worker @ $env:COMPUTERNAME"
    & "$global:JAVA" `
    -cp $global:CLASSPATH `
    "-Dtachyon.home=$global:TACHYON_HOME" `
    "-Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR" `
    "-Dtachyon.logger.type=WORKER_LOGGER" `
    "-Dtachyon.accesslogger.type=WORKER_ACCESS_LOGGER" `
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
    > $global:TACHYON_LOGS_DIR\worker.out 2>&1
}

function restart_worker
{
    if ($global:TACHYON_WORKER_JAVA_OPTS -eq $null)
    {
        $global:TACHYON_WORKER_JAVA_OPTS = $global:TACHYON_JAVA_OPTS
    }

    $RUN = @()

    $javaprocess = ps | where {$_.ProcessName -eq 'java'}
    foreach ($process in $javaprocess)
    {
        $commandLine = Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)" | select CommandLine
        if ($commandLine.CommandLine.Contains("tachyon.worker.TachyonWorker"))
        {
            $RUN += $process.Id
        }
    }

    if ($RUN.count -eq 0)
    {
        Write-Host "Restarting worker @ $env:COMPUTERNAME"

        $CLASS = "tachyon.worker.TachyonWorker"

        Write-Host "Starting worker @ $env:COMPUTERNAME"
        & "$global:JAVA" `
        -cp $global:CLASSPATH `
        "-Dtachyon.home=$global:TACHYON_HOME" `
        "-Dtachyon.logs.dir=$global:TACHYON_LOGS_DIR" `
        "-Dtachyon.logger.type=WORKER_LOGGER" `
        "-Dtachyon.accesslogger.type=WORKER_ACCESS_LOGGER" `
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
        > $global:TACHYON_LOGS_DIR\worker.out 2>&1
    }
}

function run_safe
{
    while ($true)
    {
        $RUN = @()

        $javaprocess = ps | where {$_.ProcessName -eq 'java'}
        foreach ($process in $javaprocess)
        {
            $commandLine = Get-WmiObject Win32_Process -Filter "ProcessId = $($process.Id)" | select CommandLine
            if ($commandLine.CommandLine.Contains("tachyon.worker.TachyonWorker"))
            {
                $RUN += $process.Id
            }
        }

        if ($RUN -eq 0)
        {
            Write-Host "Restarting the system master..."
            start_master
        }
        Write-Host "Tachyon is running..."
        Start-Sleep -Seconds 2
    }
}

if ($args[0].ContainsKey('h'))
{
    Write-Host $Usage
    exit
}

if ($args[0].ContainsKey('N'))
{
    $killonstart = "no"
}

$args = shift -toshift $args
Write-Host "shifted: $args"

$WHAT = $args[0]

if ($WHAT -ne $null)
{
    Write-Host "Error: no WHAT specified"
    Write-Host "$Usage"
    exit
}

get_env

ensure_dirs

if ($WHAT -eq "all")
{
    check_mount_mode $args[1]
    if ($killonstart -ne "no")
    {
        stop $bin
    }
    start_master $args[2]
    Start-Sleep -Seconds 2
    & "$bin/tachyon-workers.ps1" (& "$bin/tachyon-start.ps1" worker $args[1])
}
elif ($WHAT -eq "local")
{
    if ($killonstart -ne "no")
    {
        stop $bin
        Start-Sleep -Seconds 1
    }
    $stat = (& "$bin/tachyon-mount.ps1" SudoMount)
    if ($stat -ne $null)
    {
        Write-Host "Mount failed, not starting"
        exit
    }
    if ($args[1] -ne $null -and $args[1] -ne "-f")
    {
        Write-Host $Usage
        exit
    }
    start_master $args[1]
    Start-Sleep -Seconds 2
    start_worker NoMount
}
elif ($WHAT -eq "master")
{
    if ($args[1] -ne $null -and $args[1] -ne "-f")
    {
        Write-Host $Usage
        exit
    }
    start_master $args[1]
}
elif ($WHAT -eq "worker")
{
    check_mount_mode $args[1]
    start_worker $args[1]
}
elif ($WHAT -eq "safe")
{
    run_safe
}
elif ($WHAT -eq "workers")
{
    check_mount_mode $args[1]
    & "$bin/tachyon-workers.ps1" (& "$bin/tachyon-start.ps1" worker $args[1] $global:TACHYON_MASTER_ADDRESS)
}
elif ($WHAT -eq "restart_worker")
{
    restart_worker
}
elif ($WHAT -eq "restart_workers")
{
    & "$bin/tachyon-workers.ps1" (& "$bin/tachyon-start.ps1" restart_worker)
}
else
{
    Write-Host "Error: Invalid WHAT: $WHAT"
    Write-Host $Usage
    exit
}

Start-Sleep -Seconds 2
