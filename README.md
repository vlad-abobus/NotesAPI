# 📝 Notes API

REST API для управління нотатками користувача з підтримкою авторизації, тегів та пошуку.

## 🔧 Технології

- **Python 3.11+**
- **FastAPI** - сучасний, швидкий веб-фреймворк
- **SQLAlchemy** - ORM для роботи з базою даних
- **SQLite/PostgreSQL** - база даних
- **JWT** - авторизація через токени
- **Pydantic** - валідація даних
- **Uvicorn** - ASGI сервер

## 📋 Функціонал

### Основні можливості:
- ✅ Реєстрація та авторизація користувачів
- ✅ JWT токени для безпеки
- ✅ CRUD операції для нотаток
- ✅ Теги для організації нотаток
- ✅ Пошук по заголовку
- ✅ Фільтрація по тегам
- ✅ Логування запитів та помилок
- ✅ Автоматична документація (Swagger/ReDoc)
- ✅ Docker підтримка

## 🚀 Швидкий старт

### Локальний запуск

1. **Клонуйте репозиторій:**
```bash
git clone <your-repo-url>
cd work
```

2. **Створіть віртуальне середовище:**
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

3. **Встановіть залежності:**
```bash
pip install -r requirements.txt
```

4. **Налаштуйте змінні оточення:**
```bash
# Скопіюйте приклад
copy env.example .env  # Windows
cp env.example .env    # Linux/Mac

# Відредагуйте .env файл, встановіть SECRET_KEY
```

5. **Запустіть сервер:**
```bash
python main.py
```

API буде доступне за адресою: `http://localhost:8000`

### Docker запуск

**Варіант 1: З SQLite (простіше)**
```bash
docker-compose -f docker-compose.sqlite.yml up -d
```

**Варіант 2: З PostgreSQL (для продакшн)**
```bash
docker-compose up -d
```

## 📚 Документація API

Після запуску сервера документація доступна за адресами:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

## 🔐 API Endpoints

### Authentication

#### Реєстрація користувача
```http
POST /register
Content-Type: application/json

{
  "username": "johndoe",
  "password": "securepassword123"
}
```

**Відповідь:**
```json
{
  "id": 1,
  "username": "johndoe",
  "created_at": "2024-01-01T12:00:00"
}
```

#### Авторизація (отримання токену)
```http
POST /login
Content-Type: application/x-www-form-urlencoded

username=johndoe&password=securepassword123
```

**Відповідь:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Notes

> **Примітка:** Всі ендпоінти нижче вимагають авторизації. Додайте заголовок:  
> `Authorization: Bearer <your_token>`

#### Отримати всі нотатки
```http
GET /notes
Authorization: Bearer <token>
```

**Опціональні параметри:**
- `search` - пошук по заголовку
- `tag` - фільтр по тегу

**Приклади:**
```http
GET /notes?search=важливо
GET /notes?tag=робота
GET /notes?search=зустріч&tag=особисте
```

**Відповідь:**
```json
[
  {
    "id": 1,
    "title": "Моя перша нотатка",
    "content": "Це важливий текст...",
    "created_at": "2024-01-01T12:00:00",
    "updated_at": "2024-01-01T12:00:00",
    "user_id": 1,
    "tags": [
      {"id": 1, "name": "робота"},
      {"id": 2, "name": "важливо"}
    ]
  }
]
```

#### Створити нотатку
```http
POST /notes
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Купити продукти",
  "content": "Молоко, хліб, яйця",
  "tags": ["особисте", "покупки"]
}
```

#### Отримати конкретну нотатку
```http
GET /notes/{id}
Authorization: Bearer <token>
```

#### Оновити нотатку
```http
PUT /notes/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "Оновлений заголовок",
  "content": "Оновлений зміст",
  "tags": ["новий-тег"]
}
```

> Всі поля опціональні. Можна оновити тільки title, тільки content, або тільки tags.

#### Видалити нотатку
```http
DELETE /notes/{id}
Authorization: Bearer <token>
```

#### Отримати всі теги
```http
GET /tags
Authorization: Bearer <token>
```

**Відповідь:**
```json
[
  {"id": 1, "name": "робота"},
  {"id": 2, "name": "особисте"},
  {"id": 3, "name": "важливо"}
]
```

## 🧪 Приклади curl

### 1. Реєстрація
```bash
curl -X POST http://localhost:8000/register \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"test123456\"}"
```

### 2. Логін
```bash
curl -X POST http://localhost:8000/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testuser&password=test123456"
```

Збережіть токен з відповіді:
```bash
TOKEN="your_access_token_here"
```

### 3. Створити нотатку
```bash
curl -X POST http://localhost:8000/notes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Тестова нотатка\",\"content\":\"Це тестовий текст\",\"tags\":[\"тест\",\"приклад\"]}"
```

### 4. Отримати всі нотатки
```bash
curl -X GET http://localhost:8000/notes \
  -H "Authorization: Bearer $TOKEN"
```

### 5. Пошук нотаток
```bash
curl -X GET "http://localhost:8000/notes?search=Тестова" \
  -H "Authorization: Bearer $TOKEN"
```

