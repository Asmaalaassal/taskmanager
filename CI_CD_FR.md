# Pipeline CI/CD - Documentation Complète

## 📋 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Architecture CI/CD](#architecture-cicd)
3. [Workflow de Test](#workflow-de-test)
4. [Workflow de Production](#workflow-de-production)
5. [Configuration GitHub Actions](#configuration-github-actions)
6. [Scripts d'Automatisation](#scripts-dautomatisation)
7. [Dépannage CI/CD](#dépannage-cicd)

---

## 🎯 Vue d'Ensemble

Le projet utilise **GitHub Actions** pour l'intégration et le déploiement continus (CI/CD). Le pipeline est entièrement automatisé et garantit que chaque modification du code est testée et déployée de manière fiable.

### Objectifs du Pipeline CI/CD

1. **Validation Automatique** : Vérifier que le code compile et fonctionne
2. **Tests Automatiques** : Exécuter les tests avant le déploiement
3. **Déploiement Automatique** : Déployer automatiquement sur l'environnement de test
4. **Déploiement Contrôlé** : Déploiement en production avec confirmation manuelle
5. **Traçabilité** : Historique complet des déploiements

---

## 🏗️ Architecture CI/CD

### Flux Global

```
┌─────────────────────────────────────────────────────────┐
│              Développeur pousse du code                 │
│              (git push origin develop)                  │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│           GitHub Actions déclenché                      │
│           (workflow: deploy-test.yml)                    │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
┌───────────────┐            ┌───────────────┐
│ Test Backend  │            │ Test Frontend │
│ - Compile     │            │ - Build       │
│ - Tests       │            │ - Validation  │
└───────┬───────┘            └───────┬───────┘
        │                             │
        └──────────────┬──────────────┘
                       │ (Si tests OK)
                       ▼
┌─────────────────────────────────────────────────────────┐
│           Déploiement sur Serveur Test                  │
│           - Clone/Pull du repository                    │
│           - Build des images Docker                      │
│           - Démarrage des services                      │
│           - Health checks                               │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│           Tests de Validation                           │
│           - Vérification des services                   │
│           - Health checks                               │
└─────────────────────────────────────────────────────────┘
```

### Environnements

#### Environnement de Test
- **Branche** : `develop` ou `test`
- **Déclenchement** : Automatique sur push
- **URL** : `http://147.79.101.138:5174` (frontend), `http://147.79.101.138:8086/api` (backend)
- **Base de données** : `ticket_system_test`
- **Port MySQL** : 3307

#### Environnement de Production
- **Branche** : `main`
- **Déclenchement** : Manuel avec confirmation
- **URL** : `http://147.79.101.138` (frontend), `http://147.79.101.138:8085/api` (backend)
- **Base de données** : `ticket_system`
- **Port MySQL** : 3306

---

## 🔄 Workflow de Test

### Fichier : `.github/workflows/deploy-test.yml`

### Déclencheurs

```yaml
on:
  push:
    branches:
      - develop
      - test
  workflow_dispatch:  # Déclenchement manuel possible
```

### Jobs

#### 1. Job `test-backend`

**Objectif** : Valider que le backend compile et fonctionne.

**Étapes** :
1. **Checkout** : Récupère le code source
2. **Setup JDK 17** : Configure Java 17 avec cache Maven
3. **Build** : Compile le projet (`mvn clean compile`)
4. **Tests** : Exécute les tests (`mvn test`)

**Durée estimée** : 2-3 minutes

#### 2. Job `test-frontend`

**Objectif** : Valider que le frontend se build correctement.

**Étapes** :
1. **Checkout** : Récupère le code source
2. **Setup Node.js 18** : Configure Node.js avec cache npm
3. **Install** : Installe les dépendances (`npm ci`)
4. **Build** : Build le projet (`npm run build`)

**Durée estimée** : 1-2 minutes

#### 3. Job `deploy`

**Dépendances** : `test-backend` et `test-frontend` doivent réussir

**Objectif** : Déployer l'application sur le serveur de test.

**Étapes** :

1. **Deploy to test server** :
   - Connexion SSH au serveur
   - Clone ou mise à jour du repository
   - Synchronisation avec la branche `develop`
   - Exécution de `auto-setup.sh` (si nécessaire)
   - Exécution de `auto-deploy.sh`

2. **Health check** :
   - Attente du démarrage des services (jusqu'à 2 minutes)
   - Vérification que le backend répond
   - Affichage des logs en cas d'échec

**Durée estimée** : 5-8 minutes (première fois), 3-5 minutes (mises à jour)

### Exemple de Logs

```
✓ Test Backend completed successfully
✓ Test Frontend completed successfully
→ Deploying to test server...
  → Cloning repository...
  → Building Docker images...
  → Starting services...
  → Waiting for services...
✓ Health check passed!
```

---

## 🚀 Workflow de Production

### Fichier : `.github/workflows/deploy-prod.yml`

### Déclencheurs

```yaml
on:
  workflow_dispatch:
    inputs:
      confirm:
        description: 'Type "deploy" to confirm production deployment'
        required: true
        type: string
```

**Sécurité** : Nécessite de taper "deploy" pour confirmer.

### Jobs

#### 1. Job `validate`

**Objectif** : Valider la confirmation de déploiement.

**Étapes** :
- Vérifie que l'utilisateur a tapé "deploy"
- Échoue si la confirmation est incorrecte

#### 2. Job `test-backend` et `test-frontend`

Identiques au workflow de test, mais sur la branche `main`.

#### 3. Job `deploy`

**Spécificités Production** :
- Déploiement sur la branche `main`
- Backup automatique de la base de données avant déploiement
- Création d'un tag Git après déploiement réussi
- Health checks plus stricts

### Processus de Déploiement Production

1. **Merge vers main** : Le code est mergé dans `main`
2. **Déclenchement manuel** : Aller dans Actions → "Deploy to Production"
3. **Confirmation** : Taper "deploy" dans le champ de confirmation
4. **Exécution** :
   - Tests
   - Backup de la base de données
   - Déploiement
   - Health checks
   - Création du tag

---

## ⚙️ Configuration GitHub Actions

### Secrets Requis

Dans GitHub : Settings → Secrets and variables → Actions

#### Pour l'Environnement de Test

- `TEST_SERVER_HOST` : `147.79.101.138`
- `TEST_SERVER_USER` : `root`
- `TEST_SERVER_PASSWORD` : Mot de passe SSH

#### Pour l'Environnement de Production

- `PROD_SERVER_HOST` : `147.79.101.138`
- `PROD_SERVER_USER` : `root`
- `PROD_SERVER_PASSWORD` : Mot de passe SSH

**Note** : `GITHUB_TOKEN` est automatiquement fourni par GitHub Actions.

### Variables d'Environnement

Les variables suivantes sont utilisées dans les workflows :

- `REGISTRY` : `ghcr.io` (non utilisé actuellement, build local)
- `IMAGE_NAME` : Nom du repository GitHub

---

## 🔧 Scripts d'Automatisation

### `scripts/auto-setup.sh`

**Objectif** : Configurer l'environnement pour la première fois.

**Actions** :
1. Génère des secrets aléatoires (JWT, MySQL)
2. Crée le fichier `.env.test` ou `.env.prod`
3. Configure les variables d'environnement

**Exécution** : Automatique lors du premier déploiement.

### `scripts/auto-deploy.sh`

**Objectif** : Déployer l'application complètement.

**Processus en 9 étapes** :

1. **Vérification de l'environnement** : Vérifie que `.env` existe
2. **Backup (prod uniquement)** : Sauvegarde la base de données
3. **Arrêt des conteneurs** : Stop les services existants
4. **Build des images** : Construit les images Docker localement
5. **Démarrage des services** : Lance tous les conteneurs
6. **Attente** : Attend l'initialisation (15 secondes)
7. **Health check** : Vérifie que le backend répond
8. **Affichage du statut** : Montre l'état des conteneurs
9. **Instructions** : Affiche les URLs d'accès

**Durée** : 3-5 minutes (première fois), 1-2 minutes (mises à jour)

### `scripts/first-time-setup.sh`

**Objectif** : Configuration initiale du serveur.

**Actions** :
1. Mise à jour du système
2. Installation de Docker et Docker Compose
3. Configuration des permissions
4. Vérification de l'installation

**Exécution** : Une seule fois, manuellement sur le serveur.

---

## 🐳 Docker et Conteneurisation

### Images Docker

#### Backend Image

**Dockerfile** : `backend/Dockerfile`

**Stages** :
1. **Build** : Maven build avec Java 17
2. **Runtime** : Image Alpine avec JRE 17

**Taille** : ~200-300 MB

#### Frontend Image

**Dockerfile** : `frontend/Dockerfile`

**Stages** :
1. **Build** : Build Vite avec Node.js
2. **Runtime** : Nginx pour servir les fichiers statiques

**Taille** : ~50-100 MB

### Docker Compose

**Fichiers** :
- `docker-compose.test.yml` : Configuration test
- `docker-compose.prod.yml` : Configuration production

**Services** :
- `mysql-test/prod` : Base de données MySQL
- `backend-test/prod` : Application Spring Boot
- `frontend-test/prod` : Application React (Nginx)

**Networks** : Réseau bridge isolé pour chaque environnement

**Volumes** : Persistance des données MySQL

---

## 🔍 Health Checks

### Backend Health Check

**Endpoint** : `GET /api/auth/me`

**Logique** :
- Accepte les codes HTTP 2xx (succès) et 4xx (erreur mais serveur répond)
- 403 (Forbidden) = Serveur fonctionne mais non authentifié
- 200 (OK) = Serveur fonctionne et utilisateur authentifié
- Timeout = Serveur ne répond pas

**Configuration** :
- 60 tentatives maximum
- 2 secondes entre chaque tentative
- Timeout total : 2 minutes

### Frontend Health Check

**Endpoint** : `GET /` (Nginx)

**Vérification** : Serveur Nginx répond avec le fichier `index.html`

---

## 📊 Monitoring du Pipeline

### GitHub Actions UI

**Accès** : Repository → Actions

**Informations disponibles** :
- Statut de chaque job
- Logs détaillés de chaque étape
- Durée d'exécution
- Historique des exécutions

### Logs sur le Serveur

**Emplacement** : `/opt/ticket-manager`

**Commandes utiles** :
```bash
# Voir les logs des conteneurs
docker compose -f docker-compose.test.yml logs

# Voir les logs du backend
docker compose -f docker-compose.test.yml logs backend-test

# Voir le statut
docker compose -f docker-compose.test.yml ps
```

---

## 🐛 Dépannage CI/CD

### Problèmes Courants

#### 1. Tests Échouent

**Symptômes** : Job `test-backend` ou `test-frontend` échoue

**Solutions** :
- Vérifier les erreurs de compilation
- Vérifier que les dépendances sont à jour
- Vérifier les tests unitaires

#### 2. Déploiement Échoue

**Symptômes** : Job `deploy` échoue

**Solutions** :
- Vérifier les credentials SSH
- Vérifier la connexion au serveur
- Vérifier les logs sur le serveur

#### 3. Health Check Échoue

**Symptômes** : Health check timeout

**Solutions** :
- Vérifier que les conteneurs sont démarrés
- Vérifier les logs du backend
- Vérifier la configuration réseau
- Vérifier le firewall

#### 4. Build Docker Échoue

**Symptômes** : Erreur lors du build des images

**Solutions** :
- Vérifier que Docker est installé
- Vérifier les ressources disponibles (RAM, disque)
- Vérifier les Dockerfiles

### Commandes de Diagnostic

```bash
# Sur le serveur
cd /opt/ticket-manager

# Vérifier le statut
docker compose -f docker-compose.test.yml ps

# Voir les logs
docker compose -f docker-compose.test.yml logs --tail=50

# Vérifier les images
docker images

# Vérifier les volumes
docker volume ls
```

---

## 🔐 Sécurité CI/CD

### Bonnes Pratiques

1. **Secrets** : Jamais commités dans le code
2. **Tokens** : Rotation régulière des tokens
3. **Permissions** : Accès minimal nécessaire
4. **Validation** : Tests obligatoires avant déploiement
5. **Confirmation** : Déploiement production avec confirmation

### Sécurité des Secrets

- Stockés dans GitHub Secrets
- Chiffrés au repos
- Accessibles uniquement dans les workflows
- Jamais affichés dans les logs

---

## 📈 Améliorations Futures

### Optimisations Possibles

1. **Cache des dépendances** : Cache Maven et npm entre les builds
2. **Build parallèle** : Build backend et frontend en parallèle
3. **Tests parallèles** : Exécution des tests en parallèle
4. **Notifications** : Notifications Slack/Email en cas d'échec
5. **Rollback automatique** : Retour en arrière en cas d'échec

### Fonctionnalités Avancées

1. **Environnements multiples** : Dev, Staging, Prod
2. **Blue-Green Deployment** : Déploiement sans interruption
3. **Canary Releases** : Déploiement progressif
4. **Monitoring intégré** : Métriques et alertes
5. **Tests de charge** : Tests de performance automatiques

---

Cette documentation couvre tous les aspects du pipeline CI/CD. Le système est conçu pour être fiable, sécurisé et facile à maintenir.
