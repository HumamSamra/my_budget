import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_budget/main.dart';
import 'package:my_budget/pages/transact.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class ChartData {
  ChartData(this.title, this.x, this.y);
  final String title;
  final String x;
  final double y;
}

enum SortType {
  newFirst,
  oldFirst,
  highToLow,
  lowToHigh,
  spentOnly,
  receivedOnly
}

class _HomepageState extends State<Homepage> {
  final box = Hive.box(boxName);
  List<dynamic> transactions = [];
  double totalBalance = 0.0;
  SortType sort = SortType.newFirst;

  List<ChartData> chartData = [
    ChartData(DateFormat('MMM').format(DateTime.now()), '', 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Transact(
                                      isAdd: false,
                                    ),
                                  ));
                              getData();
                            },
                            icon: const Icon(Icons.remove)),
                        const Spacer(),
                        Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Text(
                              "Balance",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                            Text(
                              "\$${totalBalance.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: totalBalance < 0
                                      ? Theme.of(context).colorScheme.error
                                      : null),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Transact(
                                      isAdd: true,
                                    ),
                                  ));
                              getData();
                            },
                            icon: const Icon(Icons.add)),
                      ],
                    ),
                  ),
                  SfCircularChart(series: <CircularSeries>[
                    DoughnutSeries<ChartData, String>(
                        animationDuration: 500,
                        dataSource: chartData,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        dataLabelMapper: (datum, index) => datum.title,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y)
                  ]),
                  StatefulBuilder(builder: (context, setState) {
                    String time = '';
                    updateTime() {
                      setState(() {
                        time = DateFormat('yyyy MMM dd, HH:mm:ss a')
                            .format(DateTime.now());
                      });
                    }

                    updateTime();

                    Future.delayed(const Duration(seconds: 1), updateTime);

                    return Text(
                      time,
                      style: const TextStyle(fontSize: 15),
                    );
                  })
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                    maxChildSize: 1,
                    minChildSize: 0.4,
                    initialChildSize: 0.4,
                    snap: true,
                    expand: false,
                    snapSizes: const [0.4, 0.8, 1],
                    builder: (context, scrollController) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30)),
                        child: Scaffold(
                          backgroundColor:
                              Theme.of(context).colorScheme.outlineVariant,
                          body: Column(
                            children: [
                              Column(
                                children: [
                                  // Title
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 15, top: 20),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Transactions",
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                        ),
                                        const Spacer(),
                                        DropdownButton(
                                            value: sort,
                                            items: const [
                                              DropdownMenuItem(
                                                  value: SortType.newFirst,
                                                  child: Text("Newest First")),
                                              DropdownMenuItem(
                                                value: SortType.oldFirst,
                                                child: Text("Oldest First"),
                                              ),
                                              DropdownMenuItem(
                                                value: SortType.highToLow,
                                                child: Text("High to low"),
                                              ),
                                              DropdownMenuItem(
                                                value: SortType.lowToHigh,
                                                child: Text("Low to high"),
                                              ),
                                              DropdownMenuItem(
                                                value: SortType.spentOnly,
                                                child: Text("Spent only"),
                                              ),
                                              DropdownMenuItem(
                                                value: SortType.receivedOnly,
                                                child: Text("Received only"),
                                              )
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                sort = value as SortType;
                                              });
                                              getData();
                                            })
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (transactions.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "No Transactions yet...",
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 15),
                                  ),
                                ),

                              // List Items
                              ValueListenableBuilder(
                                valueListenable: box.listenable(),
                                builder: (context, hiveBox, _) => Expanded(
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    controller: scrollController,
                                    itemCount: transactions.length,
                                    itemBuilder: (context, index) {
                                      final item = transactions[index];
                                      bool isPositive =
                                          item['type'] == "Received";
                                      return Slidable(
                                          key: UniqueKey(),
                                          startActionPane: ActionPane(
                                            extentRatio: 0.3,
                                            motion: const ScrollMotion(),
                                            dismissible: DismissiblePane(
                                              onDismissed: () {
                                                delete(item['key']);
                                                setState(() {});
                                              },
                                            ),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {},
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .errorContainer,
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onBackground,
                                                icon: Icons.delete_outline,
                                                label: 'Delete',
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            onTap: () {},
                                            leading: Icon(
                                              isPositive
                                                  ? Icons.trending_up_rounded
                                                  : Icons.trending_down_rounded,
                                              size: 50,
                                              color: isPositive
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                            ),
                                            title: Text(item['type']),
                                            subtitle: Text(
                                                DateFormat('yy MMM dd, hh:mma')
                                                    .format(item['date'])),
                                            trailing: Text(
                                              "${isPositive ? '+' : '-'}\$${item['amount']}",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: isPositive
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                              ),
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() {
    Map<String, int> months = {};
    totalBalance = 0;
    transactions = [];

    // Fill the list
    for (var i = 0; i < box.length; i++) {
      dynamic value = box.getAt(i);
      value['key'] = box.keyAt(i);
      transactions.add(value);
    }

    for (final item in transactions) {
      if (item['type'] == 'Spent') {
        totalBalance -= double.parse(item['amount']);
      } else {
        totalBalance += double.parse(item['amount']);
      }
      if ((item['date'] as DateTime).year == DateTime.now().year) {
        final month = DateFormat('MMM').format(item['date']);
        months[month] = (months[month] ?? 0) + 1;
      }
    }

    chartData = [];
    if (months.keys.isNotEmpty) {
      for (final month in months.keys) {
        chartData.add(ChartData(month, '', months[month]!.toDouble()));
      }
    } else {
      chartData.add(ChartData('Empty', '', 1));
    }

    switch (sort) {
      case SortType.highToLow:
        {
          transactions.sort((a, b) => b['amount'].compareTo(a['amount']));
        }
        break;
      case SortType.lowToHigh:
        {
          transactions.sort((a, b) => a['amount'].compareTo(b['amount']));
        }
        break;
      case SortType.oldFirst:
        {
          transactions
              .sort((a, b) => (a['date'] as DateTime).compareTo(b['date']));
        }
        break;
      case SortType.spentOnly:
        {
          transactions = transactions
              .where((element) => element['type'] == 'Spent')
              .toList();
        }
        break;
      case SortType.receivedOnly:
        {
          transactions = transactions
              .where((element) => element['type'] == 'Received')
              .toList();
        }
        break;
      default:
        {
          transactions
              .sort((a, b) => (b['date'] as DateTime).compareTo(a['date']));
        }
        break;
    }

    setState(() {});
  }

  delete(dynamic key) {
    box.delete(key);
    getData();
  }
}
