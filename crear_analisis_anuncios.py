import xlsxwriter
from datetime import datetime

# Crear archivo Excel
workbook = xlsxwriter.Workbook('Analisis_Monetizacion_Anuncios_Logic.xlsx')

# ============= FORMATOS =============
# Título principal
title_format = workbook.add_format({
    'bold': True,
    'font_size': 16,
    'font_color': '#1a237e',
    'align': 'center',
    'valign': 'vcenter',
    'bg_color': '#e3f2fd',
    'border': 2
})

# Encabezados
header_format = workbook.add_format({
    'bold': True,
    'font_size': 11,
    'font_color': 'white',
    'align': 'center',
    'valign': 'vcenter',
    'bg_color': '#1976d2',
    'border': 1
})

# Subencabezados
subheader_format = workbook.add_format({
    'bold': True,
    'font_size': 10,
    'font_color': 'white',
    'align': 'center',
    'valign': 'vcenter',
    'bg_color': '#42a5f5',
    'border': 1
})

# Datos normales
data_format = workbook.add_format({
    'font_size': 10,
    'align': 'left',
    'valign': 'vcenter',
    'border': 1
})

# Números con formato moneda
currency_format = workbook.add_format({
    'font_size': 10,
    'align': 'right',
    'valign': 'vcenter',
    'border': 1,
    'num_format': '$#,##0.00'
})

# Porcentajes
percent_format = workbook.add_format({
    'font_size': 10,
    'align': 'center',
    'valign': 'vcenter',
    'border': 1,
    'num_format': '0%'
})

# Destacado verde (alta rentabilidad)
high_format = workbook.add_format({
    'font_size': 10,
    'bold': True,
    'align': 'center',
    'valign': 'vcenter',
    'bg_color': '#c8e6c9',
    'font_color': '#1b5e20',
    'border': 1
})

# Destacado amarillo (media rentabilidad)
medium_format = workbook.add_format({
    'font_size': 10,
    'align': 'center',
    'valign': 'vcenter',
    'bg_color': '#fff9c4',
    'font_color': '#f57f17',
    'border': 1
})

# Destacado rojo (baja rentabilidad)
low_format = workbook.add_format({
    'font_size': 10,
    'align': 'center',
    'valign': 'vcenter',
    'bg_color': '#ffcdd2',
    'font_color': '#b71c1c',
    'border': 1
})

# ============= HOJA 1: RESUMEN EJECUTIVO =============
ws_resumen = workbook.add_worksheet('Resumen Ejecutivo')
ws_resumen.set_column('A:A', 30)
ws_resumen.set_column('B:B', 20)
ws_resumen.set_column('C:C', 25)
ws_resumen.set_column('D:D', 20)

# Título
ws_resumen.merge_range('A1:D1', '📊 ANÁLISIS DE MONETIZACIÓN CON ANUNCIOS - APP LOGIC', title_format)
ws_resumen.merge_range('A2:D2', f'Fecha de análisis: {datetime.now().strftime("%d/%m/%Y")}', subheader_format)

# Información clave
ws_resumen.write('A4', 'MÉTRICAS CLAVE', header_format)
ws_resumen.write('B4', 'VALOR', header_format)
ws_resumen.write('C4', 'RANGO', header_format)
ws_resumen.write('D4', 'PROYECCIÓN', header_format)

metricas = [
    ['CPM Promedio', '$2.50', '$0.50 - $10.00', 'Estable'],
    ['CTR Promedio', '2.5%', '1.5% - 4.0%', 'Creciente'],
    ['Usuarios Diarios (Inicial)', '100', '50 - 200', '+20% mensual'],
    ['Ingresos Mensuales (Inicial)', '$15 - $45', '$10 - $100', 'Variable'],
    ['Fill Rate Esperado', '85%', '75% - 95%', 'Optimizable'],
]

for row, metrica in enumerate(metricas, start=5):
    ws_resumen.write(row, 0, metrica[0], data_format)
    ws_resumen.write(row, 1, metrica[1], data_format)
    ws_resumen.write(row, 2, metrica[2], data_format)
    ws_resumen.write(row, 3, metrica[3], data_format)

