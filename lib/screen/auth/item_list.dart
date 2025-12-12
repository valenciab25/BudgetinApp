import 'package:flutter/material.dart';

// LANGKAH 1: Buat Model Data Sederhana (Pengganti dari Firestore)
// Kelas ini akan merepresentasikan satu item dalam daftar kita.
class Item {
  // Kita tambahkan ID agar unik, berguna untuk update & delete
  final String id;
  String name;
  int point;

  Item({required this.id, required this.name, required this.point});
}

// =============================================================

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  // LANGKAH 2: Buat Daftar Lokal Sebagai "Database" Sementara
  // Ini adalah pengganti dari stream data Firestore.
  // Kita isi dengan beberapa data awal agar tidak kosong.
  final List<Item> _items = [
    Item(id: '1', name: 'Nasi Goreng', point: 10),
    Item(id: '2', name: 'Mie Ayam', point: 15),
    Item(id: '3', name: 'Es Teh', point: 5),
  ];

  // Siapkan Controller seperti biasa untuk menangkap input teks
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  // ====================================================================
  // LOGIKA CREATE & UPDATE (Menambah & Mengubah Data Lokal)
  // ====================================================================
  void _showDialog({Item? item}) {
    if (item != null) {
      // Mode EDIT: Isi form dengan data item yang ada
      _nameController.text = item.name;
      _pointController.text = item.point.toString();
    } else {
      // Mode TAMBAH: Kosongkan form
      _nameController.clear();
      _pointController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Judul dinamis: berubah tergantung mode edit atau tambah
        title: Text(item == null ? 'Tambah Item' : 'Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Item'),
            ),
            TextField(
              controller: _pointController,
              decoration: const InputDecoration(labelText: 'Poin Item'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final String name = _nameController.text;
              final int point = int.tryParse(_pointController.text) ?? 0;

              if (name.isNotEmpty) {
                // Gunakan setState() untuk memberitahu Flutter agar me-render ulang UI
                setState(() {
                  if (item == null) {
                    // LOGIKA CREATE LOKAL
                    // Buat ID unik sederhana berdasarkan waktu saat ini
                    final newItem = Item(
                      id: DateTime.now().toString(),
                      name: name,
                      point: point,
                    );
                    _items.add(newItem); // Tambahkan ke daftar lokal
                  } else {
                    // LOGIKA UPDATE LOKAL
                    item.name = name;
                    item.point = point;
                  }
                });

                Navigator.pop(context); // Tutup dialog
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // LOGIKA DELETE (Menghapus Data Lokal)
  // ====================================================================
  void _showDeleteConfirmation(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Item?"),
        content: Text("Apakah anda yakin menghapus item ${item.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              // LOGIKA DELETE LOKAL
              setState(() {
                _items.remove(item); // Hapus dari daftar lokal
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pointController.dispose();
    super.dispose();
  }

  // ====================================================================
  // LOGIKA READ (Menampilkan Data dari Daftar Lokal)
  // ====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Item (Lokal)'), // Judul diubah sedikit
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // LANGKAH 3: Ganti StreamBuilder dengan ListView.builder biasa
      // karena kita sudah punya datanya di _items.
      body: _items.isEmpty
          ? const Center(
          child: Text('Tidak ada item yang dapat ditampilkan!'))
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final Item item = _items[index];

          return Card(
            elevation: 2,
            margin:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('ID Lokal: ${item.id.substring(20)}'), // Tampilkan sebagian ID unik
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.point} Poin',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    // Kirim seluruh objek item untuk dihapus
                    onPressed: () => _showDeleteConfirmation(item),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
              // Kirim seluruh objek item untuk diedit
              onTap: () => _showDialog(item: item),
            ),
          );
        },
      ),
    );
  }
}