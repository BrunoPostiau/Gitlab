<#
.SYNOPSIS
    this function writes logs with header and footers if requested

.DESCRIPTION
    This function writes logs to a specific filepath, with Header and footer if required.
    additional output to screen is possible via the ToScreen switch

.PARAMETER FilePath
    Alias: Path
    Path to log file
.PARAMETER Category
    Catefory of Log event. : "Message", "Error", and "Warning".
    
.PARAMETER Message
    Message content

.PARAMETER Delimiter
    Delimiter to be used between logs

.PARAMETER Header
    Writes Header
    
.PARAMETER Footer
    Writes Footer

.PARAMETER ToScreen
    Writes also output to Screen

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Category "Message" -Message "This is an information message."

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Header

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Footer

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Category "Warning" -Message "This is a warning message." -ToScreen

.NOTES
    File Name      : Write-Log.ps1
    #>
Function Write-Log{
<#
.SYNOPSIS
    this function writes logs with header and footers if requested

.DESCRIPTION
    This function writes logs to a specific filepath, with Header and footer if required.
    additional output to screen is possible via the ToScreen switch

.PARAMETER FilePath
    Alias: Path
    Path to log file
.PARAMETER Category
    Catefory of Log event. : "Message", "Error", and "Warning".
    
.PARAMETER Message
    Message content

.PARAMETER Delimiter
    Delimiter to be used between logs

.PARAMETER Header
    Writes Header
    
.PARAMETER Footer
    Writes Footer

.PARAMETER ToScreen
    Writes also output to Screen

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Category "Message" -Message "This is an information message."

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Header

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Footer

.EXAMPLE
    Write-Log -FilePath "C:\Logs\logfile.txt" -Category "Warning" -Message "This is a warning message." -ToScreen

.NOTES
    File Name      : Write-Log.ps1
#>

[CmdletBinding(DefaultParameterSetName='Log',
SupportsShouldProcess=$true)]

param (
    [Parameter(Mandatory)]
    [Alias('Path')]
    [String] $FilePath,
   
    [Parameter(Mandatory, ParameterSetName="Log")]
    [ValidateSet("Message","Error","Warning")]
    [String]$Category,

    [Parameter( Mandatory,
                ParameterSetName='Log',
                ValueFromPipeline=$true)] 
    [String] $Message,

    [Parameter(ParameterSetName='Log')] 
    [Char] $Delimiter = ";",

    [Parameter(ParameterSetName='Header')] 
    [Switch] $Header,

    [Parameter(ParameterSetName='Footer')] 
    [Switch] $Footer,

    [Parameter()] 
    [Switch] $ToScreen
)
if ($PSCmdlet.ShouldProcess("writing log to $Filepath"))
{
    [String]$categorycolor= switch ($category)
        {
        'Message' {'Cyan'}
        'Error' {'Red'}
        'Warning' {'Yellow'}
        Default {'White'}
         }
    
    Switch($PsCmdlet.ParameterSetName){
        'Header' {
            $CIM = Get-CimInstance -ClassName Win32_OperatingSystem
            $Text = @"
+----------------------------------------------------------------------------------------+
Script fullname          : {0}
When generated           : {1}
Current user             : {2}\{3}
Current computer         : {4}
Operating System         : {5}
OS Architecture          : {6}
+----------------------------------------------------------------------------------------+
"@ -f $MyInvocation.MyCommand.Path, (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), $env:USERDOMAIN, $env:userName, $env:ComputerName, $CIM.Caption, $CIM.OSArchitecture

{
    $Content | Out-File -FilePath $Path
}
else
{
    # Code that should be processed if doing a WhatIf operation
    # Must NOT change anything outside of the function / script
}

            Add-Content -Path $FilePath -Value $Text
            
        }

        'Footer' {
            $CreatedOn = (Get-Item -Path $FilePath).CreationTime
            $Text = @"
+----------------------------------------------------------------------------------------+
End time                 : {0}
Total duration (seconds) : {1}
Total duration (minutes) : {2}
+----------------------------------------------------------------------------------------+
"@ -f (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), ($EndDate - $CreatedOn).TotalSeconds, ($EndDate - $CreatedOn).TotalMinutes

            Add-Content -Path $FilePath -Value $Text
        }
        
        'Log' {
            $Text = '{0} {3} {1} {3} {2}' -f (Get-Date).toString('yyyy-MM-dd HH:mm:ss'), $Category, $Message, $Delimiter

            Add-Content -Path $FilePath -Value $Text

            
        }
       
    }
    if ($ToScreen) {
        Write-host $text -ForegroundColor $categorycolor
    }
}
}

