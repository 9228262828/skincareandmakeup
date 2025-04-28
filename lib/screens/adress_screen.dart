import 'package:Gomla/screens/main_screen.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import '../controllers/address_controller/address_states.dart';
import '../controllers/address_controller/adress_cubit.dart';
import '../contstants.dart';
import '../screens/edit_address_screen.dart';
import '../screens/map_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressCubit()..fetchAddresses(),
      child: AddressScreenBody(),
    );
  }
}

class AddressScreenBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Color(0xFF212224),
        backgroundColor: Color(0xFF212224),
        title: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.addresses,
              style: TextStyle(
                  color: mainColor, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: mediaQueryWidth(context) * 0.25),

          ],
        ),
        leading: GestureDetector(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(index: 0)),
                  (route) => false,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 8.0),
              child: Icon(Icons.arrow_back_ios, color: mainColor, size: 20),
            )),
      ),
      backgroundColor:  Colors.grey.shade200,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<AddressCubit, AddressState>(
          listener: (context, state) {
            if (state is AddressError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }

            if (state is AddressDeleted) {
               context.read<AddressCubit>().fetchAddresses();
            }
          },
          builder: (context, state) {
            if (state is AddressLoading) {
              return Center(child: CircularProgressIndicator(color:   mainColor,));
            } else if (state is AddressLoaded) {
              if (state.addresses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.add_new_address,
                        style: TextStyle(
                            color: Color(0xFF212224),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPicker(

                                isFromAddAddress: true,
                                isFromEditAddress: false,
                                onLocationPicked: (address, city, state, country, postcode) {
                                  print('Picked Address: $address');
                                  print('City: $city');
                                  print('State: $state');
                                  print('Country: $country');
                                  print('Postal Code: $postcode');
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Color(0xFF212224)),
                            color: Colors.transparent,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.add_new_address,
                                style: TextStyle(
                                    color: Color(0xFF212224),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPicker(
                            isFromEditAddress: false,
                            isFromAddAddress: true,

                            onLocationPicked: (address, city, state, country, postcode) {
                              print('Picked Address: $address');
                              print('City: $city');
                              print('State: $state');
                              print('Country: $country');
                              print('Postal Code: $postcode');
                            },
                          ),
                        ),
                      );

                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Color(0xFF212224)),
                        color: Colors.transparent,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.add_new_address,
                            style: TextStyle(
                                color: Color(0xFF212224),
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.addresses.length,
                      itemBuilder: (context, index) {
                        final address = state.addresses[index];

                        // Define the border color for the first card
                        Color borderColor = index == 0 ? mainColor: Color(0xFFEAEAEA);

                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: borderColor, // Apply the yellow border for the first item
                              width: 1.0,
                            ),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          child: ListTile(
                            title: Row(
                               children: [
                                Icon(Icons.map_outlined, color: Colors.black),
                                SizedBox(width: 8),
                                index == 0
                                    ? Text(
                                        AppLocalizations.of(context)!.default_address,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: mainColor,
                                          fontSize: 12,
                                        ),
                                      )
                                    : Container(),
                                Spacer(flex: 1),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditAddressScreen(address: address,
                                          address1: "",
                                          city:"" ,
                                          state: "",
                                          country: "",
                                          postcode: "",
                                          fromMap: false,

                                        ),
                                      ),
                                    ).then((_) {
                                      // After popping back from EditAddressScreen, refresh the address list
                                      context.read<AddressCubit>().fetchAddresses();});
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.edit_address,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),

                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 4),
                                      index == 0
                                          ? Container():
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            context.read<AddressCubit>().deleteAddress(context ,address.id);},
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outlined,
                                                size: 16,
                                                color: Colors.red,

                                              ),
                                              Text(
                                                AppLocalizations.of(context)!.delete,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(thickness: .5),
                              if (address.notes.isNotEmpty)
                                Row(
                                  children: [

                                    Text(
                                      "${AppLocalizations.of(context)!.type_of_address}:  ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),

                                    Text(
                                      address.notes ,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                if (address.firstName.isNotEmpty && address.lastName.isNotEmpty)
                                Row(
                                  children: [

                                    Text(
                                      "${AppLocalizations.of(context)!.recipient_name}:  ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      address.firstName + " " + address.lastName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (address.firstName.isNotEmpty && address.lastName.isNotEmpty)
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.address}:  ",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        address.address1,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                if (address.phone.isNotEmpty)
                                Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.phoneNumber}:  ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      address.phone,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              );
            } else {
              return Center(child: Text('No addresses found.'));
            }
          },
        ),
      ),
    );
  }
}

