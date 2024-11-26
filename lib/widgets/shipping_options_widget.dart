import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShippingOptionsWidget extends StatefulWidget {
  final List<dynamic> shippingZones;
  final Function(int, dynamic) onShippingMethodSelected;

  ShippingOptionsWidget({
    required this.shippingZones,
    required this.onShippingMethodSelected,
  });

  @override
  _ShippingOptionsWidgetState createState() => _ShippingOptionsWidgetState();
}

class _ShippingOptionsWidgetState extends State<ShippingOptionsWidget> {
  String? _selectedZoneId;
  dynamic _selectedShippingMethod;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItems = [];

    // Create dropdown items for each zone and its cities
    for (var zone in widget.shippingZones) {
      List<String> zoneNames = zone['name'].split(', '); // Split the zone names by comma and space
      for (var zoneName in zoneNames) {
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: '${zone['id']}-$zoneName',
            child: Text(zoneName),
          ),
        );
      }
    }

    return Column(
      children: [
        DropdownButton<String>(
          hint: Text('Select Shipping Region'),
          style: TextStyle(color: Colors.black),
          isExpanded: true,
          value: _selectedZoneId,
          items: dropdownItems,
          onChanged: (String? newValue) {
            setState(() {
              _selectedZoneId = newValue;
              _selectedShippingMethod = null;
            });

            if (newValue != null) {
              int zoneId = int.parse(newValue.split('-')[0]); // Extract the original zone ID
              var selectedZone = widget.shippingZones.firstWhere((zone) => zone['id'] == zoneId);
              var firstMethod = selectedZone['methods'].isNotEmpty ? selectedZone['methods'][0] : null;
              _selectedShippingMethod = firstMethod;
              widget.onShippingMethodSelected(zoneId, firstMethod);
            }
          },
        ),
        // if (_selectedShippingMethod != null)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 8.0),
        //     child: Text('${_selectedShippingMethod['settings']['cost']['value']} ${AppLocalizations.of(context)!.egp}'),
        //   ),
      ],
    );
  }
}
