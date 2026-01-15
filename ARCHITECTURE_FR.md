# Architecture du Système de Gestion de Tickets

## 📐 Vue d'Ensemble de l'Architecture

Ce document détaille l'architecture complète du système, depuis la couche présentation jusqu'à la base de données.

---

## 🏛️ Architecture Générale

### Architecture en Couches (Layered Architecture)

Le système suit une architecture en couches classique, séparant les responsabilités :

```
┌─────────────────────────────────────────────────────────┐
│                    COUCHE PRÉSENTATION                  │
│  ┌───────────────────────────────────────────────────┐  │
│  │         Frontend React (Client-Side)             │  │
│  │  - Pages, Composants, Context, Routing          │  │
│  └───────────────────────────────────────────────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP/REST (JSON)
┌───────────────────────▼─────────────────────────────────┐
│                  COUCHE API                              │
│  ┌───────────────────────────────────────────────────┐  │
│  │      Controllers REST (Spring MVC)                │  │
│  │  - AuthController, TicketController, etc.         │  │
│  └───────────────────────┬───────────────────────────┘  │
└──────────────────────────┼──────────────────────────────┘
                            │
┌──────────────────────────▼──────────────────────────────┐
│              COUCHE MÉTIER (Business Logic)             │
│  ┌───────────────────────────────────────────────────┐  │
│  │         Services (Spring Services)               │  │
│  │  - UserService, TicketService, etc.               │  │
│  │  - Logique métier, règles de gestion              │  │
│  └───────────────────────┬───────────────────────────┘  │
└──────────────────────────┼──────────────────────────────┘
                            │
┌──────────────────────────▼──────────────────────────────┐
│            COUCHE D'ACCÈS AUX DONNÉES                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │      Repositories (Spring Data JPA)               │  │
│  │  - UserRepository, TicketRepository, etc.        │  │
│  │  - Abstraction de l'accès aux données            │  │
│  └───────────────────────┬───────────────────────────┘  │
└──────────────────────────┼──────────────────────────────┘
                            │ JDBC/Hibernate
┌──────────────────────────▼──────────────────────────────┐
│                  COUCHE DONNÉES                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │         MySQL Database                            │  │
│  │  - Tables: users, tickets, replies, etc.         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 🔐 Couche de Sécurité

### Architecture de Sécurité

```
┌─────────────────────────────────────────────────────┐
│              Requête HTTP Entrante                 │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│         JwtAuthenticationFilter                     │
│  - Extrait le token JWT du header                   │
│  - Valide le token                                  │
│  - Charge les détails de l'utilisateur              │
│  - Définit le contexte de sécurité                  │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│         SecurityFilterChain                         │
│  - Vérifie les permissions                          │
│  - Applique les règles CORS                        │
│  - Gère les exceptions de sécurité                  │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│         Contrôleur REST                             │
│  - Reçoit la requête authentifiée                   │
│  - Accède au contexte de sécurité                   │
└─────────────────────────────────────────────────────┘
```

### Flux d'Authentification JWT

1. **Login Request** → `POST /api/auth/login`
   - Validation des credentials
   - Génération du token JWT
   - Retour du token et des informations utilisateur

2. **Subsequent Requests** → Toutes les autres requêtes
   - Extraction du token depuis le header `Authorization`
   - Validation du token
   - Chargement de l'utilisateur depuis la base de données
   - Définition du contexte Spring Security

3. **Authorization** → Vérification des rôles
   - `@PreAuthorize` sur les méthodes
   - Vérification des permissions selon le rôle

---

## 🗄️ Modèle de Données

### Schéma de Base de Données

#### Table `users`

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'AGENT', 'USER') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Relations :**
- Un utilisateur peut créer plusieurs tickets (`created_by`)
- Un utilisateur (agent) peut avoir plusieurs tickets assignés (`assigned_to`)
- Un utilisateur (agent) peut avoir plusieurs spécialisations (table `agent_specializations`)

#### Table `tickets`

```sql
CREATE TABLE tickets (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status ENUM('OPEN', 'IN_PROGRESS', 'CLOSED') NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by BIGINT NOT NULL,
    assigned_to BIGINT NULL,
    problem_type_id BIGINT NULL,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (problem_type_id) REFERENCES problem_types(id) ON DELETE SET NULL
);
```

**Relations :**
- Un ticket appartient à un créateur (`created_by`)
- Un ticket peut être assigné à un agent (`assigned_to`)
- Un ticket a un type de problème (`problem_type_id`)
- Un ticket peut avoir plusieurs réponses (`replies`)

#### Table `problem_types`

```sql
CREATE TABLE problem_types (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);
```

#### Table `agent_specializations`

```sql
CREATE TABLE agent_specializations (
    agent_id BIGINT NOT NULL,
    problem_type_id BIGINT NOT NULL,
    PRIMARY KEY (agent_id, problem_type_id),
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (problem_type_id) REFERENCES problem_types(id) ON DELETE CASCADE
);
```

#### Table `replies`

```sql
CREATE TABLE replies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT NOT NULL,
    author_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### Diagramme Entité-Relation (ER)

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│    User     │         │    Ticket    │         │ ProblemType │
├─────────────┤         ├──────────────┤         ├─────────────┤
│ id          │◄──┐     │ id           │         │ id          │
│ name        │   │     │ title        │         │ name        │
│ email       │   │     │ description  │         │ description │
│ password    │   │     │ status       │         └──────┬───────┘
│ role        │   │     │ priority     │              │
│ created_at  │   │     │ created_at   │              │
└─────────────┘   │     │ created_by   │──┐           │
                  │     │ assigned_to  │──┘           │
                  │     │ problem_type │──────────────┘
                  │     │ is_public    │
                  │     └──────┬───────┘
                  │            │
                  │            │
