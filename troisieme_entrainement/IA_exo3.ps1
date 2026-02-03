# 1. Configuration des chemins
$pathEntree  = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\script_pws\troisieme_entrainement\Entree"
$pathArchive = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\script_pws\troisieme_entrainement\Archive"
$pathRapport = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\script_pws\troisieme_entrainement\RapportCritique.json"

$AlerteConsommation = @()

# 2. Vérification de l'existence du dossier d'entrée
if (-not (Test-Path -Path $pathEntree)) {
    Write-Host "ERREUR : Le chemin d'entrée n'existe pas." -ForegroundColor Red
    return
}

# Création du dossier Archive s'il n'existe pas encore
if (-not (Test-Path -Path $pathArchive)) {
    New-Item -ItemType Directory -Path $pathArchive | Out-Null
}

# 3. Récupération des fichiers XML
$FILES = Get-ChildItem -Path "$pathEntree\*.xml"

if ($FILES.Count -eq 0) {
    Write-Host "Aucun fichier XML trouvé dans le dossier d'entrée." -ForegroundColor Cyan
}

# 4. BOUCLE DE TRAITEMENT (Lecture et Archivage)
foreach ($element in $FILES) {
    Write-Host "Traitement de : $($element.Name)..." -ForegroundColor White
    
    try {
        [xml]$REl = Get-Content $element.FullName -ErrorAction Stop

        # Calcul de la RAM (on force le type [double] pour que les maths fonctionnent)
        $ramTotale   = [double]$REl.server.specs.ram_gb
        $usagePercent = [double]$REl.server.specs.usage_percent
        $ramUtilisee  = ($ramTotale * $usagePercent) / 100

        # Si l'usage est critique (> 80%)
        if ($usagePercent -gt 80) {
            $object = @{
                Name     = $REl.server.name
                Owner    = $REl.server.owner
                Status   = "ALERTE_CRITIQUE"
                RAM_Used = $ramUtilisee
            }
            $AlerteConsommation += $object
            Write-Host " -> ALERTE : $($REl.server.name) est en surchauffe !" -ForegroundColor Magenta
        }

        # Déplacement vers l'archive
        Move-Item -Path $element.FullName -Destination $pathArchive -Force -ErrorAction Stop
        Write-Host " -> Archivé avec succès." -ForegroundColor Green

    } catch {
        Write-Host " -> Erreur lors du traitement de $($element.Name) : $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 5. BOUCLE DE NETTOYAGE (Maintenance de l'archive)
Write-Host "`nNettoyage de l'archive en cours..." -ForegroundColor Gray
$vieuxFichiers = Get-ChildItem -Path $pathArchive -Filter *.xml

foreach ($vieux in $vieuxFichiers) {
    $duree = (Get-Date) - $vieux.CreationTime

    # Si le fichier a plus de 2 minutes (pour tes tests)
    if ($duree.TotalMinutes -gt 60) {
        Write-Host " -> Suppression du fichier expiré : $($vieux.Name)" -ForegroundColor Yellow
        Remove-Item -Path $vieux.FullName -Force
    } else {
        Write-Host " -> $($vieux.Name) conservé (Âge : $([math]::Round($duree.TotalMinutes, 2)) min)." -ForegroundColor DarkGray
    }
}

# 6. EXPORT DU RAPPORT FINAL
if ($AlerteConsommation.Count -gt 0) {
    $AlerteConsommation | ConvertTo-Json | Set-Content -Path $pathRapport
    Write-Host "`nRapport généré : $pathRapport" -ForegroundColor Green
} else {
    Write-Host "`nAucune alerte critique détectée aujourd'hui." -ForegroundColor Gray
}