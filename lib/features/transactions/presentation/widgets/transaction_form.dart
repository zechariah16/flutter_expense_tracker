import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../categories/domain/category_catalog.dart';
import '../../data/transaction_repository.dart';
import '../../domain/transaction.dart';
import '../../domain/transaction_type.dart';

/// Reusable add/edit form.
///
/// It only edits local state (controllers and fields). Nothing reaches the
/// database until the user taps Save with valid input, so cancelling can
/// never modify stored data.
class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    this.existing,
    required this.onSubmit,
    required this.onCancel,
  });

  final MoneyTransaction? existing;
  final Future<void> Function(MoneyTransaction transaction) onSubmit;
  final VoidCallback onCancel;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late TransactionType _type;
  String? _categoryId;
  late DateTime _date;
  bool _categoryMissing = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _amountController = TextEditingController(
      text: e == null ? '' : Money.toInputString(e.amountInMinorUnits),
    );
    _titleController = TextEditingController(text: e?.title ?? '');
    _type = e?.type ?? TransactionType.expense;
    _categoryId = e?.categoryId;
    _date = e?.date ?? dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) setState(() => _date = dateOnly(picked));
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    final hasCategory = _categoryId != null;
    setState(() => _categoryMissing = !hasCategory);
    if (!valid || !hasCategory) return;

    final amount = Money.parseToMinorUnits(_amountController.text)!;
    final now = DateTime.now();
    final existing = widget.existing;
    final transaction = existing == null
        ? MoneyTransaction(
            id: const Uuid().v4(),
            title: _titleController.text,
            amountInMinorUnits: amount,
            type: _type,
            categoryId: _categoryId!,
            date: _date,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            title: _titleController.text,
            amountInMinorUnits: amount,
            type: _type,
            categoryId: _categoryId,
            date: _date,
            updatedAt: now,
          );

    setState(() => _saving = true);
    try {
      await widget.onSubmit(transaction);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final message =
          e is RepositoryException ? e.message : 'Could not save. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = CategoryCatalog.forType(_type);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SegmentedButton<TransactionType>(
            segments: [
              for (final t in TransactionType.values)
                ButtonSegment<TransactionType>(
                  value: t,
                  label: Text(t.label),
                  icon: Icon(
                    t == TransactionType.income
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) {
              setState(() {
                _type = selection.first;
                // A category from the other type is no longer valid.
                final id = _categoryId;
                if (id != null && CategoryCatalog.byId(id).type != _type) {
                  _categoryId = null;
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            textInputAction: TextInputAction.next,
            decoration: AppTheme.fieldDecoration(
              labelText: 'Amount',
              prefixText: '${AppConstants.currencySymbol} ',
            ),
            validator: (value) {
              final minor = Money.parseToMinorUnits(value ?? '');
              if (minor == null) return 'Enter a valid amount (up to 2 decimals)';
              if (minor <= 0) return 'Amount must be greater than zero';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _titleController,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: AppTheme.fieldDecoration(labelText: 'Description'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Enter a description' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Category',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in categories)
                ChoiceChip(
                  avatar: Icon(c.icon, size: 18, color: c.color),
                  label: Text(c.name),
                  selected: _categoryId == c.id,
                  onSelected: (_) => setState(() {
                    _categoryId = c.id;
                    _categoryMissing = false;
                  }),
                ),
            ],
          ),
          if (_categoryMissing)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Select a category',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(AppRadius.field),
            child: InputDecorator(
              decoration: AppTheme.fieldDecoration(
                labelText: 'Date',
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(DateFormatter.day(_date)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save changes' : 'Save transaction'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _saving ? null : widget.onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