# Recomendaciones
ws_resumen.write('A12', '⭐ RECOMENDACIONES PRINCIPALES', header_format)
ws_resumen.merge_range('B12:D12', '', header_format)

recomendaciones = [
    ['1. Comenzar con banners no invasivos (inferior y superior)'],
    ['2. Implementar anuncios nativos después del primer mes'],
    ['3. Intersticiales solo después de acciones completadas'],
    ['4. Monitorear métricas semanalmente y optimizar'],
    ['5. No exceder 3 anuncios visibles simultáneamente'],
    ['6. Considerar Google AdMob + Facebook Audience Network'],
]

for row, rec in enumerate(recomendaciones, start=13):
    ws_resumen.merge_range(row, 0, row, 3, rec[0], data_format)

# ============= HOJA 2: UBICACIONES DE ANUNCIOS =============
ws_ubicaciones = workbook.add_worksheet('Ubicaciones de Anuncios')
ws_ubicaciones.set_column('A:A', 25)
ws_ubicaciones.set_column('B:B', 40)
ws_ubicaciones.set_column('C:C', 15)
ws_ubicaciones.set_column('D:D', 15)
ws_ubicaciones.set_column('E:E', 20)
ws_ubicaciones.set_column('F:F', 15)

# Título
ws_ubicaciones.merge_range('A1:F1', '📍 ANÁLISIS DE UBICACIONES DE ANUNCIOS', title_format)

# Encabezados
headers = ['Ubicación', 'Descripción', 'Visibilidad', 'CPM Est.', 'Nivel Invasión', 'Recomendación']
for col, header in enumerate(headers):
    ws_ubicaciones.write(2, col, header, header_format)

# Datos de ubicaciones
ubicaciones = [
    ['Banner Superior', 'Debajo del header con logo', 'Alta', '$2.00', 'Media', 'Implementar'],
    ['Banner Inferior (Sticky)', 'Fijo en parte inferior', 'Muy Alta', '$1.50', 'Baja', 'Implementar Primero'],
    ['Banner Entre Secciones', 'Entre "Chat IA" y "Formularios"', 'Alta', '$2.50', 'Baja', 'Implementar'],
    ['Anuncio Nativo en Lista', 'Cada 3-4 elementos formularios', 'Media', '$3.00', 'Muy Baja', 'Fase 2'],
    ['Intersticial al Navegar', 'Al abrir chat IA o formularios', 'Muy Alta', '$8.00', 'Alta', 'Fase 3 (Limitado)'],
    ['App Open Ad', 'Al abrir la aplicación', 'Alta', '$5.00', 'Alta', 'Opcional'],
    ['Rewarded Video', 'Por beneficios premium', 'Alta', '$15.00', 'Ninguna', 'Premium Features'],
]

for row, ubicacion in enumerate(ubicaciones, start=3):
    ws_ubicaciones.write(row, 0, ubicacion[0], data_format)
    ws_ubicaciones.write(row, 1, ubicacion[1], data_format)
    ws_ubicaciones.write(row, 2, ubicacion[2], data_format)
    ws_ubicaciones.write(row, 3, ubicacion[3], currency_format)
    
    # Color según nivel de invasión
    invasion = ubicacion[4]
    if invasion == 'Baja' or invasion == 'Muy Baja':
        ws_ubicaciones.write(row, 4, invasion, high_format)
    elif invasion == 'Media':
        ws_ubicaciones.write(row, 4, invasion, medium_format)
    else:
        ws_ubicaciones.write(row, 4, invasion, low_format)
    
    ws_ubicaciones.write(row, 5, ubicacion[5], data_format)

# ============= HOJA 3: TIPOS DE ANUNCIOS =============
ws_tipos = workbook.add_worksheet('Tipos de Anuncios')
ws_tipos.set_column('A:A', 20)
ws_tipos.set_column('B:B', 15)
ws_tipos.set_column('C:C', 15)
ws_tipos.set_column('D:D', 12)
ws_tipos.set_column('E:E', 40)
ws_tipos.set_column('F:F', 15)

