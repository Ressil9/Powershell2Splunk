$path = "C:\Users\MachNP\OneDrive - Luxottica Group S.p.A\Bureau\script_pws\troisieme_entrainement\Entree"

$AlerteConsommation = @()

if (-not (Test-Path -Path $path)) {
    Write-Host "Le chemin n'existe pas" -ForegroundColor Red
    return
}


$FILES = Get-ChildItem -Path "$path\*.xml" 

foreach ($element in $FILES) {
    [xml]$REl = Get-Content $element.FullName

    $RamUtile = ($REl.server.specs.ram_gb*$REl.server.specs.usage_percent)/100

    if ($REl.server.specs.usage_percent -gt 80) {
        $object = @{
            Name = $REl.server.name
            Owner = $REl.server.owner
            Status = "ALERTE_CRITIQUE"
            RAM_Used = $RamUtile
        }
        $AlerteConsommation += $object 
    }



    try {
        
        Move-Item -Path $element.FullName -Destination "$path/../Archive"
    
    } 
    catch {
        Write-Host "Les fichiers n'ont pas pu etre deplacer"
    }

    $duree = (Get-Date) - $element.CreationTime

    if ($duree.TotalYear -gt 1) {
        Write-Host "Suppression de $($element.Name) (Âge : $($duree.TotalMinutes) min)" -ForegroundColor Yellow
        Remove-Item -Path "$path\..\Archive\element" -Force
    } else {
        Write-Host "Le fichier $($elemement) a été conservé" -ForegroundColor Green
    }

    }

