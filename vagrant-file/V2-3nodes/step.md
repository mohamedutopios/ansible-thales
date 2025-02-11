Voici une version du script en **PowerShell** qui détecte automatiquement les conteneurs Docker et applique les configurations nécessaires.

### Script PowerShell

```powershell
# Détection automatique des conteneurs contenant "node" dans leur nom
Write-Output "Détection des conteneurs Docker contenant 'node' dans leur nom..."
$containers = docker ps --filter "name=node" --format "{{.Names}}"

if (-not $containers) {
    Write-Output "Aucun conteneur 'node' trouvé. Assurez-vous que vos conteneurs sont en cours d'exécution."
    exit 1
}

Write-Output "Conteneurs détectés :"
$containers.Split("`n") | ForEach-Object { Write-Output $_ }

# Parcours des conteneurs pour les configurer
foreach ($container in $containers.Split("`n")) {
    if (-not $container) { continue }
    Write-Output "Configuration du conteneur $container..."

    # Chemin local vers le script de configuration
    $localScriptPath = "C:\Users\mohamed\Documents\Formation\ansible-rzo\vagrant-file\V2-3nodes\configure_node.sh"

    # Vérification de l'existence du fichier de configuration
    if (-not (Test-Path -Path $localScriptPath)) {
        Write-Output "Fichier $localScriptPath introuvable. Vérifiez son emplacement."
        exit 1
    }

    # Copier le script de configuration dans le conteneur
    docker cp $localScriptPath "$container:/root/" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Échec de la copie du script dans $container"
        continue
    }

    # Rendre le script exécutable
    docker exec $container /bin/bash -c "chmod +x /root/configure_node.sh" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Échec du chmod sur $container"
        continue
    }

    # Exécuter le script dans le conteneur
    docker exec $container /bin/bash -c "/root/configure_node.sh" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Échec de l'exécution du script dans $container"
        continue
    }

    Write-Output "Configuration terminée pour le conteneur $container."
}

Write-Output "Configuration terminée pour tous les conteneurs."
```

---

### Étapes Préparatoires

1. **Vérifier le chemin du script** :
   - Assurez-vous que le script `configure_node.sh` est dans le chemin correct, par exemple :
     ```plaintext
     C:\Users\mohamed\Documents\Formation\ansible-rzo\vagrant-file\V2-3nodes\configure_node.sh
     ```

2. **Rendre le script PowerShell exécutable** :
   - Sauvegardez ce script dans un fichier nommé, par exemple, `script_principal.ps1`.
   - Lancez une console PowerShell en tant qu’administrateur et exécutez :
     ```powershell
     Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
     ```

3. **Exécuter le script** :
   - Depuis PowerShell, lancez :
     ```powershell
     .\script_principal.ps1
     ```

---

### Résultat Attendu

- Le script PowerShell :
  - Détecte tous les conteneurs contenant "node" dans leur nom.
  - Copie le fichier `configure_node.sh` dans chaque conteneur.
  - Rend le script exécutable.
  - Exécute le script dans chaque conteneur.

- Vous verrez une sortie similaire à :
  ```plaintext
  Détection des conteneurs Docker contenant 'node' dans leur nom...
  Conteneurs détectés :
  V2-3nodes_node5-inv_1737881719
  V2-3nodes_node6-inv_1737881719
  V2-3nodes_node4-inv_1737881718
  Configuration du conteneur V2-3nodes_node5-inv_1737881719...
  Configuration terminée pour le conteneur V2-3nodes_node5-inv_1737881719.
  ...
  Configuration terminée pour tous les conteneurs.
  ```

---

### Débogage

Si une erreur persiste :
1. **Vérifiez la connexion Docker** :
   - Testez manuellement une commande sur un conteneur, par exemple :
     ```powershell
     docker exec -it V2-3nodes_node5-inv_1737881719 /bin/bash
     ```
2. **Vérifiez le fichier `configure_node.sh`** :
   - Assurez-vous qu'il contient les bonnes instructions et qu'il est au bon chemin.
3. **Assurez-vous que Docker est fonctionnel** :
   - Testez des commandes simples comme `docker ps` et `docker exec`.