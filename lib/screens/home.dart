import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:weight_tracker/models/app_state.dart';
import 'package:weight_tracker/models/record.dart';
import 'package:date_format/date_format.dart';

class HomeScreen extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (BuildContext context) => HomeScreen(),
    );
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppState>(
      builder: (BuildContext context, Widget child, AppState appState) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Weight Tracker'),
          ),
          body: StreamBuilder<List<WeightRecord>>(
            stream: getAllWeights(appState.uid),
            builder: (BuildContext context, AsyncSnapshot<List<WeightRecord>> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final record = snapshot.data[index];
                    return ListTile(
                      title: Text(record.date.toString()),
                      subtitle: Text('${record.weightStone}st ${record.weightPounds}lbs'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _onEditPressed(record),
                      ),
                    );
                  },
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _onAddPressed,
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _onAddPressed() {
    return _onEditPressed();
  }

  Future<void> _onEditPressed([WeightRecord record]) async {
    final weight = await showDialog<WeightRecord>(
      context: context,
      builder: (context) => WeightTrackDialog(
            record: record,
          ),
    );
    if (weight != null) {
      final appState = ScopedModel.of<AppState>(context);
      await weight.save(appState.uid); // TODO: show save progress and wait?
    }
  }
}

class WeightTrackDialog extends StatefulWidget {
  final WeightRecord record;

  const WeightTrackDialog({
    Key key,
    this.record,
  }) : super(key: key);

  @override
  _WeightTrackDialogState createState() => _WeightTrackDialogState();
}

class _WeightTrackDialogState extends State<WeightTrackDialog> {
  final _date = ValueNotifier<DateTime>(DateTime.now());
  final _weightStones = TextEditingController();
  final _weightPounds = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _date.value = widget.record.date;
      _weightStones.text = widget.record.weightStone.toString();
      _weightPounds.text = widget.record.weightPounds.toString();
      _notes.text = widget.record.notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Track Weight'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Weight',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _weightStones,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              Text('St'),
              Expanded(
                child: TextField(
                  controller: _weightPounds,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    WhitelistingTextInputFormatter(RegExp(r'[\d\.]+')),
                  ],
                ),
              ),
              Text('Lb'),
            ],
          ),
          Material(
            child: InkWell(
              onTap: _onDatePressed,
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _date,
                        builder: (BuildContext context, value, Widget child) {
                          return Text(
                            _date.value.toString(),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextField(
            controller: _notes,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Notes (optional)',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: _onCancel,
          child: Text('CANCEL'),
        ),
        FlatButton(
          onPressed: _onSave,
          child: Text('SAVE'),
        ),
      ],
    );
  }

  Future<void> _onDatePressed() async {
    final now = DateTime.now();
    DateTime choice = await showDatePicker(
      context: context,
      initialDate: _date.value,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now,
    );
    if (choice != null) {
      _date.value = choice;
    }
  }

  void _onCancel() {
    Navigator.of(context).pop(null);
  }

  void _onSave() {
    final weightStone = _weightStones.value.text;
    final weightPounds = _weightPounds.value.text;
    final WeightRecord record = widget.record ?? WeightRecord();
    record.date = _date.value;
    record.weightStone = weightStone.isNotEmpty ? int.parse(weightStone) : 0;
    record.weightPounds = weightPounds.isNotEmpty ? double.parse(weightPounds) : 0.0;
    record.notes = _notes.value.text;
    Navigator.of(context).pop(record);
  }
}
