import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lcpl_admin/provider/upload_provider.dart';
import 'package:lcpl_admin/screens/postscreens/updage_files.dart';
import 'package:lcpl_admin/theme/theme.dart';
import 'package:lcpl_admin/utils/utils.dart';
import 'package:provider/provider.dart';

class AudioTab extends StatefulWidget {
  const AudioTab({super.key});

  @override
  State<AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<AudioTab> {
  final fireStore = FirebaseFirestore.instance.collection('audio').snapshots();

  CollectionReference urlRef = FirebaseFirestore.instance.collection('audio');
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: fireStore,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2.6),
                child: Center(
                    child: Text(
                  'No data available',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontWeight: FontWeight.normal),
                )),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2.6),
                child: const Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2.6),
                child: Center(
                  child: Text(
                    'No data available',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        Utils.urlLauncher(data['url']);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.greyColor),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['title'],
                              style: const TextStyle(fontSize: 20),
                            ),
                           Consumer<UploadProvider>(
                                builder: (context, value, child) {
                              return PopupMenuButton(
                                color: Colors.white,
                                elevation: 4,
                                padding: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2))),
                                icon: const Icon(
                                  Icons.more_vert,
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: ListTile(
                                      onTap: () {      Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UpdateFile(
                                                  appBartitle: 'Update Quotes',
                                                  collection: 'quotes',
                                                  fileType: FileType.any),
                                            ),
                                          );
                                   },
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Edit'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: ListTile(
                                      onTap: () {
                                        value
                                            .deleteFileAndData(
                                                docId: document.id,
                                                collectionPath: 'document',
                                                url: data['url'])
                                            .then((value) {
                                          Navigator.pop(context);
                                        },);
                                      },
                                      leading: const Icon(Icons.delete_outline),
                                      title: const Text('Delete'),
                                    ),
                                  ),
                                ],
                              );
                            },),    ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        )
      ],
    );
  }
}
