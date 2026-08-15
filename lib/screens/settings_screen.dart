import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/app_state.dart';
import '../providers/app_state_provider.dart';
import '../widgets/app_logo.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _importController = TextEditingController();

  void _exportCSV(BuildContext context, AppState state) {
    final csv = state.exportToCSV();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV de transacciones copiado al portapapeles.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppState state) {
    _importController.clear();
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        title: const Text(
          'Importar desde CSV',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pega el contenido CSV exportado previamente:',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _importController,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 11),
              decoration: const InputDecoration(
                hintText: '"ID","Concepto","Monto","Fecha"...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: theme.hintColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final content = _importController.text.trim();
              if (content.isNotEmpty) {
                final success = state.importFromCSV(content);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Transacciones importadas con éxito'
                          : 'Error al importar. Verifica el formato del CSV.',
                    ),
                    backgroundColor: success ? const Color(0xFF6F8F72) : const Color(0xFFB07D7D),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.scaffoldBackgroundColor,
            ),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, AppState state) {
    final theme = Theme.of(context);
    final currencies = [
      { 'symbol': '\$', 'name': 'Peso / Dólar (\$)' },
      { 'symbol': '€', 'name': 'Euro (€)' },
      { 'symbol': '£', 'name': 'Libra (£)' },
      { 'symbol': '¥', 'name': 'Yen / Yuan (¥)' },
      { 'symbol': 'MXN', 'name': 'Peso Mexicano (MXN)' },
      { 'symbol': 'COP', 'name': 'Peso Colombiano (COP)' },
      { 'symbol': 'ARS', 'name': 'Peso Argentino (ARS)' },
      { 'symbol': 'CLP', 'name': 'Peso Chileno (CLP)' },
      { 'symbol': 'PEN', 'name': 'Sol Peruano (PEN)' },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        title: const Text(
          'Seleccionar Moneda Principal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: currencies.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
            itemBuilder: (context, idx) {
              final curr = currencies[idx];
              final isSelected = state.currency == curr['symbol'];

              return ListTile(
                title: Text(curr['name']!, style: const TextStyle(fontSize: 13)),
                trailing: isSelected 
                    ? Icon(Icons.check_rounded, color: theme.primaryColor, size: 18) 
                    : null,
                onTap: () {
                  state.setCurrency(curr['symbol']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: theme.hintColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen Title
                  Text(
                    'Ajustes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.6,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Theme Preference Card
                  _buildSectionHeader('Preferencia de Visualización'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: const Text('Tema Oscuro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          state.isDarkMode ? 'Activado' : 'Desactivado (Tema Claro)',
                          style: TextStyle(fontSize: 10, color: theme.hintColor),
                        ),
                        trailing: Switch.adaptive(
                          value: state.isDarkMode,
                          activeColor: theme.primaryColor,
                          onChanged: (val) {
                            state.toggleTheme();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Currency section
                  _buildSectionHeader('Soporte Multimoneda'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        title: const Text('Moneda de Registro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'Actual: ${state.currency}',
                          style: TextStyle(fontSize: 10, color: theme.hintColor),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: theme.hintColor),
                        onTap: () => _showCurrencyDialog(context, state),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data backup section
                  _buildSectionHeader('Datos y Respaldos'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Exportar Respaldo CSV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              'Copia todos tus registros al portapapeles en formato CSV.',
                              style: TextStyle(fontSize: 10, color: theme.hintColor),
                            ),
                            trailing: Icon(Icons.copy_all_rounded, color: theme.hintColor),
                            onTap: () => _exportCSV(context, state),
                          ),
                          Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
                          ListTile(
                            title: const Text('Importar desde CSV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              'Restaura transacciones pegando texto CSV válido.',
                              style: TextStyle(fontSize: 10, color: theme.hintColor),
                            ),
                            trailing: Icon(Icons.paste_rounded, color: theme.hintColor),
                            onTap: () => _showImportDialog(context, state),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // App version info / branding
                  Center(
                    child: Column(
                      children: [
                        const AppLogo(size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'GastosController',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Versión 1.0.0 • Diseñado para Luci',
                          style: TextStyle(fontSize: 9, color: theme.hintColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: Colors.grey,
        ),
      ),
    );
  }
}
