$path = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\script_pws\quatrieme_entrainement"



$dossiers = @("$path\Source_A", "$path\Source_B")
$inventaireGlobal = @()
$executionLog = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\Exo_suivi.log"



"¤¤¤¤¤¤¤¤¤     Ce fichier est un fichier de log qui permet de retracer le déroulé du script qui vient d'etre lancé     ¤¤¤¤¤¤¤¤¤" | Out-File -FilePath "$executionLog" -Force
"`nCe script a été lancé le : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")" | Out-File -FilePath "$executionLog" -Append

if (Test-Path $path){
    $scc = "`nLe chemin est bon "
    Write-Host $scc -ForegroundColor green
    $scc |Out-File -FilePath "$executionLog" -Append
} else {
    $scc = "`nLe chemin est mauvais "
    Write-Host $scc -ForegroundColor Red 
    $scc| Out-File -FilePath "$executionLog" -Append
    return
}



foreach ($dossier in $dossiers) {
    $fichiers = Get-ChildItem -Path $dossier -Include *.xml, *.json -Recurse
    
    foreach ($file in $fichiers) {
        if ($file.Extension -eq ".xml") {
            # Logique XML
            [xml]$texte1 = Get-Content $file.FullName





            $object = [PSCustomObject]@{
                NomServeur = $texte1.check.server
                ChargeCPU = $texte1.check.data.value
                OS = "Windows"
                Etat = ""
            }
            if ($object.ChargeCPU -gt 90) {$object.Etat = "CRITIQUE"} 
            elseif (($object.ChargeCPU -ge 50) -and ($object.ChargeCPU -le 90)) {$object.Etat = "WARNING"} 
            else {$object.Etat = "OK"}

            $inventaireGlobal += $object

        } elseif ($file.Extension -eq ".json") {

                $texte = Get-Content -Raw $file | ConvertFrom-Json
                $object = [PSCustomObject]@{
                    NomServeur = $texte.host
                    ChargeCPU = $texte.metrics.cpu_load
                    OS = "Linux"
                    Etat = ""
            }

            if ($object.ChargeCPU -gt 90) {$object.Etat = "CRITIQUE"} 
            elseif (($object.ChargeCPU -ge 50) -and ($object.ChargeCPU -le 90)) {$object.Etat = "WARNING"} 
            else {$object.Etat = "OK"}
             $inventaireGlobal += $object


        }
    } 
}

$inventaireGlobal| ConvertTo-Json | Set-Content -Path $path\file.JS -Force







# Génération HTML
# $inventaireGlobal | ConvertTo-Html -Title "Rapport de Flotte" | Set-Content "Rapport.html"
