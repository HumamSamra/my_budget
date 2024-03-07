import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_budget/main.dart';
import 'package:wheel_chooser/wheel_chooser.dart';

class Transact extends StatefulWidget {
  final bool isAdd;
  const Transact({super.key, this.isAdd = false});

  @override
  State<Transact> createState() => _TransactState();
}

class _TransactState extends State<Transact> {
  final box = Hive.box(boxName);
  final textScrollController = ScrollController();

  DateTime dateTime = DateTime.now();

  String type = '';
  String value = '0.00';
  String time = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 30,
                      )),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final datePicked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now());
                      if (mounted && datePicked != null) {
                        final timePicked = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());

                        if (timePicked != null) {
                          setState(() {
                            dateTime = DateTime(
                              datePicked.year,
                              datePicked.month,
                              datePicked.day,
                              timePicked.hour,
                              timePicked.minute,
                            );

                            time = DateFormat('yy mmm dd, hh:MMa')
                                .format(dateTime);
                          });
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        backgroundColor:
                            Theme.of(context).colorScheme.outlineVariant),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.date_range_rounded,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            time,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            const Spacer(),
            Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.attach_money_rounded,
                  size: 55,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: textScrollController,
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 55,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 100,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: WheelChooser(
                onValueChanged: (s) {
                  type = s;
                },
                isInfinite: true,
                startPosition: widget.isAdd ? 1 : 0,
                datas: const ["Spent", "Received"],
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Container(
                padding: const EdgeInsets.only(bottom: 10, top: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              updateValue('1');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20)),
                            child: Text(
                              "1",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('2');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "2",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('3');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "3",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              updateValue('4');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "4",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('5');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "5",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('6');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "6",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              updateValue('7');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "7",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('8');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "8",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('9');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Text(
                              "9",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                            onPressed: () {
                              updateValue('-');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10)),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 30,
                              color: Theme.of(context).colorScheme.onBackground,
                            )),
                        TextButton(
                            onPressed: () {
                              updateValue('0');
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10)),
                            child: Text(
                              "0",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                        TextButton(
                            onPressed: (value.contains('.'))
                                ? null
                                : () {
                                    updateValue('.');
                                  },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10)),
                            child: Text(
                              ".",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                            )),
                      ],
                    ),
                    Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: FilledButton(
                          onPressed: () {
                            add();
                          },
                          style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: const Text("Add Transaction"),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    type = widget.isAdd ? "Received" : "Spent";
  }

  add() {
    if (value.isNotEmpty && double.parse(value) > 0) {
      box.add({
        "amount": double.parse(value).toStringAsFixed(2),
        "type": type,
        "date": dateTime
      });
    }
    Navigator.pop(context);
  }

  updateValue(String number) {
    setState(() {
      if (number == '-') {
        if (value != '0.00') {
          value = value.substring(0, value.length - 1);
        }
      } else {
        if (value == '0.00') {
          value = number;
        } else {
          value += number;
        }
      }

      if (value.isEmpty) {
        value = '0.00';
      }
    });

    textScrollController.jumpTo(textScrollController.position.maxScrollExtent);
  }
}
