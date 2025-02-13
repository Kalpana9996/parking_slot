import 'package:flutter/material.dart';

class SlotGrid extends StatelessWidget {
  final List<String> availableSlots;
  final List<String> bookedSlots;
  final String? selectedSlot;
  final Function(String) onSlotSelected;

  const SlotGrid({
    required this.availableSlots,
    required this.bookedSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, childAspectRatio: 1.5),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        String slot = availableSlots[index];
        bool isBooked = bookedSlots.contains(slot);
        return GestureDetector(
          onTap: isBooked
              ? null
              : () {
            onSlotSelected(slot);
          },
          child: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isBooked ? Colors.red : (selectedSlot == slot ? Colors.grey : Colors.blueGrey[800]),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              slot,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
