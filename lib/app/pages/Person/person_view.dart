import 'dart:async';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:swipedetector/swipedetector.dart';

class PersonDetailsPage extends StatelessWidget {
  ScreenArguments args;
  Person initialP;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    final String userListId = args.idUserList;
    initialP = args.person;

    var elementToRender;
    return MultiBlocProvider(
        providers: [
          BlocProvider<PersonBloc>(
            create: (context) {
              return PersonBloc(
                personRepository: DataPersonRepository(),
              )..add(LoadUserListPersons(userListId));
            },
          )
        ],
        child: BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
          if (state is PersonLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserListPersonLoaded) {
            //Check the size of the person list and manage exceptions
            if (state.person.isEmpty) {
              elementToRender = Center(
                  child: Text(
                      AppLocalizations.of(context).translate('learn_emptyList'),
                      style: TextStyle(fontSize: 20)));
            } else {
              List<Person> personsList = state.person;
              personsList.sort((Person a,Person b) => a.lastname.toLowerCase().compareTo(b.lastname.toLowerCase()));
              elementToRender = DetailsPage(
                  persons: personsList,
                  userListId : userListId,
                  initialPerson : initialP); //Quiz(person: state.person);
            }
            return  elementToRender;
          } else {
            return Text(AppLocalizations.of(context).translate('learn_error'),
                style: TextStyle(fontSize: 20));
          }
        }));
  }
}

class DetailsPage extends StatefulWidget {
  final List<Person> persons;
  final String userListId;
  final Person initialPerson;

  const DetailsPage({Key key, @required this.persons, this.userListId,this.initialPerson})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  TextEditingController nameController = new TextEditingController();
  Image _image;
  String idUserList;
  Person person;
  bool activeBtn = true;
  bool showAnswer = false;
  final TextStyle _personstyle = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white);

  int _currentIndex;
  final Map<int, dynamic> _answers = {};
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @protected
  void initState() {
    super.initState();
    _currentIndex = widget.persons.indexWhere((element) => element.id == widget.initialPerson.id);
  }

  deleteDialog(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('This person will be deleted'),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () => {
                  Navigator.of(context).pop(false),
                }),
            FlatButton(
              child: Text('Ok'),
              onPressed: () => {
                // Pop the dialog
                Navigator.of(context).pop(true),
                // Pop the page
                Navigator.of(context).pop(true),
                // Delete the person
                BlocProvider.of<PersonBloc>(context)
                    .add(DeletePerson(widget.persons[_currentIndex], idUserList))
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    print("PERSONS : ${widget.persons}");
    print("INDEXXXXXXX ACTUAL BORDEL : ${_currentIndex}");
    person = widget.persons[_currentIndex];
    idUserList = widget.userListId;
    _image = Image.network(person.image_url);
    return SwipeDetector(
        onSwipeLeft: () {
          setState(() {
            print("LEFTTTTTT      ACTUAL INDEX : ${_currentIndex} and MAX INDEX : ${widget.persons.length}");
            if(_currentIndex<widget.persons.length-1){
              _currentIndex++;
            }else{
              _currentIndex=0;
            }

          });
        },
        onSwipeRight:() {
          setState(() {
            print("RIGGHHHHHTT     ACTUAL INDEX : ${_currentIndex} and MAX INDEX : ${widget.persons.length}");
            if(_currentIndex>0){
              _currentIndex--;
            }else{
              _currentIndex=widget.persons.length-1;
            }
          });
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text(widget.persons[_currentIndex].firstname + " " + widget.persons[_currentIndex].lastname,
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: _image == null
                          ? Text('Error, could not load image or a problem occured.')
                          : Container(
                        child: ExtendedImage.network(widget.persons[_currentIndex].image_url,
                            fit: BoxFit.fill),
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            alignment: Alignment.center,
                            width: halfMediaWidth,
                            child: MyText(
                              label: 'First name',
                              text: widget.persons[_currentIndex].firstname,
                            )),
                        Container(
                          // padding: EdgeInsets.all(16.0),
                            alignment: Alignment.center,
                            width: halfMediaWidth,
                            child: MyText(
                              label: 'Last name',
                              text: widget.persons[_currentIndex].lastname,
                            )),
                      ],
                    ),
                  ),
                  Container(
                    // padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      // width: halfMediaWidth,
                      child: MyText(
                        label: 'Job',
                        text: widget.persons[_currentIndex].job,
                      )),

                  Container(
                      padding: EdgeInsets.fromLTRB(55, 16, 55, 16),
                      alignment: Alignment.center,
                      child: MyText(
                        label: 'Description',
                        text: widget.persons[_currentIndex].description,
                      )),
                  SizedBox(height: 30.0),
                  Container(
                    margin: EdgeInsets.only(right: 20,top: 10),
                    child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.blueAccent,
                        heroTag: null,
                        onPressed: () => Navigator.pushNamed(
                            context, '/personForm',
                            arguments: new ScreenArguments(widget.persons[_currentIndex], idUserList)),
                        child: Icon(Icons.edit)),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 20,top: 10),
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      heroTag: null,
                      onPressed: () => deleteDialog(context),
                      child: Icon(Icons.delete),
                    ),
                  ),

                ],
              ),
            ),
          ),
        )
    );
  }
}

class MyText extends StatelessWidget {
  final String text;
  final String label;

  MyText({this.text, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(5.0),
        // child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: (label),
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: TextStyle(
              fontSize: 15.0,
              // fontFamily: 'Open Sans',
              color: Colors.black,
            ),

            children: <TextSpan>[
              TextSpan(
                  text: '\n$text',
                  style:
                  TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0)),
            ],
          ),
        ));
  }
}
