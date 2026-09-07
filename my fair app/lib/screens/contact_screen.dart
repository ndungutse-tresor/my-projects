import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/company_data.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const contact = CompanyData.contact;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.navyDark, AppColors.navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get in touch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We are here to help. Reach out and our team will get '
                    'back to you.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ContactTile(
              icon: Icons.location_on_outlined,
              title: 'Head Office',
              subtitle: '${contact.addressLine1}\n${contact.addressLine2}',
            ),
            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: contact.email,
              copyValue: contact.email,
            ),
            _ContactTile(
              icon: Icons.phone_outlined,
              title: 'Phone',
              subtitle: contact.phone,
              copyValue: contact.phone,
            ),
            _ContactTile(
              icon: Icons.language_outlined,
              title: 'Website',
              subtitle: contact.website,
              copyValue: contact.website,
            ),
            _ContactTile(
              icon: Icons.access_time,
              title: 'Working Hours',
              subtitle: contact.workingHours,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enquiry forms are coming in a future update.'),
                    ),
                  );
                },
                icon: const Icon(Icons.send_outlined),
                label: const Text('Send an enquiry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? copyValue;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.copyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.navy),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
        ),
        trailing: copyValue == null
            ? null
            : IconButton(
                icon: const Icon(Icons.copy_outlined, size: 20),
                color: AppColors.navyLight,
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: copyValue!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied: $copyValue')),
                  );
                },
              ),
      ),
    );
  }
}