# Título
ws_tipos.merge_range('A1:F1', '🎯 COMPARATIVA DE TIPOS DE ANUNCIOS', title_format)

# Encabezados
headers = ['Tipo de Anuncio', 'CPM Mín.', 'CPM Máx.', 'CTR', 'Ventajas', 'Desventajas']
for col, header in enumerate(headers):
    ws_tipos.write(2, col, header, header_format)

# Datos
tipos_anuncios = [
    ['Banner Standard', '$0.50', '$3.00', '1.5%', 'Fácil implementación, no invasivo', 'CPM bajo'],
    ['Interstitial', '$4.00', '$10.00', '3.5%', 'eCPM muy alto, pantalla completa', 'Puede molestar usuarios'],
    ['Native Ads', '$2.00', '$5.00', '4.0%', 'Integrado, alto CTR, buena UX', 'Requiere diseño custom'],
    ['Rewarded Video', '$10.00', '$20.00', '8.0%', 'eCPM altísimo, usuarios contentos', 'Requiere incentivo'],
    ['App Open Ad', '$3.00', '$8.00', '2.0%', 'Primera impresión, buen CPM', 'Solo una vez al abrir'],
    ['Medium Rectangle', '$1.50', '$4.00', '2.5%', 'Buen tamaño, visible', 'Ocupa espacio'],
]

for row, tipo in enumerate(tipos_anuncios, start=3):
    ws_tipos.write(row, 0, tipo[0], data_format)
    ws_tipos.write(row, 1, tipo[1], currency_format)
    ws_tipos.write(row, 2, tipo[2], currency_format)
    
    # CTR con formato porcentaje
    ctr_value = float(tipo[3].replace('%', '')) / 100
    ws_tipos.write(row, 3, ctr_value, percent_format)
    
    ws_tipos.write(row, 4, tipo[4], data_format)
    ws_tipos.write(row, 5, tipo[5], data_format)

# ============= HOJA 4: PROYECCIONES DE INGRESOS =============
ws_proyeccion = workbook.add_worksheet('Proyecciones de Ingresos')
ws_proyeccion.set_column('A:A', 20)
ws_proyeccion.set_column('B:G', 15)

# Título
ws_proyeccion.merge_range('A1:G1', '💰 PROYECCIONES DE INGRESOS MENSUALES', title_format)

# Encabezados
headers = ['Usuarios Diarios', 'Impresiones/Día', 'CPM Promedio', 'Ingresos Diarios', 'Ingresos Mensuales', 'Escenario Bajo', 'Escenario Alto']
for col, header in enumerate(headers):
    ws_proyeccion.write(2, col, header, header_format)

# Datos de proyección
proyecciones = [
    [100, 300, 2.50, 0.75, 22.50, 15.00, 45.00],
    [250, 750, 2.50, 1.88, 56.25, 37.50, 112.50],
    [500, 1500, 2.50, 3.75, 112.50, 75.00, 225.00],
    [1000, 3000, 2.50, 7.50, 225.00, 150.00, 450.00],
    [2500, 7500, 2.50, 18.75, 562.50, 375.00, 1125.00],
    [5000, 15000, 2.50, 37.50, 1125.00, 750.00, 2250.00],
    [10000, 30000, 2.50, 75.00, 2250.00, 1500.00, 4500.00],
]

for row, proyeccion in enumerate(proyecciones, start=3):
    ws_proyeccion.write(row, 0, proyeccion[0], data_format)
    ws_proyeccion.write(row, 1, proyeccion[1], data_format)
    ws_proyeccion.write(row, 2, proyeccion[2], currency_format)
    ws_proyeccion.write(row, 3, proyeccion[3], currency_format)
    ws_proyeccion.write(row, 4, proyeccion[4], currency_format)
    ws_proyeccion.write(row, 5, proyeccion[5], currency_format)
    ws_proyeccion.write(row, 6, proyeccion[6], currency_format)

