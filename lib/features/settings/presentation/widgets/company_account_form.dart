import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/presentation/company_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// What the company can change about itself: the data the candidates see
/// and the login email. The legal name and the CNPJ are shown but fixed.
class CompanyAccountForm extends StatefulWidget {
  final CompanyEntity company;
  final bool isSaving;
  final void Function(CompanyEntity updated) onSave;

  const CompanyAccountForm({
    super.key,
    required this.company,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<CompanyAccountForm> createState() => _CompanyAccountFormState();
}

class _CompanyAccountFormState extends State<CompanyAccountForm> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.company.email);
  late final _tradeName = TextEditingController(text: widget.company.tradeName);
  late final _phone = TextEditingController(text: widget.company.phone);
  late final _area = TextEditingController(text: widget.company.businessArea);
  late final _zip = TextEditingController(text: widget.company.zipCode);
  late final _address = TextEditingController(text: widget.company.address);
  late final _city = TextEditingController(text: widget.company.city);
  late final _state = TextEditingController(text: widget.company.state);
  late final _description = TextEditingController(text: widget.company.description);

  @override
  void dispose() {
    for (final c in [_email, _tradeName, _phone, _area, _zip, _address, _city, _state, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final c = widget.company;
    widget.onSave(CompanyEntity(
      companyId: c.companyId,
      companyName: c.companyName,
      cnpj: c.cnpj,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      tradeName: _tradeName.text.trim(),
      businessArea: _area.text.trim(),
      zipCode: _zip.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      description: _description.text.trim(),
    ));
  }

  /// Side by side from tablet up; stacked on phones.
  Widget _pair(BuildContext context, Widget first, Widget second) {
    return Flex(
      direction: context.isMobile ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        for (final field in [first, second]) context.isMobile ? field : Expanded(child: field),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final c = widget.company;

    Widget fixed(String label, String value) => InputDecorator(
          decoration: InputDecoration(labelText: label, enabled: false),
          child: Text(value, style: TextStyle(color: colors.textMuted)),
        );

    InputDecoration deco(String label, {IconData? icon}) => InputDecoration(
          labelText: label,
          counterText: '',
          prefixIcon: icon == null ? null : Icon(icon, size: 18),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          _pair(context, fixed(l10n.companyLegalNameLabel, c.companyName), fixed(l10n.companyCnpjLabel, formatCnpj(c.cnpj))),
          TextFormField(
            controller: _email,
            maxLength: 150, // accounts.email VARCHAR(150)
            keyboardType: TextInputType.emailAddress,
            decoration: deco(l10n.emailLabel, icon: Icons.email_outlined),
            validator: (v) => _emailRegex.hasMatch(v?.trim() ?? '') ? null : l10n.settingsEmailInvalid,
          ),
          _pair(
            context,
            TextFormField(
              controller: _tradeName,
              maxLength: 150, // companies.trade_name VARCHAR(150)
              decoration: deco(l10n.companyTradeNameLabel, icon: Icons.storefront_outlined),
            ),
            TextFormField(
              controller: _phone,
              maxLength: 20, // companies.phone VARCHAR(20)
              keyboardType: TextInputType.phone,
              decoration: deco(l10n.companyPhoneLabel, icon: Icons.call_outlined),
            ),
          ),
          TextFormField(
            controller: _area,
            maxLength: 200, // companies.business_area VARCHAR(200)
            decoration: deco(l10n.companyBusinessAreaLabel, icon: Icons.work_outline),
          ),
          _pair(
            context,
            TextFormField(
              controller: _zip,
              maxLength: 9, // 8 digits, with or without the dash
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
              decoration: deco(l10n.companyZipCodeLabel, icon: Icons.markunread_mailbox_outlined),
              validator: (v) {
                final digits = (v ?? '').replaceAll('-', '');
                return digits.isEmpty || digits.length == 8 ? null : l10n.companyZipCodeInvalid;
              },
            ),
            TextFormField(
              controller: _address,
              maxLength: 200, // companies.address VARCHAR(200)
              decoration: deco(l10n.companyAddressLabel, icon: Icons.location_on_outlined),
            ),
          ),
          _pair(
            context,
            TextFormField(
              controller: _city,
              maxLength: 100, // companies.city VARCHAR(100)
              decoration: deco(l10n.companyCityLabel, icon: Icons.location_city_outlined),
            ),
            TextFormField(
              controller: _state,
              maxLength: 2, // companies.state CHAR(2)
              textCapitalization: TextCapitalization.characters,
              decoration: deco(l10n.companyStateLabel),
              validator: (v) => (v ?? '').isEmpty || v!.length == 2 ? null : l10n.companyStateInvalid,
            ),
          ),
          TextFormField(
            controller: _description,
            maxLines: 3,
            decoration: deco(l10n.companyDescriptionLabel),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: widget.isSaving ? null : _save,
              icon: widget.isSaving
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.onAccent),
                    )
                  : const Icon(Icons.check, size: 16),
              label: Text(widget.isSaving ? l10n.settingsSaving : l10n.settingsSaveChanges),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
