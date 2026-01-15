# Guide de Déploiement Complet

## 📋 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Prérequis](#prérequis)
3. [Configuration Initiale du Serveur](#configuration-initiale-du-serveur)
4. [Configuration GitHub](#configuration-github)
5. [Déploiement Automatique](#déploiement-automatique)
6. [Déploiement Manuel](#déploiement-manuel)
7. [Vérification du Déploiement](#vérification-du-déploiement)
8. [Maintenance](#maintenance)
9. [Dépannage](#dépannage)

---

## 🎯 Vue d'Ensemble

Ce guide détaille le processus complet de déploiement du système de gestion de tickets sur un serveur VPS. Le déploiement est entièrement automatisé via GitHub Actions, mais peut également être effectué manuellement.

### Environnements

- **Test** : Déploiement automatique sur push vers `develop`
- **Production** : Déploiement manuel avec confirmation

---

## 📦 Prérequis

### Serveur VPS

- **OS** : Ubuntu 20.04+ ou Debian 11+
- **RAM** : Minimum 2GB (4GB recommandé)
- **Disque** : Minimum 20GB d'espace libre
- **Réseau** : Accès Internet et ports ouverts (22, 80, 443, 8085, 8086, 5174)
- **Accès** : Accès SSH avec privilèges root

### Compte GitHub

- Repository GitHub avec le code source
- Accès aux Settings → Secrets and variables → Actions

### Outils Locaux

- Git installé
- Accès SSH au serveur

---

## 🖥️ Configuration Initiale du Serveur

### Étape 1 : Connexion SSH

```bash
ssh root@147.79.101.138
# Entrer le mot de passe
```

### Étape 2 : Exécution du Script de Configuration

```bash
cd /opt

# Cloner le repository (si pas déjà fait)
git clone https://github.com/votre-username/ticket-manager.git
cd ticket-manager

# Rendre les scripts exécutables
chmod +x scripts/*.sh

# Exécuter la configuration initiale
./scripts/first-time-setup.sh
```

**Ce script fait** :
- Mise à jour du système
- Installation de Docker et Docker Compose
- Configuration des permissions
- Vérification de l'installation

**Durée** : 5-10 minutes

### Étape 3 : Vérification

```bash
# Vérifier Docker
docker --version
docker compose version

# Vérifier que tout est installé
which docker
which docker-compose
```

---

## 🔐 Configuration GitHub

### Étape 1 : Accéder aux Secrets

1. Aller sur GitHub → Votre Repository
2. Settings → Secrets and variables → Actions
3. Cliquer sur "New repository secret"

### Étape 2 : Ajouter les Secrets

#### Pour l'Environnement de Test

Ajouter ces secrets :

- **Nom** : `TEST_SERVER_HOST`
  - **Valeur** : `147.79.101.138`

- **Nom** : `TEST_SERVER_USER`
  - **Valeur** : `root`

- **Nom** : `TEST_SERVER_PASSWORD`
  - **Valeur** : Votre mot de passe SSH

#### Pour l'Environnement de Production

Ajouter ces secrets :

- **Nom** : `PROD_SERVER_HOST`
  - **Valeur** : `147.79.101.138`

- **Nom** : `PROD_SERVER_USER`
  - **Valeur** : `root`

- **Nom** : `PROD_SERVER_PASSWORD`
  - **Valeur** : Votre mot de passe SSH

**Note** : `GITHUB_TOKEN` est automatiquement fourni par GitHub Actions.

---

## 🚀 Déploiement Automatique

### Déploiement Test (Automatique)

Le déploiement test se fait automatiquement à chaque push vers la branche `develop` ou `test`.

#### Processus

1. **Push du code** :
   ```bash
   git add .
   git commit -m "Nouvelle fonctionnalité"
   git push origin develop
   ```

2. **GitHub Actions** :
   - Déclenchement automatique du workflow
   - Exécution des tests
   - Déploiement si tests OK

3. **Surveillance** :
   - Aller dans GitHub → Actions
   - Voir le statut du workflow
   - Consulter les logs en cas d'erreur

#### Vérification

Après le déploiement, vérifier :

```bash
# Sur le serveur
ssh root@147.79.101.138
cd /opt/ticket-manager

# Vérifier les conteneurs
docker compose -f docker-compose.test.yml ps

# Vérifier les logs
docker compose -f docker-compose.test.yml logs --tail=20
```

#### Accès

- **Frontend** : http://147.79.101.138:5174
- **Backend** : http://147.79.101.138:8086/api

---

## 🎛️ Déploiement Manuel

### Déploiement Test Manuel

Si nécessaire, le déploiement peut être déclenché manuellement :

1. Aller dans GitHub → Actions
2. Sélectionner "Deploy to Test Environment"
3. Cliquer sur "Run workflow"
4. Sélectionner la branche `develop`
5. Cliquer sur "Run workflow"

### Déploiement Production

#### Étape 1 : Merge vers Main

```bash
# Sur votre machine locale
git checkout main
git merge develop
git push origin main
```

#### Étape 2 : Déclenchement du Workflow

1. Aller dans GitHub → Actions
2. Sélectionner "Deploy to Production"
3. Cliquer sur "Run workflow"
4. **Important** : Taper "deploy" dans le champ de confirmation
5. Cliquer sur "Run workflow"

#### Étape 3 : Surveillance

- Surveiller l'exécution du workflow
- Vérifier que tous les jobs réussissent
- Vérifier les health checks

#### Accès

- **Frontend** : http://147.79.101.138
- **Backend** : http://147.79.101.138:8085/api

---

## ✅ Vérification du Déploiement

### Vérifications de Base

#### 1. Statut des Conteneurs

```bash
cd /opt/ticket-manager

# Test
docker compose -f docker-compose.test.yml ps

# Production
docker compose -f docker-compose.prod.yml ps
```

**Résultat attendu** : Tous les conteneurs doivent être "Up" et "healthy".

#### 2. Logs des Services

```bash
# Backend
docker compose -f docker-compose.test.yml logs backend-test --tail=30

# Frontend
docker compose -f docker-compose.test.yml logs frontend-test --tail=30

# MySQL
docker compose -f docker-compose.test.yml logs mysql-test --tail=30
```

**Vérifier** :
- Pas d'erreurs critiques
- Backend démarré correctement
- Migrations Flyway exécutées

#### 3. Test de Connectivité

```bash
# Depuis le serveur
curl http://localhost:8086/api/auth/me

# Depuis votre machine
curl http://147.79.101.138:8086/api/auth/me
```

**Résultat attendu** : HTTP 403 (serveur répond, mais non authentifié) ou HTTP 200 (si authentifié).

#### 4. Test Frontend

Ouvrir dans un navigateur :
- Test : http://147.79.101.138:5174
- Production : http://147.79.101.138

**Vérifier** :
- Page se charge
- Formulaire de connexion visible
- Pas d'erreurs dans la console

#### 5. Test de Connexion

1. Ouvrir l'application dans le navigateur
2. Se connecter avec :
   - Email : `admin@ticketmanager.com`
   - Mot de passe : `admin123`
3. Vérifier que le tableau de bord s'affiche

---

## 🔧 Maintenance

### Sauvegarde de la Base de Données

#### Automatique

Les sauvegardes sont créées automatiquement avant chaque déploiement en production.

#### Manuelle

```bash
cd /opt/ticket-manager
./scripts/backup-database.sh prod
```

**Emplacement** : `/opt/ticket-manager/backups/`

**Format** : `backup_prod_YYYYMMDD_HHMMSS.sql.gz`

### Restauration

```bash
cd /opt/ticket-manager
./scripts/restore-database.sh prod backups/backup_prod_20240115_120000.sql.gz
```

### Mise à Jour

#### Mise à Jour du Code

```bash
# Sur le serveur
cd /opt/ticket-manager
git pull origin develop  # ou main pour production
./scripts/auto-deploy.sh test  # ou prod
```

#### Mise à Jour des Images Docker

Les images sont reconstruites automatiquement lors du déploiement.

### Nettoyage

#### Nettoyer les Images Inutilisées

```bash
docker system prune -a
```

#### Nettoyer les Volumes (⚠️ Supprime les données)

```bash
docker volume prune
```

### Monitoring

#### Vérifier l'Utilisation des Ressources

```bash
# Utilisation CPU et RAM
docker stats

# Espace disque
df -h

# Espace Docker
docker system df
```

---

## 🐛 Dépannage

### Problèmes Courants

#### 1. Conteneurs Ne Démarrant Pas

**Symptômes** : Conteneurs en état "Exited" ou "Restarting"

**Solutions** :
```bash
# Voir les logs
docker compose -f docker-compose.test.yml logs

# Redémarrer
docker compose -f docker-compose.test.yml restart

# Recréer les conteneurs
docker compose -f docker-compose.test.yml up -d --force-recreate
```

#### 2. Erreur de Connexion MySQL

**Symptômes** : `Public Key Retrieval is not allowed`

**Solution** : Vérifier que `allowPublicKeyRetrieval=true` est dans l'URL de connexion.

#### 3. Port Déjà Utilisé

**Symptômes** : `Bind for 0.0.0.0:8086 failed: port is already allocated`

**Solutions** :
```bash
# Trouver le processus utilisant le port
lsof -i :8086
# ou
netstat -tlnp | grep 8086

# Arrêter le processus ou changer le port
```

#### 4. Frontend Ne Se Charge Pas

**Symptômes** : Page blanche ou erreur 502

**Solutions** :
```bash
# Vérifier les logs
docker compose -f docker-compose.test.yml logs frontend-test

# Vérifier que le backend est accessible
curl http://localhost:8086/api/auth/me

# Rebuild le frontend
docker compose -f docker-compose.test.yml build frontend-test
docker compose -f docker-compose.test.yml up -d frontend-test
```

#### 5. Firewall Bloque les Ports

**Symptômes** : Timeout de connexion depuis l'extérieur

**Solutions** :
```bash
# Vérifier le firewall
sudo ufw status

# Ouvrir les ports
sudo ufw allow 8086/tcp
sudo ufw allow 5174/tcp
sudo ufw reload

# Ou utiliser le script
cd /opt/ticket-manager
sudo ./scripts/fix-firewall.sh
```

### Scripts de Diagnostic

#### Diagnostic Complet

```bash
cd /opt/ticket-manager
chmod +x scripts/diagnose-server.sh
./scripts/diagnose-server.sh
```

Ce script vérifie :
- Statut des conteneurs
- Logs des services
- Configuration réseau
- Firewall
- Connectivité

### Logs Importants

#### Backend

```bash
# Logs en temps réel
docker compose -f docker-compose.test.yml logs -f backend-test

# Dernières 100 lignes
docker compose -f docker-compose.test.yml logs --tail=100 backend-test
```

#### Frontend

```bash
docker compose -f docker-compose.test.yml logs -f frontend-test
```

#### MySQL

```bash
docker compose -f docker-compose.test.yml logs -f mysql-test
```

---

## 🔄 Rollback

### Rollback Rapide

Si un déploiement cause des problèmes :

```bash
cd /opt/ticket-manager

# Revenir à un commit précédent
git checkout <commit-hash>
./scripts/auto-deploy.sh test  # ou prod
```

### Rollback avec Backup

```bash
# Restaurer la base de données
./scripts/restore-database.sh prod backups/backup_prod_YYYYMMDD_HHMMSS.sql.gz

# Revenir au code précédent
git checkout <commit-hash>
./scripts/auto-deploy.sh prod
```

---

## 📊 Monitoring Post-Déploiement

### Métriques à Surveiller

1. **Disponibilité** : Les services sont-ils accessibles ?
2. **Performance** : Temps de réponse des API
3. **Ressources** : Utilisation CPU, RAM, disque
4. **Erreurs** : Nombre d'erreurs dans les logs
5. **Base de données** : Taille, nombre de connexions

### Commandes Utiles

```bash
# Statut des conteneurs
docker compose -f docker-compose.test.yml ps

# Utilisation des ressources
docker stats

# Espace disque
df -h
du -sh /opt/ticket-manager

# Connexions MySQL
docker compose -f docker-compose.test.yml exec mysql-test mysql -u root -p -e "SHOW PROCESSLIST;"
```

---

## 🔐 Sécurité Post-Déploiement

### Recommandations

1. **Changer les mots de passe par défaut** :
   - Mot de passe admin
   - Mots de passe MySQL
   - Clé secrète JWT

2. **Configurer HTTPS** :
   - Obtenir un certificat SSL
   - Configurer Nginx pour HTTPS
   - Rediriger HTTP vers HTTPS

3. **Restreindre l'accès SSH** :
   - Utiliser des clés SSH au lieu de mots de passe
   - Désactiver l'accès root
   - Configurer un firewall strict

4. **Mises à jour régulières** :
   - Mettre à jour le système
   - Mettre à jour Docker
   - Mettre à jour les images

---

Ce guide couvre tous les aspects du déploiement. Pour plus de détails sur le CI/CD, voir [CI_CD_FR.md](./CI_CD_FR.md).
