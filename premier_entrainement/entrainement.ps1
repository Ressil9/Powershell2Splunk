#Tu es responsable de la maintenance informatique. Tu reçois un fichier XML contenant l'état de plusieurs serveurs. Ton script doit :

Sécuriser la lecture : Tenter de lire le fichier XML (si le fichier n'existe pas, afficher un message d'erreur propre).

Extraire les données : Parcourir chaque serveur présent dans le XML.

Transformer : Pour chaque serveur, créer un objet PowerShell contenant uniquement son nom et son statut.

Exporter : Convertir la liste finale d'objets en format JSON (prêt à être envoyé à un système comme Splunk).

$chemin = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\exo_supprimer\special.xml"

try {
    [xml]$file = Get-Content $chemin
    }
catch {
    Write-Host "Erreur sur la lecture du fichier XML" -ErrorAction Stop
    }

$i = 0

$results = @()


foreach ($element in $file.root.inventory.server) {
    $MyObject = @{
        serverName = $server.name
        status     = $server.status# utilise $server ici
    }
    $results += $MyObject
}

$results

# 7. Conversion finale en JSON pour Splunk
$jsonFinal = $results | ConvertTo-Json -Depth 3

# Affichage du résultat
Write-Host "--- Résultat JSON ---"
Write-Host $jsonFinal
$jsonFinal | Set-Content -Path "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\exo_supprimer\myObject.JSON"
