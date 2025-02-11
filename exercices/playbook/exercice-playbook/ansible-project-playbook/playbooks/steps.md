L'erreur indique que le programme **`crontab`** n'est pas installé dans le conteneur **Ubuntu 20.04** sur le node. `crontab` est requis pour gérer les tâches planifiées (cron jobs). Voici comment résoudre ce problème.

---

### **Solution : Installer le paquet `cron`**

Le programme `crontab` fait partie du paquet **`cron`**. Ajoutez une tâche dans votre playbook pour installer et activer `cron` avant de configurer les cron jobs.

#### **Mise à jour du Playbook**

Ajoutez cette section avant la tâche "Ajouter un cron job pour les backups" :

```yaml
    - name: Installer le service cron
      apt:
        name: cron
        state: present

    - name: Démarrer et activer le service cron
      service:
        name: cron
        state: started
        enabled: true
```

---

### **Playbook complet mis à jour**

Voici votre playbook complet mis à jour pour inclure l'installation et l'activation de `cron` :

```yaml
- name: Installer MySQL dans des conteneurs Ubuntu 20.04
  hosts: mysql_nodes
  become: yes
  vars:
    mysql_root_password: root_password
    mysql_user: my_user
    mysql_password: my_password
    mysql_database: my_database
    backup_dir: /var/backups/mysql
  tasks:
    - name: Mettre à jour les paquets
      apt:
        update_cache: yes

    - name: Installer MySQL serveur
      apt:
        name: mysql-server
        state: present

    - name: Installer pip pour Python 3
      apt:
        name: python3-pip
        state: present

    - name: Installer le module PyMySQL pour Python 3
      pip:
        name: PyMySQL
        state: present
        executable: pip3

    - name: Démarrer MySQL manuellement (conteneurs)
      shell: |
        mkdir -p /var/run/mysqld
        chown -R mysql:mysql /var/run/mysqld
        mysqld_safe --datadir=/var/lib/mysql &
      async: 30
      poll: 0

    - name: Attendre que MySQL démarre
      wait_for:
        port: 3306
        delay: 5
        timeout: 30

    - name: Changer le plugin d'authentification de root pour mysql_native_password
      command: >
        mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '{{ mysql_root_password }}'; FLUSH PRIVILEGES;"

    - name: Configurer un utilisateur MySQL
      mysql_user:
        name: "{{ mysql_user }}"
        password: "{{ mysql_password }}"
        priv: "{{ mysql_database }}.*:ALL"
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"

    - name: Créer une base de données MySQL
      mysql_db:
        name: "{{ mysql_database }}"
        state: present
        login_user: root
        login_password: "{{ mysql_root_password }}"

    - name: Assurer que MySQL écoute sur 0.0.0.0
      lineinfile:
        path: /etc/mysql/mysql.conf.d/mysqld.cnf
        regexp: '^bind-address'
        line: 'bind-address = 0.0.0.0'

    - name: Créer un répertoire pour les backups
      file:
        path: "{{ backup_dir }}"
        state: directory
        mode: '0755'

    - name: Générer un script de backup
      copy:
        dest: /usr/local/bin/backup_mysql.sh
        content: |
          #!/bin/bash
          TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
          BACKUP_FILE="{{ backup_dir }}/{{ mysql_database }}_$TIMESTAMP.sql"
          MYSQL_PWD="{{ mysql_root_password }}" mysqldump -u root {{ mysql_database }} > $BACKUP_FILE
          if [ $? -eq 0 ]; then
            echo "Backup réussi : $BACKUP_FILE"
          else
            echo "Erreur lors du backup !" >&2
            exit 1
          fi
          # Supprimer les backups de plus de 7 jours
          find {{ backup_dir }} -type f -name "*.sql" -mtime +7 -exec rm -f {} \;
        mode: '0755'

    - name: Installer le service cron
      apt:
        name: cron
        state: present

    - name: Démarrer et activer le service cron
      service:
        name: cron
        state: started
        enabled: true

    - name: Ajouter un cron job pour les backups
      cron:
        name: "Backup MySQL toutes les 10 minutes"
        minute: "*/10"
        job: "/usr/local/bin/backup_mysql.sh"
```

---

### **Explications des modifications**

1. **Installation de `cron` :**
   - La tâche `apt` installe le service `cron` si celui-ci n'est pas encore disponible.

2. **Démarrage du service `cron` :**
   - La tâche `service` s'assure que le service `cron` est démarré et activé au démarrage.

3. **Ajout du cron job :**
   - Une fois que `cron` est installé et actif, le module `cron` ajoute la tâche planifiée pour exécuter le script de sauvegarde toutes les 10 minutes.

---

### **Exécution**
Relancez votre playbook avec :
```bash
ansible-playbook -i inventory/hosts.yml playbooks/mysql_setup.yaml
```

---

### **Vérifications**

1. **Vérifiez que `cron` est installé et actif :**
   Sur le node, exécutez :
   ```bash
   systemctl status cron
   ```

2. **Vérifiez que le cron job est ajouté :**
   Sur le node, listez les cron jobs :
   ```bash
   crontab -l
   ```

3. **Testez manuellement le script de backup :**
   Exécutez directement le script de backup pour vérifier son bon fonctionnement :
   ```bash
   /usr/local/bin/backup_mysql.sh
   ```

---

### Résultat attendu

- `cron` est installé et actif sur le node.
- Un cron job est configuré pour exécuter le script de sauvegarde toutes les 10 minutes.
- Les fichiers de sauvegarde sont générés dans le répertoire `/var/backups/mysql`.