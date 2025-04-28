import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart';

import '../providers/review_controller/review_cubit.dart';
import '../providers/review_controller/review_states.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewWidget extends StatelessWidget {
  final int productId;

  ReviewWidget({required this.productId});

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) => ReviewBloc()..add(FetchReviews(productId)),
      child: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoading) {
            return Center(child: CircularProgressIndicator(color: mainColor));
          } else if (state is ReviewLoaded) {
            if (state.reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(height: mediaQueryHeight(context) * 0.02),
                      Center(
                          child: Text(AppLocalizations.of(context)!.noReviews_yet,
                              style: TextStyle(color: Color(0xFF212224)))),

                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.reviewProduct,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          "${state.reviews.length} ${AppLocalizations.of(context)!.review}",
                          style: TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: mediaQueryHeight(context) * 0.02),
                    ListView.builder(
                      shrinkWrap:
                      true, // Makes the ListView take only as much height as needed
                      physics:
                      NeverScrollableScrollPhysics(), // Disable its scroll, let the parent scroll handle it
                      itemCount:
                      state.reviews.length  ,
                      itemBuilder: (context, index) {
                        final review = state.reviews[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          width: mediaQueryHeight(context) * 0.3,
                          height: mediaQueryHeight(context) * 0.17,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reviewer Avatar
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: NetworkImage(
                                        review.reviewerAvatarUrls.avatar96),
                                    radius:
                                    25, // Adjust the size of the avatar
                                  ),
                                  const SizedBox(width: 8),
                                    Column(
                                    children: [
                                      Text(
                                        review.reviewer,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                     /* ReviewWidget1 (
                                        dateCreated: review.dateCreated,
                                      )*/
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: buildRatingIcons(
                                        review.rating.toDouble()), // Helper function to build star icons
                                  ),
                                  Text(
                                    "${AppLocalizations.of(context)!.rating} ${review.rating}",
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                                Expanded(
                                child: Text(
                                  _stripHtmlTags(review.review),                                  style: TextStyle(fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow
                                      .ellipsis, // Add ellipsis for overflow
                                ),
                              ),

                              Divider(
                                thickness: .5,
                                color: Color(0xFFEAEAEA),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ReviewError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text('No reviews available.'));
          }
        },
      ),
    );

  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }
}

List<Widget> buildRatingIcons(double rating) {
  List<Widget> stars = [];

  // Handle cases where the rating is greater than 5
  if (rating > 5) {
    String ratingStr = rating.toString();
    int firstDigit = int.parse(ratingStr[0]);
    rating = (10 - firstDigit).toDouble();
  }

  int fullStars = rating.floor();
  double partialStar =
      rating - fullStars;

   for (int i = 0; i < fullStars; i++) {
    stars.add(Icon(Icons.star, color: Colors.amber, size: 16));
  }

  // Add partially filled star (if any)
  if (partialStar > 0) {
    stars.add(
      Stack(
        children: [
          Icon(Icons.star_border, color: Colors.amber, size: 16),
          ClipRect(
            clipper: _PartialStarClipper(partialStar),
            child:
            Icon(Icons.star, color: Colors.amber, size: 16),
          ),
        ],
      ),
    );
  }

  // Add remaining empty stars (if any)
  int remainingStars = 5 - stars.length;
  for (int i = 0; i < remainingStars; i++) {
    stars.add(Icon(Icons.star_border, color: Colors.amber, size: 16));
  }

  return stars;
}

class _PartialStarClipper extends CustomClipper<Rect> {
  final double fraction;

  _PartialStarClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}


