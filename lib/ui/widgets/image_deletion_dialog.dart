import 'package:flutter/material.dart';

class ImageDeletionDialog extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onApply;

  const ImageDeletionDialog({super.key, this.onApply, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удаление'),
      content: const Text('Вы действительно хотите удалить это изображение?'),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Отменить')),
        TextButton(onPressed: onApply, child: const Text('Подтвердить')),
      ],
    );
  }
}
