// import 'dart:async';
// import 'package:flowprotest/select_bt_device.dart';
// import 'package:flutter/material.dart';
// import 'package:gauges/gauges.dart';

// class MyHomePage extends StatefulWidget {
//   // final List<BluetoothService> services;

//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   List<int> values = [30, 40, 50, 60, 70, 80];
//   List<String> valueTitles = [
//     'Primary',
//     'Secoundary',
//     'Basement',
//     '1st floor',
//     'Roof',
//     'Rig',
//   ];
//   List<String> valueSubtitles = [
//     'The primary reader',
//     'The secoundary reader',
//     'The basement reader',
//     'The 1st floor reader',
//     'The roof reader',
//     'The rig reader'
//   ];
//   Timer? _timer;
//   // void startTimer() async {
//   //   Random rand = Random();
//   //   _timer = Timer.periodic(
//   //     const Duration(seconds: 1),
//   //     (Timer timer) {
//   //       setState(() {
//   //         for (var i = 0; i < values.length; i++) {
//   //           if (values[i] < 5) {
//   //             values[i] += rand.nextInt(15);
//   //           } else if (values[i] > 95) {
//   //             values[i] -= rand.nextInt(15);
//   //           } else {
//   //             values[i] += rand.nextInt(10) - 5;
//   //           }
//   //         }
//   //       });
//   //     },
//   //   );
//   // }

//   @override
//   void initState() {
//     // startTimer();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {},
//       //   backgroundColor: Colors.blue,
//       //   foregroundColor: Colors.white,
//       //   child: const Icon(Icons.add),
//       // ),
//       // appBar: AppBar(
//       // leadingWidth: 100,
//       // leading: Container(
//       //   margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
//       //   child: Image.asset(
//       //     'assets/logo/logo_light.png',
//       //   ),
//       // ),
//       // title: Container(
//       //   height: 60,
//       //   margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
//       //   child: Image.asset(
//       //     'assets/logo/logo_light.png',
//       //   ),
//       // ),
//       //Text(widget.title),
//       // ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               const SizedBox(
//                 height: kToolbarHeight,
//               ),
//               SizedBox(
//                 height: 80,
//                 child: Image.asset(
//                   'assets/logo/logo_light.png',
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//                 width: double.infinity,
//               ),
//               // Padding(
//               //   padding: const EdgeInsets.symmetric(horizontal: 4),
//               //   child: Row(
//               //     children: [
//               //       const Expanded(child: SizedBox()),
//               //       const SizedBox(width: 5),
//               //       // Container(
//               //       //   padding: const EdgeInsets.all(6),
//               //       //   width: 80,
//               //       //   child: const Center(child: Text('Pressure')),
//               //       // ),
//               //       // Container(
//               //       //   padding: const EdgeInsets.all(6),
//               //       //   width: 80,
//               //       //   child: const Center(child: Text('Usage')),
//               //       // ),
//               //     ],
//               //   ),
//               // ),
//               const Text(
//                 'Connect to a bluetooth unit',
//                 style: TextStyle(color: Colors.white38, fontSize: 16),
//               ),
//               const SelectBtDevice(),
//               // ListView.builder(
//               //   padding: EdgeInsets.zero,
//               //   shrinkWrap: true,
//               //   physics: const NeverScrollableScrollPhysics(),
//               //   itemCount: values.length,
//               //   itemBuilder: (BuildContext context, int index) {
//               //     // isThreeLine: true,
//               //     // title: Text('Cool name'),
//               //     // subtitle: Text('Subtitle name'),
//               //     // leading: Icon(Icons.water_drop),
//               //     return Card(
//               //       child: InkWell(
//               //         onTap: () {
//               //           // Navigator.push(
//               //           //   context,
//               //           //   MaterialPageRoute(
//               //           //     builder: (context) => SingleReaderPage(
//               //           //       title: valueTitles[index],
//               //           //       services: widget.services,
//               //           //     ),
//               //           //   ),
//               //           // );
//               //         },
//               //         child: Row(
//               //           mainAxisSize: MainAxisSize.min,
//               //           children: [
//               //             Padding(
//               //               padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25),
//               //               child: Icon(valueTitles[index].length > 7 ? Icons.join_inner : Icons.webhook_outlined),
//               //             ),
//               //             Expanded(
//               //               child: Column(
//               //                 crossAxisAlignment: CrossAxisAlignment.start,
//               //                 children: [
//               //                   Text(
//               //                     valueTitles[index],
//               //                     style: const TextStyle(fontWeight: FontWeight.bold),
//               //                   ),
//               //                   Text(
//               //                     valueSubtitles[index],
//               //                     style: const TextStyle(color: Colors.white54),
//               //                   ),
//               //                 ],
//               //               ),
//               //             ),
//               //             const SizedBox(width: 5),
//               //             // Card(
//               //             //   color: Colors.blue,
//               //             //   child: Padding(
//               //             //     padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
//               //             //     child: Text('Connect'),
//               //             //   ),
//               //             // )
//               //             const Icon(
//               //               Icons.link,
//               //               color: Colors.blue,
//               //             ),
//               //             const SizedBox(width: 20),

