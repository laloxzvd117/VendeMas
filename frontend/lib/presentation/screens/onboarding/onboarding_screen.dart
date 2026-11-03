import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _nameError;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Escribe el nombre de tu negocio' : null;
      _phoneError = _phoneController.text.trim().length < 10 ? 'Ingresa un número válido' : null;
    });

    if (_nameError != null || _phoneError != null) return;

    final biz = context.read<BusinessProvider>();
    biz.register(_nameController.text.trim(), _phoneController.text.trim());

    context.read<ProductProvider>().loadSampleData(biz.business!.id);
    context.read<SaleProvider>().loadSampleData();

    context.go(homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.store, size: 40, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenido a\nVendeMas',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tu negocio para empezar a vender y llevar el control de tus productos.',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre del negocio',
                      border: const OutlineInputBorder(),
                      errorText: _nameError,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Tu número de celular',
                      border: const OutlineInputBorder(),
                      helperText: 'Para recuperar tu cuenta después',
                      errorText: _phoneError,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Comenzar', style: TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
