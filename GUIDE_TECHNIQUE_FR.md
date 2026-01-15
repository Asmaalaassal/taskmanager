# Guide Technique Complet

## 📋 Table des Matières

1. [Architecture Backend](#architecture-backend)
2. [Architecture Frontend](#architecture-frontend)
3. [Base de Données](#base-de-données)
4. [Sécurité](#sécurité)
5. [API REST](#api-rest)
6. [Docker et Conteneurisation](#docker-et-conteneurisation)
7. [Configuration](#configuration)
8. [Développement](#développement)
9. [Tests](#tests)
10. [Performance](#performance)

---

## 🏗️ Architecture Backend

### Structure du Projet Spring Boot

```
backend/
├── src/main/java/com/ticketmanager/
│   ├── TicketManagerApplication.java    # Point d'entrée
│   ├── config/                          # Configuration
│   │   └── SecurityConfig.java          # Sécurité et CORS
│   ├── controller/                      # Contrôleurs REST
│   │   ├── AuthController.java
│   │   ├── TicketController.java
│   │   ├── AgentController.java
│   │   ├── ReplyController.java
│   │   └── ProblemTypeController.java
│   ├── dto/                             # Data Transfer Objects
│   │   ├── LoginRequest.java
│   │   ├── AuthResponse.java
│   │   ├── TicketResponse.java
│   │   └── ...
│   ├── entity/                          # Entités JPA
│   │   ├── User.java
│   │   ├── Ticket.java
│   │   ├── Reply.java
│   │   ├── ProblemType.java
│   │   ├── Role.java
│   │   ├── TicketStatus.java
│   │   └── Priority.java
│   ├── repository/                      # Repositories JPA
│   │   ├── UserRepository.java
│   │   ├── TicketRepository.java
│   │   ├── ReplyRepository.java
│   │   └── ProblemTypeRepository.java
│   ├── service/                          # Services (logique métier)
│   │   ├── UserService.java
│   │   ├── TicketService.java
│   │   ├── ReplyService.java
│   │   └── ProblemTypeService.java
│   ├── security/                        # Sécurité
│   │   └── JwtAuthenticationFilter.java
│   ├── exception/                       # Gestion des exceptions
│   │   ├── ResourceNotFoundException.java
│   │   └── GlobalExceptionHandler.java
│   └── util/                            # Utilitaires
│       └── JwtUtil.java
└── src/main/resources/
    ├── application.yml                   # Configuration
    └── db/migration/                    # Migrations Flyway
        ├── V1__create_users_table.sql
        ├── V2__create_tickets_table.sql
        └── ...
```

### Couches de l'Application

#### 1. Couche Contrôleur (Controller)

**Responsabilités** :
- Recevoir les requêtes HTTP
- Valider les entrées (DTOs)
- Appeler les services
- Retourner les réponses HTTP

**Exemple** : `TicketController.java`

```java
@RestController
@RequestMapping("/api/tickets")
@RequiredArgsConstructor
public class TicketController {
    private final TicketService ticketService;
    
    @GetMapping
    public ResponseEntity<List<TicketResponse>> getAllTickets(
        @RequestParam(required = false) String status,
        @RequestParam(required = false) String priority
    ) {
        // Logique de récupération
    }
}
```

#### 2. Couche Service (Service)

**Responsabilités** :
- Logique métier
- Validation des règles métier
- Orchestration des opérations
- Gestion des transactions

**Exemple** : `TicketService.java`

```java
@Service
@RequiredArgsConstructor
public class TicketService {
    private final TicketRepository ticketRepository;
    private final UserRepository userRepository;
    
    public TicketResponse createTicket(CreateTicketRequest request, User creator) {
        // Validation
        // Attribution automatique
        // Création
        // Retour
    }
}
```

#### 3. Couche Repository (Repository)

**Responsabilités** :
- Accès aux données
- Requêtes personnalisées
- Abstraction de la base de données

**Exemple** : `TicketRepository.java`

```java
@Repository
public interface TicketRepository extends JpaRepository<Ticket, Long> {
    List<Ticket> findByAssignedToId(Long agentId);
    List<Ticket> findByCreatedById(Long userId);
    // Requêtes personnalisées
}
```

### Spring Security

#### Configuration

**Fichier** : `SecurityConfig.java`

**Fonctionnalités** :
- Désactivation CSRF (stateless avec JWT)
- Configuration CORS
- Filtre JWT personnalisé
- Gestion des sessions (STATELESS)

#### Filtre JWT

**Fichier** : `JwtAuthenticationFilter.java`

**Processus** :
1. Intercepte chaque requête
2. Extrait le token du header `Authorization`
3. Valide le token
4. Charge l'utilisateur depuis la base de données
5. Définit le contexte Spring Security

### Gestion des Exceptions

#### GlobalExceptionHandler

**Fichier** : `GlobalExceptionHandler.java`

**Fonctionnalités** :
- Capture toutes les exceptions
- Retourne des réponses HTTP appropriées
- Logging des erreurs
- Messages d'erreur structurés

**Exemple** :
```java
@ExceptionHandler(ResourceNotFoundException.class)
public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ErrorResponse(ex.getMessage()));
}
```

---

## 🎨 Architecture Frontend

### Structure du Projet React

```
frontend/
├── src/
│   ├── main.jsx                         # Point d'entrée
│   ├── App.jsx                          # Composant racine
│   ├── index.css                        # Styles globaux
│   ├── api/
│   │   └── axios.js                     # Configuration Axios
│   ├── context/
│   │   └── AuthContext.jsx              # Context d'authentification
│   ├── components/
│   │   └── PrivateRoute.jsx             # Route protégée
│   └── pages/
│       ├── Login.jsx                    # Page de connexion
│       ├── Dashboard.jsx                # Layout principal
│       ├── TicketList.jsx                # Liste des tickets
│       ├── CreateTicket.jsx             # Création de ticket
│       ├── TicketDetails.jsx            # Détails d'un ticket
│       └── AgentManagement.jsx          # Gestion des agents
├── package.json
├── vite.config.js
├── tailwind.config.js
└── nginx.conf                           # Configuration Nginx (prod)
```

### Gestion d'État

#### AuthContext

**Fichier** : `AuthContext.jsx`

**État** :
- `user` : Utilisateur actuel
- `token` : Token JWT
- `loading` : État de chargement

**Fonctions** :
- `login(email, password)` : Connexion
- `register(userData)` : Inscription
- `logout()` : Déconnexion
- `getCurrentUser()` : Récupérer l'utilisateur actuel

**Utilisation** :
```jsx
const { user, login, logout } = useAuth();
```

### Routing

**Bibliothèque** : React Router DOM v6

**Structure** :
```jsx
<Routes>
  <Route path="/login" element={<Login />} />
  <Route path="/dashboard" element={<PrivateRoute><Dashboard /></PrivateRoute>}>
    <Route path="tickets" element={<TicketList />} />
    <Route path="tickets/new" element={<CreateTicket />} />
    <Route path="tickets/:id" element={<TicketDetails />} />
    <Route path="agents" element={<AgentManagement />} />
  </Route>
</Routes>
```

### Communication API

#### Configuration Axios

**Fichier** : `api/axios.js`

**Fonctionnalités** :
- Configuration de base URL
- Intercepteur pour ajouter le token
- Intercepteur pour gérer les erreurs
- Gestion automatique de la déconnexion

**Exemple** :
```javascript
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

---

## 🗄️ Base de Données

### MySQL

**Version** : 8.0+

**Configuration** :
- Charset : UTF-8
- Collation : utf8mb4_unicode_ci
- Timezone : UTC

### Migrations Flyway

**Principe** : Versioning du schéma de base de données

**Fichiers** : `backend/src/main/resources/db/migration/`

**Convention de nommage** : `V{version}__{description}.sql`

**Exemples** :
- `V1__create_users_table.sql`
- `V2__create_tickets_table.sql`
- `V3__insert_default_admin.sql`

**Exécution** : Automatique au démarrage de l'application

### Relations

#### Users ↔ Tickets

- **One-to-Many** : Un utilisateur peut créer plusieurs tickets
- **Many-to-One** : Un ticket appartient à un créateur
- **Many-to-One** : Un ticket peut être assigné à un agent

#### Tickets ↔ Replies

- **One-to-Many** : Un ticket peut avoir plusieurs réponses
- **Many-to-One** : Une réponse appartient à un ticket

#### Users ↔ ProblemTypes (via Agent Specializations)

- **Many-to-Many** : Un agent peut avoir plusieurs spécialisations
- **Table de jointure** : `agent_specializations`

### Index

**Index créés** :
- `users.email` : UNIQUE (contrainte)
- `tickets.created_by` : INDEX (recherche fréquente)
- `tickets.assigned_to` : INDEX (recherche fréquente)
- `replies.ticket_id` : INDEX (recherche fréquente)

---

## 🔒 Sécurité

### Authentification JWT

#### Génération du Token

**Fichier** : `JwtUtil.java`

**Processus** :
1. Création des claims (email, rôle)
2. Définition de l'expiration (24 heures)
3. Signature avec la clé secrète
4. Encodage en Base64

**Exemple** :
```java
String token = Jwts.builder()
    .setSubject(user.getEmail())
    .claim("role", user.getRole().name())
    .setExpiration(new Date(System.currentTimeMillis() + expiration))
    .signWith(SignatureAlgorithm.HS256, secret)
    .compact();
```

#### Validation du Token

**Processus** :
1. Extraction du token du header
2. Parsing et validation de la signature
3. Vérification de l'expiration
4. Extraction des claims
5. Chargement de l'utilisateur depuis la base de données

### Hachage des Mots de Passe

**Algorithme** : BCrypt

**Force** : 12 rounds

**Exemple** :
```java
BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);
String hashedPassword = encoder.encode("password123");
```

### CORS

**Configuration** : `SecurityConfig.java`

**Origines autorisées** :
- `http://localhost:5173` (développement)
- `http://147.79.101.138:5174` (test)
- `http://147.79.101.138` (production)

**Méthodes autorisées** : GET, POST, PUT, DELETE, OPTIONS, PATCH

**Headers autorisés** : Tous (`*`)

**Credentials** : Autorisés

---

## 🌐 API REST

### Conventions

#### URLs

- **Format** : `/api/{resource}/{id?}/{action?}`
- **Exemples** :
  - `/api/tickets`
  - `/api/tickets/1`
  - `/api/tickets/1/assign`

#### Méthodes HTTP

- **GET** : Récupération de ressources
- **POST** : Création de ressources
- **PUT** : Mise à jour complète
- **PATCH** : Mise à jour partielle
- **DELETE** : Suppression

#### Codes de Statut

- **200 OK** : Succès
- **201 Created** : Ressource créée
- **400 Bad Request** : Requête invalide
- **401 Unauthorized** : Non authentifié
- **403 Forbidden** : Non autorisé
- **404 Not Found** : Ressource introuvable
- **500 Internal Server Error** : Erreur serveur

### Documentation API

#### Endpoints Principaux

**Authentification** :
- `POST /api/auth/login` : Connexion
- `POST /api/auth/register` : Inscription
- `GET /api/auth/me` : Utilisateur actuel

**Tickets** :
- `GET /api/tickets` : Liste (filtrée)
- `POST /api/tickets` : Création
- `GET /api/tickets/{id}` : Détails
- `PUT /api/tickets/{id}` : Mise à jour
- `PUT /api/tickets/{id}/assign` : Attribution
- `DELETE /api/tickets/{id}` : Suppression

**Réponses** :
- `GET /api/tickets/{id}/replies` : Liste
- `POST /api/tickets/{id}/replies` : Création

---

## 🐳 Docker et Conteneurisation

### Dockerfile Backend

**Stratégie** : Multi-stage build

**Stages** :
1. **Build** : Maven avec JDK 17
2. **Runtime** : Alpine Linux avec JRE 17

**Optimisations** :
- Image finale minimale (~200MB)
- Utilisateur non-root
- Health check intégré

### Dockerfile Frontend

**Stratégie** : Multi-stage build

**Stages** :
1. **Build** : Node.js avec Vite
2. **Runtime** : Nginx Alpine

**Optimisations** :
- Image finale minimale (~50MB)
- Configuration Nginx optimisée
- Support SPA (Single Page Application)

### Docker Compose

**Fichiers** :
- `docker-compose.test.yml` : Environnement de test
- `docker-compose.prod.yml` : Environnement de production

**Services** :
- MySQL : Base de données
- Backend : Application Spring Boot
- Frontend : Application React (Nginx)

**Networks** : Isolation par environnement

**Volumes** : Persistance des données MySQL

---

## ⚙️ Configuration

### Backend (`application.yml`)

**Sections principales** :
- `spring` : Configuration Spring
  - `datasource` : Configuration MySQL
  - `jpa` : Configuration JPA/Hibernate
  - `flyway` : Configuration Flyway
- `server` : Configuration serveur
  - `port` : Port d'écoute
  - `address` : Interface d'écoute (0.0.0.0)
- `jwt` : Configuration JWT
  - `secret` : Clé secrète
  - `expiration` : Durée de validité

### Frontend

**Variables d'environnement** :
- `VITE_API_URL` : URL de l'API backend

**Configuration Vite** :
- `vite.config.js` : Configuration du build
- `tailwind.config.js` : Configuration Tailwind CSS

### Variables d'Environnement Docker

**Backend** :
- `SPRING_DATASOURCE_URL` : URL de connexion MySQL
- `SPRING_DATASOURCE_USERNAME` : Utilisateur MySQL
- `SPRING_DATASOURCE_PASSWORD` : Mot de passe MySQL
- `JWT_SECRET` : Clé secrète JWT
- `SERVER_PORT` : Port d'écoute

**Frontend** :
- `VITE_API_URL` : URL de l'API (passée au build)

---

## 💻 Développement

### Setup Local

#### Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

### Hot Reload

**Backend** : Spring Boot DevTools (si ajouté)

**Frontend** : Vite HMR (Hot Module Replacement) activé par défaut

### Debugging

#### Backend

**IDE** : Attacher un debugger sur le port 5005 (si configuré)

**Logs** : Console ou fichiers de logs

#### Frontend

**Browser DevTools** : Console, Network, React DevTools

**Vite** : Logs dans le terminal

---

## 🧪 Tests

### Backend

**Framework** : JUnit 5 + Spring Boot Test

**Types de tests** :
- Unitaires : Services, Utilitaires
- Intégration : Controllers, Repositories
- Sécurité : Authentification, Autorisation

**Exécution** :
```bash
mvn test
```

### Frontend

**Framework** : (À implémenter : Vitest, React Testing Library)

**Types de tests** :
- Unitaires : Composants
- Intégration : Flux utilisateur
- E2E : (À implémenter : Playwright, Cypress)

---

## ⚡ Performance

### Optimisations Actuelles

1. **Lazy Loading** : Relations JPA chargées à la demande
2. **Indexation** : Index sur colonnes fréquemment recherchées
3. **Pagination** : (À implémenter pour les listes)
4. **Cache** : (Potentiel de mise en cache)

### Améliorations Possibles

1. **Cache Redis** : Sessions, données fréquentes
2. **CDN** : Assets statiques
3. **Database Connection Pooling** : HikariCP (déjà configuré)
4. **Compression** : Gzip pour les réponses HTTP
5. **Load Balancing** : Plusieurs instances backend

### Métriques

**À surveiller** :
- Temps de réponse des API
- Utilisation CPU/RAM
- Nombre de connexions MySQL
- Taille de la base de données
- Temps de chargement frontend

---

Ce guide technique couvre tous les aspects techniques du système. Pour plus de détails sur l'architecture, voir [ARCHITECTURE_FR.md](./ARCHITECTURE_FR.md).
