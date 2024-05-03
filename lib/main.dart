import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID-19 Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CovidTrackerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CovidTrackerPage extends StatefulWidget {
  @override
  _CovidTrackerPageState createState() => _CovidTrackerPageState();
}

class _CovidTrackerPageState extends State<CovidTrackerPage> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
        Uri.parse('https://data.covid19india.org/state_district_wise.json'));

    if (response.statusCode == 200) {
      setState(() {
        final jsonData = json.decode(response.body);
        // Filter out State Unassigned data
        _data = Map.fromEntries(
            jsonData.entries.where((entry) => entry.key != 'State Unassigned'));
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _showDistrictData(String state, Map<String, dynamic> districtData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DistrictDataPage(state: state, districtData: districtData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'COVID-19 Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              fetchData();
            },
            color: Colors.white,
          ),
        ],
      ),
      body: _data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _data!.keys.length,
              itemBuilder: (BuildContext context, int index) {
                final state = _data!.keys.toList()[index];
                final districts =
                    _data![state]['districtData'] as Map<String, dynamic>;
                final totalCases = districts.values.fold(
                    0,
                    (sum, districtData) =>
                        sum + (districtData['confirmed'] as int));
                final activeCases = districts.values.fold(
                    0,
                    (sum, districtData) =>
                        sum + (districtData['active'] as int));
                final recoveredCases = districts.values.fold(
                    0,
                    (sum, districtData) =>
                        sum + (districtData['recovered'] as int));
                final deceasedCases = districts.values.fold(
                    0,
                    (sum, districtData) =>
                        sum + (districtData['deceased'] as int));

                Color color;
                if (activeCases > 5000) {
                  color = Colors.red;
                } else if (activeCases > 1000) {
                  color = Colors.orange;
                } else {
                  color = Colors.green;
                }

                return Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      state,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Cases',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('$totalCases',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Active',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('$activeCases',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: color)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Recovered',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('$recoveredCases',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deceased',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('$deceasedCases',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    onTap: () {
                      _showDistrictData(state, districts);
                    },
                  ),
                );
              },
            ),
    );
  }
}

class DistrictDataPage extends StatelessWidget {
  final String state;
  final Map<String, dynamic> districtData;

  const DistrictDataPage({required this.state, required this.districtData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'District Data - $state',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: districtData.entries.map((entry) {
          final district = entry.key;
          final cases = entry.value['confirmed'];
          final activeCases = entry.value['active'];
          final recoveredCases = entry.value['recovered'];
          final deceasedCases = entry.value['deceased'];

          Color color;
          if (activeCases > 500) {
            color = Colors.red;
          } else if (activeCases > 100) {
            color = Colors.orange;
          } else {
            color = Colors.green;
          }

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                district,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Cases',
                                style: TextStyle(color: Colors.grey)),
                            Text('$cases',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Active',
                                style: TextStyle(color: Colors.grey)),
                            Text('$activeCases',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: color)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recovered',
                                style: TextStyle(color: Colors.grey)),
                            Text('$recoveredCases',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Deceased',
                                style: TextStyle(color: Colors.grey)),
                            Text('$deceasedCases',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
