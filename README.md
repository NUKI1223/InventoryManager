# Inventory Management System

Система управления складом с возможностями учёта товаров, категорий, транзакций, уведомлений и отчётов.

## 🚀 Технологический стек

### Backend
- **Java 17** + **Spring Boot 3.5.6**
- **PostgreSQL 16** - база данных
- **Spring Data JPA** / Hibernate - ORM
- **Spring Security** + **JWT** - аутентификация
- **Swagger/OpenAPI** - документация API
- **SLF4J** - логирование
- **Apache POI** - генерация Excel отчётов

### Frontend
- **Flutter** - кроссплатформенный UI
- **Riverpod** - state management
- **Dio** - HTTP клиент
- **Go Router** - навигация

### DevOps
- **Docker** + **Docker Compose**
- **Maven** - сборка backend
- **Git** - версионирование

---

## 📦 Быстрый старт с Docker

### Предварительные требования
- Docker 20.10+
- Docker Compose 2.0+

### Запуск всего стека

```bash
# Клонировать репозиторий
git clone <repo-url>
cd InventoryManagement

# Запустить с помощью Docker Compose
docker-compose up -d

# Проверить статус
docker-compose ps

# Просмотр логов
docker-compose logs -f backend
```

Приложение будет доступно:
- **Backend API**: http://localhost:9000
- **Swagger UI**: http://localhost:9000/swagger-ui.html
- **API Docs**: http://localhost:9000/api-docs
- **PostgreSQL**: localhost:5432

### Остановка

```bash
docker-compose down

# С удалением данных
docker-compose down -v
```

---

## 🛠️ Локальная разработка

### Backend

```bash
cd backend/InventoryManagementApi

# Установка зависимостей и сборка
./mvnw clean install

# Запуск
./mvnw spring-boot:run

# Или через JAR
java -jar target/InventoryManagementApi-0.0.1-SNAPSHOT.jar
```

**Требования:**
- Java 17+
- PostgreSQL 16
- Maven 3.9+

**Конфигурация** (`application.properties`):
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/inventorydb
spring.datasource.username=postgres
spring.datasource.password=admin
server.port=9000
```

### Frontend

```bash
cd frontend

# Установка зависимостей
flutter pub get

# Запуск на эмуляторе/устройстве
flutter run

# Сборка APK
flutter build apk
```

---

## 📚 API Документация

### Аутентификация

Все защищённые endpoints требуют JWT токен в заголовке:
```
Authorization: Bearer <token>
```

#### POST `/api/auth/login`
Вход в систему

**Request:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "userId": 1,
  "username": "admin",
  "role": "ADMIN"
}
```

#### POST `/api/auth/register`
Регистрация нового пользователя

**Request:**
```json
{
  "username": "newuser",
  "password": "password123",
  "fullName": "Иван Иванов",
  "role": "USER"
}
```

---

### Товары (Products)

#### GET `/api/products`
Получить список товаров (пагинация)

**Parameters:**
- `q` (optional) - поиск по названию/SKU
- `categoryId` (optional) - фильтр по категории
- `page` - номер страницы (default: 0)
- `size` - размер страницы (default: 20)

**Response:**
```json
{
  "content": [
    {
      "id": 1,
      "sku": "LAPTOP-001",
      "name": "Ноутбук HP",
      "description": "15.6 inch, Intel Core i5",
      "price": 45000.00,
      "currentStock": 15,
      "category": {
        "id": 1,
        "name": "Electronics"
      }
    }
  ],
  "totalElements": 100,
  "totalPages": 5,
  "size": 20,
  "number": 0
}
```

#### POST `/api/products`
Создать товар (требуется аутентификация)

**Request:**
```json
{
  "sku": "DESK-001",
  "name": "Офисный стол",
  "description": "120x60 см",
  "price": 8500.00,
  "currentStock": 10,
  "categoryId": 2
}
```

#### PUT `/api/products/{id}`
Обновить товар

#### DELETE `/api/products/{id}`
Удалить товар (только ADMIN)

---

### Категории (Categories)

#### GET `/api/categories`
Получить все категории

#### POST `/api/categories` (ADMIN)
Создать категорию

**Request:**
```json
{
  "name": "Electronics",
  "description": "Electronic devices"
}
```

---

### Управление запасами (Stock)

