import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_colors.dart';

class JelajahScreen extends StatefulWidget {
  const JelajahScreen({super.key});

  @override
  State<JelajahScreen> createState() => _JelajahScreenState();
}

class _JelajahScreenState extends State<JelajahScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Data Master Wisata untuk Simulasi Jelajah & Search
  final List<Map<String, dynamic>> _allWisata = [
    {'id': 1, 'nama': 'Gunung Citiis Utama', 'kategori': 'Gunung', 'rating': 4.8, 'harga': 25000, 'image': '🎟️'},
    {'id': 2, 'nama': 'Citiis Camping Ground', 'kategori': 'Camping', 'rating': 4.7, 'harga': 75000, 'image': '🏕️'},
    {'id': 3, 'nama': 'Resort & Villa Citiis', 'kategori': 'Penginapan', 'rating': 4.9, 'harga': 350000, 'image': '🏨'},
    {'id': 4, 'nama': 'Sewa Alat Camp Berkah', 'kategori': 'Sewa Alat', 'rating': 4.5, 'harga': 15000, 'image': '🛠️'},
  ];

  // List penampung hasil filter pencarian
  List<Map<String, dynamic>> _filteredWisata = [];
  String _selectedKategori = 'Semua';

  @override
  void initState() {
    super.initState();
    // Di awal, tampilkan semua data
    _filteredWisata = _allWisata;
  }

  // FUNGSI UTAMA PENCARIAN & FILTER KATEGORI
  void _jalankanFilter(String query) {
    List<Map<String, dynamic>> hasil = [];
    
    if (query.isEmpty) {
      hasil = _allWisata;
    } else {
      // Filter berdasarkan kecocokan nama wisata (Ignore Case)
      hasil = _allWisata
          .where((wisata) => wisata['nama'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Filter tambahan berdasarkan kategori tab yang dipilih
    if (_selectedKategori != 'Semua') {
      hasil = hasil.where((wisata) => wisata['kategori'] == _selectedKategori).toList();
    }

    setState(() {
      _filteredWisata = hasil;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Jelajah Wisata Citiis', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. KOTAK INPUT PENCARIAN (SEARCH BAR)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _jalankanFilter(value), // OTOMATIS MENCARI SAAT DIKETIK
              decoration: InputDecoration(
                hintText: 'Cari tempat camp, hotel, atau tiket...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _jalankanFilter('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
              ),
            ),
          ),

          // 2. FILTER KATEGORI QUICK BUTTONS
          _buildCategoryFilterRow(),

          // 3. DAFTAR HASIL JELAJAH/PENCARIAN
          Expanded(
            child: _filteredWisata.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredWisata.length,
                    itemBuilder: (context, index) {
                      final item = _filteredWisata[index];
                      return _buildWisataCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterRow() {
    final kategoriList = ['Semua', 'Gunung', 'Camping', 'Penginapan', 'Sewa Alat'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kategoriList.length,
        itemBuilder: (context, idx) {
          final kat = kategoriList[idx];
          final isSelected = _selectedKategori == kat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(kat, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.white,
              onSelected: (bool selected) {
                setState(() {
                  _selectedKategori = kat;
                  _jalankanFilter(_searchController.text);
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWisataCard(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: AppColors.lightGreen, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(item['image'], style: const TextStyle(fontSize: 22))),
        ),
        title: Text(item['nama'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(item['kategori'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('Data pariwisata kosong atau tidak ditemukan', 
        style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}