# Gráfico de proyecciones
chart1 = workbook.add_chart({'type': 'line'})
chart1.add_series({
    'name': 'Ingresos Mensuales',
    'categories': '=Proyecciones de Ingresos!$A$4:$A$10',
    'values': '=Proyecciones de Ingresos!$E$4:$E$10',
    'line': {'color': '#1976d2', 'width': 3},
    'marker': {'type': 'circle', 'size': 8, 'fill': {'color': '#1976d2'}},
})

chart1.add_series({
    'name': 'Escenario Bajo',
    'categories': '=Proyecciones de Ingresos!$A$4:$A$10',
    'values': '=Proyecciones de Ingresos!$F$4:$F$10',
    'line': {'color': '#f44336', 'width': 2, 'dash_type': 'dash'},
})

chart1.add_series({
    'name': 'Escenario Alto',
    'categories': '=Proyecciones de Ingresos!$A$4:$A$10',
    'values': '=Proyecciones de Ingresos!$G$4:$G$10',
    'line': {'color': '#4caf50', 'width': 2, 'dash_type': 'dash'},
})

chart1.set_title({'name': 'Proyección de Ingresos por Usuarios Diarios'})
chart1.set_x_axis({'name': 'Usuarios Diarios', 'num_font': {'size': 10}})
chart1.set_y_axis({'name': 'Ingresos Mensuales (USD)', 'num_font': {'size': 10}})
chart1.set_legend({'position': 'bottom'})
chart1.set_size({'width': 720, 'height': 400})

ws_proyeccion.insert_chart('A12', chart1)

# ============= HOJA 5: ESTRATEGIA DE IMPLEMENTACIÓN =============
ws_estrategia = workbook.add_worksheet('Estrategia Implementación')
ws_estrategia.set_column('A:A', 15)
ws_estrategia.set_column('B:B', 30)
ws_estrategia.set_column('C:C', 40)
ws_estrategia.set_column('D:D', 20)
ws_estrategia.set_column('E:E', 15)

# Título
ws_estrategia.merge_range('A1:E1', '🚀 ROADMAP DE IMPLEMENTACIÓN', title_format)

# Encabezados
headers = ['Fase', 'Acción', 'Descripción', 'Anuncios a Implementar', 'Tiempo Est.']
for col, header in enumerate(headers):
    ws_estrategia.write(2, col, header, header_format)

# Roadmap
roadmap = [
    ['Fase 1\nSemana 1', 'Configuración Inicial', 'Crear cuenta AdMob, configurar IDs, integrar SDK', 'Banner Inferior (Sticky)', '3-5 días'],
    ['Fase 2\nSemana 2-3', 'Expansión Moderada', 'Agregar banner superior después del header', 'Banner Superior', '2-3 días'],
    ['Fase 3\nSemana 4', 'Optimización Visual', 'Banner entre secciones (Chat IA y Formularios)', 'Banner Entre Secciones', '2 días'],
    ['Fase 4\nMes 2', 'Anuncios Integrados', 'Implementar anuncios nativos en lista de formularios', 'Native Ads (cada 4 items)', '5-7 días'],
    ['Fase 5\nMes 2-3', 'Monetización Avanzada', 'Intersticiales limitados (max 1 cada 3 navegaciones)', 'Interstitial Ads', '3-4 días'],
    ['Fase 6\nMes 3+', 'Premium Features', 'Rewarded videos para desbloquear funciones', 'Rewarded Video Ads', '5-7 días'],
]

for row, fase in enumerate(roadmap, start=3):
    ws_estrategia.write(row, 0, fase[0], subheader_format)
    ws_estrategia.write(row, 1, fase[1], data_format)
    ws_estrategia.write(row, 2, fase[2], data_format)
    ws_estrategia.write(row, 3, fase[3], data_format)
    ws_estrategia.write(row, 4, fase[4], data_format)

# KPIs a monitorear
ws_estrategia.write('A11', '📊 KPIs A MONITOREAR', header_format)
ws_estrategia.merge_range('B11:E11', '', header_format)

