import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String BOOKINGS_KEY = "bookings";

  /// Save a booking with vehicle type included
  static Future<void> saveBooking(
      String name, String email, String vehicleNumber, String slot, String vehicleType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookings = prefs.getStringList(BOOKINGS_KEY) ?? [];

    // ✅ Fix: Ensure vehicle type is stored properly
    bookings.add("$name|$email|$vehicleNumber|$slot|$vehicleType");
    await prefs.setStringList(BOOKINGS_KEY, bookings);
  }

  /// Retrieve all bookings
  static Future<List<String>> getBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(BOOKINGS_KEY) ?? [];
  }

  /// Remove a booking by slot number
  static Future<void> removeBooking(String slot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookings = prefs.getStringList(BOOKINGS_KEY) ?? [];

    // ✅ Fix: Remove correct booking by slot
    bookings.removeWhere((booking) => booking.split('|')[3] == slot);
    await prefs.setStringList(BOOKINGS_KEY, bookings);
  }
}
