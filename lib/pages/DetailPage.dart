import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laporan_book/components/status_dialog.dart';
import 'package:intl/intl.dart';
import 'package:laporan_book/components/styles.dart';
import 'package:laporan_book/models/akun.dart';
import 'package:laporan_book/models/laporan.dart';
import 'package:laporan_book/models/like.dart';
  import 'package:url_launcher/url_launcher.dart';

  class DetailPage extends StatefulWidget {
    DetailPage({super.key});
    @override
    State<StatefulWidget> createState() => _DetailPageState();
  }

  class _DetailPageState extends State<DetailPage> {
    final _firestore = FirebaseFirestore.instance;
    final _auth = FirebaseAuth.instance;
    bool _isLoading = false;
    bool isLiked = false;
    List<like> listlike = [];
    String? status;

    void addTransaksi(Akun akun) async {
    setState(() {
      _isLoading = true;
    });
    try {
      CollectionReference laporanCollection = _firestore.collection('like');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());


      final id = laporanCollection.doc().id;

      await laporanCollection.doc(id).set({
        'uid': _auth.currentUser!.uid,
        'docId': id,
        'nama': akun.nama,
        'tanggal': timestamp,
        'Liked': 1,
      }).catchError((e) {
        throw e;
      });
      Navigator.popAndPushNamed(context, '/dashboard');
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
    // Fungsi untuk menangani tombol like
  void handleLikeButton(Akun akun, Laporan laporan) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('like')
          .where('uid', isEqualTo: _auth.currentUser!.uid)
          .limit(1) // kondisi untuk menccari laporan yang sesuai dengan akun yang telah login
          .get();
          for (var documents in querySnapshot.docs) {
          final String likedNama = documents.data()['nama'];
          final likedValue = documents.data()['liked'];
          final likeddoc = documents.data()['docId'];

          if (likedNama != null && likedValue != null) {
              // Tambahkan data ke listlike
              listlike.add(
                like(
                  uid: documents.data()['uid'],
                  docId: likeddoc,
                  nama: likedNama,
                  liked: likedValue,
                  tanggal: documents['tanggal'].toDate(),
                ),
              );

              // Cek apakah data like sesuai dengan kondisi yang diinginkan
              if (likedNama == akun.nama &&  likeddoc == laporan.docId) {
                setState(() {
                  isLiked = true;
                });
              }
            }
            
        }
    if (!isLiked) {
      CollectionReference laporanCollection = _firestore.collection('like');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());


      final id = laporanCollection.doc().id;

      await laporanCollection.doc(id).set({
        'uid': _auth.currentUser!.uid,
        'docId': laporan.docId,
        'nama': akun.nama,
        'tanggal': timestamp,
        'liked' : 1,
      }).catchError((e) {
        throw e;
      });
      // Kirim data user yang melakukan like dan timestamp
      // ...

      // Set state agar tombol like tidak bisa diklik lagi
      setState(() {
        isLiked = false;
      });
    }
   
  }

    Future launch(String uri) async {
      if (uri == '') return;
      if (!await launchUrl(Uri.parse(uri))) {
        throw Exception('Tidak dapat memanggil : $uri');
      }
    }

    void statusDialog(Laporan laporan) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatusDialog(
            laporan: laporan,
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      Laporan laporan = arguments['laporan'];
      Akun akun = arguments['akun'];

      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title:
              Text('Detail Laporan', style: headerStyle(level: 3, dark: false)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          laporan.judul,
                          style: headerStyle(level:3),
                        ),
                        if (akun.role == 'admin')
                          Container(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  status = laporan.status;
                                });
                                statusDialog(laporan);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Ubah Status'),
                            ),
                          ),
                        SizedBox(height: 15),
                        laporan.gambar != ''
                            ? Image.network(laporan.gambar!)
                            : Image.asset('assets/istock-default.jpg'),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            laporan.status == 'Posted'
                                ? textStatus(
                                    'Posted', Colors.yellow, Colors.black)
                                : laporan.status == 'Process'
                                    ? textStatus(
                                        'Process', Colors.green, Colors.white)
                                    : textStatus(
                                        'Done', Colors.blue, Colors.white),
                            textStatus(
                                laporan.instansi, Colors.white, Colors.black),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Visibility(
                          visible: isLiked = true,
                          child: IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : null,
                          ),
                          onPressed:() {handleLikeButton(akun,laporan);}
                        
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: const Center(child: Text('Nama Pelapor')),
                          subtitle: Center(
                            child: Text(laporan.nama),
                          ),
                          trailing: SizedBox(width: 45),
                        ),
                        ListTile(
                          leading: Icon(Icons.date_range),
                          title: Center(child: Text('Tanggal Laporan')),
                          subtitle: Center(
                              child: Text(DateFormat('dd MMMM yyyy')
                                  .format(laporan.tanggal))),
                          trailing: IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: () {
                              launch(laporan.maps);
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                        Text(
                          'Deskripsi Laporan',
                          style: headerStyle(level:3),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(laporan.deskripsi ?? ''),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
    }

    Container textStatus(String text, var bgcolor, var textcolor) {
      return Container(
        width: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: bgcolor,
            border: Border.all(width: 1, color: primaryColor),
            borderRadius: BorderRadius.circular(25)),
        child: Text(
          text,
          style: TextStyle(color: textcolor),
        ),
      );
    }
  }