//               //             // Container(
//               //             //     padding: const EdgeInsets.all(6),
//               //             //     width: 80,
//               //             //     height: 80,
//               //             //     child: SingleGaugeDial(value: values[index].toDouble(), isPressure: true)),
//               //             // Container(
//               //             //     padding: const EdgeInsets.all(6),
//               //             //     width: 80,
//               //             //     height: 80,
//               //             //     child: SingleGaugeDial(value: values[index].toDouble(), isPressure: false)),
//               //           ],
//               //         ),
//               //       ),
//               //     );
//               //   },
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SingleGaugeDial extends StatelessWidget {
//   final double value;
//   final bool isPressure;
//   const SingleGaugeDial({Key? key, required this.value, required this.isPressure}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Color color1, color2, color3;
//     double start1, start2, start3, end;
//     if (isPressure) {
//       start1 = 0;
//       start2 = 40;
//       start3 = 60;
//       end = 100;
//       color1 = Colors.white;
//       color2 = Colors.green;
//       color3 = Colors.blue;
//     } else {
//       start1 = 0;
//       start2 = 25;
//       start3 = 75;
//       end = 100;
//       color1 = Colors.green;
//       color2 = Colors.orange;
//       color3 = Colors.red;
//     }
//     return RadialGauge(
//       axes: [
//         RadialGaugeAxis(
//           minValue: 0,
//           maxValue: 300,
//           minAngle: -150,
//           maxAngle: 150,
//           radius: 0.9,
//           width: 0.1,
//           color: Colors.transparent,
//           pointers: [
//             RadialNeedlePointer(
//                 value: value, thicknessStart: 4, thicknessEnd: 0, length: 0.7, knobRadiusAbsolute: 3, color: Colors.white, knobColor: Colors.white)
//           ],
//           ticks: [
//             RadialTicks(interval: 20, alignment: RadialTickAxisAlignment.inside, color: Colors.white, length: 0.17, children: [
//               RadialTicks(
//                 // interval: 50,
//                 ticksInBetween: 5,
//                 length: 0.13,
//                 color: Colors.grey,
//               ),
//             ]),
//           ],
//           segments: [
//             RadialGaugeSegment(
//               minValue: 0,
//               maxValue: 100,
//               minAngle: -150,
//               maxAngle: -50,
//               color: color1,
//             ),
//             RadialGaugeSegment(
//               minValue: 100,
//               maxValue: 200,
//               minAngle: -50,
//               maxAngle: 50,
//               color: color2,
//             ),
//             RadialGaugeSegment(
//               minValue: 200,
//               maxValue: 300,
//               minAngle: 50,
//               maxAngle: 150,
//               color: color3,
//             ),
//           ],
//         ),
//       ],
//     );
//     // return SfRadialGauge(
//     //   axes: <RadialAxis>[
//     //     RadialAxis(
//     //       minimum: 0,
//     //       maximum: 100,
//     //       showLabels: false,
//     //       ranges: <GaugeRange>[
//     //         GaugeRange(startValue: start1, endValue: start2, color: color1),
//     //         GaugeRange(startValue: start2, endValue: start3, color: color2),
//     //         GaugeRange(startValue: start3, endValue: end, color: color3)
//     //       ],
//     //       pointers: <GaugePointer>[
//     //         NeedlePointer(
//     //           knobStyle: const KnobStyle(knobRadius: 0.1, borderWidth: 20),
//     //           // tailStyle: const TailStyle(width: 1, length: 0.2),
//     //           needleLength: 0.7,
//     //           needleStartWidth: 0.5,
//     //           needleEndWidth: 2,
//     //           animationDuration: 1000,
//     //           animationType: AnimationType.ease,
//     //           enableAnimation: true,
//     //           value: value,
//     //         )
//     //       ],
//     //       // annotations: <GaugeAnnotation>[
//     //       //   GaugeAnnotation(
//     //       //     widget: Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
//     //       //     angle: 90,
//     //       //     positionFactor: 0.5,
//     //       //   )
//     //       // ],
//     //     )
//     //   ],
//     // );
//   }
// }

//           // child: Column(
//           //   crossAxisAlignment: CrossAxisAlignment.start,
//           //   // mainAxisAlignment: MainAxisAlignment.center,
//           //   children: <Widget>[
//           //     Row(
//           //       children: [
//           //         const SizedBox(width: 20),
//           //         Expanded(
//           //           flex: 2,
//           //           child: Image.asset('assets/logo/logo_light.png'),
//           //         ),
//           //         Expanded(
//           //           flex: 3,
//           //           child: Padding(
//           //             // padding: const EdgeInsets.all(8.0),
//           //             padding: const EdgeInsets.all(10),
//           //             child: Container(
//           //               // height: 150,
//           //               child: Card(
//           //                 // color: Colors.red,
//           //                 child: Padding(
//           //                   padding: const EdgeInsets.all(8.0),
//           //                   child: Column(
//           //                     crossAxisAlignment: CrossAxisAlignment.center,
//           //                     children: [
//           //                       GridView.builder(
//           //                         padding: EdgeInsets.zero,
//           //                         shrinkWrap: true,
//           //                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           //                           crossAxisCount: 3,
//           //                         ),
//           //                         itemCount: values.length,
//           //                         itemBuilder: (BuildContext context, int index) {
//           //                           return Card(
//           //                             color: Colors.black,
//           //                             child: IconButton(
//           //                               icon: const Icon(Icons.power_settings_new),
//           //                               onPressed: () {},
//           //                             ),
//           //                           );
//           //                         },
//           //                       ),
//           //                     ],
//           //                   ),
//           //                 ),
//           //               ),
//           //             ),
//           //           ),
//           //         )
//           //       ],
//           //     ),
//           //     const SizedBox(height: 20),
//           //     const Text(
//           //       'Gas forbrug',
//           //       style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//           //     ),
//           //     const Divider(thickness: 2),
//           //     GridView.builder(
//           //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           //         crossAxisCount: 3,
//           //       ),
//           //       shrinkWrap: true,
//           //       itemCount: values.length,
//           //       itemBuilder: (BuildContext context, int index) {
//           //         return Stack(
//           //           alignment: Alignment.center,
//           //           children: [
//           //             Align(
//           //               alignment: Alignment.topLeft,
//           //               child: CircleAvatar(
//           //                 backgroundColor: Colors.blue,
//           //                 foregroundColor: Colors.white,
//           //                 child: Text('${index + 1}'),
//           //               ),
//           //             ),
//           //             SingleGaugeDial(
//           //               value: values[index].toDouble(),
//           //             )
//           //           ],
//           //         );
//           //       },
//           //     ),
//           //   ],
//           // ),