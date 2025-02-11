Voici un exemple spécifique pour chaque module demandé (**`file`**, **`user`**, **`apt`**, **`copy`**) présenté dans des playbooks distincts pour une compréhension claire de leur utilisation.

---

### Exemple 1 : Module `file`
Créer un répertoire spécifique avec des permissions, propriétaire, et groupe.

```yaml
---
- name: Exemple du module file
  hosts: nodes
  become: true

  tasks:
    - name: Créer un répertoire pour les logs d'application
      file:
        path: /var/log/my_application
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'
```

---

### Exemple 2 : Module `user`
Créer un utilisateur et l'ajouter à un groupe.

```yaml
---
- name: Exemple du module user
  hosts: nodes
  become: true

  tasks:
    - name: Créer un groupe de déploiement
      group:
        name: deploygroup
        state: present

    - name: Créer un utilisateur pour le déploiement
      user:
        name: deployuser
        comment: "Utilisateur pour le déploiement"
        shell: /bin/bash
        groups: deploygroup
        state: present
```

---

### Exemple 3 : Module `apt`
Installer une liste de paquets et mettre à jour le cache.

```yaml
---
- name: Exemple du module apt
  hosts: nodes
  become: true

  tasks:
    - name: Mettre à jour la liste des paquets
      apt:
        update_cache: yes

    - name: Installer les paquets nécessaires
      apt:
        name:
          - vim
          - git
          - curl
        state: present
```

---

### Exemple 4 : Module `copy`
Copier un fichier de configuration sur les hôtes.

```yaml
---
- name: Exemple du module copy
  hosts: nodes
  become: true

  tasks:
    - name: Copier un fichier de configuration
      copy:
        src: /home/ansible/files/example_config.conf
        dest: /etc/my_application/config.conf
        owner: root
        group: root
        mode: '0644'
```

---

### Organisation des fichiers
Pour le module `copy`, assurez-vous que le fichier source existe à l'emplacement défini. Par exemple :
```
ansible-project/
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── files/
│   └── example_config.conf
├── playbooks/
│   ├── file_playbook.yml
│   ├── user_playbook.yml
│   ├── apt_playbook.yml
│   └── copy_playbook.yml
```

---

### Exécution des Playbooks
Pour exécuter ces playbooks, utilisez les commandes suivantes :

1. Pour le module `file` :
   ```bash
   ansible-playbook playbooks/file_playbook.yml
   ```

2. Pour le module `user` :
   ```bash
   ansible-playbook playbooks/user_playbook.yml
   ```

3. Pour le module `apt` :
   ```bash
   ansible-playbook playbooks/apt_playbook.yml
   ```

4. Pour le module `copy` :
   ```bash
   ansible-playbook playbooks/copy_playbook.yml
   ```

---

Ces exemples montrent des cas simples et pratiques pour chaque module. Vous pouvez les adapter à vos besoins spécifiques en modifiant les variables ou les paramètres.