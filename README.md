# Ticket Management System

A modern, full-stack ticket management system built with Spring Boot (backend) and React (frontend), featuring JWT authentication, role-based access control, and database migrations.

## Features

- **Authentication & Authorization**
  - JWT-based stateless authentication
  - Role-based access control (ADMIN, AGENT)
  - Secure password hashing with BCrypt

- **Ticket Management**
  - Create, read, update, and delete tickets
  - Assign tickets to agents (ADMIN only)
  - Update ticket status and priority
  - Filter tickets by role (ADMIN sees all, AGENT sees assigned)

- **Database Migrations**
  - Flyway for version-controlled database migrations
  - Automatic schema creation and updates

- **Modern UI**
  - Clean, responsive design with Tailwind CSS
  - Role-based navigation
  - Color-coded status and priority indicators

## Tech Stack

### Backend
- Spring Boot 3.2.0
- Java 17
- Spring Data JPA + Hibernate
- Spring Security
- JWT (jjwt 0.12.3)
- MySQL
- Flyway
- Lombok
- Maven

### Frontend
- React 18
- Vite
- Tailwind CSS
- Axios
- React Router DOM

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- Node.js 18+ and npm
- MySQL 8.0+
- MySQL server running on `localhost:3306`

## Database Setup

1. **Create MySQL Database**
   ```sql
   CREATE DATABASE ticket_system;
   ```

2. **Update Database Credentials**
   Edit `backend/src/main/resources/application.yml` if your MySQL credentials differ:
   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3306/ticket_system?useSSL=false&serverTimezone=UTC
       username: root
       password: root  # Change if needed
   ```

## Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Build the project**
   ```bash
   mvn clean install
   ```

3. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

   The backend will start on `http://localhost:8080`

   **Note:** Flyway will automatically run migrations on startup:
   - `V1__create_users_table.sql` - Creates users table
   - `V2__create_tickets_table.sql` - Creates tickets table
   - `V3__insert_default_admin.sql` - Inserts default admin user

## Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

   The frontend will start on `http://localhost:5173`

## Default Admin Credentials

After running the migrations, you can login with:

- **Email:** `admin@ticketmanager.com`
- **Password:** `admin123`

**Note:** The password is BCrypt hashed in the migration file. The hash is:
```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

## API Endpoints

### Authentication

- `POST /api/auth/login` - Login (public)
  ```json
  {
    "email": "admin@ticketmanager.com",
    "password": "admin123"
  }
  ```

- `POST /api/auth/register` - Register new agent (ADMIN only)
  ```json
  {
    "name": "Agent Name",
    "email": "agent@example.com",
    "password": "password123"
  }
  ```

- `GET /api/auth/me` - Get current user (authenticated)

### Tickets

- `POST /api/tickets` - Create ticket (ADMIN only)
  ```json
  {
    "title": "Ticket Title",
    "description": "Ticket Description",
    "priority": "HIGH"
  }
  ```

- `GET /api/tickets` - List tickets
  - ADMIN: Returns all tickets
  - AGENT: Returns only assigned tickets

- `GET /api/tickets/{id}` - Get ticket details

- `PUT /api/tickets/{id}` - Update ticket status/priority
  ```json
  {
    "status": "IN_PROGRESS",
    "priority": "MEDIUM"
  }
  ```

- `PUT /api/tickets/{id}/assign` - Assign ticket to agent (ADMIN only)
  ```json
  {
    "agentId": 2
  }
  ```

- `DELETE /api/tickets/{id}` - Delete ticket (ADMIN only)

## Database Migrations (Flyway)

Flyway migrations are located in `backend/src/main/resources/db/migration/`:

1. **V1__create_users_table.sql**
   - Creates `users` table with id, name, email, password, role, and created_at

2. **V2__create_tickets_table.sql**
   - Creates `tickets` table with id, title, description, status, priority, created_at, created_by, and assigned_to
   - Foreign keys to users table

3. **V3__insert_default_admin.sql**
   - Inserts default admin user with BCrypt hashed password

Flyway automatically runs migrations on application startup. The `ddl-auto` is set to `validate` to ensure schema matches entities.

## Project Structure

```
taskmanager/
├── backend/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/ticketmanager/
│   │   │   │   ├── config/          # Security & CORS config
│   │   │   │   ├── controller/      # REST controllers
│   │   │   │   ├── dto/             # Data Transfer Objects
│   │   │   │   ├── entity/          # JPA entities
│   │   │   │   ├── exception/       # Exception handlers
│   │   │   │   ├── repository/      # JPA repositories
│   │   │   │   ├── security/        # JWT filter
│   │   │   │   ├── service/         # Business logic
│   │   │   │   └── util/            # JWT utilities
│   │   │   └── resources/
│   │   │       ├── db/migration/    # Flyway migrations
│   │   │       └── application.yml  # Application config
│   │   └── pom.xml
│   └── README.md
├── frontend/
│   ├── src/
│   │   ├── components/              # Reusable components
│   │   ├── context/                 # React context (Auth)
│   │   ├── pages/                   # Page components
│   │   ├── api/                     # API configuration
│   │   ├── App.jsx
│   │   └── main.jsx
│   ├── package.json
│   └── vite.config.js
└── README.md
```

## JWT Authentication Flow

1. User submits login credentials to `/api/auth/login`
2. Backend validates credentials and generates JWT token
3. Frontend stores token in `localStorage`
4. Axios interceptor adds `Authorization: Bearer <token>` header to all requests
5. Backend JWT filter validates token on each request
6. User details are extracted and set in Spring Security context

## Role-Based Access Control

### ADMIN
- Full CRUD operations on tickets
- Assign tickets to agents
- Register new agents
- Delete tickets

### AGENT
- View assigned tickets only
- Update ticket status and priority
- Cannot create, delete, or assign tickets

## CORS Configuration

CORS is configured to allow requests from `http://localhost:5173` (React dev server). Update `SecurityConfig.java` if using a different frontend URL.

## Troubleshooting

### Backend Issues

1. **Database Connection Error**
   - Ensure MySQL is running
   - Verify database credentials in `application.yml`
   - Check if database `ticket_system` exists

2. **Migration Errors**
   - Drop and recreate database if migrations fail
   - Check Flyway logs in console

3. **Port Already in Use**
   - Change port in `application.yml`:
     ```yaml
     server:
       port: 8081
     ```

### Frontend Issues

1. **CORS Errors**
   - Ensure backend is running
   - Check CORS configuration in `SecurityConfig.java`

2. **API Connection Errors**
   - Verify backend URL in `AuthContext.jsx` and API calls
   - Check if backend is running on port 8080

3. **Build Errors**
   - Delete `node_modules` and run `npm install` again
   - Clear Vite cache: `rm -rf node_modules/.vite`

## Development Notes

- JWT secret key should be changed in production (currently in `application.yml`)
- Password hashing uses BCrypt with strength 10
- All timestamps are stored in UTC
- Hibernate `ddl-auto` is set to `validate` to prevent schema changes outside Flyway

## License

This project is for educational purposes.