kpis = [
    ['KPI', 'Meta Mes 1', 'Meta Mes 3', 'Meta Mes 6', 'Herramienta'],
    ['CTR (Click-Through Rate)', '1.5%', '2.5%', '3.5%', 'AdMob Dashboard'],
    ['Fill Rate', '80%', '85%', '90%', 'AdMob Dashboard'],
    ['eCPM (Effective CPM)', '$2.00', '$2.50', '$3.50', 'AdMob Dashboard'],
    ['Impresiones Diarias', '300', '1,500', '5,000', 'AdMob Dashboard'],
    ['Ingresos Diarios', '$0.60', '$3.75', '$17.50', 'AdMob Dashboard'],
    ['Tasa de Retención', '60%', '70%', '75%', 'Firebase Analytics'],
    ['Tiempo en App', '3 min', '5 min', '8 min', 'Firebase Analytics'],
]

for row, kpi in enumerate(kpis, start=12):
    for col, value in enumerate(kpi):
        if row == 12:
            ws_estrategia.write(row, col, value, header_format)
        else:
            ws_estrategia.write(row, col, value, data_format)

# ============= HOJA 6: CONFIGURACIÓN ADMOB =============
ws_config = workbook.add_worksheet('Configuración AdMob')
ws_config.set_column('A:A', 25)
ws_config.set_column('B:B', 50)
ws_config.set_column('C:C', 30)

# Título
ws_config.merge_range('A1:C1', '⚙️ GUÍA DE CONFIGURACIÓN ADMOB', title_format)

# IDs de prueba
ws_config.write('A3', 'TIPO DE ANUNCIO', header_format)
ws_config.write('B3', 'ID DE PRUEBA (TEST)', header_format)
ws_config.write('C3', 'REEMPLAZAR CON', header_format)

test_ids = [
    ['Banner', 'ca-app-pub-3940256099942544/6300978111', 'Tu ID de Banner Real'],
    ['Interstitial', 'ca-app-pub-3940256099942544/1033173712', 'Tu ID de Interstitial Real'],
    ['Native Advanced', 'ca-app-pub-3940256099942544/2247696110', 'Tu ID de Native Real'],
    ['Rewarded Video', 'ca-app-pub-3940256099942544/5224354917', 'Tu ID de Rewarded Real'],
    ['App Open', 'ca-app-pub-3940256099942544/3419835294', 'Tu ID de App Open Real'],
]

for row, test_id in enumerate(test_ids, start=4):
    ws_config.write(row, 0, test_id[0], data_format)
    ws_config.write(row, 1, test_id[1], data_format)
    ws_config.write(row, 2, test_id[2], data_format)

# Pasos de configuración
ws_config.write('A11', 'PASOS DE CONFIGURACIÓN', header_format)
ws_config.merge_range('B11:C11', '', header_format)

pasos = [
    ['1. Crear cuenta en AdMob', 'https://admob.google.com/'],
    ['2. Crear nueva app en AdMob', 'Seleccionar Android/iOS + nombre "Logic"'],
    ['3. Crear unidades de anuncios', 'Banner, Interstitial, Native, etc.'],
    ['4. Copiar IDs de anuncios', 'Reemplazar en el código los IDs de prueba'],
    ['5. Configurar pubspec.yaml', 'Agregar: google_mobile_ads: ^5.1.0'],
    ['6. Inicializar en main.dart', 'MobileAds.instance.initialize()'],
    ['7. Implementar anuncios', 'Seguir código de ejemplo proporcionado'],
    ['8. Probar con IDs de prueba', 'Validar que funcionan correctamente'],
    ['9. Cambiar a IDs reales', 'Después de pruebas exitosas'],
    ['10. Publicar y monitorear', 'Revisar métricas diariamente'],
]

for row, paso in enumerate(pasos, start=12):
    ws_config.write(row, 0, paso[0], data_format)
    ws_config.merge_range(row, 1, row, 2, paso[1], data_format)

# ============= HOJA 7: MEJORES PRÁCTICAS =============
ws_practicas = workbook.add_worksheet('Mejores Prácticas')
ws_practicas.set_column('A:A', 40)
ws_practicas.set_column('B:B', 60)

