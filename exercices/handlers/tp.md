Bien sûr ! Voici un exemple pédagogique de **handlers** pour un TP. L'objectif est de configurer un service **SSH**, de déployer un fichier de bannière personnalisé, et de redémarrer le service SSH si le fichier de bannière est modifié.

---

### **Contexte du TP**
- **But :** Personnaliser le message de connexion SSH (bannière) sur les nodes.
- **Handler :** Redémarrer le service SSH uniquement si le fichier de bannière est modifié.
- **Technologies :** Utilisation du module `template` pour déployer le fichier de bannière.

---

### **Arborescence du projet**
```
ansible-project-handlers-tp/
├── inventory/
│   └── hosts.yml
├── playbooks/
│   ├── main.yaml
│   └── templates/
│       └── ssh-banner.j2
```

---

### **1. Fichier d'inventaire (`inventory/hosts.yml`)**
```yaml
all:
  children:
    nodes:
      hosts:
        node1:
          ansible_host: 192.168.60.10
        node2:
          ansible_host: 192.168.60.11
```

---

### **2. Template pour le fichier de bannière (`playbooks/templates/ssh-banner.j2`)**
```jinja
##########################################################################
# Attention : accès réservé exclusivement aux utilisateurs autorisés.   #
# Toute activité est surveillée et enregistrée.                         #
# {{ ansible_date_time.date }}                                           #
##########################################################################
```

---

### **3. Playbook principal (`playbooks/main.yaml`)**
Voici le playbook complet :

```yaml
- name: Configurer SSH avec une bannière personnalisée
  hosts: nodes
  become: yes

  vars:
    ssh_banner_file: "/etc/issue.net"

  tasks:
    - name: Installer le serveur SSH
      apt:
        name: openssh-server
        state: present

    - name: Déployer le fichier de bannière SSH
      template:
        src: templates/ssh-banner.j2
        dest: "{{ ssh_banner_file }}"
        owner: root
        group: root
        mode: '0644'
      notify: Redémarrer SSH

    - name: Configurer SSH pour utiliser la bannière
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^Banner'
        line: "Banner {{ ssh_banner_file }}"
        state: present
      notify: Redémarrer SSH

  handlers:
    - name: Redémarrer SSH
      service:
        name: ssh
        state: restarted
```

---

### **Commandes pour exécuter le TP**

1. **Exécutez le playbook :**
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/main.yaml
   ```

2. **Vérifiez le fichier de bannière sur un node :**
   Connectez-vous à un node (par exemple, `node1`) et affichez le fichier `/etc/issue.net` :
   ```bash
   cat /etc/issue.net
   ```

3. **Vérifiez que SSH utilise la bannière :**
   Connectez-vous au node via SSH. Vous devriez voir le message de bannière avant de pouvoir entrer le mot de passe.

---

### **Résultat attendu**
- Si le fichier `ssh-banner.j2` est modifié, le service SSH sera redémarré automatiquement grâce au handler.
- Si aucune modification n'est apportée, le handler ne sera pas déclenché.

---

### **Explication des éléments clés**
1. **Module `template` :**
   - Déploie un fichier de bannière dynamique basé sur la date actuelle.

2. **Module `lineinfile` :**
   - Configure le fichier `sshd_config` pour inclure la bannière.

3. **Handler :**
   - Redémarre le service SSH uniquement si le fichier de bannière ou la configuration a été modifiée.

---

### **Exercice Bonus**
1. Modifiez le contenu du fichier `ssh-banner.j2` (par exemple, changez le texte).
2. Relancez le playbook et observez si le handler est déclenché.

---

Avec cet exemple, les apprenants peuvent comprendre comment utiliser des handlers dans un contexte réel et dynamique. Si vous voulez d'autres variantes ou cas pratiques, n'hésitez pas à demander ! 😊