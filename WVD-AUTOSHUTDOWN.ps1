#IMPORT MODULE
import-module Az.DesktopVirtualization
import-module Az.Compute
import-module Az.Accounts

#COnnect to azure
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    connect-azAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

### DECLARACAO DE VARIAVEIS ####
$subscriptionID = "6469ee74-8e84-41e8-b22b-397bb86a5453" 
$tenantID = "eec0ce79-5f0a-47b1-8f50-b917b35979b2"
$hostpoolname = "WVD-V2-pool" 
$rgname = "RG-WVD-V2"
$tempo = 120 #TEMPO EM SEGUNDOS ENTRE A MENSAGEM E O DESLIGAMENTO DA VM

### CONECTA NA AZURE ACCOUNT E TENANT
#Select-AzSubscription -Tenant $tenantID -Subscription $subscriptionID 

#PEGA A LISTA DE SESSION HOSTS
$sessionhost = Get-AzWvdSessionHost -HostPoolName $hostpoolname -ResourceGroupName $rgname

#PARA CADA SERVIDOR DA LISTA, VERIFICA AS SESSÕES, ENVIA MENSAGEM E DESLIGA A VM
foreach ($server in $sessionhost){
    $temp = $server.name
    $array = $temp.Split("/") #DIVIDE O NOME DA VM
    #LISTA AS SESSOES DE UM SESSION HOST
    $session = Get-AzWvdUserSession -HostPoolName $hostpoolname -ResourceGroupName $rgname -SessionHostName $array[1]
    #TESTA SE TEM SESSOES CONECTADAS
    if ($session -eq $nul)
        {
            #SE NAO TEM SESSAO CONECTADA, DESLIGA A VM
            $vmname = $array[1].Split(".")
            Write-Host $vmname[0] "Sendo Desligada"
            Stop-AzVM -Name $vmname[0] -ResourceGroupName $rgname -Force
        }
    else
        {
            #SE TEM SESSAO, PARA CADA SESSAO ENVIA A MENSAGEM E DESCONTECTA O USUARIO
            foreach ($userid in $session) {
                write-host $userid
                #SEPARA O ID DO USUARIO
                $temps = $userid.Name
                $xid = $temps.Split("/")
                write-host "Session ID" $xid[2]
                #ENVIA MENSAGEM PARA O USUARIO QUE SERA DESCONECTADO - PODE SER CUSTOMIZADA
                Send-AzWvdUserSessionMessage -HostPoolName $hostpoolname -ResourceGroupName $rgname -SessionHostName $array[1] -UserSessionId $xid[2] -MessageTitle "VM Será Desligada" -MessageBody "Sua VM será desligada em 120 segundos. Salve seu trabalho e faça o logoff"
                #AGUARDA ALGUNS SEGUNDOS ANTES DE DESCONECTAR O USUARIO
                sleep $tempo
                #DESCONECTA A SESSÃO DO USUARIO
                Remove-AzWvdUserSession -HostPoolName $hostpoolname -ResourceGroupName $rgname -SessionHostName $array[1] -Id $xid[2] -Force
            }
            #DESLIGA A VM
            $vmname = $array[1].Split(".")
            Write-Host $vmname[0] "Sendo Desligada"
            Stop-AzVM -Name $vmname[0] -ResourceGroupName $rgname -Force
        }
}
