<# 
This homework was done WITHOUT Generative AI. 
AI is a major issue from an environmental, moral, educational and societal standpoint.
The creator of this script strongly enourages anyone wanting to learn how to write scripts
and general coding to use resources such as www.stackoverflow.com www.github.com and various
online forums/discord servers/group chats.

Completed in ~7 hours of learning, testing, troubleshooting and debugging.
#>
$menuRun = $true
$credit = "Anjie Chenard"
$mainText = @"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Menu principal
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Informations
2. Objects Active Directory
3. Services et processus
4. Quitter
"@
$menuAdText = @"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Objets Active Directory
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Ajout d'utilisateur
2. Retour au menu principal
"@
$menuSrvText = @"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Services et processus
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Liste des processus qui ont un temps CPU de plus de 100 secondes
2. Liste des services arretes
3. Retour au menu principal
"@
function pauseMenu {
	Write-Host "Appuyez sur une touche pour retourner au menu..." -NoNewLine
	$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
function infoMenu {
	echo "Script fait par: " $credit "`nNom de la machine presente:" $env:COMPUTERNAME "`n"
	pauseMenu
}
function adConf{
	echo "Veuillez verifier que toutes les informations sont correctes"
	echo "Prenom: $fname"
	echo "Nom: $lname"
	echo "Mot de passe: [REDIGE]"
	echo "SAM/Login: $sam"
	echo "Domaine: $($domainList[0])"
	echo "Chemin: $ou"
	echo "Courriel: $prcpl"
	$choice = Read-Host"Est-ce que l'information ci-dessus est valide? (o/n)"
}
function newAdUserMenu {
	while($true){
		cls
		echo $menuAdText
		$choice = Read-Host "Entrez votre choix"
		if ($choice -eq "1") {
			cls
			$fname = Read-Host "Veuillez indiquez le prenom du nouvel l'utilisateur" 
			cls
			$lname = Read-Host "Veuillez indiquez le nom de famille du nouvel l'utilisateur"
			cls
			$sam = $fname.Substring(0,1) + $lname
			cls
			$pwd = Read-Host-AsSecureString "Veuillez indiquez le mot de passe l'utilisateur"
			cls
			$domainList = (Get-ADForest).Domains
			<#
			Normally I would've made an entire menu to pick and choose from available domains, DCs and OUs.
			But as that degree of complexity is outside the scope of this homework, I opted to pick the first one and
			generate the missing information to add the user to our Domain.
			#>
			$prcpl = $sam + "@" + $domainList[0]
			$ou = "DC=" + $domainList[0].Substring(0, $domainList[0].IndexOf(".")) + "," + "DC=" + $domainList[0].Substring($domainList[0].IndexOf(".")+1)
			cls
			adConf
			if ($choice -match "^[nN]$"){
				$choice = "1"
			} elseif ($choice -match "^[oOyY]$") {
			cls
			New-ADUser `
			-Name $lname `
			-GivenName $fname `
			-SamAccountName $sam `
			-UserPrincipalName $prcpl `
			-AccountPassword $pwd `
			-Enabled $true `
			-Path $ou `
			-ChangePasswordAtLogon $true 
			echo "L'utilisateur a ete ajoute avec success! Retour au menu Active Directory.."
			Start-Sleep -Seconds 3
			$choice = ""
			} else {
			echo "Vous n'avez pas selectione un choix valide (o/n)"
			Start-Sleep -Seconds 2
			adConf
			}
		} elseif ($choice -eq "2") {
			return
		} else {
			cls
			echo "Vous n'avez pas entre un chiffre entre 1 et 2. Veuillez reessayer de nouveau. `nPour retourner au menu principal, utilisez l'option 2."
			$choice = ""
			Start-Sleep -Seconds 3
		}
	}
}
function srvPrcsMenu{
	while($true) {
		cls
		echo $menuSrvText
		$choice = Read-Host "Entrez votre choix"
		switch ($choice) {
			"1" {
				cls
				$cpu = Get-Process | ? { $_.CPU -gt 10 } | Select-Object ProcessName, Id, @{Name = 'CPU(s)';Expression={ "{0:N1}" -f $_.CPU }} | Out-String
				$cpu
				pauseMenu
			}
			"2" {
				cls
				<#
				Only Name + DisplayName because Status is stopped only anyways, waste of space. 
				Not specified in instructions if "stopped" display is required. 
				Otherwise I would have put it there.
				#>
				$srv = Get-Service | ? { $_.Status -eq "Stopped" } | Select-Object Name, DisplayName | Out-String
				$srv
				pauseMenu
			}
			"3" {
				cls
				return
			}
			default {
				cls
				echo "Vous n'avez pas entre un chiffre entre 1 et 3. Veuillez reessayer de nouveau. `nPour retourner au menu principal, utilisez l'option 3."
				$choice = ""
				Start-Sleep -Seconds 3
			}
		}
	}
}
function mainMenu{
	Do {
		cls
		echo $mainText
		$choice = Read-Host "Entrez votre choix"
	
		switch ($choice) {
			"1" {
				cls
				infoMenu
			}
			"2" {
				cls
				newAdUserMenu
			}
			"3" {
				cls
				srvPrcsMenu
			}
			"4" {
				cls
				echo "Sortie du programme"
				Start-Sleep -Seconds 3
				$menuRun = $false; break
			}
			default {
				cls
				echo "Vous n'avez pas entre un chiffre entre 1 et 4. `nVeuillez reessayer de nouveau. Pour quitter, utilisez l'option 4."
				Start-Sleep -Seconds 3
			}
		}
	} while ($menuRun -eq $true)
}
mainMenu
