# Fonctionnalités Détaillées du Système de Gestion de Tickets

## 📋 Table des Matières

1. [Authentification et Autorisation](#authentification-et-autorisation)
2. [Gestion des Utilisateurs](#gestion-des-utilisateurs)
3. [Gestion des Tickets](#gestion-des-tickets)
4. [Système de Réponses](#système-de-réponses)
5. [Gestion des Agents](#gestion-des-agents)
6. [Types de Problèmes](#types-de-problèmes)
7. [Attribution Automatique](#attribution-automatique)
8. [Interface Utilisateur](#interface-utilisateur)

---

## 🔐 Authentification et Autorisation

### Authentification JWT

**Description** : Système d'authentification sans état utilisant JSON Web Tokens.

**Fonctionnalités** :
- Connexion avec email et mot de passe
- Génération de token JWT valide 24 heures
- Stockage sécurisé du token dans le localStorage
- Validation automatique du token sur chaque requête
- Déconnexion automatique si le token expire

**Flux** :
1. L'utilisateur saisit ses identifiants
2. Le backend valide les credentials
3. Un token JWT est généré avec les informations utilisateur
4. Le token est renvoyé au frontend
5. Le frontend stocke le token et l'inclut dans toutes les requêtes suivantes

**Sécurité** :
- Mots de passe hachés avec BCrypt (force 12)
- Tokens signés avec une clé secrète
- Expiration automatique des tokens
- Validation côté serveur à chaque requête

### Contrôle d'Accès Basé sur les Rôles (RBAC)

#### Rôle ADMIN

**Permissions** :
- ✅ Accès complet au système
- ✅ Création, lecture, modification, suppression de tous les tickets
- ✅ Attribution manuelle de tickets aux agents
- ✅ Création et gestion des agents
- ✅ Gestion des types de problèmes
- ✅ Suppression de tickets
- ✅ Consultation de tous les tickets (publics et privés)

**Interface** :
- Tableau de bord avec vue d'ensemble complète
- Page de gestion des agents
- Statistiques et métriques

#### Rôle AGENT

**Permissions** :
- ✅ Consultation des tickets qui lui sont assignés
- ✅ Modification du statut des tickets assignés
- ✅ Modification de la priorité des tickets assignés
- ✅ Ajout de réponses aux tickets assignés
- ❌ Création de nouveaux tickets
- ❌ Suppression de tickets
- ❌ Attribution de tickets
- ❌ Consultation des tickets non assignés

**Interface** :
- Tableau de bord avec tickets assignés
- Filtres pour trouver des tickets spécifiques
- Vue détaillée des tickets avec historique

#### Rôle USER

**Permissions** :
- ✅ Création de nouveaux tickets
- ✅ Consultation de ses propres tickets
- ✅ Consultation des tickets publics
- ✅ Ajout de réponses à ses tickets
- ✅ Suivi de l'état de ses tickets
- ❌ Modification des tickets (sauf ses propres réponses)
- ❌ Suppression de tickets
- ❌ Consultation des tickets privés d'autres utilisateurs

**Interface** :
- Formulaire de création de ticket
- Liste de ses tickets
- Vue détaillée avec réponses

---

## 👥 Gestion des Utilisateurs

### Inscription Publique

**Description** : Les utilisateurs peuvent créer un compte eux-mêmes.

**Processus** :
1. L'utilisateur accède à la page de connexion
2. Clique sur "S'inscrire" ou "Créer un compte"
3. Remplit le formulaire :
   - Nom complet
   - Email (unique)
   - Mot de passe (minimum 6 caractères)
4. Le compte est créé avec le rôle USER par défaut
5. L'utilisateur est automatiquement connecté

**Validation** :
- Email doit être unique
- Email doit être valide
- Mot de passe minimum 6 caractères
- Tous les champs sont obligatoires

### Création d'Agents par l'Administrateur

**Description** : Seuls les administrateurs peuvent créer des comptes agents.

**Processus** :
1. L'administrateur accède à la page "Gestion des Agents"
2. Clique sur "Créer un Agent"
3. Remplit le formulaire :
   - Nom complet
   - Email (unique)
   - Mot de passe
   - Spécialisations (une ou plusieurs)
4. L'agent est créé avec le rôle AGENT
5. L'agent peut se connecter immédiatement

**Spécialisations** :
- Un agent peut avoir plusieurs spécialisations
- Les spécialisations déterminent quels tickets peuvent lui être assignés
- Les spécialisations peuvent être modifiées par l'administrateur

---

## 🎫 Gestion des Tickets

### Création de Tickets

**Par les Utilisateurs** :
- Formulaire accessible depuis le tableau de bord
- Champs requis :
  - Titre (obligatoire)
  - Description (obligatoire)
  - Type de problème (sélection)
  - Priorité (LOW, MEDIUM, HIGH)
  - Visibilité (Public/Privé)
- Attribution automatique à un agent disponible

**Par les Administrateurs** :
- Même formulaire que les utilisateurs
- Possibilité d'assigner manuellement après création
- Peut créer des tickets pour d'autres utilisateurs

### Types de Problèmes

**Types par défaut** :
1. **TECHNICAL** : Problèmes techniques et bugs
2. **BILLING** : Problèmes de facturation et paiement
3. **ACCOUNT** : Gestion de compte
4. **FEATURE_REQUEST** : Demandes de fonctionnalités
5. **GENERAL** : Demandes générales

**Gestion** :
- Les administrateurs peuvent ajouter/modifier les types
- Chaque ticket doit avoir un type de problème
- Les types déterminent l'agent à assigner

### Statuts des Tickets

**Statuts disponibles** :
- **OPEN** : Ticket créé, en attente de traitement
- **IN_PROGRESS** : Ticket pris en charge par un agent
- **CLOSED** : Ticket résolu et fermé

**Transitions** :
- OPEN → IN_PROGRESS : Agent commence le traitement
- IN_PROGRESS → CLOSED : Problème résolu
- CLOSED → IN_PROGRESS : Réouverture si nécessaire

### Priorités

**Niveaux de priorité** :
- **LOW** : Priorité faible, peut attendre
- **MEDIUM** : Priorité normale
- **HIGH** : Priorité élevée, traitement urgent

**Affichage** :
- Codes couleur dans l'interface
- Filtrage possible par priorité
- Tri par priorité disponible

### Visibilité

**Public** :
- Visible par tous les utilisateurs connectés
- Permet la collaboration entre utilisateurs
- Utile pour les questions fréquentes

**Privé** :
- Visible uniquement par le créateur et l'agent assigné
- Pour les problèmes sensibles ou personnels
- Confidentialité garantie

### Filtrage et Recherche

**Filtres disponibles** :
- Par statut (OPEN, IN_PROGRESS, CLOSED)
- Par priorité (LOW, MEDIUM, HIGH)
- Par type de problème
- Par agent assigné (ADMIN uniquement)
- Par créateur (USER voit seulement les siens)

**Recherche** :
- Recherche textuelle dans le titre et la description
- Recherche par ID de ticket
- Combinaison de filtres multiples

---

## 💬 Système de Réponses

### Fonctionnalités

**Réponses multiples** :
- Utilisateurs et agents peuvent répondre
- Historique complet des échanges
- Ordre chronologique des réponses

**Interface** :
- Zone de réponse en bas de chaque ticket
- Affichage de toutes les réponses avec :
  - Auteur (nom et rôle)
  - Date et heure
  - Contenu de la réponse
- Indication visuelle du rôle de l'auteur

**Permissions** :
- Utilisateurs : Peuvent répondre à leurs propres tickets
- Agents : Peuvent répondre aux tickets assignés
- Administrateurs : Peuvent répondre à tous les tickets

### Format des Réponses

**Contenu** :
- Texte libre (TEXT)
- Pas de limite de caractères
- Support du formatage basique (à améliorer avec Markdown)

**Métadonnées** :
- ID unique
- ID du ticket
- ID de l'auteur
- Date de création (timestamp)

---

## 👨‍💼 Gestion des Agents

### Création d'Agents

**Processus** :
1. Administrateur accède à "Gestion des Agents"
2. Clique sur "Créer un Agent"
3. Remplit le formulaire :
   - Informations personnelles (nom, email)
   - Mot de passe
   - Sélection des spécialisations
4. L'agent est créé et peut se connecter

### Spécialisations

**Définition** :
- Un agent peut être spécialisé dans un ou plusieurs types de problèmes
- Les spécialisations déterminent l'éligibilité pour l'attribution automatique
- Un agent sans spécialisation ne recevra pas de tickets automatiquement

**Gestion** :
- Ajout/modification des spécialisations par l'administrateur
- Un agent peut avoir plusieurs spécialisations
- Les spécialisations peuvent être modifiées à tout moment

### Suivi des Agents

**Métriques disponibles** :
- Nombre de tickets actifs par agent
- Nombre total de tickets traités
- Temps moyen de résolution (à implémenter)

**Affichage** :
- Liste de tous les agents
- Nombre de tickets actifs affiché
- Tri par charge de travail

---

## 🎯 Attribution Automatique

### Algorithme d'Attribution

**Processus en deux étapes** :

1. **Filtrage par Spécialisation** :
   - Trouve tous les agents ayant la spécialisation correspondant au type de problème
   - Si aucun agent n'a la spécialisation, trouve les agents sans spécialisation

2. **Sélection par Round-Robin** :
   - Compte le nombre de tickets actifs (non CLOSED) pour chaque agent éligible
   - Sélectionne l'agent avec le moins de tickets actifs
   - En cas d'égalité, utilise un système round-robin

**Exemple** :
```
Ticket créé avec type "TECHNICAL"
  ↓
Agents avec spécialisation TECHNICAL :
  - Agent A : 3 tickets actifs
  - Agent B : 2 tickets actifs
  - Agent C : 2 tickets actifs
  ↓
Sélection : Agent B ou C (round-robin entre les deux)
```

### Attribution Manuelle

**Par les Administrateurs** :
- Possibilité d'assigner manuellement un ticket à n'importe quel agent
- Utile pour :
  - Réassigner un ticket
  - Assigner à un agent spécifique
  - Équilibrer la charge manuellement

**Processus** :
1. Administrateur ouvre un ticket
2. Clique sur "Assigner"
3. Sélectionne un agent dans la liste
4. Le ticket est assigné immédiatement

---

## 🎨 Interface Utilisateur

### Design

**Framework** : Tailwind CSS
- Design moderne et épuré
- Responsive (mobile, tablette, desktop)
- Codes couleur pour les statuts et priorités

### Navigation

**Structure** :
- Sidebar avec navigation principale
- Contenu principal au centre
- Header avec informations utilisateur

**Routes** :
- `/login` : Connexion/Inscription
- `/dashboard` : Tableau de bord
- `/dashboard/tickets` : Liste des tickets
- `/dashboard/tickets/new` : Créer un ticket
- `/dashboard/tickets/:id` : Détails d'un ticket
- `/dashboard/agents` : Gestion des agents (ADMIN)

### Composants Réutilisables

**PrivateRoute** :
- Protection des routes authentifiées
- Redirection vers login si non authentifié

**Dashboard** :
- Layout commun avec sidebar
- Adaptation selon le rôle utilisateur

**TicketCard** :
- Affichage compact d'un ticket
- Informations essentielles visibles
- Lien vers les détails

### Responsive Design

**Breakpoints** :
- Mobile : < 640px
- Tablette : 640px - 1024px
- Desktop : > 1024px

**Adaptations** :
- Sidebar collapsible sur mobile
- Tableaux scrollables horizontalement
- Formulaires adaptés à la taille d'écran

---

## 📊 Statistiques et Rapports

### Métriques Disponibles

**Pour les Administrateurs** :
- Nombre total de tickets
- Répartition par statut
- Répartition par priorité
- Répartition par type de problème
- Nombre de tickets par agent
- Temps moyen de résolution (à implémenter)

**Pour les Agents** :
- Nombre de tickets assignés
- Répartition par statut
- Tickets en attente

**Pour les Utilisateurs** :
- Nombre de tickets créés
- Statut de leurs tickets

### Améliorations Futures

- Graphiques et visualisations
- Export de rapports (CSV, PDF)
- Notifications en temps réel
- Dashboard avec widgets personnalisables

---

Cette documentation détaille toutes les fonctionnalités du système. Chaque fonctionnalité est conçue pour être intuitive, sécurisée et efficace.
