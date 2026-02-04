$path = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\script_pws\quatrieme_entrainement"
$dossiers = @("$path\Source_A", "$path\Source_B")
$inventaireGlobal = @()
$executionLog = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\Exo_suivi.log"

# Initialisation du Log avec en-tête propre
"¤" * 100 | Out-File -FilePath $executionLog -Force
"Ce fichier est un fichier de log qui permet de retracer le déroulé du script lancé le : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $executionLog -Append
"¤" * 100 | Out-File -FilePath $executionLog -Append

# Vérification du chemin racine
if (Test-Path $path) {
    $scc = "SUCCÈS : Le chemin racine est accessible."
    Write-Host $scc -ForegroundColor Green; $scc | Out-File $executionLog -Append
} else {
    $err = "ERREUR CRITIQUE : Le chemin $path est introuvable."
    Write-Host $err -ForegroundColor Red; $err | Out-File $executionLog -Append
    return
}

foreach ($dossier in $dossiers) {
    # On récupère les fichiers de manière sécurisée
    $fichiers = Get-ChildItem -Path $dossier -Include *.xml, *.json -Recurse -ErrorAction SilentlyContinue
    
    foreach ($file in $fichiers) {
        
        # --- LOGIQUE XML (Windows) ---
        if ($file.Extension -eq ".xml") {
            try {
                [xml]$texte1 = Get-Content $file.FullName -ErrorAction Stop
                
                $object = [PSCustomObject]@{
                    NomServeur = $texte1.check.server
                    ChargeCPU   = [int]$texte1.check.data.value # Forçage en entier pour les calculs
                    OS         = "Windows"
                    Etat       = ""
                }

                if ($object.ChargeCPU -gt 90) { $object.Etat = "CRITIQUE" } 
                elseif ($object.ChargeCPU -ge 50) { $object.Etat = "WARNING" } 
                else { $object.Etat = "OK" }

                $inventaireGlobal += $object
                "LOG : Fichier XML $($file.Name) traité." | Out-File $executionLog -Append

            } catch {
                $err = "ERREUR XML : Impossible de lire $($file.Name). Détails : $($_.Exception.Message)"
                Write-Host $err -ForegroundColor Yellow; $err | Out-File $executionLog -Append
            }
        } 

        # --- LOGIQUE JSON (Linux) ---
        elseif ($file.Extension -eq ".json") {
            try {
                $texte = Get-Content -Raw $file.FullName -ErrorAction Stop | ConvertFrom-Json
                
                $object = [PSCustomObject]@{
                    NomServeur = $texte.host
                    ChargeCPU   = [int]$texte.metrics.cpu_load
                    OS         = "Linux"
                    Etat       = ""
                }

                if ($object.ChargeCPU -gt 90) { $object.Etat = "CRITIQUE" } 
                elseif ($object.ChargeCPU -ge 50) { $object.Etat = "WARNING" } 
                else { $object.Etat = "OK" }

                $inventaireGlobal += $object
                "LOG : Fichier JSON $($file.Name) traité." | Out-File $executionLog -Append

            } catch {
                $err = "ERREUR JSON : Impossible de lire $($file.Name). Détails : $($_.Exception.Message)"
                Write-Host $err -ForegroundColor Yellow; $err | Out-File $executionLog -Append
            }
        }
    } 
}

# --- GÉNÉRATION DES RAPPORTS ---

# Export JSON (Extension .json recommandée au lieu de .JS)
$inventaireGlobal | ConvertTo-Json -Depth 10 | Set-Content -Path "$path\Rapport_Final.json" -Force

# Génération HTML (Stylisée)
$style = "<style>body{font-family:Arial;} table{border-collapse:collapse;width:100%;} th{background:#4CAF50;color:white;padding:8px;} td{border:1px solid #ddd;padding:8px;} tr:nth-child(even){background:#f2f2f2;}</style>"
$inventaireGlobal | ConvertTo-Html -Head $style -Title "Rapport de Flotte" | Set-Content "$path\Rapport.html"

# Bilan final dans la console et le log
$critiques = ($inventaireGlobal | Where-Object { $_.Etat -eq "CRITIQUE" }).Count
$bilan = "`nBILAN : $($inventaireGlobal.Count) serveurs scannés. Alertes critiques : $critiques"
$couleurBilan = if ($critiques -gt 0) { "Red" } else { "Green" }
Write-Host $bilan -ForegroundColor $couleurBilan
$bilan | Out-File $executionLog -Append

Write-Host "`nRapports générés dans : $path" -ForegroundColor Cyan