### 6. Фільтрація по тегу
```bash
curl -X GET "http://localhost:8000/notes?tag=тест" \
  -H "Authorization: Bearer $TOKEN"
```

### 7. Оновити нотатку
```bash
curl -X PUT http://localhost:8000/notes/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"Оновлена нотатка\",\"content\":\"Новий текст\"}"
```

### 8. Видалити нотатку
```bash
curl -X DELETE http://localhost:8000/notes/1 \
  -H "Authorization: Bearer $TOKEN"
```

## 📮 Приклади Postman

### Налаштування

1. Створіть нову колекцію "Notes API"
2. Додайте змінну `base_url` = `http://localhost:8000`
3. Додайте змінну `token` (буде автоматично заповнена після логіну)

### Запити

#### 1. Register
- **Method:** POST
- **URL:** `{{base_url}}/register`
- **Body (JSON):**
```json
{
  "username": "testuser",
  "password": "test123456"
}
```

#### 2. Login
- **Method:** POST
- **URL:** `{{base_url}}/login`
- **Body (x-www-form-urlencoded):**
  - `username`: testuser
  - `password`: test123456
- **Tests (додайте для автоматичного збереження токену):**
```javascript
var jsonData = pm.response.json();
pm.collectionVariables.set("token", jsonData.access_token);
```

#### 3. Create Note
- **Method:** POST
- **URL:** `{{base_url}}/notes`
- **Headers:**
  - `Authorization`: `Bearer {{token}}`
- **Body (JSON):**
```json
{
  "title": "Моя нотатка",
  "content": "Це важливий текст",
  "tags": ["робота", "важливо"]
}
```

#### 4. Get All Notes
- **Method:** GET
- **URL:** `{{base_url}}/notes`
- **Headers:**
  - `Authorization`: `Bearer {{token}}`

#### 5. Search Notes
- **Method:** GET
- **URL:** `{{base_url}}/notes?search=важливо`
- **Headers:**
  - `Authorization`: `Bearer {{token}}`

#### 6. Update Note
- **Method:** PUT
- **URL:** `{{base_url}}/notes/1`
- **Headers:**
  - `Authorization`: `Bearer {{token}}`
- **Body (JSON):**
```json
{
  "title": "Оновлена нотатка",
  "tags": ["важливо", "термінове"]
}
```

#### 7. Delete Note
- **Method:** DELETE
- **URL:** `{{base_url}}/notes/1`
- **Headers:**
  - `Authorization`: `Bearer {{token}}`

## 📁 Структура проекту

```
work/
├── app/
│   ├── __init__.py
│   ├── main.py              # Головний файл FastAPI
│   ├── config.py            # Налаштування
│   ├── database.py          # Підключення до БД
│   ├── models.py            # SQLAlchemy моделі
│   ├── schemas.py           # Pydantic схеми
│   ├── auth.py              # JWT авторизація
│   ├── logger.py            # Логування
│   └── routers/
│       ├── __init__.py
│       ├── users.py         # Ендпоінти користувачів
│       └── notes.py         # Ендпоінти нотаток
├── main.py                  # Точка входу
├── requirements.txt         # Залежності
├── Dockerfile              # Docker образ
├── docker-compose.yml      # Docker Compose (PostgreSQL)
├── docker-compose.sqlite.yml # Docker Compose (SQLite)
├── env.example             # Приклад .env
├── .gitignore
└── README.md
```

## 🔒 Безпека

- Паролі хешуються за допомогою bcrypt
- JWT токени для авторизації
- Змініть `SECRET_KEY` в `.env` на випадковий рядок для продакшн
- Токени дійсні 30 хвилин (налаштовується)

### Генерація SECRET_KEY:
```python
import secrets
print(secrets.token_urlsafe(32))
```

## 📊 База даних

### SQLite (за замовчуванням)
- Файл БД: `notes.db`
- Не потрібна додаткова установка
- Ідеально для розробки та тестування

### PostgreSQL (опціонально)
Змініть `DATABASE_URL` в `.env`:
```
DATABASE_URL=postgresql://user:password@localhost/notesdb
```

## 🐛 Логування

Логи зберігаються в:
- `app.log` - файл з усіма логами
- stdout - вивід в консоль

Логуються:
- Всі HTTP запити
- Час обробки запитів
- Помилки з трейсами

## 🧪 Тестування

Для тестування API використовуйте:
- Swagger UI: http://localhost:8000/docs (вбудований інтерфейс)
- Postman (імпортуйте приклади вище)
- curl (команди в розділі вище)

## 🚢 Деплой

### Docker
```bash
# Білд образу
docker build -t notes-api .

# Запуск контейнера
docker run -p 8000:8000 notes-api
```

### Docker Compose
```bash
# Запуск
docker-compose up -d

# Перегляд логів
docker-compose logs -f

# Зупинка
docker-compose down
```

## 🤝 Контрибьюція

1. Fork проєкту
2. Створіть feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit зміни (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Відкрийте Pull Request
---

**Зроблено з ❤️ на FastAPI**

