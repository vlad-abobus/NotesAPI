# PowerShell скрипт для тестування API в Windows
# Використання: .\test_api.ps1

$BaseUrl = "http://localhost:8000"

Write-Host "🚀 Тестування Notes API" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host ""

# 1. Реєстрація
Write-Host "1️⃣ Реєстрація користувача..." -ForegroundColor Cyan
$registerBody = @{
    username = "testuser"
    password = "test123456"
} | ConvertTo-Json

$registerResponse = Invoke-RestMethod -Uri "$BaseUrl/register" `
    -Method Post `
    -ContentType "application/json" `
    -Body $registerBody `
    -ErrorAction SilentlyContinue

Write-Host "Відповідь:" ($registerResponse | ConvertTo-Json)
Write-Host ""

# 2. Логін
Write-Host "2️⃣ Авторизація..." -ForegroundColor Cyan
$loginBody = @{
    username = "testuser"
    password = "test123456"
}

$loginResponse = Invoke-RestMethod -Uri "$BaseUrl/login" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body $loginBody

$token = $loginResponse.access_token
Write-Host "Токен отримано: $($token.Substring(0, 20))..." -ForegroundColor Yellow
Write-Host ""

# Заголовки з токеном
$headers = @{
    Authorization = "Bearer $token"
}

# 3. Створення нотаток
Write-Host "3️⃣ Створення нотаток..." -ForegroundColor Cyan
$note1Body = @{
    title = "Робоча нотатка"
    content = "Завдання на сьогодні"
    tags = @("робота", "важливо")
} | ConvertTo-Json

$note1 = Invoke-RestMethod -Uri "$BaseUrl/notes" `
    -Method Post `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $note1Body

Write-Host "Нотатка 1 створена: ID $($note1.id)"

$note2Body = @{
    title = "Особиста нотатка"
    content = "Купити продукти"
    tags = @("особисте")
} | ConvertTo-Json

$note2 = Invoke-RestMethod -Uri "$BaseUrl/notes" `
    -Method Post `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $note2Body

Write-Host "Нотатка 2 створена: ID $($note2.id)"
Write-Host ""

# 4. Отримання всіх нотаток
Write-Host "4️⃣ Отримання всіх нотаток..." -ForegroundColor Cyan
$notes = Invoke-RestMethod -Uri "$BaseUrl/notes" `
    -Method Get `
    -Headers $headers

Write-Host "Знайдено нотаток: $($notes.Count)"
foreach ($note in $notes) {
    Write-Host "  - $($note.title) (ID: $($note.id))"
}
Write-Host ""

# 5. Пошук
Write-Host "5️⃣ Пошук по заголовку 'Робоча'..." -ForegroundColor Cyan
$searchResults = Invoke-RestMethod -Uri "$BaseUrl/notes?search=Робоча" `
    -Method Get `
    -Headers $headers

Write-Host "Знайдено: $($searchResults.Count) нотаток"
Write-Host ""

# 6. Фільтр по тегу
Write-Host "6️⃣ Фільтр по тегу 'робота'..." -ForegroundColor Cyan
$filterResults = Invoke-RestMethod -Uri "$BaseUrl/notes?tag=робота" `
    -Method Get `
    -Headers $headers

Write-Host "Знайдено: $($filterResults.Count) нотаток з тегом 'робота'"
Write-Host ""

# 7. Отримання тегів
Write-Host "7️⃣ Отримання всіх тегів..." -ForegroundColor Cyan
$tags = Invoke-RestMethod -Uri "$BaseUrl/tags" `
    -Method Get `
    -Headers $headers

Write-Host "Теги користувача:"
foreach ($tag in $tags) {
    Write-Host "  - $($tag.name)"
}
Write-Host ""

# 8. Оновлення нотатки
Write-Host "8️⃣ Оновлення першої нотатки..." -ForegroundColor Cyan
$updateBody = @{
    title = "Оновлена робоча нотатка"
    tags = @("робота", "важливо", "термінове")
} | ConvertTo-Json

$updated = Invoke-RestMethod -Uri "$BaseUrl/notes/1" `
    -Method Put `
    -Headers $headers `
    -ContentType "application/json" `
    -Body $updateBody

Write-Host "Нотатка оновлена: $($updated.title)"
Write-Host ""

Write-Host "✅ Тестування завершено!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Відкрийте Swagger документацію: $BaseUrl/docs" -ForegroundColor Yellow

