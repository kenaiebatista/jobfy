import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/company/data/repositories/company_repository_impl.dart';
import 'package:jobfy/features/company/domain/entities/company_entity.dart';
import 'package:jobfy/features/company/domain/usecases/lookup_cnpj_usecase.dart';
import 'package:jobfy/features/company/domain/usecases/register_company_usecase.dart';
import 'package:jobfy/features/company/presentation/controllers/company_register_controller.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Company sign-up, shown on the register page in "I'm a company" mode.
/// Typing the CNPJ and tapping the magnifier fills the fields from
/// BrasilAPI (Receita Federal); every field stays editable.
class CompanyRegisterForm extends StatefulWidget {
  /// The register page's terms checkbox row and its current value.
  final Widget termsRow;
  final bool acceptedTerms;

  /// Shown under the submit button (the "already have an account" link).
  final Widget footer;

  /// Called with the created company (and its id) after a successful save.
  final ValueChanged<CompanyEntity> onRegistered;

  const CompanyRegisterForm({
    super.key,
    required this.termsRow,
    required this.acceptedTerms,
    required this.footer,
    required this.onRegistered,
  });

  @override
  State<CompanyRegisterForm> createState() => _CompanyRegisterFormState();
}

class _CompanyRegisterFormState extends State<CompanyRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _cnpj = TextEditingController();
  final _legalName = TextEditingController();
  final _tradeName = TextEditingController();
  final _phone = TextEditingController();
  final _businessArea = TextEditingController();
  final _zipCode = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _description = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  late final CompanyRegisterController _controller;

  @override
  void initState() {
    super.initState();
    final repo = CompanyRepositoryImpl();
    _controller = CompanyRegisterController(LookupCnpjUsecase(repo), RegisterCompanyUsecase(repo));
  }

  @override
  void dispose() {
    for (final c in [_cnpj, _legalName, _tradeName, _phone, _businessArea, _zipCode, _address, _city, _state, _description, _email, _password]) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  Future<void> _lookup() async {
    final cnpj = _digits(_cnpj.text);
    if (cnpj.length != 14) {
      _formKey.currentState!.validate();
      return;
    }
    final data = await _controller.lookup(cnpj);
    if (data == null || !mounted) return;
    void fill(TextEditingController c, String? v) {
      if (v != null && v.isNotEmpty) c.text = v;
    }
    fill(_legalName, data.legalName);
    fill(_tradeName, data.tradeName);
    fill(_phone, data.phone);
    fill(_businessArea, data.businessArea);
    fill(_zipCode, data.zipCode);
    fill(_address, data.address);
    fill(_city, data.city);
    fill(_state, data.state);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!widget.acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.termsRequiredError)));
      return;
    }
    final created = await _controller.register(
      CompanyEntity(
        companyId: '',
        companyName: _legalName.text.trim(),
        cnpj: _digits(_cnpj.text),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        tradeName: _tradeName.text.trim(),
        businessArea: _businessArea.text.trim(),
        zipCode: _digits(_zipCode.text),
        address: _address.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        description: _description.text.trim(),
      ),
      _password.text,
    );
    if (created != null && mounted) widget.onRegistered(created);
  }

  String _errorText(AppLocalizations l10n, CompanyRegisterError e) => switch (e) {
        CompanyRegisterError.cnpjNotFound => l10n.companyCnpjNotFound,
        CompanyRegisterError.lookupFailed => l10n.companyCnpjLookupError,
        CompanyRegisterError.emailInUse => l10n.authErrorEmailInUse,
        CompanyRegisterError.cnpjInUse => l10n.authErrorCnpjInUse,
        CompanyRegisterError.network => l10n.authErrorNetwork,
        CompanyRegisterError.failed => l10n.authErrorRegistrationFailed,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final optional = l10n.optionalSuffix;
    String? required(String? v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final error = _controller.error;
        final lookup = _controller.lookupResult;
        final lookupError = error == CompanyRegisterError.cnpjNotFound || error == CompanyRegisterError.lookupFailed;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              _title(l10n.companySectionData),
              TextFormField(
                controller: _cnpj,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => _lookup(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                  return _digits(v).length == 14 ? null : l10n.cnpjInvalid;
                },
                decoration: InputDecoration(
                  labelText: l10n.companyCnpjLabel,
                  hintText: l10n.companyCnpjHint,
                  helperText: l10n.companyCnpjSearchHint,
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                  suffixIcon: _controller.isLookingUp
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : IconButton(
                          tooltip: l10n.companyCnpjSearchTooltip,
                          icon: const Icon(Icons.search),
                          onPressed: _lookup,
                        ),
                ),
              ),
              if (lookupError)
                _note(_errorText(l10n, error!), colors.danger)
              else if (lookup != null && !lookup.isActive)
                _note(l10n.companyCnpjStatusWarning(lookup.status ?? ''), colors.warning)
              else if (lookup != null)
                _note(l10n.companyCnpjFilled, colors.success),
              _field(_legalName, l10n.companyLegalNameLabel, Icons.business_outlined, validator: required),
              _field(_tradeName, '${l10n.companyTradeNameLabel} $optional', Icons.storefront_outlined),
              _field(_phone, '${l10n.companyPhoneLabel} $optional', Icons.call_outlined,
                  hint: l10n.companyPhoneHint, keyboard: TextInputType.phone),
              _field(_businessArea, '${l10n.companyBusinessAreaLabel} $optional', Icons.work_outline),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    flex: 3,
                    child: _field(_zipCode, '${l10n.companyZipCodeLabel} $optional', Icons.markunread_mailbox_outlined,
                        keyboard: TextInputType.number),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _state,
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(labelText: l10n.companyStateLabel, counterText: ''),
                    ),
                  ),
                ],
              ),
              _field(_address, '${l10n.companyAddressLabel} $optional', Icons.location_on_outlined),
              _field(_city, '${l10n.companyCityLabel} $optional', Icons.location_city_outlined),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '${l10n.companyDescriptionLabel} $optional',
                  hintText: l10n.companyDescriptionHint,
                  alignLabelWithHint: true,
                ),
              ),
              const Divider(height: 8),
              _title(l10n.companySectionAccess),
              _field(_email, l10n.emailLabel, Icons.email_outlined,
                  hint: l10n.emailHint,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()) ? null : l10n.emailInvalid;
                  }),
              TextFormField(
                controller: _password,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.fieldRequired;
                  return v.length >= 6 ? null : l10n.passwordTooShort;
                },
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  hintText: l10n.passwordHintMin6,
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                ),
              ),
              const Divider(height: 8),
              widget.termsRow,
              if (error != null && !lookupError)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Text(_errorText(l10n, error), style: TextStyle(color: colors.danger, fontSize: 13)),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _controller.isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.textPrimary,
                    foregroundColor: colors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _controller.isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: colors.surface, strokeWidth: 2),
                        )
                      : Text(l10n.companyRegisterButton, style: const TextStyle(fontSize: 15)),
                ),
              ),
              widget.footer,
            ],
          ),
        );
      },
    );
  }

  Widget _title(String text) =>
      Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold));

  Widget _note(String text, Color color) => Text(text, style: TextStyle(fontSize: 12.5, color: color));

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    String? hint,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
      ),
    );
  }
}
