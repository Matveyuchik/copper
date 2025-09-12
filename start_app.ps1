# Скрипт для запуска Flutter приложения Copper Messenger
Write-Host "📱 Запуск Flutter приложения Copper Messenger..." -ForegroundColor Green

# Проверяем, что Flutter установлен
$flutterPath = "C:\flutter\bin\flutter.bat"
if (Test-Path $flutterPath) {
    Write-Host "✅ Flutter найден" -ForegroundColor Green
} else {
    Write-Host "❌ Flutter не найден по пути $flutterPath" -ForegroundColor Red
    Write-Host "Установите Flutter или обновите путь в скрипте" -ForegroundColor Yellow
    exit 1
}

# Устанавливаем зависимости
Write-Host "📦 Установка зависимостей..." -ForegroundColor Yellow
& $flutterPath pub get

# Проверяем устройство
Write-Host "🔍 Поиск устройств..." -ForegroundColor Yellow
& $flutterPath devices

# Запускаем приложение
Write-Host "🚀 Запуск приложения..." -ForegroundColor Yellow
& $flutterPath run
