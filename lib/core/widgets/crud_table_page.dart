import 'package:flutter/material.dart';
import 'dart:convert';
import '../crud/crud_repository.dart';

enum CrudFieldType {
  text,
  number,
  boolean,
  json,
  date,
}

class CrudField {
  final String keyName;
  final String label;
  final TextInputType keyboardType;
  final bool multiline;
  final bool readOnly;
  final CrudFieldType fieldType;

  const CrudField({
    required this.keyName,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.multiline = false,
    this.readOnly = false,
    this.fieldType = CrudFieldType.text,
  });
}

class CrudTableConfig {
  final String table;
  final String idColumn;
  final String titleColumn;
  final List<CrudField> fields;
  final String? orderBy;
  final bool orderAscending;

  const CrudTableConfig({
    required this.table,
    required this.idColumn,
    required this.titleColumn,
    required this.fields,
    this.orderBy,
    this.orderAscending = true,
  });
}

class CrudTablePage extends StatefulWidget {
  final CrudTableConfig config;
  final Map<String, dynamic> Function()? defaultInsertValues;
  final CrudRepository repository;

  const CrudTablePage({
    super.key,
    required this.config,
    required this.repository,
    this.defaultInsertValues,
  });

  @override
  State<CrudTablePage> createState() => _CrudTablePageState();
}

class _CrudTablePageState extends State<CrudTablePage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orderBy = widget.config.orderBy ?? widget.config.idColumn;
      final res = await widget.repository.list(
        table: widget.config.table,
        orderBy: orderBy,
        ascending: widget.config.orderAscending,
        limit: 200,
      );
      res.match(
        (l) => setState(() => _error = l.userMessage),
        (r) => setState(() => _rows = r),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openEditor({Map<String, dynamic>? row}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _CrudEditPage(
          config: widget.config,
          row: row,
          defaultInsertValues: widget.defaultInsertValues?.call(),
          repository: widget.repository,
        ),
      ),
    );

    if (saved == true) {
      await _load();
    }
  }

  Future<void> _deleteRow(Map<String, dynamic> row) async {
    final id = row[widget.config.idColumn];
    if (id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('This will delete ${widget.config.table} row: $id'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final res = await widget.repository.delete(
        table: widget.config.table,
        idColumn: widget.config.idColumn,
        id: id,
      );
      res.match(
        (l) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${l.userMessage}')));
          }
        },
        (r) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
          }
          await _load();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.table),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : ListView.separated(
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = _rows[index];
                    final title = (row[widget.config.titleColumn] ?? row[widget.config.idColumn] ?? '').toString();
                    final subtitle = (row[widget.config.idColumn] ?? '').toString();
                    return ListTile(
                      title: Text(title.isEmpty ? '(no title)' : title),
                      subtitle: subtitle.isEmpty ? null : Text(subtitle),
                      onTap: () => _openEditor(row: row),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteRow(row),
                      ),
                    );
                  },
                ),
    );
  }
}

class _CrudEditPage extends StatefulWidget {
  final CrudTableConfig config;
  final Map<String, dynamic>? row;
  final Map<String, dynamic>? defaultInsertValues;
  final CrudRepository repository;

  const _CrudEditPage({
    required this.config,
    required this.row,
    required this.defaultInsertValues,
    required this.repository,
  });

  @override
  State<_CrudEditPage> createState() => _CrudEditPageState();
}

class _CrudEditPageState extends State<_CrudEditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _saving = false;

  bool get _isEdit => widget.row != null;

  @override
  void initState() {
    super.initState();
    for (final f in widget.config.fields) {
      final initial = widget.row?[f.keyName];
      _controllers[f.keyName] = TextEditingController(text: initial?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _saving = true;
    });

    final payload = <String, dynamic>{};
    for (final f in widget.config.fields) {
      if (f.readOnly) continue;
      final value = _controllers[f.keyName]!.text.trim();

      // Don't write NULLs for empty fields; keeps NOT NULL columns safe.
      if (value.isEmpty) continue;

      switch (f.fieldType) {
        case CrudFieldType.number:
          final parsed = num.tryParse(value);
          if (parsed == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid number for "${f.label}": $value')),
            );
            return;
          }
          payload[f.keyName] = parsed;
          break;
        case CrudFieldType.boolean:
          final lower = value.toLowerCase();
          payload[f.keyName] = lower == 'true' || lower == '1' || lower == 'yes' || lower == 'y';
          break;
        case CrudFieldType.json:
          try {
            payload[f.keyName] = jsonDecode(value);
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid JSON for "${f.label}". Example: {"key":"value"}')),
            );
            return;
          }
          break;
        case CrudFieldType.date:
          // Keep as string; Postgres date will parse "YYYY-MM-DD".
          payload[f.keyName] = value;
          break;
        case CrudFieldType.text:
          payload[f.keyName] = value;
      }
    }

    if (!_isEdit && widget.defaultInsertValues != null) {
      payload.addAll(widget.defaultInsertValues!);
    }

    try {
      if (_isEdit) {
        final id = widget.row![widget.config.idColumn];
        final res = await widget.repository.update(
          table: widget.config.table,
          idColumn: widget.config.idColumn,
          id: id,
          payload: payload,
        );
        final ok = res.match((l) => false, (r) => true);
        if (!ok) {
          if (mounted) {
            final msg = res.match((l) => l.userMessage, (r) => '');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $msg')));
          }
          return;
        }
      } else {
        final res = await widget.repository.insert(table: widget.config.table, payload: payload);
        final ok = res.match((l) => false, (r) => true);
        if (!ok) {
          if (mounted) {
            final msg = res.match((l) => l.userMessage, (r) => '');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $msg')));
          }
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit' : 'Add'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final f in widget.config.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: _controllers[f.keyName],
                  keyboardType: f.keyboardType,
                  maxLines: f.multiline ? 4 : 1,
                  readOnly: f.readOnly,
                  decoration: InputDecoration(
                    labelText: f.label,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

