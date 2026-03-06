import 'package:flutter/material.dart';

/// Card principale della schermata di login.
///
/// Mantiene il rendering separato dalla page, che resta focalizzata
/// sull'orchestrazione del flusso di autenticazione.
class LoginHeroCard extends StatelessWidget {
  const LoginHeroCard({
    super.key,
    required this.isLoading,
    required this.onLoginPressed,
  });

  final bool isLoading;
  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F0F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF155E75),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Condominio',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Accesso sicuro con Keycloak',
                style: TextStyle(fontSize: 15, color: Color(0xFF52606D)),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onLoginPressed,
                  icon: const Icon(Icons.login),
                  label: Text(isLoading ? 'Autenticazione...' : 'Accedi'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF155E75),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
