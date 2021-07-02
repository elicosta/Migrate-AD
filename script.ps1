Write-Host ""
# Instanciando modulo AD
Import-Module ActiveDirectory

#Realizando importação do arquivo CSV
Import-Csv \\zeus\Public\SEI.csv -Delimiter : |

#Lendo todos os dados do arquivo
foreach {
    $SomeSamAccountName = "$($_.CPF)"

    #Verificando existência do usuário no Active Directory
    if ([bool] (Get-ADUser -Filter { SamAccountName -eq $SomeSamAccountName })) {
        Write-Host "O usuário $($_.CPF) já existente. Proximo usuário do arquivo CSV."
        $exists++
    }

    #Realizando migração do CSV para o Active Directory soa usuários inexistentes na floresta.
    else{
        Write-Host "O usuário $($_.CPF) não existente. Realizando a migração para o Active Directory."
        $name = "$($_.Nome) $($_.Sobrenome)"
        $discription = "$($_.Descricao)"
        $secpass = ConvertTo-SecureString "$($_.Senha)" -AsPlainText -Force

        New-ADUser -GivenName $($_.Nome) -Surname $($_.Sobrenome) -Name $name -SamAccountName $($_.CPF) -UserPrincipalName "$($_.CPF)@itep.govrn" -AccountPassword $secpass -Path "OU=AD SEI,DC=itep,DC=govrn" -EmailAddress $($_.Email) -Description $discription -PasswordNeverExpires $true -Enabled $true
        $migration++
    }
}

Write-Host ""
Write-Host "Total de usuários já existente na floresta $exists"
Write-Host ""
Write-Host "Total de usuários migrados $migration"

Clear-Variable -Name "exists"
Clear-Variable -Name "migration"
