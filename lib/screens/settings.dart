import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:majdoor/services/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Column(
                        children: [
                          _buildThemeOption(
                            context,
                            'System',
                            ThemeMode.system,
                            themeProvider,
                          ),
                          Divider(),
                          _buildThemeOption(
                            context,
                            'Light',
                            ThemeMode.light,
                            themeProvider,
                          ),
                          Divider(),
                          _buildThemeOption(
                            context,
                            'Dark',
                            ThemeMode.dark,
                            themeProvider,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      value: mode,
      groupValue: themeProvider.themeMode,
      onChanged: (ThemeMode? value) {
        if (value != null) {
          themeProvider.setThemeMode(value);
        }
      },
      activeColor: Theme.of(context).primaryColor,
    );
  }
}
