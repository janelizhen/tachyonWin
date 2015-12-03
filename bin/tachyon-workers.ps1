$usage = "Usage: tachyon-workers.ps1 command..."

Write-Host $args

if ($($args.Count) -le 0)
{
    Write-Host $usage
    exit
}

$bin = $PSScriptRoot
$DEFAULT_LIBEXEC_DIR = "$bin\..\libexec"
$global:TACHYON_LIBEXEC_DIR = @{$true=$DEFAULT_LIBEXEC_DIR;$false=$global:TACHYON_LIBEXEC_DIR}[$global:TACHYON_LIBEXEC_DIR -eq $null]

$HOSTLIST = "$global:TACHYON_CONF_DIR\workers"
Write-Host "TACHYON_CONF_DIR=$global:TACHYON_CONF_DIR"
Write-Host "HOSTLIST=$HOSTLIST"

$hostlistContent = Get-Content $HOSTLIST

foreach ($hostContent in $hostlistContent)
{
    if ($hostContent.Contains("#")) # Comment in the file, skip
    {
        continue
    }

    Write-Host "Connecting to $hostContent as $env:USERNAME..."
    if ($global:TACHYON_SSH_FOREGROUND -ne $null)
    {
        $cmdStr = "$bin/tachyon.ps1"
        Invoke-Command -ComputerName $hostContent {& "$cmdStr" $args} -ArgumentList $args
        #& "$bin/tachyon.ps1" formatWorker
    }
    else
    {
        #Invoke-Command -ComputerName $hostContent {& "$($args[0])\tachyon.ps1" formatWorker} -ArgumentList $bin
        & "bin/tachyon.ps1" formatWorker
    }
    if ("$global:TACHYON_WORKER_SLEEP" -ne "")
    {
        Start-Sleep -Seconds $global:TACHYON_WORKER_SLEEP
    }
}
