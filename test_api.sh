#!/bin/bash

# Скрипт для швидкого тестування API
# Використання: ./test_api.sh

BASE_URL="http://localhost:8000"

echo "🚀 Тестування Notes API"
echo "======================="
echo ""

# 1. Реєстрація
echo "1️⃣ Реєстрація користувача..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123456"}')
echo "Відповідь: $REGISTER_RESPONSE"
echo ""

# 2. Логін
echo "2️⃣ Авторизація..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testuser&password=test123456")
echo "Відповідь: $LOGIN_RESPONSE"

# Витягуємо токен
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
echo "Токен: $TOKEN"
echo ""

# 3. Створення нотаток
echo "3️⃣ Створення нотаток..."
NOTE1=$(curl -s -X POST "$BASE_URL/notes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Робоча нотатка","content":"Завдання на сьогодні","tags":["робота","важливо"]}')
echo "Нотатка 1: $NOTE1"

NOTE2=$(curl -s -X POST "$BASE_URL/notes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Особиста нотатка","content":"Купити продукти","tags":["особисте"]}')
echo "Нотатка 2: $NOTE2"
echo ""

# 4. Отримання всіх нотаток
echo "4️⃣ Отримання всіх нотаток..."
NOTES=$(curl -s -X GET "$BASE_URL/notes" \
  -H "Authorization: Bearer $TOKEN")
echo "Нотатки: $NOTES"
echo ""

# 5. Пошук
echo "5️⃣ Пошук по заголовку 'Робоча'..."
SEARCH=$(curl -s -X GET "$BASE_URL/notes?search=Робоча" \
  -H "Authorization: Bearer $TOKEN")
echo "Результат: $SEARCH"
echo ""

# 6. Фільтр по тегу
echo "6️⃣ Фільтр по тегу 'робота'..."
FILTER=$(curl -s -X GET "$BASE_URL/notes?tag=робота" \
  -H "Authorization: Bearer $TOKEN")
echo "Результат: $FILTER"
echo ""

# 7. Отримання тегів
echo "7️⃣ Отримання всіх тегів..."
TAGS=$(curl -s -X GET "$BASE_URL/tags" \
  -H "Authorization: Bearer $TOKEN")
echo "Теги: $TAGS"
echo ""

# 8. Оновлення нотатки
echo "8️⃣ Оновлення першої нотатки..."
UPDATE=$(curl -s -X PUT "$BASE_URL/notes/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"Оновлена робоча нотатка","tags":["робота","важливо","термінове"]}')
echo "Результат: $UPDATE"
echo ""

echo "✅ Тестування завершено!"
echo ""
echo "🌐 Відкрийте Swagger документацію: $BASE_URL/docs"

