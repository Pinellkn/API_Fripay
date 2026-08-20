# 🚀 FriPay - API de Transferts Inter-Opérateurs (Bénin)

## Architecture Microservices

```
C:\laragon\www\API_Fripay\
├── fripay-users/        # Service Utilisateurs (port 8000)
├── fripay-payments/     # Service Paiements (port 8001)
├── fripay-admin/        # Service Back-Office (port 8002)
├── fripay-gateway/      # API Gateway (port 8080)
├── fripay_database_dump.sql  # Dump PostgreSQL
├── Reference_Technique_API_Donnees.md
├── start-fripay.bat     # Script de démarrage (Windows)
└── start-fripay.ps1     # Script de démarrage (PowerShell)
```

## Prérequis

- PHP 8.3+ (inclus dans Laragon)
- PostgreSQL 17.2+ (inclus dans Laragon)
- Composer
- Extensions PHP : `pdo_pgsql`, `pgsql`, `openssl`, `curl`

## Installation

```bash
# 1. Installer les dépendances de chaque service
cd C:\laragon\www\API_Fripay\fripay-users
composer install

cd ..\fripay-payments
composer install

cd ..\fripay-admin
composer install

# 2. Restaurer la base de données
psql -U postgres -c "CREATE DATABASE fripay;"
psql -U postgres -d fripay < fripay_database_dump.sql

# 3. Configurer les .env (clés déjà générées)
```

## Démarrage

### Option 1 : Script automatique
```bash
start-fripay.bat
```

### Option 2 : Manuel
```bash
# Terminal 1 - Users
php -S localhost:8000 -t fripay-users/public

# Terminal 2 - Payments
php -S localhost:8001 -t fripay-payments/public

# Terminal 3 - Admin
php -S localhost:8002 -t fripay-admin/public

# Terminal 4 - Gateway
php -S localhost:8080 -t fripay-gateway/public
```

## Endpoints API

### Service Utilisateurs (port 8000)
| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/v1/auth/register` | Inscription |
| POST | `/api/v1/auth/verify-otp` | Vérification OTP |
| POST | `/api/v1/auth/login` | Connexion par PIN |
| GET | `/api/v1/users/me` | Profil utilisateur |
| POST | `/api/v1/users/me/pin` | Définir/modifier PIN |
| GET | `/api/v1/users/me/accounts` | Comptes liés |
| GET | `/api/v1/users/me/contacts` | Contacts favoris |
| GET | `/api/v1/notifications` | Notifications |

### Service Paiements (port 8001)
| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/v1/transfers/quote` | Simulation de frais |
| POST | `/api/v1/transfers` | Initier un transfert |
| GET | `/api/v1/transfers` | Historique |
| POST | `/api/v1/webhooks/aggregator/{provider}` | Webhook agrégateur |

### Service Admin (port 8002)
| Méthode | Route | Permission |
|---------|-------|------------|
| POST | `/api/v1/admin/auth/login` | - |
| GET | `/api/v1/admin/users` | users.read |
| PUT | `/api/v1/admin/users/{id}/status` | users.block |
| GET | `/api/v1/admin/transactions` | transactions.read |
| GET | `/api/v1/admin/corridors` | corridors.read |
| GET | `/api/v1/admin/dashboard/kpis` | dashboard.read |
| POST | `/api/v1/admin/staff` | staff.write |

## Comptes par défaut

**Admin back-office :**
- Email : `admin@fripay.bj`
- Mot de passe : `admin1234`

## Base de données

Base PostgreSQL partagée `fripay` avec les tables :
- `operators`, `phone_prefixes` — Référentiel opérateurs
- `users`, `otp_codes`, `auth_sessions` — Authentification
- `linked_accounts`, `contacts` — Comptes et contacts
- `corridors`, `transactions`, `transaction_status_history` — Transferts
- `notifications`, `audit_logs`, `webhook_events` — Traçabilité
- `roles`, `permissions`, `role_permissions`, `staff_users` — RBAC
