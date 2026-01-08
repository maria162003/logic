# Script para preparar y deployar Flutter Web a Netlify
Write-Host "🚀 Preparando proyecto Flutter para Netlify..." -ForegroundColor Cyan
Write-Host ""

# Paso 1: Limpiar build anterior
Write-Host "🧹 Limpiando build anterior..." -ForegroundColor Yellow
flutter clean

# Paso 2: Obtener dependencias
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# Paso 3: Compilar para web con configuraciones optimizadas
Write-Host "🔨 Compilando proyecto para web..." -ForegroundColor Yellow
flutter build web --release --base-href "/"

# Paso 4: Crear archivo _redirects en build/web
Write-Host "📄 Creando archivo de redirecciones..." -ForegroundColor Yellow
$redirectsContent = "/*    /index.html   200"
Set-Content -Path "build/web/_redirects" -Value $redirectsContent

# Paso 5: Verificar que los archivos necesarios existen
Write-Host ""
Write-Host "✅ Verificando archivos..." -ForegroundColor Green

$requiredFiles = @(
    "build/web/index.html",
    "build/web/main.dart.js",
    "build/web/flutter.js",
    "build/web/_redirects",
    "build/web/manifest.json"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (FALTA)" -ForegroundColor Red
        $allFilesExist = $false
    }
}

Write-Host ""
if ($allFilesExist) {
    Write-Host "🎉 ¡Proyecto compilado exitosamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 SIGUIENTE PASO - Sube a Netlify:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "OPCIÓN 1 - Netlify Drop (Más fácil):" -ForegroundColor Yellow
    Write-Host "  1. Ve a: https://app.netlify.com/drop" -ForegroundColor White
    Write-Host "  2. Arrastra la carpeta: build\web" -ForegroundColor White
    Write-Host "  3. ¡Listo! Tu sitio estará en línea" -ForegroundColor White
    Write-Host ""
    Write-Host "OPCIÓN 2 - Netlify CLI:" -ForegroundColor Yellow
    Write-Host "  Ejecuta: netlify deploy --prod --dir=build/web" -ForegroundColor White
    Write-Host ""
    Write-Host "OPCIÓN 3 - GitHub + Netlify (Automático):" -ForegroundColor Yellow
    Write-Host "  1. Sube tu código a GitHub" -ForegroundColor White
    Write-Host "  2. Conecta el repo en Netlify" -ForegroundColor White
    Write-Host "  3. Netlify usará el archivo netlify.toml automáticamente" -ForegroundColor White
    Write-Host ""
    Write-Host "📁 Carpeta a subir: $(Get-Location)\build\web" -ForegroundColor Magenta
} else {
    Write-Host "❌ Error: Faltan archivos necesarios" -ForegroundColor Red
    Write-Host "   Revisa los errores de compilación arriba" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 TIP: Si ves un 404 después de subir:" -ForegroundColor Cyan
Write-Host "   - Verifica que el archivo _redirects esté en build/web" -ForegroundColor White
Write-Host "   - En Netlify, ve a Site settings > Build & deploy > Post processing" -ForegroundColor White
Write-Host "   - Activa 'Asset optimization' si está desactivado" -ForegroundColor White
