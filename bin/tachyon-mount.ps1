function shift
{
    param($toshift)
    $toshift[1..($toshift.Count)]
}

$Usage = "Usage: tachyon-mount.ps1 [Mount|SudoMount] [MACHINE] `
`n If omitted, MACHINE is default to be 'local'. MACHINE is one of: `
`n local`t`t`tMount local machine `
`n workers`t`tMount all the workers on worker nodes"


function init_env
{
    $bin = $PSScriptRoot

    $DEFAULT_LIBEXEC_DIR = "$bin/../libexec"
    $TACHYON_LIBEXEC_DIR = @{$true=$DEFAULT_LIBEXEC_DIR;$false=$global:TACHYON_LIBEXEC_DIR}[$global:TACHYON_LIBEXEC_DIR -eq $null]
    & "$TACHYON_LIBEXEC_DIR\tachyon-config.ps1"

    if ($global:TACHYON_WORKER_MEMORY_SIZE -eq $null)
    {
        Write-Host "TACHYON_WORKER_MEMORY_SIZE was not set. Using the default one: 128MB"
        $global:TACHYON_WORKER_MEMORY_SIZE = "128MB"
    }

    $script:MEM_SIZE=$global:TACHYON_WORKER_MEMORY_SIZE.ToLower().Trim()
}

#shopt -s extglob

function mem_size_to_bytes
{
    $float_scale = 2

    function float_eval
    {
        $result = 0.0
        if ($args.Count -eq 0)
        {
            $result = "{0:N$($float_scale)}" -f $args
        }

        $result
    }

    $SIZE = [regex]::Match($script:MEM_SIZE, '^[0-9]*([.][0-9]+|[0-9]*)').Groups[0].Value
    if ($script:MEM_SIZE -match ".*g(b)?$")
    {
        # Size was specified in gigabytes
        $BYTE_SIZE = $(float_eval "$SIZE * 1024 * 1024 * 1024")
    }
    elif ($script:MEM_SIZE -match ".*m(b)?$")
    {
        # Size was specified in megabytes
        $BYTE_SIZE = $(float_eval "$SIZE * 1024 * 1024")
    }
    elif ($script:MEM_SIZE -match ".*k(b)?$")
    {
        # Size was specified in kilobytes
        $BYTE_SIZE = $(float_eval "$SIZE * 1024")
    }
    elif ($script:MEM_SIZE -match "[0-9.]+(b)?$")
    {
        # Size was specified in bytes
        $BYTE_SIZE = $SIZE
    }
    else
    {
        Write-Host "Please specify TACHYON_WORKER_MEMORY_SIZE in a correct form."
        exit
    }
}

function max_hfs_provision_sectors
{
    # ignored
}

function mount_ramfs_linux
{

}

function mount_ramfs_mac
{
    # ignored
}