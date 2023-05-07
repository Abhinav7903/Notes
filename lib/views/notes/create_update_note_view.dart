import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:notes/utilities/Dialog/cannot_share_empty_note_dialog.dart';
import 'package:notes/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  final _focusNode = FocusNode();

  @override
  void initState (){
    _notesService=FirebaseCloudStorage();
    _textController=TextEditingController();
    _focusNode.requestFocus();
    super.initState();
  }

void _textControllerListener() async{
    final note=_note;
    if(note==null){
      return;
    }
    final text=_textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text,);
}

void _setupTextControllerListener(){
    _textController.removeListener((_textControllerListener) );
    _textController.addListener((_textControllerListener));
}

  Future<CloudNote?>createOrGetExistingNote(BuildContext context) async{
    final widgetNote=context.getArgument<CloudNote>();

    if(widgetNote!=null){
      _note=widgetNote;
      _textController.text=widgetNote.text;
      return widgetNote;
    }

    final existingNote=_note;
    if(existingNote!=null){
      return existingNote;
    }

    final currentUser=AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    var newNote=await _notesService.createNewNote(ownerUserId: userId);
    _note=newNote;
    return newNote;


  }

  void _deleteNoteIfTextIsEmpty(){
    final note=_note;
    if(_textController.text.isEmpty && note!=null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty()async{
    final note=_note;
    final text=_textController.text;
    if(note!=null && text.isNotEmpty){
      await _notesService.updateNote(
          documentId: note.documentId,
          text: text,
      );
    }
  }
  @override
  void dispose(){
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    _focusNode.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(

        title:  const Text('New note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      actions: [
        IconButton(onPressed: ()async{
          final text=_textController.text;
          if(_note == null || text.isEmpty){
            await showCannotShareEmptyNoteDialog(context);
          }
          else{
            Share.share(text);
          }
        }, icon: const Icon(Icons.share_sharp))
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context,snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.done:

                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Start typing',
                    labelText: 'Enter your text',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textController.clear();
                      },
                    ),
                  ),
                  focusNode: _focusNode,
                );


              default:
                return const CircularProgressIndicator();
            }
          }

        ),
      ),
    );
  }
}
// 1:00:29
