import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
        ),
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
            width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      decoration: InputDecoration(
        labelText: 'Phone number',
        hintText: '01XXXXXXXXX',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.phone_android),
        // Small visual hint that it's locked on later steps (optional)
        suffixIcon: enabled ? null : const Icon(Icons.lock_outline),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (value) {
        // When disabled, validation won't run, but keep it here for the first step
        final v = (value ?? '').trim();
        if (!RegExp(r'^01\d{9}$').hasMatch(v)) {
          return 'Enter a valid 11-digit phone number (starts with 01)';
        }
        return null;
      },
    );
  }
}

// -------- OTP INPUT (6 boxes) --------

class OtpCodeInput extends StatefulWidget {
  const OtpCodeInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.boxSize = 40,
    this.boxSpacing = 4,
  }) : assert(length > 0);

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final double boxSize;
  final double boxSpacing;

  @override
  State<OtpCodeInput> createState() => OtpCodeInputState();
}

class OtpCodeInputState extends State<OtpCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _fieldNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _fieldNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _fieldNodes) n.dispose();
    super.dispose();
  }

  void clear() {
    for (final c in _controllers) c.clear();
    if (mounted) {
      setState(() {});
      _fieldNodes.first.requestFocus(); // focus the first *TextField*
    }
    _notify();
  }

  void _notify() {
    final code = _controllers.map((c) => c.text).join();
    widget.onChanged(code);
    if (code.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!(code);
    }
  }

  void _onChanged(int index, String value) {
    if (value.isEmpty) {
      _notify();
      return;
    }

    // keep only last typed digit
    final ch = value.characters.last;
    _controllers[index].text = ch;
    _controllers[index].selection =
        TextSelection.collapsed(offset: _controllers[index].text.length);

    // move focus to the *next TextField* (keyboard stays open)
    if (index + 1 < widget.length) {
      FocusScope.of(context).requestFocus(_fieldNodes[index + 1]);
    } else {
      _fieldNodes[index].unfocus();
    }
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.boxSpacing / 2),
          child: SizedBox(
            width: widget.boxSize,
            height: widget.boxSize,
            // Optional: handle Backspace to go to previous box (hardware kbd)
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.backspace): () {
                  if (_controllers[i].text.isEmpty && i > 0) {
                    FocusScope.of(context).requestFocus(_fieldNodes[i - 1]);
                    _controllers[i - 1].clear();
                    _notify();
                  }
                },
              },
              child: TextField(
                controller: _controllers[i],
                focusNode: _fieldNodes[i],
                autofocus: i == 0,
                textInputAction: i == widget.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Sizes.normalText(context),
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: cs.primary, width: 2),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          ),
        );
      }),
    );
  }
}


class PasswordField extends StatelessWidget {
  const PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          tooltip: obscure ? 'Show password' : 'Hide password',
        ),
      ),
    );
  }
}

class ConfirmPasswordField extends StatelessWidget {
  const ConfirmPasswordField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      autofillHints: const [AutofillHints.newPassword],
      decoration: const InputDecoration(
        labelText: 'Confirm password',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
    );
  }
}

class NameField extends StatelessWidget {
  const NameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email (optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.alternate_email),
      ),
    );
  }
}