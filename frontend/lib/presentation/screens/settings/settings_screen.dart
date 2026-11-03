import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final biz = context.watch<BusinessProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.store, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(biz.business?.name ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(biz.business?.phoneNumber ?? '',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _SettingsItem(
            icon: Icons.edit,
            title: 'Editar nombre del negocio',
            onTap: () => _showEditNameDialog(context),
          ),
          _SettingsItem(
            icon: Icons.sync,
            title: 'Estado de sincronización',
            subtitle: biz.isOnline ? 'Conectado' : 'Sin conexión',
            trailing: Switch(
              value: biz.isOnline,
              onChanged: (_) => biz.toggleOnline(),
            ),
          ),
          const Divider(height: 32),
          _SettingsItem(
            icon: Icons.logout,
            title: 'Cerrar sesión',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final biz = context.read<BusinessProvider>();
    final controller = TextEditingController(text: biz.business?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del negocio',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                biz.updateName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tus datos están guardados en este dispositivo y no se perderán.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/onboarding');
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: isDestructive ? colorScheme.error : null)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant) : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