# Título
ws_practicas.merge_range('A1:B1', '✅ MEJORES PRÁCTICAS Y RECOMENDACIONES', title_format)

# Categorías
categorias = [
    ['EXPERIENCIA DE USUARIO', [
        ('No más de 3 anuncios visibles simultáneamente', 'Evita saturar la interfaz'),
        ('Espaciado adecuado entre anuncios', 'Mínimo 200px de separación'),
        ('Anuncios relevantes al contenido legal', 'Mayor CTR y mejor experiencia'),
        ('Tiempos de espera razonables', 'Intersticiales cada 3+ navegaciones'),
        ('Opción de cerrar anuncios', 'Si es posible, dar control al usuario'),
    ]],
    ['OPTIMIZACIÓN DE INGRESOS', [
        ('Probar diferentes ubicaciones (A/B testing)', 'Optimizar basándose en datos'),
        ('Usar múltiples redes publicitarias', 'AdMob + Facebook Audience Network'),
        ('Implementar mediation', 'Maximizar fill rate y eCPM'),
        ('Anuncios nativos cuando sea posible', 'Mejor integración = mayor CTR'),
        ('Monitorear métricas semanalmente', 'Ajustar estrategia constantemente'),
    ]],
    ['CUMPLIMIENTO Y POLÍTICAS', [
        ('Leer políticas de AdMob', 'Evitar suspensiones de cuenta'),
        ('No hacer clic en tus propios anuncios', 'Puede resultar en ban permanente'),
        ('Contenido apropiado', 'Verificar que cumple políticas'),
        ('Colocación correcta de anuncios', 'No cerca de botones clickeables'),
        ('Transparencia con usuarios', 'Política de privacidad actualizada'),
    ]],
    ['TÉCNICAS AVANZADAS', [
        ('Segmentación de audiencia', 'Anuncios diferentes por perfil de usuario'),
        ('Frecuency capping', 'Limitar impresiones por usuario'),
        ('Rewarded ads para premium', 'Monetizar sin subscripción'),
        ('Smart Segmentation', 'AdMob optimiza automáticamente'),
        ('Open Bidding', 'Aumenta competencia y CPM'),
    ]],
]

row = 3
for categoria in categorias:
    # Título de categoría
    ws_practicas.merge_range(row, 0, row, 1, f'📌 {categoria[0]}', header_format)
    row += 1
    
    # Prácticas
    for practica in categoria[1]:
        ws_practicas.write(row, 0, practica[0], data_format)
        ws_practicas.write(row, 1, practica[1], data_format)
        row += 1
    
    row += 1  # Espacio entre categorías

# ============= HOJA 8: ANÁLISIS DE COMPETENCIA =============
ws_competencia = workbook.add_worksheet('Análisis Competencia')
ws_competencia.set_column('A:A', 25)
ws_competencia.set_column('B:B', 20)
ws_competencia.set_column('C:C', 20)
ws_competencia.set_column('D:D', 40)

# Título
ws_competencia.merge_range('A1:D1', '🔍 ANÁLISIS DE APPS LEGALES SIMILARES', title_format)

# Encabezados
headers = ['App Competidora', 'Tipos de Anuncios', 'Estrategia Principal', 'Lecciones Aprendidas']
for col, header in enumerate(headers):
    ws_competencia.write(2, col, header, header_format)

# Datos de competencia (ejemplos hipotéticos)
competencia = [
    ['LegalZoom', 'Banner + Interstitial', 'Interstitiales después de cotizaciones', 'Balance entre monetización y conversión'],
    ['Rocket Lawyer', 'Banner + Native', 'Anuncios nativos en resultados búsqueda', 'Alta integración = mejor UX'],
    ['Avvo', 'Banner + Video', 'Videos recompensados por consultaas', 'Usuarios aceptan anuncios por beneficios'],
    ['LawRato (India)', 'Banner + Intersticial', 'Banners discretos + intersticiales limitados', 'Menos es más en apps de servicios'],
    ['JusticeDirect', 'Solo Banner', 'Monetización mínima, enfoque en conversión', 'Priorizar experiencia sobre ads'],
]