┌─────────────┐   │     ┌──────▼───────┐
│   Reply     │   │     │   Reply      │
├─────────────┤   │     ├──────────────┤
│ id          │   │     │ id           │
│ ticket_id   │───┘     │ content      │
│ author_id   │─────────│ created_at   │
│ content     │         └──────────────┘
│ created_at  │
└─────────────┘
```

---

## 🔄 Flux de Données

### Flux de Création d'un Ticket

```
1. Utilisateur remplit le formulaire
   ↓
2. Frontend envoie POST /api/tickets
   ↓
3. TicketController reçoit la requête
   ↓
4. TicketService.createTicket()
   - Valide les données
   - Trouve un agent disponible (spécialisation + round-robin)
   - Crée le ticket avec l'agent assigné
   ↓
5. TicketRepository.save()
   ↓
6. Hibernate génère SQL INSERT
   ↓
7. MySQL exécute l'insertion
   ↓
8. TicketResponse retourné au frontend
   ↓
9. Frontend met à jour l'interface
```

### Flux d'Attribution Automatique

```
1. TicketService.createTicket()
   ↓
2. Récupère le type de problème du ticket
   ↓
3. Trouve les agents avec cette spécialisation
   ↓
4. Pour chaque agent, compte les tickets actifs
   ↓
5. Sélectionne l'agent avec le moins de tickets
   ↓
6. En cas d'égalité, utilise round-robin
   ↓
7. Assigne le ticket à l'agent sélectionné
```

---

## 🎨 Architecture Frontend

### Structure des Composants React

```
App.jsx
├── AuthContext (Provider)
│   └── Gestion de l'état d'authentification
│
├── Routes
│   ├── /login → Login.jsx
│   │   └── Formulaire de connexion/inscription
│   │
│   ├── /dashboard → Dashboard.jsx
│   │   ├── Sidebar (navigation)
│   │   └── Outlet (contenu)
│   │       ├── /tickets → TicketList.jsx
│   │       ├── /tickets/new → CreateTicket.jsx
│   │       ├── /tickets/:id → TicketDetails.jsx
│   │       └── /agents → AgentManagement.jsx (ADMIN)
│   │
│   └── PrivateRoute
│       └── Protection des routes authentifiées
│
└── Components
    └── PrivateRoute.jsx
        └── Vérification de l'authentification
