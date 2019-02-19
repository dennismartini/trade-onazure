# Get the ID and security principal of the current user account 
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent() 
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID) 
# Get the security principal for the Administrator role 
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator 
# Check to see if we are currently running "as Administrator" 
if ($myWindowsPrincipal.IsInRole($adminRole)) 
   { 
   # We are running "as Administrator" - so change the title and background color to indicate this 
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)" 
   $Host.UI.RawUI.BackgroundColor = "DarkBlue" 
   clear-host 
   } 
else 
   { 
   # We are not running "as Administrator" - so relaunch as administrator 
   # Create a new process object that starts PowerShell 
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell"; 
   # Specify the current script path and name as a parameter 
   $newProcess.Arguments = $myInvocation.MyCommand.Definition; 
   # Indicate that the process should be elevated 
   $newProcess.Verb = "runas"; 
   # Start the new process 
   [System.Diagnostics.Process]::Start($newProcess); 
   # Exit from the current, unelevated, process 
   exit 
   } 
   
   
# Run your code that needs to be elevated here 
Write-Host -NoNewLine "Elevacao para administrador concluida, pressione qualquer tecla para continuar e aguarde alguns segundos" 
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 


#instala o PowerShellGet 
if (Get-InstalledModule -Name "PowerShellGet" -MinimumVersion 1.1.2.0) { 
    Write-Host "o Modulo necessario PowerShellGet existe" 
} else { 
    Write-Host "Sera instalado a versÆo mais atual do PowerShellGet - Requerimento - Por favor aguarde" 
    Install-Module PowerShellGet -Force 
} 


#Install and Import AzureRM 
if (Get-InstalledModule -Name "AzureRM.Profile" -MinimumVersion 4.0.0) { 
    Write-Host "o Modulo necessario AzureRM.Profile existe" 
	Import-Module -Name AzureRM 
} else { 
    Write-Host "Sera instalado a versao mais atual do AzureRM - Por favor aguarde" 
    Install-Module -Name AzureRM -AllowClobber -Force 
    Import-Module -Name AzureRM 
} 


#Login no AzureRM 
Connect-AzureRmAccount -ErrorAction Stop 

#Start VM with same name of the user

#Get updated WAN IP to $ip
$ip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip 

#Get NetWork security group from VM

#Allow 3389 from local IP
Get-AzureRmNetworkSecurityGroup -Name  nsg1 -ResourceGroupName rg1 | 
Add-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access 
    Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix Internet 
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 | 
    Set-AzureRmNetworkSecurityGroup
	
#Get Current Status from VM and procced if the VM are started

#Get Actual IP from started VM

#Start MSTSC with actual VM IP and user
mstsc /v:$server:3389

#Shutdown the started VM
