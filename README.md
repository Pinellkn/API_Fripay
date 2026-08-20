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

## 🌐 Mode hors-ligne (transferts acceptés sans connexion à l'agrégateur)

Le service Paiements **accepte et enregistre un transfert même si le connecteur du réseau est indisponible** (API native MTN, Moov, Celtiis ou agrégateur : réseau coupé, timeout, HTTP 5xx, API pas encore intégrée) :

> **Connecteur MTN MoMo (premier connecteur natif intégré)** : `app/Services/Connectors/MtnMomoConnector.php` implémente le produit **Disbursements** de l'API MTN MoMo. Tant que les clés `MTN_MOMO_*` ne sont pas renseignées dans `.env`, `isConfigured()` vaut `false` : les transferts vers MTN sont acceptés et conservés en file d'attente (comportement hors-ligne). Dès que les clés sont ajoutées, ils partent automatiquement. Clés : https://momodeveloper.mtn.com (créer un compte, s'abonner au produit Disbursements, puis créer un API User + API Key via `POST /v1_0/apiuser`).

- `POST /api/v1/transfers` → la transaction est créée localement avec le statut `pending` (réponse `202`), puis une entrée est mise en file d'attente locale (`pending_transfers`).
- Le transfert est exécuté **automatiquement dès que la connexion revient** :
  - de façon **opportuniste** : `GET /api/v1/transfers` et `GET /api/v1/transfers/{id}` déclenchent le traitement de la file ;
  - de façon **planifiée** : `php artisan transfers:process-pending` (enregistrée dans le scheduler, toutes les minutes — `php artisan schedule:run` en production).
- Retry avec **backoff exponentiel** (60 s → 2 min → 4 min … plafonné 24 h) jusqu'à 10 tentatives ; paramétrable via `config/fripay.php` (variables `FRIPAY_OUTBOX_*`).
- Un **rejet métier 4xx** reste un échec immédiat (`failed`) ; seul un webhook du réseau peut finaliser la transaction (`succeeded`/`failed`).

Migration nécessaire : `cd fripay-payments && php artisan migrate`


## ⚠️ Ce qui reste à faire (suite audit API QR / offline)

Statut au 20/08/2026 — audit du module QR/offline (`QrCryptoService`, `OfflineQrController`,
connecteurs réseaux) : la quasi-totalité des points de l'audit est corrigée et vérifiée
(connecteurs, double dépense, middleware d'idempotence, rate limiting, locking, HMAC, CORS,
validation téléphone, logs, purge, CDN). Il reste 2 chantiers réels à finaliser.

### 🔴 B1 — Tests PHPUnit manquants (priorité, ~4h estimées)

Seul `tests/OfflineQrMerchantBlockTest.php` existe (un seul cas : blocage des QR marchands
dans le flux P2P). Il manque :

- **`QrCryptoService`** : génération de paires de clés, signature/vérification valide,
  rejet d'une signature falsifiée, rejet d'un payload expiré/altéré.
- **`OfflineQrController`** : `generate` (succès + limites de montant/durée), `verify`,
  `receive` (y compris double réception simultanée), `redeem`, `transfer`, `revoke`,
  `status` (accès refusé à un tiers).
- **Connecteurs** (`MoovMoneyConnector`, `CeltiisConnector`, `MtnMomoConnector`) : au
  minimum avec `Http::fake()` pour couvrir succès / 409 idempotent / 4xx / 5xx retryable.

### 🟠 M3 — Décision d'architecture à valider avec le boss

La clé privée Ed25519 n'est jamais liée à un compte utilisateur côté serveur (design
assumé : sécurité vs traçabilité). À trancher avant de toucher au schéma.

### 🟡 Bonus repéré hors audit initial (à ne pas oublier avant prod)

`config/cors.php` a `allowed_origins => ['*']`, avec un commentaire qui recommande déjà
de le restreindre en prod.

### ✅ Déjà fait (pour info)

- Import inutilisé supprimé de `QrCryptoService.php`.
- Scope mort supprimé : `MerchantQrController::history()` utilise `OfflineQrCode::forMerchant($userId)`.
- Alpine.js pinné en `3.14.8`. Tailwind Play CDN : limite technique documentée (build
  compilée recommandée avant prod).
- Middleware `IdempotencyMiddleware` : alias réactivé (il existait déjà dans le package
  partagé `fripay-common`, l'audit s'était trompé en disant qu'il fallait le créer).

**Prochaine étape : le second doit se concentrer uniquement sur B1 (tests PHPUnit).**
Tout le reste des 17 autres points de l'audit est clos et vérifié dans le code.
