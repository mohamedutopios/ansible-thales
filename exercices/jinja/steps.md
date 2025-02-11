Voici un exemple de **template Jinja** pour un script de sauvegarde d'une base de données sur l'un de vos nodes. Ce template est conçu pour générer un script de sauvegarde (`backup.sh`) qui prend en compte des paramètres dynamiques tels que le nom de la base, l'utilisateur, le mot de passe et le chemin de sauvegarde.

---

### **Template Jinja (`templates/backup.sh.j2`)**
```jinja
#!/bin/bash
# Script de sauvegarde pour {{ inventory_hostname }}
# Généré automatiquement par Ansible

# Variables
DB_NAME="{{ db_name }}"
DB_USER="{{ db_user }}"
DB_PASSWORD="{{ db_password }}"
BACKUP_DIR="{{ backup_dir }}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/{{ db_name }}_$TIMESTAMP.sql"

# Création du répertoire de sauvegarde s'il n'existe pas
mkdir -p $BACKUP_DIR

# Export des informations d'authentification
export MYSQL_PWD=$DB_PASSWORD

echo "Démarrage du processus de sauvegarde de la base de données : $DB_NAME"
mysqldump -u $DB_USER $DB_NAME > $BACKUP_FILE

# Vérification du succès
if [ $? -eq 0 ]; then
  echo "Sauvegarde réussie : $BACKUP_FILE"
else
  echo "Erreur lors de la sauvegarde !" >&2
  exit 1
fi

# Nettoyage des anciennes sauvegardes (plus de 7 jours)
find $BACKUP_DIR -type f -name "*.sql" -mtime +7 -exec rm -f {} \;

echo "Processus de sauvegarde terminé pour {{ inventory_hostname }}"
```

---

### **Playbook Ansible**
Ce playbook génère le script et l'exécute pour effectuer une sauvegarde.

```yaml
- name: Sauvegarder la base de données
  hosts: all
  vars:
    db_name: my_database
    db_user: my_user
    db_password: my_password
    backup_dir: /var/backups/db
  tasks:
    - name: Générer le script de sauvegarde
      template:
        src: templates/backup.sh.j2
        dest: /usr/local/bin/backup.sh
        mode: '0755'

    - name: Exécuter le script de sauvegarde
      command: /usr/local/bin/backup.sh
```

---

### **Explications du template**
1. **Paramètres dynamiques** : 
   - Les variables comme `db_name`, `db_user`, `db_password` et `backup_dir` sont injectées depuis le playbook.

2. **Sécurité** :
   - Le mot de passe est exporté via la variable d’environnement `MYSQL_PWD` pour éviter qu’il apparaisse dans les logs.

3. **Gestion des anciennes sauvegardes** :
   - Les fichiers de sauvegarde plus vieux que 7 jours sont automatiquement supprimés.

4. **Compatibilité multi-nodes** :
   - Le script est généré pour chaque node avec ses propres paramètres, grâce à l’utilisation des variables Ansible et de Jinja.

---

### **Exemple de résultat (`backup.sh` pour `node1`)**
```bash
#!/bin/bash
# Script de sauvegarde pour node1
# Généré automatiquement par Ansible

# Variables
DB_NAME="my_database"
DB_USER="my_user"
DB_PASSWORD="my_password"
BACKUP_DIR="/var/backups/db"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/my_database_$TIMESTAMP.sql"

# Création du répertoire de sauvegarde s'il n'existe pas
mkdir -p $BACKUP_DIR

# Export des informations d'authentification
export MYSQL_PWD=$DB_PASSWORD

echo "Démarrage du processus de sauvegarde de la base de données : my_database"
mysqldump -u $DB_USER my_database > $BACKUP_FILE

# Vérification du succès
if [ $? -eq 0 ]; then
  echo "Sauvegarde réussie : $BACKUP_FILE"
else
  echo "Erreur lors de la sauvegarde !" >&2
  exit 1
fi

# Nettoyage des anciennes sauvegardes (plus de 7 jours)
find $BACKUP_DIR -type f -name "*.sql" -mtime +7 -exec rm -f {} \;

echo "Processus de sauvegarde terminé pour node1"
```

---

### **Commandes complémentaires**
1. **Vérifier les sauvegardes générées** :
   ```bash
   ls -l /var/backups/db
   ```
2. **Planifier la sauvegarde avec un cron job (facultatif)** :
   Ajoutez une tâche cron via Ansible :
   ```yaml
   - name: Ajouter une tâche cron pour la sauvegarde
     cron:
       name: "Backup de la base de données"
       minute: "0"
       hour: "3"
       job: "/usr/local/bin/backup.sh"
   ```

Avec cette approche, vos bases de données seront sauvegardées régulièrement et de manière automatisée pour chaque node. Si vous avez besoin d’adapter ou d’ajouter des fonctionnalités (comme des notifications en cas de succès ou d’échec), faites-le-moi savoir !