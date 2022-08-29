import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/providers/select_type_provider.dart';

class MyDropdownButton extends StatelessWidget {
  const MyDropdownButton({
    Key? key,
    required this.selectTypeListProvider,
  }) : super(key: key);

  final SelectTypeListProvider selectTypeListProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // width: double.infinity,
        child: DropdownButton<SelectType>(
          value: selectTypeListProvider.selectType[selectTypeListProvider.indexSelected],
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          dropdownColor: Colors.blue,
          borderRadius: BorderRadius.circular(5),
          isExpanded: true,

          // style: const TextStyle(color: Colors.),
          underline: const SizedBox.shrink(),
          onChanged: (SelectType? newValue) {
            if (newValue != null) {
              context.read<SelectTypeListProvider>().changeSelected(newValue.id);
            }
          },
          items: selectTypeListProvider.selectType.map<DropdownMenuItem<SelectType>>((SelectType value) {
            return DropdownMenuItem<SelectType>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(child: Text(value.title)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
