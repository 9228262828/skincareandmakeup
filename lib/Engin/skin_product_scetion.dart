import 'package:Gomla/Engin/skin_cubit_and_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../contstants.dart';
import '../models/cart.dart';
import '../screens/main_screen.dart';
import '../shared/utils/app_values.dart';
import '../widgets/product_shimmer_widget.dart';
import 'details_product_card.dart';
import 'models.dart';

class SkinProductsSection extends StatefulWidget {
  final Map<String, dynamic> reports;
  final Map<String, dynamic> score;

  const SkinProductsSection({Key? key, required this.reports, required this.score}) : super(key: key);

  @override
  State<SkinProductsSection> createState() => _SkinProductsSectionState();
}

class _SkinProductsSectionState extends State<SkinProductsSection> {
  List<ProductDetails> selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dryness = widget.reports["moisture"];
        final redness = widget.reports["redness"];
        final oilliness = widget.reports["oiliness"];
        final acne = widget.reports["acne"];
        final pores = widget.reports["pore"];
        final texture = widget.reports["texture"];
        final wrinkles = widget.reports["wrinkle"];
        final darkspots = widget.reports["age_spot"];
        final darkcircles = widget.reports["dark_circle_v2"];
        final radiance = widget.reports["radiance"];
        final skinAge = widget.score["skinAge"];
        final overallScore = widget.score["overallScore"];

        if ([dryness, redness, oilliness, acne, pores, texture, wrinkles, darkspots, darkcircles, radiance, skinAge, overallScore].contains(null)) {
          return SkinAnalysisCubit()..emit(SkinAnalysisError("Missing necessary data."));
        }

        return SkinAnalysisCubit()
          ..fetchSkinAnalysis(
            dryness,
            redness,
            oilliness,
            acne,
            pores,
            texture,
            wrinkles,
            darkspots,
            darkcircles,
            radiance,
            skinAge,
            overallScore,
          );
      },
      child: BlocBuilder<SkinAnalysisCubit, SkinAnalysisState>(
        builder: (context, state) {
          if (state is SkinAnalysisLoading) {
            return const ProductCardWithShimmer(count: 2);
          } else if (state is SkinAnalysisError) {
            return Center(child: Text(state.message));
          } else if (state is SkinAnalysisSuccess) {
            final categories = _filterValidCategories(state.response.data.categories);

            if (selectedProducts.isEmpty) {
              selectedProducts.addAll(categories.map((c) => c.details));
            }

            if (categories.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.4,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: DTreatmentCard(
                            details: categories[index].details,
                            onSelected: (details, isSelected) {
                              setState(() {
                                if (isSelected) {
                                  selectedProducts.add(details);
                                } else {
                                  selectedProducts.removeWhere((item) => item.ar?.id == details.ar?.id);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (selectedProducts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          maximumSize: Size(double.infinity, 50),
                          fixedSize: Size(double.infinity, 45),
                          minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                          backgroundColor :   mainColor,
                          foregroundColor: Colors.white,
                          elevation: 0),
                      onPressed: () {
                        _addAllToCart(selectedProducts, context);
                      },
                      child: Text('Add ${selectedProducts.length} Products to Cart'),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _addAllToCart(List<ProductDetails> products, BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);

    for (var details in products) {
      cart.addItemFromDetails(details);
    }

    Future.delayed(const Duration(seconds: 1), () {
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: mediaQueryWidth(context) * 0.95,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.check_circle, color: Colors.green, size: 50,),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${products.length} ${AppLocalizations.of(context)!.products_added}',
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.in_cart,
                            maxLines: 2,
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(width: 1, color: Color(0xFF212224)),
                    maximumSize: Size(double.infinity, 50),
                    fixedSize: Size(double.infinity, 45),
                    minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    elevation: 0),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.show_another_product,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF212224)),
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    maximumSize: Size(double.infinity, 50),
                    fixedSize: Size(double.infinity, 45),
                    minimumSize: Size(mediaQueryWidth(context) * .9, 40),
                    backgroundColor: Color(0xFF212224),
                    foregroundColor: Colors.white,
                    elevation: 0),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(index: 4),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.goToCart,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
    });
  },
    );
  }
  List<ProductCategory> _filterValidCategories(
      List<ProductCategory> categories)
  {
    return categories.where((category) {
      final details = category.details;

      final hasValidAr = details.ar != null &&
          details.ar!.id != null &&
          details.ar!.name != null &&
          details.ar!.description != null &&
          details.ar!.price != null;

      final hasValidEn = details.en != null &&
          details.en!.id != null &&
          details.en!.name != null &&
          details.en!.description != null &&
          details.en!.price != null;


      final isValid = hasValidAr || hasValidEn;
      if (!isValid) {
        print("Invalid category: ${category.key}");
      }

      return isValid;
    }).toList();
  }

}
