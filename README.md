# GastosController - Control de Gastos Minimalista

GastosController es una aplicación móvil, de escritorio y web desarrollada en **Flutter** diseñada para llevar un control financiero impecable, rápido y con un diseño estético premium y minimalista. Cumple con los requerimientos esenciales del día a día y añade características adicionales pensadas para optimizar la salud financiera de Luci.

---

## 🎨 Sistema de Diseño Minimalista

El diseño de la aplicación evita excesos visuales, brillos innecesarios o tonos neón. En su lugar, utiliza una paleta de colores orgánicos y neutrales:

*   **Tema Oscuro (Predeterminado):**
    *   Fondo: Grafito Profundo (`#0F0F0F`)
    *   Superficies/Tarjetas: Carbón Suave (`#161616`)
    *   Color Primario: Arena Cálida (`#C5B4A1`)
    *   Líneas y Separadores: Gris Oscuro (`#222222`)
    *   Textos: Blanco Muted (`#E5E5E5`) y Gris Hint (`#757575`)
*   **Tema Claro:**
    *   Fondo: Alabastro Cálido (`#FAF9F6`)
    *   Superficies/Tarjetas: Blanco Puro (`#FFFFFF`)
    *   Color Primario: Sépia Suave (`#8A7968`)
    *   Líneas y Separadores: Gris Hueso (`#ECEAE4`)
    *   Textos: Carbón Primario (`#1C1A17`) y Beige Cenizo (`#8C8A84`)

---

## 🚀 Características Clave

### 📂 Gestión Básica del Día a Día
1.  **Registro de Transacciones:**
    *   Concepto del gasto (ej. Almuerzo, Gasolina, Supermercado).
    *   Monto, fecha y método de pago (Efectivo, Tarjeta, Transferencia).
    *   Notas u observaciones opcionales.
2.  **Categorización Predeterminada:**
    *   *Gastos:* Comida (terracota), Transporte (sage green), Servicios (slate blue), Entretenimiento (lavanda), Salud (coral), Compras (oro), Educación (acero) y Otros (gris).
    *   *Ingresos:* Sueldo (verde bosque), Freelance (denim) y Extra (rosa viejo).
3.  **Gestión de Ingresos:** Filtro y lógica especial para salarios, cobros freelance o extras.
4.  **Presupuesto Mensual Simple:** Establece un límite global mensual, mostrando la barra de progreso y saldo restante en tiempo real.
5.  **Historial y Filtros Dinámicos:**
    *   Búsqueda por texto (concepto o notas).
    *   Filtro por mes/año y por categorías.
    *   Filtro por tipo de transacción (Todos, Gastos o Ingresos).
    *   Agrupación por fecha (ej. "Hoy", "Ayer", "14 de Agosto") con subtotales diarios.
6.  **Soporte Multimoneda Principal:** Cambia la moneda en los Ajustes ($, €, £, ¥, MXN, COP, ARS, CLP, PEN).

### 📈 Gráficos Visuales Estándar (Custom Rendered)
*   **Gráfico Circular/Donut:** Generado a medida mediante `CustomPainter` para visualizar la distribución de tus gastos por porcentaje e indicador central de gasto total.
*   **Gráfico de Barras:** Muestra de manera interactiva (tocar barras) las tendencias de gasto de los últimos 7 días.

---

## 🌟 Características Extra Añadidas

1.  **Metas de Ahorro (Savings Goals):**
    *   Crea metas (ej. "Fondo de Emergencia" o "Viaje").
    *   Establece montos objetivo y fechas límites.
    *   **Aportación Automatizada:** Al presionar "Aportar", el monto se deduce automáticamente del saldo e ingresa como una transacción de egreso en el historial para mantener la concordancia contable.
2.  **Suscripciones y Gastos Fijos (Recurring Tracker):**
    *   Administra tus pagos mensuales recurrentes (ej. Netflix, Spotify, Alquiler).
    *   Especifica el día del cobro (1 al 31) y activa/desactiva servicios para previsualizar el gasto fijo acumulado mensual.
3.  **Motor de Consejos Financieros (Insights):**
    *   Analiza dinámicamente tu comportamiento mensual.
    *   Muestra alertas si excedes el presupuesto, destaca la categoría con mayores salidas del mes y calcula tu tasa de ahorro.
4.  **Exportación e Importación CSV (Backups):**
    *   **Exportar:** Copia una cadena de texto formateada en CSV al portapapeles con un toque para abrirla en Excel.
    *   **Importar:** Pega texto en formato CSV dentro de la app para restaurar rápidamente registros históricos sin configuraciones de base de datos complejas.

---

## 🛠️ Arquitectura del Proyecto

El código está estructurado para ser altamente eficiente, modular y sin dependencias innecesarias que provoquen conflictos:

```text
lib/
│
├── models/
│   ├── transaction.dart   # Modelo de transacciones (ingresos/egresos)
│   ├── category.dart      # Estructura de categorías y colores predeterminados
│   ├── goal.dart          # Modelo para metas de ahorro
│   └── subscription.dart  # Modelo para suscripciones y cobros fijos
│
├── services/
│   └── storage_service.dart # Persistencia local híbrida (shared_preferences + JSON)
│
├── providers/
│   ├── app_state.dart     # Reglas de negocio, cálculos y lógica principal
│   └── app_state_provider.dart # Inyección de dependencias usando InheritedWidget
│
├── widgets/
│   ├── custom_pie_chart.dart     # Gráfico circular animado (CustomPainter)
│   ├── custom_bar_chart.dart     # Tendencia de barra de los últimos 7 días
│   ├── transaction_dialog.dart   # Formulario creador/editor de transacciones
│   ├── goal_dialog.dart          # Formulario creador/editor de metas
│   └── subscription_dialog.dart  # Formulario de suscripciones
│
└── screens/
    ├── home_shell.dart          # Contenedor de pestañas principal
    ├── dashboard_screen.dart    # Tab 1: Bienvenida, balance, insights y gráficos
    ├── transactions_screen.dart # Tab 2: Historial agrupado, búsqueda y filtros
    ├── budget_screen.dart       # Tab 3: Presupuesto mensual, metas y suscripciones
    └── settings_screen.dart     # Tab 4: Temas, moneda y copias de seguridad CSV
```

*   **Gestión de Estado:** `ChangeNotifier` nativo de Flutter junto con el widget `ListenableBuilder` (disponible desde Flutter 3.10+). Esto proporciona una reactividad extremadamente fluida sin necesidad de pesados paquetes externos.
*   **Persistencia:** `shared_preferences` almacena los datos serializados en JSON para compatibilidad total multiplataforma (Web, Android, iOS, Windows, macOS, Linux).

---

## ⚙️ Cómo Ejecutar el Proyecto

### Requisitos Previos
*   Tener instalado Flutter SDK (versión >= 3.12.2).
*   Dart SDK compatible.

### Pasos
1.  **Obtener dependencias:**
    ```bash
    flutter pub get
    ```
2.  **Verificar código estático:**
    ```bash
    flutter analyze
    ```
3.  **Ejecutar en modo de desarrollo:**
    ```bash
    flutter run
    ```
