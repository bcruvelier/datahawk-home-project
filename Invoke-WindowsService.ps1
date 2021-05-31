<# 
.SYNOPSIS
    This script remotely start or stop a windows service
.DESCRIPTION
    Pre-Requisites : The user launching the script must have the rights to connect to the remote server
.PARAMETER ComputerName
    Server on which the service exists
.PARAMETER Action
    Action to do (Stop or Start)
.PARAMETER ServiceName
    Name of the service
.EXAMPLE
    Invoke-WindowsService.ps1 -ComputerName 'SRV1' -Action 'Stop' -ServiceName 'MyService'
    Stop the service MyService on the Server SRV1
.EXAMPLE
    Invoke-WindowsService.ps1 -ComputerName 'SRV1' -Action 'Start' -ServiceName 'MyService'
    Start the service MyService on the Server SRV1
#>
[CmdletBinding()]
param(
    [parameter(Mandatory=$true,HelpMessage="Computer")]
    [ValidateScript({Test-Connection -ComputerName $_ -Quiet -Count 1})]
        [string]$ComputerName, 
    
    [Parameter(Mandatory=$false,HelpMessage="Action to do")]
    [ValidateSet('Stop','Start')]
        [string]$Action, 

    [parameter(Mandatory=$true,HelpMessage="Service Name")]
        [String]$ServiceName
)

#region function
function Stop-RemoteService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,HelpMessage="Service Name")]
            [string]$ServiceName,
        
        [Parameter(Mandatory=$true,Position=1,HelpMessage="Server")]
            [ValidateScript({Test-Connection -ComputerName $_ -Quiet -Count 1})]
            [string]$Server
    )
    try{
        $Service = Get-Service -ComputerName $Server -Name "$ServiceName"
        if($Service){
            Write-Verbose "[$Server] Service [$Service] present"
            if($Service | Where-Object {$_.Status -eq "Running"}){
                Write-Host "[$Server] Stopping service [$ServiceName]"
                Stop-Service -InputObject $Service
                Start-Sleep -Seconds 5
            }else{
                Write-Warning "[$Server] service [$ServiceName] not running (status : $($_.Status))"
            }
        }else{
            throw "Service does not exist"
        }
    }catch{
        throw "Error while stopping service [$ServiceName] on server [$Server] : $_"
    }
}

function Start-RemoteService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,HelpMessage="Service Name")]
            [string]$ServiceName,
        
        [Parameter(Mandatory=$true,Position=1,HelpMessage="Server")]
            [ValidateScript({Test-Connection -ComputerName $_ -Quiet -Count 1})]
            [string]$Server
    )
    try{
        $Service = Get-Service -ComputerName $Server -Name "$ServiceName"
        if($Service){
            Write-Verbose "[$Server] Service [$Service] present"
            if($Service | Where-Object {$_.Status -eq "Stopped"}){
                Write-Host "[$Server] Stopping service [$ServiceName]"
                Write-CEGIDEventLog -Message "$Server : Demarrage du service $ServiceName" -EntryType Information
                Start-Service -InputObject $Service
                Start-Sleep -Seconds 5
            }else{
                Write-Warning "[$Server] service [$ServiceName] not stopped (status : $($_.Status))"
            }
        }else{
            throw "Service does not exist"
        }
    }catch{
        throw "Error while starting service [$ServiceName] on server [$Server] : $_"
    }
}
#endregion

try{

    $ErrorActionPreference = 'STOP'

    Switch($Action){
        "Stop" {
            Stop-RemoteService -ServiceName $ServiceName -Server $ComputerName
        } "Start" {
            Start-RemoteService -ServiceName $ServiceName -Server $ComputerName
        } Default {
            throw "Action $Action unknown"
        }
    }
}catch{
    throw $_
}


