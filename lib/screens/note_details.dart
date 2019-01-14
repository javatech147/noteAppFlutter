import 'package:flutter/material.dart';
import 'package:flutter_note_app/models/note.dart';
import 'package:flutter_note_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetails(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.note, this.appBarTitle);
  }
}

class NoteDetailsState extends State<NoteDetails> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper databaseHelper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailsState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        // Handle code when user press device back button
        // This method is similar to onBackPress()
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }),
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: ListView(
            children: <Widget>[
              // First element - Drop down button
              ListTile(
                title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint("user selected $valueSelectedByUser");
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    }),
              ),

              // Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('title TextField changed');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('description TextField changed');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),

              // Fourth Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                _save();
                                debugPrint('Save button clicked');
                              });
                            })),

                    Container(
                      width: 5.0,
                    ),

                    // Second element of Row
                    Expanded(
                        child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint('Delete button clicked');
                                _delete();
                              });
                            })),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;

      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;

      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object as entered by user.
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object as entered by user.
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save to database.
  void _save() async {
    moveToLastScreen();
    int result;

    var currentDateTime = DateTime.now();
    debugPrint("Current Date and Time : $currentDateTime");
    note.date = DateFormat.yMMMd().format(currentDateTime);

    if (note.id != null) {
      // Update Note
      result = await databaseHelper.updateNote(note);
    } else {
      // Insert Note
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Some error occurs while saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1 - User is trying to delete new note. i.e. user has come to this
    // page by clicking on FAB icon for Add Note.

    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2 - User is trying to delete old note that is already has a valid ID.
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error occurs while deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }
}
