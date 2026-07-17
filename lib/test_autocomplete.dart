import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CustomAutocompleteExample());
  }
}

// the following code was taken from https://chatgpt.com/share/6994778f-19f8-8003-9fd8-290c0d0709b4
// I did the following minor changes:
// - make c-tor for class CustomAutocompleteExample const to avoid warning
// - added some options to test scrolling
// - commented some lines in ListView.builder which seem to be not needed
// - added asimple ListView in comment as alternative to ListView.builder

class CustomAutocompleteExample extends StatelessWidget {
  const CustomAutocompleteExample({super.key});

  final List<String> _options = const [
    'Apple',
    'Banana',
    'Blueberry',
    'Cherry',
    'Grape',
    'Mango',
    'Orange',
    'Peach',
    'Strawberry',
    'Test01',
    'Test02',
    'Test03',
    'Test04',
    'Test05',
    'Test06',
    'Test07',
    'Test08',
    'Test09',
    'Test10',
    'Test11',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Autocomplete')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RawAutocomplete<String>(
          textEditingController: TextEditingController(),
          focusNode: FocusNode(),

          // 1️⃣ Filter logic
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _options.where(
              (option) => option.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ),
            );
          },

          // 2️⃣ What happens when user selects an option
          onSelected: (String selection) {
            debugPrint('Selected: $selection');
          },

          // 3️⃣ The TextField itself
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Search fruit',
                    border: OutlineInputBorder(),
                  ),
                );
              },

          // 4️⃣ CUSTOM suggestions widget
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    //padding: EdgeInsets.zero,
                    //shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return _SuggestionTile(
                        text: option,
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                  // child: ListView(
                  //   children: [
                  //     for (var option in options)
                  //       _SuggestionTile(
                  //         text: option,
                  //         onTap: () => onSelected(option),
                  //       ),
                  //   ],
                  // ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
