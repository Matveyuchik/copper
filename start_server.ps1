# Скрипт для запуска сервера Copper Messenger
Write-Host "🚀 Запуск сервера Copper Messenger..." -ForegroundColor Green

# Переходим в папку сервера
Set-Location -Path "server"

# Проверяем, что Dart установлен
try {
    dart --version | Out-Null
    Write-Host "✅ Dart найден" -ForegroundColor Green
} catch {
    Write-Host "❌ Dart не найден. Установите Dart SDK" -ForegroundColor Red
    exit 1
}

# Устанавливаем зависимости
Write-Host "📦 Установка зависимостей..." -ForegroundColor Yellow
dart pub get

# Запускаем сервер
Write-Host "🌐 Запуск сервера..." -ForegroundColor Yellow
Write-Host "HTTP API: http://localhost:8080" -ForegroundColor Cyan
Write-Host "WebSocket: ws://localhost:8081" -ForegroundColor Cyan
Write-Host "Для остановки нажмите Ctrl+C" -ForegroundColor Gray

dart run bin/server.dart
