// lib/widgets/date_range_selector.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangeSelector extends StatelessWidget {
  final Function(PickerDateRange) onRangeSelected;
  final PickerDateRange? initialRange;

  const DateRangeSelector({
    super.key,
    required this.onRangeSelected,
    this.initialRange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                initialRange == null
                    ? 'Select Date Range'
                    : '${_formatDate(initialRange!.startDate)} - ${_formatDate(initialRange!.endDate)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _showDateRangePicker(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDateRangePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300, // Adjust width as needed
            height: 300, // Adjust height as needed
            child: SfDateRangePicker(
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  onRangeSelected(args.value as PickerDateRange);
                  Navigator.of(context).pop(); // Close dialog after selection
                }
              },
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: initialRange,
              showActionButtons: false, // Optional: if you want custom buttons
            ),
          ),
        );
      },
    );
  }
}
