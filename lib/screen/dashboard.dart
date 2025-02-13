import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/shared_prefs.dart';
import 'booking_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, String>> bookedSlots = [];

  final int totalSpots = 24;
  int occupiedSpots = 0;
  int remainingSpots = 24;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    List<String> bookings = await SharedPrefs.getBookings();
    setState(() {
      bookedSlots = bookings.map((e) {
        final parts = e.split('|');
        return {
          'name': parts[0],
          'email': parts[1],
          'vehicleNumber': parts[2],
          'slot': parts[3],
          'vehicleType': parts.length > 4 ? parts[4] : "Unknown"
        };
      }).toList();

      occupiedSpots = bookedSlots.length;
      remainingSpots = totalSpots - occupiedSpots;
    });

    if (remainingSpots == 0) {
      Fluttertoast.showToast(
        msg: "All slots are booked!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _unparkSlot(String slot) async {
    await SharedPrefs.removeBooking(slot);
    _loadBookings();

    Fluttertoast.showToast(
      msg: "Slot $slot has been freed!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Parking Dashboard",style: TextStyle(
        color: Colors.white
      ),), backgroundColor: Colors.blueGrey[900]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Parking Slots: $totalSpots", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Occupied Slots: $occupiedSpots", style: TextStyle(fontSize: 16)),
            Text("Remaining Slots: $remainingSpots", style: TextStyle(fontSize: 16, color: remainingSpots == 0 ? Colors.red : Colors.black)),
            SizedBox(height: 10),
            Expanded(
              child: bookedSlots.isEmpty
                  ? Center(child: Text("No parked vehicles."))
                  : ListView.builder(
                itemCount: bookedSlots.length,
                itemBuilder: (context, index) {
                  final booking = bookedSlots[index];
                  return Card(
                    color: booking['vehicleType'] == "Car"
                        ? Colors.blue.shade100
                        : booking['vehicleType'] == "Van"
                        ? Colors.blue.shade100
                        : Colors.blue.shade100,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Icon(
                        booking['vehicleType'] == "Car"
                            ? Icons.directions_car
                            : booking['vehicleType'] == "Van"
                            ? Icons.directions_bus
                            : Icons.motorcycle,
                        size: 36,
                      ),
                      title: Text("${booking['name']} - Slot: ${booking['slot']}"),
                      subtitle: Text(
                        "Vehicle: ${booking['vehicleType']}\nNumber: ${booking['vehicleNumber']}\nEmail: ${booking['email']}",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _unparkSlot(booking['slot']!),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: remainingSpots > 0
            ? () async {
          bool? newBooking = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingScreen()),
          );

          if (newBooking == true) _loadBookings();
        }
            : () {
          Fluttertoast.showToast(
            msg: "No available slots! Please wait for a slot to be free.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        },
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: remainingSpots > 0 ? Colors.blueGrey[900] : Colors.grey,
      ),
    );
  }
}