```

### Gestion d'État

- **AuthContext** : État global de l'authentification
  - `user` : Utilisateur actuel
  - `token` : Token JWT
  - `login()` : Fonction de connexion
  - `logout()` : Fonction de déconnexion

- **État Local** : Utilisé dans chaque composant pour les données spécifiques

### Communication API

```
Frontend Component
    ↓
Axios Instance (api.js)
    ↓
Intercepteur Request
    - Ajoute Authorization header
    ↓
Intercepteur Response
    - Gère les erreurs 401 (déconnexion)
    ↓
Backend API
```

---

## 🐳 Architecture Docker

### Structure des Conteneurs

```
┌─────────────────────────────────────────┐
│         Docker Compose Network          │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │   Frontend   │  │   Backend    │   │
│  │   (Nginx)    │  │  (Spring)    │   │
│  │   Port 5174  │  │  Port 8086   │   │
│  └──────┬───────┘  └──────┬───────┘   │
│         │                │           │
│         │                │           │
│  ┌──────▼────────────────▼───────┐   │
│  │         MySQL Database        │   │
│  │         Port 3307             │   │
│  └───────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### Configuration Docker Compose

- **Network** : `ticket-network-test` (bridge)
- **Volumes** : Persistance des données MySQL
- **Health Checks** : Vérification de l'état des services
- **Dependencies** : Backend dépend de MySQL, Frontend dépend de Backend

---

## 🔄 Patterns de Conception Utilisés

### 1. Repository Pattern
- Abstraction de l'accès aux données
- Implémenté via Spring Data JPA

### 2. Service Layer Pattern
- Séparation de la logique métier
- Services injectés dans les contrôleurs

### 3. DTO Pattern
- Data Transfer Objects pour les échanges API
- Séparation entre entités JPA et objets de transfert

### 4. Filter Pattern
- JwtAuthenticationFilter pour l'authentification
- Intercepte toutes les requêtes

### 5. Strategy Pattern
- Algorithme d'attribution (spécialisation + round-robin)
- Peut être facilement étendu

---

## 📊 Performance et Scalabilité

### Optimisations Actuelles

1. **Lazy Loading** : Relations JPA chargées à la demande
2. **Indexation** : Index sur les colonnes fréquemment recherchées
3. **Pagination** : Possibilité d'ajouter la pagination pour les listes
4. **Cache** : Potentiel de mise en cache des requêtes fréquentes

### Améliorations Possibles

1. **Cache Redis** : Pour les sessions et données fréquentes
2. **Load Balancing** : Plusieurs instances backend
3. **CDN** : Pour les assets statiques du frontend
4. **Database Replication** : Pour la haute disponibilité

---

## 🔍 Monitoring et Logging

### Logging Actuel

- **Spring Boot Logging** : Logs par défaut
- **Niveaux** : DEBUG pour développement, INFO pour production
- **Logs SQL** : Activés en développement (`show-sql: true`)

### Améliorations Possibles

1. **Structured Logging** : JSON logs pour l'analyse
2. **Log Aggregation** : ELK Stack ou équivalent
3. **Metrics** : Spring Boot Actuator
4. **APM** : Application Performance Monitoring

---

## 🛡️ Sécurité

### Mesures de Sécurité Implémentées

1. **Authentification JWT** : Tokens signés et expirables
2. **Hachage BCrypt** : Mots de passe sécurisés
3. **CORS** : Configuration restrictive
4. **Validation** : Validation des entrées utilisateur
5. **SQL Injection Protection** : Via JPA/Hibernate

### Bonnes Pratiques

- Tokens JWT avec expiration
- Secrets stockés dans les variables d'environnement
- HTTPS en production (à configurer)
- Rate limiting (à implémenter)

---

Cette architecture garantit une séparation claire des responsabilités, une maintenabilité élevée et une évolutivité pour les futures fonctionnalités.
