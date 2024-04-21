import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:velocity_x/velocity_x.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _controllerCenter;
  File? _posterImage;
  TimeOfDay? eventStartTime;
  TimeOfDay? eventEndTime;
  String? eventParticipants;
  String? personInCharge;
  final List<String> _venues = [
    'Male campus lecture hall',
    'Female campus lecture hall',
    'Robotics lab',
    'Cyber security lab',
    'F015 Male campus library',
    'Prince turkey center female campus',
    'Prince turkey center male campus'
  ];
  String? selectedVenue;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  TextEditingController organizerNameController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController numberOfParticipantsController =
  TextEditingController();
  TextEditingController inChargeFullNameController = TextEditingController();
  TextEditingController inChargePmuIdController = TextEditingController();
  TextEditingController inChargeContactNumberController =
  TextEditingController();
  TextEditingController activityTypeController = TextEditingController();
  TextEditingController activityDescriptionController = TextEditingController();
  TextEditingController eventBudgetController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  ProgressDialog? _progressDialog;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference events = FirebaseFirestore.instance.collection('events');
  List<String> unavailableDates = [];

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Future<void> _getImage() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _posterImage = image != null ? File(image.path) : null;
    });
  }

  Future<String> UploadImage() async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('events/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = ref.putFile(_posterImage!);
    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  List<DateTime> getRangeWithoutWeekends(DateTime start, DateTime end) {
    List<DateTime> range = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      DateTime currentDate = start.add(Duration(days: i));
      if (currentDate.weekday != DateTime.friday &&
          currentDate.weekday != DateTime.saturday) {
        range.add(currentDate);
      }
    }

    return range;
  }

  Future<String> getRange() async {
    String result = '';
    if (_rangeStart != null && _rangeEnd != null) {
      List<DateTime> range = getRangeWithoutWeekends(_rangeStart!, _rangeEnd!);
      for (int i = 0; i < range.length; i++) {
        result += '${range[i].day}/${range[i].month}/${range[i].year}, ';
      }
    }
    return result;
  }

  void getDisableDates() async{
    QuerySnapshot querySnapshot = await events.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String dateRange = data['dateRange'];
      if(dateRange.isNotEmpty){
        dateRange = dateRange.substring(0, dateRange.length - 2);
        List<String> dates = dateRange.split(', ');
        for (int i = 0; i < dates.length; i++) {
          List<String> date = dates[i].split('/');
          // append unavailableDates
          setState(() {
            unavailableDates.add('${date[0]}/${date[1]}/${date[2]}');
          });
        }
      }
    }
  }

  void createEvent() async {
    if (_formKey.currentState!.validate()) {
      _progressDialog = ProgressDialog(context: context);
      _progressDialog!.show(max: 100, msg: 'Loading...');
      //check if any date from dateRange is in unavailableDates
      String dateRange = await getRange();
      List<String> dates = dateRange.split(', ');
      for (int i = 0; i < dates.length; i++) {
        if (unavailableDates.contains(dates[i])) {
          _progressDialog!.close();
          Get.snackbar('Error', 'Selected date is not available',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Vx.hexToColor('#FFA451'));
          return;
        }
      }

      String imageUrl = await UploadImage();

      events.add({
        'event_id': auth.currentUser!.uid,
        'organizerName': organizerNameController.text,
        'eventTitle': eventTitleController.text,
        'numberOfParticipants': numberOfParticipantsController.text,
        'eventParticipants': eventParticipants,
        'personInCharge': personInCharge,
        'inChargeFullName': inChargeFullNameController.text,
        'inChargePmuId': inChargePmuIdController.text,
        'inChargeContactNumber': inChargeContactNumberController.text,
        'activityType': activityTypeController.text,
        'activityDescription': activityDescriptionController.text,
        'eventBudget': eventBudgetController.text,
        'selectedVenue': selectedVenue,
        'eventStartTime': eventStartTime.toString(),
        'eventEndTime': eventEndTime.toString(),
        'location': locationController.text,
        'poster': imageUrl,
        'dateRange': dateRange,
        'status': 'pending',
        'reason': '',
        'timestamp': DateTime.now(),
      }).then((value) {
        _progressDialog!.close();
        Get.snackbar('Success', 'Event created successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Vx.hexToColor('#FFA451'));
      }).catchError((error) {
        _progressDialog!.close();
        Get.snackbar('Error', error.toString(),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Vx.hexToColor('#FFA451'));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
    getDisableDates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'Create Event'.text.white.make(),
        centerTitle: true,
        backgroundColor: Vx.hexToColor('#042745'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                'Event Information'.text.xl.bold.make(),
                TextFormField(
                  controller: organizerNameController,
                  decoration: InputDecoration(
                    labelText: 'Organizer Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the organizer name';
                    }
                    return null;
                  },
                ).p8(),
                //event title
                TextFormField(
                  controller: eventTitleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the event title';
                    }
                    return null;
                  },
                ).p8(),
                //number of participants
                TextFormField(
                  controller: numberOfParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Participants',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the number of participants';
                    }
                    return null;
                  },
                ).p8(),
                'Participants'.text.xl.make(),
                [
                  Expanded(
                    child: RadioListTile(
                      title: 'Male'.text.make(),
                      value: 'Male',
                      groupValue: eventParticipants,
                      onChanged: (value) {
                        setState(() {
                          eventParticipants = value.toString();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: 'Female'.text.make(),
                      value: 'Female',
                      groupValue: eventParticipants,
                      onChanged: (value) {
                        setState(() {
                          eventParticipants = value.toString();
                        });
                      },
                    ),
                  ),
                ].hStack(alignment: MainAxisAlignment.center),
                RadioListTile(
                  title: 'Both'.text.make(),
                  value: 'Both',
                  groupValue: eventParticipants,
                  onChanged: (value) {
                    setState(() {
                      eventParticipants = value.toString();
                    });
                  },
                ),
                Divider(
                  color: Vx.hexToColor('#FFA451'),
                ),
                'Person in-charge of event'.text.xl.make(),
                [
                  Expanded(
                    child: RadioListTile(
                      title: 'Student'.text.make(),
                      value: 'Student',
                      groupValue: personInCharge,
                      onChanged: (value) {
                        setState(() {
                          personInCharge = value.toString();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: 'Staff'.text.make(),
                      value: 'Staff',
                      groupValue: personInCharge,
                      onChanged: (value) {
                        setState(() {
                          personInCharge = value.toString();
                        });
                      },
                    ),
                  ),
                ].hStack(alignment: MainAxisAlignment.center),
                TextFormField(
                  controller: inChargeFullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the full name';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: inChargePmuIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'PMU ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the PMU ID';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: inChargeContactNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the contact number';
                    }
                    return null;
                  },
                ).p8(),
                Divider(
                  color: Vx.hexToColor('#FFA451'),
                ),
                'Activity Information'.text.xl.make(),
                TextFormField(
                  controller: activityTypeController,
                  decoration: InputDecoration(
                    labelText: 'Activity Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the activity type';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: activityDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Activity Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the activity description';
                    }
                    return null;
                  },
                ).p8(),
                TextFormField(
                  controller: eventBudgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Event Budget (SAR)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the event budget';
                    }
                    return null;
                  },
                ).p8(),
                Divider(
                  color: Vx.hexToColor('#FFA451'),
                ),
                DropdownButtonFormField(
                  value: selectedVenue,
                  items: _venues
                      .map(
                        (venue) => DropdownMenuItem(
                      value: venue,
                      child: venue.text.make(),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVenue = value.toString();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Venue',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select the venue';
                    }
                    return null;
                  },
                ).p8(),
                'Enter event start time'.text.xl.make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        print(picked);
                        if (picked != null &&
                            picked.hour >= 8 &&
                            picked.hour < 16) {
                          setState(() {
                            eventStartTime = picked;
                          });
                        } else {
                          Get.snackbar('Error',
                              'Please select a time between 8 AM and 4 PM',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Vx.hexToColor('#FFA451'));
                        }
                      },
                      child: 'Select Start Time'.text.make(),
                    ).p8(),
                    if (eventStartTime != null)
                      eventStartTime!.format(context).text.make().p8(),
                  ],
                ),
                'Enter event end time'.text.xl.make(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null &&
                            picked.hour >= 8 &&
                            picked.hour < 16) {
                          setState(() {
                            eventEndTime = picked;
                          });
                        } else {
                          Get.snackbar('Error',
                              'Please select a time between 8 AM and 4 PM',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Vx.hexToColor('#FFA451'));
                        }
                      },
                      child: 'Select End Time'.text.make(),
                    ).p8(),
                    if (eventEndTime != null)
                      eventEndTime!.format(context).text.make().p8(),
                  ],
                ),
                'Select Date'.text.xl.make(),
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2025, 1, 1),
                  focusedDay: _focusedDay,
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,

                  // Disable weekends
                  availableGestures: AvailableGestures.horizontalSwipe,
                  enabledDayPredicate: (day) {
                    return day.weekday != DateTime.friday &&
                        day.weekday != DateTime.saturday;
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    disabledDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    rangeHighlightColor: Colors.green.withOpacity(0.5),
                    rangeStartDecoration: BoxDecoration(
                      color: Colors.green,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: Colors.green,
                    ),
                  ),
                  onRangeSelected: (start, end, focusedDay) {
                    setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                      _focusedDay = focusedDay;
                    });
                  },
                ).p8(),
                [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  10.widthBox,
                  'Available'.text.make(),
                ].hStack(alignment: MainAxisAlignment.start),
                [
                  Container(
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  10.widthBox,
                  'Unavailable'.text.make(),
                ].hStack(alignment: MainAxisAlignment.start),
                Divider(
                  color: Vx.hexToColor('#FFA451'),
                ),
                'Poster File'.text.xl.make(),
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: _posterImage == null
                      ? ElevatedButton(
                    onPressed: () {
                      //pick image of the poster
                      _getImage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Vx.hexToColor('#F37022'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.upload_circle,
                            color: Color(0xFF042745),
                            size: 80,
                          ).centered().p8(),
                          'Upload Poster'.text.white.make(),
                        ],
                      ),
                    ),
                  )
                      : Image.file(_posterImage!),
                ).p8(),
                'Location'.text.xl.make(),
                Container(
                  width: double.infinity,
                  height: 200,
                  child: ElevatedButton(

                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Vx.hexToColor('#F37022'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          color: Color(0xFF042745),
                          size: 80,
                        ).p8(),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: 'Write down your location',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your location';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ).p8(),
                //submit
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ConfettiWidget(
                        confettiController: _controllerCenter,
                        blastDirectionality: BlastDirectionality.explosive,
                        // don't specify a direction, blast randomly
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink,
                          Colors.orange,
                          Colors.purple
                        ],
                        // manually specify the colors to be used
                        createParticlePath:
                        drawStar, // define a custom shape/path.
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _controllerCenter.play();
                          createEvent();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Vx.hexToColor('#F36F23'),
                        ),
                        child: 'Send Event Request'.text.white.make(),
                      ).p8(),
                    ),
                  ],
                ),
              ],
            ).p8(),
          ),
        ),
      ),
    );
  }
}