#### POST `/api/stock/{productId}/adjust`
Корректировка запасов

**Request:**
```json
{
  "changeAmount": 10,
  "type": "INCOMING",
  "reference": "PO-12345",
  "note": "Поступление от поставщика"
}
```

**Types:** `INCOMING`, `SALE`, `ADJUSTMENT`, `DAMAGE`, `SALE_RETURN`

#### GET `/api/stock/{productId}/transactions`
История транзакций товара

---

### Bulk операции

#### POST `/api/bulk/delete` (ADMIN)
Массовое удаление

**Request:**
```json
[1, 2, 3, 4, 5]
```

#### POST `/api/bulk/update-price` (ADMIN)
Массовое обновление цен

**Request:**
```json
{
  "productIds": [1, 2, 3],
  "newPrice": 1500.00
}
```

#### POST `/api/bulk/adjust-stock` (ADMIN)
Массовая корректировка запасов

---

### Уведомления (Notifications)

#### GET `/api/notifications`
Получить уведомления пользователя

#### GET `/api/notifications/unread-count`
Количество непрочитанных

#### PUT `/api/notifications/{id}/read`
Отметить как прочитанное

#### DELETE `/api/notifications/{id}`
Удалить уведомление

---

### Отчёты (Reports)

#### GET `/api/reports/products` (ADMIN)
Скачать Excel отчёт по товарам

#### GET `/api/reports/transactions` (ADMIN)
Скачать Excel отчёт по транзакциям

#### GET `/api/reports/low-stock?threshold=10` (ADMIN)
Отчёт по товарам с низким запасом

---

### Профиль (Profile)

#### GET `/api/profile`
Получить профиль текущего пользователя

#### PUT `/api/profile`
Обновить профиль

**Request:**
```json
{
  "username": "newusername",
  "fullName": "Новое Имя"
}
```

#### PUT `/api/profile/password`
Сменить пароль

**Request:**
```json
{
  "oldPassword": "current123",
  "newPassword": "new456"
}
```

---

### Dashboard

#### GET `/api/products/low-stock?threshold=5`
Товары с низким запасом

#### GET `/api/products/zero-stock`
Товары с нулевым запасом

#### GET `/api/stats/recent-transactions?limit=10`
Последние транзакции

#### GET `/api/stats/by-category`
Статистика по категориям

---

## 🗄️ База данных

### Схема

**Основные таблицы:**
- `users` - пользователи
- `products` - товары
- `categories` - категории
- `stock_transactions` - складские транзакции
- `notifications` - уведомления
- `product_changes` - история изменений товаров

### Миграции

Используется Hibernate DDL-auto для автоматического обновления схемы:
```properties
spring.jpa.hibernate.ddl-auto=update
```

### Тестовые данные

При первом запуске `DataSeeder` создаёт:
- 2 пользователя: `admin/admin123` (ADMIN), `user/user123` (USER)
- 5 категорий: Electronics, Furniture, Stationery, Tools, Food
- 15 тестовых товаров

---

## 🔒 Безопасность

- **JWT токены** с истечением через 1 час
- **BCrypt** хеширование паролей
- **Role-based access control** (ADMIN, USER)
- **CORS** настроен для фронтенда
- **SQL Injection protection** через JPA Prepared Statements

---

## 📊 Мониторинг и логирование

### Логирование

Конфигурация в `application.properties`:
```properties
logging.level.org.ngcvfb.inventorymanagementapi=DEBUG
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
```

Логи включают:
- Аутентификацию пользователей
- CRUD операции
- Складские транзакции
- Создание уведомлений
- Ошибки и исключения

---

## 🧪 Тестирование

```bash
# Запуск тестов
./mvnw test

# С покрытием кода
./mvnw test jacoco:report
```

---

## 📝 Git

### Ветки

- `main` - production-ready код
- `dev` - разработка

### Коммиты

Все реализованные дни:
- День 1: Категории, DataSeeder, Git
- День 2: Profile, Dashboard, SLF4J Logging
- День 3: Уведомления, Адаптивность
- День 4: Bulk операции, Отчёты

---

## 🐛 Известные проблемы

*Список известных багов и ограничений*

---

## 📄 Лицензия

MIT License

---

## 👥 Авторы

Development Team

---

## 📞 Поддержка

Email: support@inventory.com

---

**Последнее обновление:** 2026-02-12
