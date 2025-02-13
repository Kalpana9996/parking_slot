import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vechicle_parking/slot.dart';
import 'package:vechicle_parking/utils/contants.dart';
import '../utils/shared_prefs.dart';
import '../widgets/custom_textfield.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  String selectedVehicleType = "Motorcycle";
  String? selectedSlot;
  List<String> bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
  }

  Future<void> _loadBookedSlots() async {
    List<String> bookings = await SharedPrefs.getBookings();
    setState(() {
      bookedSlots = bookings.map((e) => e.split('|')[3]).toList();
    });
  }

  List<String> getAvailableSlots() {
    if (selectedVehicleType == "Car") return carSlots;
    if (selectedVehicleType == "Van") return vanSlots;
    return allSlots;
  }

  Future<void> _bookSlot() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _vehicleNumberController.text.isEmpty) {
      _showToast("All fields are required!", Colors.grey);
      return;
    }

    if (selectedSlot == null) {
      _showToast("Please select a parking slot!", Colors.grey);
      return;
    }

    await SharedPrefs.saveBooking(
      _nameController.text,
      _emailController.text,
      _vehicleNumberController.text,
      selectedSlot!,
      selectedVehicleType,
    );

    _showToast("Booking successful for slot $selectedSlot!", Colors.grey);

    Navigator.pop(context, true);
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> availableSlots = getAvailableSlots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Slot",style: TextStyle(
          color: Colors.white
        ),),leading: IconButton(onPressed: (){
          Navigator.pop(context);
      }, icon: Icon(Icons.arrow_left_outlined,color: Colors.white,)),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: _nameController, label: "Owner Name"),
            SizedBox(height: 10),
            CustomTextField(controller: _emailController, label: "Owner Email"),
            SizedBox(height: 10),
            CustomTextField(controller: _vehicleNumberController, label: "Vehicle Number"),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedVehicleType,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  selectedVehicleType = value!;
                  selectedSlot = null; // Reset slot selection when vehicle type changes
                });
              },
              items: ["Motorcycle", "Car", "Van"].map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SlotGrid(
                availableSlots: availableSlots,
                bookedSlots: bookedSlots,
                selectedSlot: selectedSlot,
                onSlotSelected: (slot) {
                  setState(() {
                    selectedSlot = slot;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _bookSlot,
              child: Text("Park It",style: TextStyle(
                color: Colors.white
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[900],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
