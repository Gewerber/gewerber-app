import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/guidance.dart';
import 'package:gewerber_app/domain/repositories/guidance_repository.dart';

/// In-memory [GuidanceRepository] backing the demo experience and the widget
/// tests.
///
/// Mirrors the onboarding checklist catalog that ships with the app and
/// persists progress locally through [SharedPreferences], so the demo stays
/// fully functional without a backend.
@LazySingleton(as: GuidanceRepository, env: [AppEnvironment.authMock])
class MockGuidanceRepository implements GuidanceRepository {
  static const String _storageKey = 'getting_started_checklist_completed';
  static const String _tipsStorageKey = 'guidance_tips_dismissed';

  @override
  bool get supportsUnmark => true;

  @override
  Future<List<GuidanceTip>> tips() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList(_tipsStorageKey)?.toSet() ?? {};
    return const [
      GuidanceTip(
        topic: 'invoicing.kleinunternehmer',
        title: 'Small business regulation (§ 19 UStG)',
        body:
            'As a small business owner you do not charge VAT on your invoices '
            'and do not file VAT advance returns. Your invoices must include a '
            'note about the small business regulation.',
      ),
      GuidanceTip(
        topic: 'invoicing.goBD',
        title: 'GoBD-compliant invoice numbers',
        body:
            'Invoice numbers must be unique and sequential (GoBD). Gewerber '
            'assigns numbers automatically and without gaps.',
      ),
      GuidanceTip(
        topic: 'accounting.euer',
        title: 'Profit & loss (EÜR)',
        body:
            'As a sole trader you usually determine your profit via EÜR: '
            'income minus expenses on a cash basis. The report shows your '
            'current position at any time.',
      ),
    ].where((tip) => !dismissed.contains(tip.topic)).toList();
  }

  @override
  Future<List<GuidanceChecklist>> checklists() async {
    return const [
      GuidanceChecklist(
        key: 'onboarding',
        title: 'Getting started',
        items: [
          GuidanceChecklistItem(
            key: 'business_profile',
            title: 'Set up your business profile',
            body: 'Company name, address and legal form.',
          ),
          GuidanceChecklistItem(
            key: 'invoice_defaults',
            title: 'Configure your invoice defaults',
            body: 'Invoice numbering and payment terms.',
          ),
          GuidanceChecklistItem(
            key: 'first_customer',
            title: 'Add your first customer',
            body: 'Create a customer so you can bill them.',
          ),
          GuidanceChecklistItem(
            key: 'first_invoice',
            title: 'Create your first invoice',
            body: 'Send a professional invoice in minutes.',
          ),
          GuidanceChecklistItem(
            key: 'vat_basics',
            title: 'Understand VAT basics',
            body: 'Standard, reduced and Kleinunternehmer §19 rules.',
          ),
          GuidanceChecklistItem(
            key: 'personalize',
            title: 'Personalize the app',
            body: 'Pick your theme and language.',
          ),
        ],
      ),
    ];
  }

  @override
  Future<Set<String>> completedItemKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_storageKey)?.toSet() ?? <String>{};
  }

  @override
  Future<void> markCompleted(String itemKey) async {
    final completed = await completedItemKeys();
    completed.add(itemKey);
    await _saveCompleted(completed);
  }

  @override
  Future<void> unmarkCompleted(String itemKey) async {
    final completed = await completedItemKeys();
    completed.remove(itemKey);
    await _saveCompleted(completed);
  }

  @override
  Future<void> dismissTip(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList(_tipsStorageKey)?.toSet() ?? {};
    dismissed.add(topic);
    await prefs.setStringList(_tipsStorageKey, dismissed.toList()..sort());
  }

  Future<void> _saveCompleted(Set<String> completedIds) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = completedIds.toList()..sort();
    await prefs.setStringList(_storageKey, sorted);
  }
}
