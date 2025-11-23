import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class LangTranslator extends StatefulWidget {
  const LangTranslator({super.key});

  @override
  State<LangTranslator> createState() => _LangTranslatorState();
}

class _LangTranslatorState extends State<LangTranslator>
    with TickerProviderStateMixin {

  var lang = ['English', 'Hindi', 'Arabic'];
  var origin = "English";
  var desiredOutput = "Hindi";
  var output = "";

  TextEditingController languageController = TextEditingController();

  late AnimationController loaderController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    loaderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    loaderController.dispose();
    super.dispose();
  }

  // Translation function
  void translate(String src, String dest, String input) async {
    if (input.trim().isEmpty) {
      setState(() {
        output = "Please enter text to translate.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    GoogleTranslator translator = GoogleTranslator();
    var translation = await translator.translate(input, from: src, to: dest);

    setState(() {
      output = translation.text.toString();
      isLoading = false;
    });
  }

  // Convert language to code
  String getLangCode(String lang) {
    if (lang == "English") return "en";
    if (lang == "Hindi") return "hi";
    if (lang == "Arabic") return "ar";
    return "en";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        title: const Text(
          "Language Translator",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      body: Container(
        height: double.infinity,
        width: double.infinity,

        // Full screen gradient (fixes white bottom)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1565C0),
              Color(0xFF1E88E5),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 40),

                // ----- Language Selection Box -----
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // From Language Dropdown
                      dropdownBox(
                        value: origin,
                        items: lang,
                        onChanged: (v) => setState(() => origin = v!),
                      ),

                      // Swap Button Animated
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            String temp = origin;
                            origin = desiredOutput;
                            desiredOutput = temp;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(Icons.swap_horiz,
                              color: Colors.white, size: 26),
                        ),
                      ),

                      // To Language Dropdown
                      dropdownBox(
                        value: desiredOutput,
                        items: lang,
                        onChanged: (v) => setState(() => desiredOutput = v!),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ----- Input Box -----
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: TextField(
                    controller: languageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Enter text",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      hintText: "Type something to translate...",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: 20),

                // ----- Translate Button -----
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 14),
                    backgroundColor: Colors.white.withOpacity(0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    translate(
                      getLangCode(origin),
                      getLangCode(desiredOutput),
                      languageController.text,
                    );
                  },
                  child: const Text(
                    "Translate",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 30),

                // ----- Result Box -----
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: isLoading
                      ? Center(
                    child: RotationTransition(
                      turns: loaderController,
                      child: const Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  )
                      : Text(
                    output.isEmpty
                        ? "Your translation will appear here."
                        : output,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Powered by Google Translate (via translator package)",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown Widget (Reusable)
  Widget dropdownBox({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          dropdownColor: Colors.blue.shade900,
          style: const TextStyle(color: Colors.white),
          items: items.map((lang) {
            return DropdownMenuItem(
              value: lang,
              child: Text(lang),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }
}
