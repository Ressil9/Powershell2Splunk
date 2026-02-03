#Écris un script PowerShell qui :

#Scanne le dossier Entree pour trouver tous les fichiers .xml (Utilise Get-ChildItem).

#Boucle sur chaque fichier trouvé :

#Lit le contenu XML.

#Condition (IF) : Si le <level> est égal à "Critical", crée un objet avec l'ID et le Message, puis ajoute-le à une liste $RapportCritique.

#Archivage : Déplace le fichier vers le dossier Archive une fois lu (qu'il soit critique ou non).

#Sortie : Convertis la liste $RapportCritique en JSON et affiche-la.

#Sécurité : Utilise un Try/Catch autour du Move-Item au cas où un fichier serait verrouillé.

#💡 Indice pour bien démarrer
#Pour récupérer tes fichiers, commence par : $fichiers = Get-ChildItem "C:\Temp\Logs\Entree\*.xml"

#Ensuite, ta boucle ressemblera à ceci : foreach ($file in $fichiers) { ... }

#C'est un gros morceau ! Prends ton temps, brique par brique (D'abord la liste des fichiers, puis la lecture, puis la condition).


$fichiers = Get-ChildItem -Path "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\exo_supprimer\*.xml"

$liste = @()
$RapportCritique= @()



foreach ($element in $fichiers) {

    [xml]$affiche = Get-Content $element.FullName

    if ($affiche.log.level -eq "Critical" ) {
    $objet1 = @{
            ID = $affiche.log.id
            Message = $affiche.log.message
        }

    $RapportCritique += $objet1 
    }

    try {
        Move-Item -Path $element.FullName -Destination "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\exo_supprimer\Archive\"    
    }
    catch {
        Write-Host "Fichier non deplacer erreur"
    }

}

$RapportCritique | ConvertTo-Json | Set-Content -Path "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\exo_supprimer\RapportCritique.JSON" -Force


