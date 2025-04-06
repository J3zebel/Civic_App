import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestUpdatePage extends StatefulWidget {
  final int requestId; // Added requestId parameter

  const RequestUpdatePage({super.key, required this.requestId});

  @override
  State<RequestUpdatePage> createState() => _RequestUpdatePageState();
}

class _RequestUpdatePageState extends State<RequestUpdatePage> {
  final supabase = Supabase.instance.client;
  int requestStatus = 0; // Default status

  @override
  void initState() {
    super.initState();
    fetchRequestStatus();
  }

  // Fetch request status from Supabase
  Future<void> fetchRequestStatus() async {
    final response = await supabase
        .from('User_tbl_request')
        .select('request_status')
        .eq('id', widget.requestId)
        .maybeSingle();

    if (response != null && response.containsKey('request_status')) {
      setState(() {
        requestStatus = response['request_status'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final updates = [
      "Request submitted",
      "Request acknowledged",
      "Processing request",
      "Resolution proposed",
      "Request completed",
    ];

    double completionPercentage = (requestStatus / (updates.length - 1)) * 100;
    completionPercentage = completionPercentage.clamp(0, 100);

    String currentDate = DateFormat('MMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: CustomAppBar(
          completionPercentage: completionPercentage,
          currentDate: currentDate,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('hh:mm a').format(DateTime.now()),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(updates.length, (index) {
                return _TimelineUpdateItem(
                  updateText: updates[index],
                  isHighlighted: index <= requestStatus,
                  isFirst: index == 0,
                  isLast: index == updates.length - 1,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineUpdateItem extends StatelessWidget {
  final String updateText;
  final bool isHighlighted;
  final bool isFirst;
  final bool isLast;

  const _TimelineUpdateItem({
    required this.updateText,
    required this.isHighlighted,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isHighlighted
                    ? const Color.fromARGB(255, 12, 101, 175)
                    : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            if (!isLast)
              Container(
                height: 30,
                width: 2,
                color: isHighlighted
                    ? const Color.fromARGB(255, 12, 101, 175)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color.fromARGB(255, 12, 101, 175)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              updateText,
              style: TextStyle(
                fontSize: 14,
                color: isHighlighted ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final double completionPercentage;
  final String currentDate;

  const CustomAppBar({
    super.key,
    required this.completionPercentage,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 12, 101, 175),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                const Text(
                  "Request Updates",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: completionPercentage,
                            color: Colors.white,
                            radius: 30,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 - completionPercentage,
                            color: Colors.blue.shade700,
                            radius: 30,
                            showTitle: false,
                          ),
                        ],
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${completionPercentage.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Task Completed",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      currentDate,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
