import 'package:digikam/statistic/month_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';

class StatisticMonthDialog extends StatefulWidget {
  const StatisticMonthDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StatisticMonthState();
  }
}

class _StatisticMonthState extends State<StatisticMonthDialog> {
  late MonthStatisticBloc bloc;
  late MonthStatistic stat;

  @override
  void initState() {
    super.initState();
    bloc = MonthStatisticBloc();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MonthStatisticBloc>(
        create: (context) => bloc,
        child: BlocConsumer<MonthStatisticBloc, MonthStatisticState>(
            listener: (context, state) {
          if (state is MonthStatisticDataState) {
            stat = state.stat;
          } else if (state is MonthStatisticNoDataState) {
            SnackBar snackBar = const SnackBar(
                content: Text('Es wurden keine Daten gefunden.'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state is MonthStatisticErrorState) {
            SnackBar snackBar = SnackBar(
                content: Text('Es ist ein Fehler aufgetreten: ${state.msg}'));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (state is MonthStatisticInitializedState) {
            bloc.add(MonthStatisticStartedEvent());
          }
        }, builder: (context, state) {
          if (state is MonthStatisticDataState) {
            return resultList(context, state.stat);
          } else {
            context
                .read<MonthStatisticBloc>()
                .add(MonthStatisticStartedEvent());
            return processingIndicator();
          }
        }));
  }

  Widget resultList(BuildContext context, MonthStatistic stat) {
    List<ListItem> items = [];
    for (StatisticMonth item in stat.list) {
      if (item.month! == 0) {
        items.add(YearItem(count: item.cnt!, year: item.year!));
      } else {
        items.add(MonthItem(
            month: item.month!,
            year: item.year!,
            count: item.cnt!,
            maxCount: stat.maxCount));
      }
    }
    items.add(CloseItem());

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return item.buildItem(context);
          }),
    );
  }

  Widget processingIndicator() {
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: CircularProgressIndicator());
  }
}

abstract class ListItem {
  final double spacing = 30.0;

  Widget buildItem(BuildContext context);

  Widget _text(BuildContext context, String value) {
    return Text(
      value,
      style: Theme.of(context).textTheme.labelMedium,
    );
  }
}

class MonthItem extends ListItem {
  final int month;
  final int year;
  final int count;
  final int maxCount;

  MonthItem(
      {required this.month,
      required this.year,
      required this.count,
      required this.maxCount});

  @override
  Widget buildItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: spacing,
          children: [
            _text(context, '${month.toString().padLeft(2, '0')}.$year'),
            _text(context, '$count'),
          ],
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width -8) * count / maxCount,
          height: 5,
          child: const DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.blue
            ),
          ),
        ),
      ],
    );
  }
}

class YearItem extends ListItem {
  final int year;
  final int count;

  YearItem({required this.count, required this.year});

  @override
  Widget buildItem(BuildContext context) {
    return Wrap(
      spacing: spacing + 18,
      children: [
        _text(context, '$year'),
        _text(context, '$count'),
      ],
    );
  }
}

class CloseItem extends ListItem {
  @override
  Widget buildItem(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: _text(context, 'Close'),
    );
  }
}