for row, comp in enumerate(competencia, start=3):
    ws_competencia.write(row, 0, comp[0], data_format)
    ws_competencia.write(row, 1, comp[1], data_format)
    ws_competencia.write(row, 2, comp[2], data_format)
    ws_competencia.write(row, 3, comp[3], data_format)

# ============= HOJA 9: MÉTRICAS Y BENCHMARKS =============
ws_metricas = workbook.add_worksheet('Métricas y Benchmarks')
ws_metricas.set_column('A:A', 25)
ws_metricas.set_column('B:E', 15)

# Título
ws_metricas.merge_range('A1:E1', '📈 BENCHMARKS DE LA INDUSTRIA', title_format)

# Encabezados
headers = ['Métrica', 'Bajo', 'Promedio', 'Alto', 'Excelente']
for col, header in enumerate(headers):
    ws_metricas.write(2, col, header, header_format)

# Benchmarks
benchmarks = [
    ['CTR - Banner', '0.5%', '1.5%', '2.5%', '4.0%'],
    ['CTR - Interstitial', '1.0%', '2.0%', '3.5%', '5.0%'],
    ['CTR - Native', '1.5%', '3.0%', '5.0%', '8.0%'],
    ['Fill Rate', '60%', '75%', '85%', '95%'],
    ['eCPM - Banner', '$0.50', '$1.50', '$3.00', '$5.00'],
    ['eCPM - Interstitial', '$2.00', '$5.00', '$8.00', '$15.00'],
    ['eCPM - Native', '$1.50', '$3.00', '$5.00', '$8.00'],
    ['Retención Día 1', '30%', '45%', '60%', '75%'],
    ['Retención Día 7', '15%', '25%', '35%', '50%'],
    ['Retención Día 30', '8%', '15%', '22%', '35%'],
]

for row, benchmark in enumerate(benchmarks, start=3):
    ws_metricas.write(row, 0, benchmark[0], data_format)
    ws_metricas.write(row, 1, benchmark[1], low_format)
    ws_metricas.write(row, 2, benchmark[2], medium_format)
    ws_metricas.write(row, 3, benchmark[3], high_format)
    ws_metricas.write(row, 4, benchmark[4], high_format)

# Gráfico de benchmarks
chart2 = workbook.add_chart({'type': 'column'})
chart2.add_series({
    'name': 'Bajo',
    'categories': '=Métricas y Benchmarks!$A$4:$A$10',
    'values': '=Métricas y Benchmarks!$B$4:$B$10',
    'fill': {'color': '#f44336'},
})
chart2.add_series({
    'name': 'Promedio',
    'categories': '=Métricas y Benchmarks!$A$4:$A$10',
    'values': '=Métricas y Benchmarks!$C$4:$C$10',
    'fill': {'color': '#ff9800'},
})
chart2.add_series({
    'name': 'Alto',
    'categories': '=Métricas y Benchmarks!$A$4:$A$10',
    'values': '=Métricas y Benchmarks!$D$4:$D$10',
    'fill': {'color': '#4caf50'},
})

chart2.set_title({'name': 'Benchmarks de CTR por Tipo de Anuncio'})
chart2.set_x_axis({'name': 'Tipo de Anuncio'})
chart2.set_y_axis({'name': 'Porcentaje (%)'})
chart2.set_legend({'position': 'bottom'})
chart2.set_size({'width': 720, 'height': 400})

ws_metricas.insert_chart('A15', chart2)

# Cerrar el archivo
workbook.close()

print("✅ Archivo Excel creado exitosamente: 'Analisis_Monetizacion_Anuncios_Logic.xlsx'")
print("📊 Incluye 9 hojas con análisis completo:")
print("   1. Resumen Ejecutivo")
print("   2. Ubicaciones de Anuncios")
print("   3. Tipos de Anuncios")
print("   4. Proyecciones de Ingresos (con gráfico)")
print("   5. Estrategia de Implementación")
print("   6. Configuración AdMob")
print("   7. Mejores Prácticas")
print("   8. Análisis de Competencia")
print("   9. Métricas y Benchmarks (con gráfico)")
