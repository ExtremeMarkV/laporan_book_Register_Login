import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laporan_book/components/styles.dart';
import 'package:laporan_book/models/akun.dart';
import 'package:laporan_book/models/laporan.dart';

class ListItem extends StatefulWidget {
  final Laporan laporan;
  final Akun akun;
  final bool isLaporanku;
  ListItem(
      {super.key,
      required this.laporan,
      required this.akun,
      required this.isLaporanku});

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  // fungsi delete
  final _firestore = FirebaseFirestore.instance;
   final _storage = FirebaseStorage.instance;

   void deleteLaporan() async {
     try {
       await _firestore.collection('laporan').doc(widget.laporan.docId).delete();

 // menghapus gambar dari storage
       if (widget.laporan.gambar != '') {
         await _storage.refFromURL(widget.laporan.gambar!).delete();
       }
       Navigator.popAndPushNamed(context, '/dashboard');
     } catch (e) {
       print(e);
     }
   }
  // build
  @override
    Widget build(BuildContext context) {
        print(widget.laporan.status);

      return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/detail', arguments: {
              'laporan': widget.laporan,
              'akun': widget.akun,
            });
          },
          onLongPress: () {
            if (widget.isLaporanku) {
              showDialog(
                  context: context,
                  builder: (BuildContext) {
                    return AlertDialog(
                      title: Text('Delete ${widget.laporan.judul}?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteLaporan();
                          },
                          child: Text('Hapus'),
                        ),
                      ],
                    );
                  });
            }
          },
          child: Column(
            children: [
              widget.laporan.gambar != ''
                  ? Image.network(
                      widget.laporan.gambar!,
                      width: 90,
                      height: 90,
                    )
                  : Image.asset(
                      'assets/istock-default.jpg',
                      width: 90,
                      height: 90,
                    ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 0),
                decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(width: 2))),
                child: Text(
                  widget.laporan.judul,
                  style: headerStyle(level: 4),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: warningColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                          ),
                          border: const Border.symmetric(
                              vertical: BorderSide(width: 1))),
                      alignment: Alignment.center,
                      child: Text(
                        widget.laporan.status,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(5)),
                          border: const Border.symmetric(
                              vertical: BorderSide(width: 1))),
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(widget.laporan.tanggal),
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      );
    }
}