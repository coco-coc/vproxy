import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vx/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

class AddSshKeyDialog extends StatefulWidget {
  const AddSshKeyDialog({super.key, this.fullScreen = false});
  final bool fullScreen;

  @override
  State<AddSshKeyDialog> createState() => _AddSshKeyDialogState();
}

class AddSshKeyForm {
  final String name;
  final String? remark;
  final String? sshKey;
  final String? sshKeyPath;
  final String? sshKeyPassphrase;

  AddSshKeyForm(
      {required this.name,
      this.remark,
      this.sshKey,
      this.sshKeyPath,
      this.sshKeyPassphrase});
}

class _AddSshKeyDialogState extends State<AddSshKeyDialog> {
  final _nameController = TextEditingController();
  final _remarkController = TextEditingController();
  final _sshKeyController = TextEditingController();
  final _sshKeyPathController = TextEditingController();
  final _sshKeyPassphraseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _nameController.dispose();
    _remarkController.dispose();
    _sshKeyController.dispose();
    _sshKeyPathController.dispose();
    _sshKeyPassphraseController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final form = AddSshKeyForm(
      name: _nameController.text,
      remark: _remarkController.text,
      sshKey: _sshKeyController.text,
      sshKeyPath: _sshKeyPathController.text,
      sshKeyPassphrase: _sshKeyPassphraseController.text,
    );
    Navigator.of(context).pop(form);
  }

  @override
  Widget build(BuildContext context) {
    final form = Theme(
      data: Theme.of(context).copyWith(
          inputDecorationTheme:
              const InputDecorationTheme(border: OutlineInputBorder())),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.fieldRequired;
                }
                return null;
              },
            ),
            const Gap(10),
            TextFormField(
              controller: _remarkController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.remark,
              ),
            ),
            const Gap(10),
            TextFormField(
              controller: _sshKeyController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.sshKey,
              ),
              validator: (value) {
                if (_sshKeyController.text.isEmpty &&
                    _sshKeyPathController.text.isEmpty) {
                  return AppLocalizations.of(context)!
                      .sshKeyContentOrPathRequired;
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        // allowedExtensions: ['pem', 'key', 'txt'],
                        withData: true);
                    if (result != null && result.files.single.bytes != null) {
                      _sshKeyController.text =
                          utf8.decode(result.files.single.bytes!);
                    }
                  },
                  icon: const Icon(Icons.folder),
                  label: Text(AppLocalizations.of(context)!.selectFromFile)),
            ),
            const Gap(10),
            // TextFormField(
            //   controller: _sshKeyPathController,
            //   decoration: InputDecoration(
            //     labelText: AppLocalizations.of(context)!.sshKeyPath,
            //   ),
            //   validator: (value) {
            //     if (_sshKeyController.text.isEmpty &&
            //         _sshKeyPathController.text.isEmpty) {
            //       return AppLocalizations.of(context)!
            //           .sshKeyContentOrPathRequired;
            //     }
            //     return null;
            //   },
            // ),
            // Gap(10),
            TextFormField(
              controller: _sshKeyPassphraseController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.keyPassphrase,
              ),
            )
          ],
        ),
      ),
    );
    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () => _save(context),
                child: Text(AppLocalizations.of(context)!.save))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(child: form),
        ),
      );
    }
    return AlertDialog(
      scrollable: true,
      // title: Text(AppLocalizations.of(context)!.addSshKey),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
        child: form,
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () => _save(context),
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
