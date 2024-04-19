
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

class Clubs extends StatefulWidget {
  const Clubs({super.key});

  @override
  State<Clubs> createState() => _ClubsState();
}

class _ClubsState extends State<Clubs> {
  CollectionReference clubs = FirebaseFirestore.instance.collection('users');
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Searchbar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).p8(),
            StreamBuilder<QuerySnapshot>(
              stream: clubs.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return 'Something went wrong'.text.make();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator().centered();
                }

                // Filter data based on search query
                final filteredDocs = snapshot.data!.docs.where((document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  final clubName = data['club_name'].toString().toLowerCase();
                  final searchTerm = _searchController.text.toLowerCase();
                  return clubName.contains(searchTerm);
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    return data['role'] == 'club'
                        ? SizedBox(
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.toNamed('/club_data', arguments: {
                                      'data': data,
                                      'document': snapshot.data!.docs[index].id,
                                    });
                                  },
                                  child: ListTile(
                                    tileColor: Vx.hexToColor('#042745'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    leading:
                                        Icon(Icons.people, color: Colors.white),
                                    title: data['club_name']
                                        .toString()
                                        .text
                                        .white
                                        .make(),
                                    trailing: data['profile'] != null &&
                                            data['profile'] != ''
                                        ? Image.network(
                                            data['profile'].toString(),
                                            height: 50,
                                            width: 50,
                                          )
                                        : Image.network(
                                            'https://www.pngkey.com/png/full/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png',
                                            height: 50,
                                            width: 50,
                                          ),
                                  ).p4(),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ).p8(),
      ),
    );
  }
}
