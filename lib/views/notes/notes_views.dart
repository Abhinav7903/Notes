import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:notes/utilities/Dialog/delete_dialog.dart';
import 'package:notes/utilities/Dialog/logout_dialog.dart';


import '../../constants/routes.dart';
import '../../enum/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes  "),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // ignore: use_build_context_synchronously
                    context.read<AuthBloc>().add(const AuthEventLogOut());

                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Logout"),
                ),
              ];
            },
          )
        ],
      ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return GridView.builder(
                    itemCount: allNotes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final note = allNotes.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(15.0),
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.white // Light mode color
                              : Colors.black26,
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    arguments: note,
                                    createUpdateNoteRoute,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          note.text.length > 25 ? '${note.text.substring(0, 25)}...' : note.text,
                                          style:  TextStyle(fontSize: 18.0, color: Theme.of(context).brightness == Brightness.light
                                              ? Colors.black // Light mode color
                                              : Colors.white,) ,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? Colors.black // Light mode color
                                      : Colors.white,
                                  onPressed: () async {
                                    final del=await showDeleteDialog(context);
                                    if(del) {
                                      await _notesService.deleteNote(
                                          documentId: note.documentId);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                } else {
                  return const Center(child: CircularProgressIndicator());
                }

              default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      )
    );
  }
}
//1:03:40:44