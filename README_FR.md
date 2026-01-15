# Système de Gestion de Tickets

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Fonctionnalités](#fonctionnalités)
3. [Architecture Technique](#architecture-technique)
4. [Prérequis](#prérequis)
5. [Installation et Configuration](#installation-et-configuration)
6. [Guide d'Utilisation](#guide-dutilisation)
7. [Documentation Technique](#documentation-technique)
8. [CI/CD et Déploiement](#cicd-et-déploiement)
9. [Structure du Projet](#structure-du-projet)
10. [API REST](#api-rest)
11. [Sécurité](#sécurité)
12. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

Le **Système de Gestion de Tickets** est une application web full-stack moderne conçue pour gérer efficacement les tickets de support technique. Le système permet aux utilisateurs de créer des tickets, aux agents de les traiter, et aux administrateurs de superviser l'ensemble du processus.

### Objectifs du Projet

- **Gestion centralisée** : Unifier la gestion des demandes de support
- **Attribution automatique** : Répartition intelligente des tickets selon les spécialisations
- **Suivi en temps réel** : Suivi de l'état et de la progression des tickets
- **Communication** : Système de réponses pour faciliter la communication
- **Sécurité** : Authentification JWT et contrôle d'accès basé sur les rôles

### Cas d'Usage

1. **Utilisateurs** : Créent des tickets pour signaler des problèmes
2. **Agents** : Traitent les tickets qui leur sont assignés selon leur spécialisation
3. **Administrateurs** : Supervisent, gèrent les agents et assignent manuellement les tickets

---

## ✨ Fonctionnalités

### 🔐 Authentification et Autorisation

- **Authentification JWT** : Système d'authentification sans état (stateless)
- **Contrôle d'accès basé sur les rôles (RBAC)** : Trois niveaux d'accès
  - **ADMIN** : Accès complet au système
  - **AGENT** : Gestion des tickets assignés
  - **USER** : Création et consultation de ses propres tickets
- **Hachage sécurisé** : Mots de passe cryptés avec BCrypt
- **Inscription publique** : Les utilisateurs peuvent créer un compte

### 🎫 Gestion des Tickets

- **Création de tickets** : Par les utilisateurs et les administrateurs
- **Types de problèmes** : Catégorisation des tickets (Technique, Billing, etc.)
- **Visibilité** : Tickets publics ou privés
- **Statuts** : OPEN, IN_PROGRESS, CLOSED
- **Priorités** : LOW, MEDIUM, HIGH
- **Attribution automatique** : Répartition selon spécialisation et round-robin
- **Attribution manuelle** : Par les administrateurs
- **Filtrage** : Par statut, priorité, type de problème
- **Recherche** : Recherche dans les tickets

### 👥 Gestion des Agents

- **Création d'agents** : Par les administrateurs uniquement
- **Spécialisations** : Agents spécialisés par type de problème
- **Suivi** : Nombre de tickets actifs par agent
- **Répartition équitable** : Algorithme round-robin pour équilibrer la charge

### 💬 Système de Réponses

- **Réponses multiples** : Utilisateurs et agents peuvent répondre
- **Forum-like** : Interface de discussion pour chaque ticket
- **Historique** : Suivi complet des échanges

### 📊 Tableau de Bord

- **Vue d'ensemble** : Statistiques et tickets récents
- **Navigation par rôle** : Interface adaptée selon les permissions
- **Filtres avancés** : Recherche et tri des tickets

---

## 🏗️ Architecture Technique

### Stack Technologique

#### Backend
- **Spring Boot 3.2.0** : Framework Java pour applications web
- **Java 17** : Langage de programmation
- **Spring Data JPA** : Abstraction pour l'accès aux données
- **Hibernate** : ORM (Object-Relational Mapping)
- **Spring Security** : Framework de sécurité
- **JWT (jjwt 0.12.3)** : Tokens d'authentification
- **MySQL 8.0** : Base de données relationnelle
- **Flyway** : Gestion des migrations de base de données
- **Lombok** : Réduction du code boilerplate
- **Maven** : Gestion des dépendances et build

#### Frontend
- **React 18** : Bibliothèque JavaScript pour interfaces utilisateur
- **Vite** : Build tool moderne et rapide
- **Tailwind CSS** : Framework CSS utility-first
- **Axios** : Client HTTP pour les appels API
- **React Router DOM** : Routage côté client

#### DevOps
- **Docker** : Conteneurisation
- **Docker Compose** : Orchestration de conteneurs
- **GitHub Actions** : CI/CD automatisé
- **Nginx** : Serveur web pour le frontend en production

### Architecture en Couches

```
┌─────────────────────────────────────┐
│         Frontend (React)            │
│  - Pages, Components, Context       │
└──────────────┬──────────────────────┘
               │ HTTP/REST
┌──────────────▼──────────────────────┐
│      Backend (Spring Boot)          │
│  ┌────────────────────────────────┐ │
│  │  Controllers (REST API)        │ │
│  └──────────┬─────────────────────┘ │
│  ┌──────────▼─────────────────────┐ │
│  │  Services (Business Logic)     │ │
│  └──────────┬─────────────────────┘ │
│  ┌──────────▼─────────────────────┐ │
│  │  Repositories (Data Access)     │ │
│  └──────────┬─────────────────────┘ │
└──────────────┼───────────────────────┘
               │ JDBC
┌──────────────▼───────────────────────┐
│      MySQL Database                   │
│  - Users, Tickets, Replies, etc.      │
└───────────────────────────────────────┘
```

### Modèle de Données

#### Entités Principales

1. **User** (Utilisateur)
   - id, name, email, password, role
   - Relations : tickets créés, tickets assignés, spécialisations

2. **Ticket** (Ticket)
   - id, title, description, status, priority
   - Relations : créateur, agent assigné, type de problème, réponses

3. **ProblemType** (Type de Problème)
   - id, name, description
   - Relations : tickets, agents spécialisés

4. **Reply** (Réponse)
   - id, content, createdAt
   - Relations : ticket, auteur

---

## 📦 Prérequis

### Pour le Développement Local

- **Java 17** ou supérieur
- **Maven 3.6+**
- **Node.js 18+** et npm
- **MySQL 8.0+**
- **Git**

### Pour le Déploiement

- **Serveur VPS** (Ubuntu/Debian)
- **Docker** et Docker Compose
- **Accès SSH** au serveur
- **Compte GitHub** (pour CI/CD)

---

## 🚀 Installation et Configuration

### 1. Cloner le Repository

```bash
git clone https://github.com/votre-username/ticket-manager.git
cd ticket-manager
```

### 2. Configuration de la Base de Données

#### Créer la Base de Données

```sql
CREATE DATABASE ticket_system;
```

#### Configurer les Credentials

Éditer `backend/src/main/resources/application.yml` :

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/ticket_system?useSSL=false&serverTimezone=UTC
    username: root
    password: votre_mot_de_passe
```

### 3. Backend Setup

```bash
cd backend

# Installer les dépendances et compiler
mvn clean install

# Lancer l'application
mvn spring-boot:run
```

Le backend démarre sur `http://localhost:8085`

**Note** : Flyway exécute automatiquement les migrations au démarrage :
- Création des tables
- Insertion de l'utilisateur admin par défaut

### 4. Frontend Setup

```bash
cd frontend

# Installer les dépendances
npm install

# Lancer le serveur de développement
npm run dev
```

Le frontend démarre sur `http://localhost:5173`

### 5. Identifiants par Défaut

Après le premier démarrage, connectez-vous avec :

- **Email** : `admin@ticketmanager.com`
- **Mot de passe** : `admin123`

---

## 📖 Guide d'Utilisation

### Pour les Utilisateurs (USER)

1. **Inscription** : Créer un compte sur la page de connexion
2. **Créer un ticket** : Cliquer sur "Créer un ticket"
3. **Remplir les informations** :
   - Titre et description
   - Type de problème
   - Priorité
   - Visibilité (public/privé)
4. **Suivre le ticket** : Consulter l'état et les réponses
5. **Répondre** : Ajouter des réponses pour communiquer avec l'agent

### Pour les Agents (AGENT)

1. **Connexion** : Se connecter avec les identifiants fournis
2. **Voir les tickets assignés** : Tableau de bord avec tickets assignés
3. **Traiter un ticket** :
   - Changer le statut (OPEN → IN_PROGRESS → CLOSED)
   - Modifier la priorité si nécessaire
   - Répondre aux questions de l'utilisateur
4. **Filtrer** : Utiliser les filtres pour trouver des tickets spécifiques

### Pour les Administrateurs (ADMIN)

1. **Gestion des agents** :
   - Créer de nouveaux agents
   - Définir leurs spécialisations
   - Voir le nombre de tickets actifs par agent

2. **Gestion des tickets** :
   - Voir tous les tickets
   - Assigner manuellement des tickets
   - Modifier statuts et priorités
   - Supprimer des tickets

3. **Supervision** :
   - Vue d'ensemble du système
   - Statistiques et métriques

---

## 🔧 Documentation Technique

Voir les fichiers détaillés :

- **[ARCHITECTURE_FR.md](./ARCHITECTURE_FR.md)** : Architecture détaillée
- **[FEATURES_FR.md](./FEATURES_FR.md)** : Fonctionnalités complètes
- **[GUIDE_TECHNIQUE_FR.md](./GUIDE_TECHNIQUE_FR.md)** : Guide technique approfondi
- **[CI_CD_FR.md](./CI_CD_FR.md)** : Pipeline CI/CD
- **[DEPLOIEMENT_FR.md](./DEPLOIEMENT_FR.md)** : Guide de déploiement

---

## 🔄 CI/CD et Déploiement

Le projet utilise **GitHub Actions** pour l'intégration et le déploiement continus.

### Pipeline CI/CD

1. **Tests** : Validation du build backend et frontend
2. **Déploiement Test** : Automatique sur push vers `develop`
3. **Déploiement Production** : Manuel avec confirmation

Voir **[CI_CD_FR.md](./CI_CD_FR.md)** pour les détails complets.

---

## 📁 Structure du Projet

```
taskmanager/
├── backend/                    # Application Spring Boot
│   ├── src/main/java/
│   │   └── com/ticketmanager/
│   │       ├── config/         # Configuration (Sécurité, CORS)
│   │       ├── controller/     # Contrôleurs REST
│   │       ├── dto/            # Data Transfer Objects
│   │       ├── entity/          # Entités JPA
│   │       ├── exception/      # Gestion des exceptions
│   │       ├── repository/     # Repositories JPA
│   │       ├── security/        # Filtre JWT
│   │       ├── service/        # Logique métier
│   │       └── util/           # Utilitaires (JWT)
│   ├── src/main/resources/
│   │   ├── db/migration/       # Migrations Flyway
│   │   └── application.yml    # Configuration
│   └── Dockerfile
│
├── frontend/                   # Application React
│   ├── src/
│   │   ├── api/               # Configuration Axios
│   │   ├── components/        # Composants réutilisables
│   │   ├── context/           # Context React (Auth)
│   │   ├── pages/             # Pages de l'application
│   │   ├── App.jsx            # Composant principal
│   │   └── main.jsx           # Point d'entrée
│   ├── Dockerfile
│   └── nginx.conf             # Configuration Nginx
│
├── scripts/                   # Scripts d'automatisation
│   ├── auto-deploy.sh         # Déploiement automatique
│   ├── auto-setup.sh          # Configuration automatique
│   ├── first-time-setup.sh    # Configuration initiale
│   └── ...
│
├── .github/workflows/         # GitHub Actions
│   ├── deploy-test.yml        # Déploiement test
│   └── deploy-prod.yml       # Déploiement production
│
├── docker-compose.test.yml    # Configuration Docker (test)
├── docker-compose.prod.yml    # Configuration Docker (production)
└── README_FR.md              # Cette documentation
```

---

## 🌐 API REST

### Authentification

#### POST `/api/auth/login`
Connexion d'un utilisateur.

**Request Body:**
```json
{
  "email": "admin@ticketmanager.com",
  "password": "admin123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@ticketmanager.com",
    "role": "ADMIN"
  }
}
```

#### POST `/api/auth/register`
Inscription d'un nouvel utilisateur (public).

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

#### GET `/api/auth/me`
Récupérer l'utilisateur actuellement connecté.

### Tickets

#### GET `/api/tickets`
Liste des tickets (filtrée selon le rôle).

**Query Parameters:**
- `status` : Filtrer par statut (OPEN, IN_PROGRESS, CLOSED)
- `priority` : Filtrer par priorité (LOW, MEDIUM, HIGH)
- `problemTypeId` : Filtrer par type de problème

#### POST `/api/tickets`
Créer un nouveau ticket.

**Request Body:**
```json
{
  "title": "Problème de connexion",
  "description": "Je ne peux pas me connecter à l'application",
  "priority": "HIGH",
  "problemTypeId": 1,
  "isPublic": true
}
```

#### GET `/api/tickets/{id}`
Détails d'un ticket spécifique.

#### PUT `/api/tickets/{id}`
Mettre à jour un ticket.

**Request Body:**
```json
{
  "status": "IN_PROGRESS",
  "priority": "MEDIUM"
}
```

#### PUT `/api/tickets/{id}/assign`
Assigner un ticket à un agent (ADMIN uniquement).

**Request Body:**
```json
{
  "agentId": 2
}
```

#### DELETE `/api/tickets/{id}`
Supprimer un ticket (ADMIN uniquement).

### Réponses

#### GET `/api/tickets/{ticketId}/replies`
Récupérer toutes les réponses d'un ticket.

#### POST `/api/tickets/{ticketId}/replies`
Ajouter une réponse à un ticket.

**Request Body:**
```json
{
  "content": "Merci pour votre signalement. Nous travaillons sur le problème."
}
```

### Agents

#### GET `/api/agents`
Liste de tous les agents (ADMIN uniquement).

#### POST `/api/agents`
Créer un nouvel agent (ADMIN uniquement).

**Request Body:**
```json
{
  "name": "Agent Smith",
  "email": "agent@example.com",
  "password": "password123",
  "specializationIds": [1, 2]
}
```

---

## 🔒 Sécurité

### Authentification JWT

1. L'utilisateur se connecte avec email/mot de passe
2. Le backend valide les credentials
3. Un token JWT est généré et renvoyé
4. Le frontend stocke le token dans `localStorage`
5. Chaque requête inclut le token dans le header `Authorization: Bearer <token>`
6. Le backend valide le token et extrait les informations utilisateur

### Contrôle d'Accès Basé sur les Rôles (RBAC)

- **ADMIN** : Accès complet
- **AGENT** : Gestion des tickets assignés uniquement
- **USER** : Création et consultation de ses propres tickets

### Sécurité des Mots de Passe

- Hachage BCrypt avec force 12
- Mots de passe jamais stockés en clair
- Validation des mots de passe côté serveur

### CORS

Configuration CORS pour autoriser les requêtes depuis :
- `http://localhost:5173` (développement)
- `http://147.79.101.138:5174` (test)
- `http://147.79.101.138` (production)

---

## 🐛 Dépannage

### Problèmes de Connexion à la Base de Données

**Erreur** : `Public Key Retrieval is not allowed`

**Solution** : Ajouter `allowPublicKeyRetrieval=true` à l'URL de connexion MySQL.

### Erreurs de Migration Flyway

**Solution** : Vérifier que la base de données est vide ou utiliser `baseline-on-migrate: true`.

### Problèmes CORS

**Solution** : Vérifier que l'origine du frontend est dans la liste des origines autorisées dans `SecurityConfig.java`.

### Port Déjà Utilisé

**Solution** : Changer le port dans `application.yml` :
```yaml
server:
  port: 8081
```

Pour plus de détails, voir **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**.

---

## 📄 Licence

Ce projet est à des fins éducatives.

---

## 👥 Auteurs

Projet développé dans le cadre d'un projet scolaire.

---

## 📚 Ressources

- [Documentation Spring Boot](https://spring.io/projects/spring-boot)
- [Documentation React](https://react.dev/)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation GitHub Actions](https://docs.github.com/en/actions)
