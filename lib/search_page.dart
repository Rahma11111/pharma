// lib/search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();

  List<dynamic> allMedicines = [];
  List<dynamic> filteredMedicines = [];

  bool isLoading = true;
  bool isError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  @override
  void dispose() {
    companyController.dispose();
    medicineController.dispose();
    super.dispose();
  }

  Future<void> loadMedicines() async {
    setState(() {
      isLoading = true;
      isError = false;
      errorMessage = "";
    });

    try {
      final data = await ApiService.getMedicines();
      // تأكّد إن الداتا لست
      if (data is List) {
        setState(() {
          allMedicines = data;
          filteredMedicines = List.from(allMedicines);
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorMessage = "Unexpected response format from API";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = "Failed to load medicines: $e";
        isLoading = false;
      });
    }
  }

  // Clean and normalize the image url returned from API
  String fixImageUrl(dynamic urlRaw) {
    if (urlRaw == null) return "";
    String url = urlRaw.toString().trim();

    if (url.isEmpty) return "";

    // If already a complete URL, return as is
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    }

    // Replace backslashes with forward slashes
    url = url.replaceAll(r"\", "/");

    // Remove multiple slashes
    while (url.contains("//")) {
      url = url.replaceAll("//", "/");
    }

    // Ensure it starts with a slash
    if (!url.startsWith("/")) {
      url = "/$url";
    }

    // Build full URL
    return "https://pharmalink.runasp.net$url";
  }

  void filterList() {
    String med = medicineController.text.trim().toLowerCase();
    String comp = companyController.text.trim().toLowerCase();

    setState(() {
      filteredMedicines = allMedicines.where((item) {
        final name = (item["medicineName"] ?? "").toString().toLowerCase();
        final company = (item["companyName"] ?? "").toString().toLowerCase();
        final matchMed = med.isEmpty ? true : name.contains(med);
        final matchComp = comp.isEmpty ? true : company.contains(comp);
        return matchMed && matchComp;
      }).toList();
    });
  }

  void showMedicineModal(dynamic item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item["medicineName"] ?? ""),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((item["imageUrl"] ?? "").toString().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    fixImageUrl(item["imageUrl"]),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 12),
              Text(item["description"] ?? ""),
              const SizedBox(height: 12),
              Text("Price: ${item["price"]?.toString() ?? "-"} EGP"),
              Text("In stock: ${item["inStock"]?.toString() ?? "-"}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // call add to cart
              if (item["id"] != null) {
                ApiService.addToCart(item["id"]);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to cart")),
                );
              }
            },
            child: const Text("Add to cart"),
          )
        ],
      ),
    );
  }

  Widget _searchFields() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: companyController,
              decoration: InputDecoration(
                hintText: "🔍 Company...",
                filled: true,
                fillColor: const Color(0xffd9e8d8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (_) => filterList(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: medicineController,
              decoration: InputDecoration(
                hintText: "🔍 Medicine...",
                filled: true,
                fillColor: const Color(0xffd9e8d8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (_) => filterList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xff008682),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text("Drug", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 2, child: Center(child: Text("Company", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Price", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Quantity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Add", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          Expanded(flex: 1, child: Center(child: Text("Photo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _medicineRow(dynamic med) {
    final name = med["medicineName"] ?? "-";
    final company = med["companyName"] ?? "-";
    final price = med["price"]?.toString() ?? "-";
    final qty = med["inStock"]?.toString() ?? "-";

    final rawImage = med["imageUrl"];
    final imgUrl = (rawImage == null) ? "" : fixImageUrl(rawImage);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text(name, textAlign: TextAlign.center))),
          Expanded(flex: 2, child: Center(child: Text(company, textAlign: TextAlign.center))),
          Expanded(flex: 1, child: Center(child: Text("$price EGP", textAlign: TextAlign.center))),
          Expanded(flex: 1, child: Center(child: Text(qty, textAlign: TextAlign.center))),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (med["id"] != null) {
                    ApiService.addToCart(med["id"]);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to cart")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff008682),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("+", style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () => showMedicineModal(med),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: imgUrl.isEmpty
                        ? const Icon(Icons.image_not_supported, color: Colors.grey, size: 30)
                        : Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print("Image error for $imgUrl: $error");
                        return const Icon(Icons.image_not_supported, color: Colors.grey, size: 30);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyContent() {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (isError) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: loadMedicines, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (filteredMedicines.isEmpty) {
      return const Expanded(child: Center(child: Text("No medicines found")));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredMedicines.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return _tableHeader();
          }
          final med = filteredMedicines[i - 1];
          return _medicineRow(med);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Medicines"),
        backgroundColor: const Color(0xff008682),
      ),
      body: Column(
        children: [
          _searchFields(),
          _bodyContent(),
        ],
      ),
    );
  }
}