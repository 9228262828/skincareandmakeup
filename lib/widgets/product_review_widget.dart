import 'package:Gomla/contstants.dart';
import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart';

import '../providers/review_controller/review_cubit.dart';
import '../providers/review_controller/review_states.dart';

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
            return Center(child: CircularProgressIndicator());
          } else if (state is ReviewLoaded) {
            if (state.reviews.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)!.noReviews_yet,
                      style: TextStyle(color: mainColor)));
            }
            return SizedBox(
              height: mediaQueryHeight(context) * 0.21,
              // Set your desired height here
              child: ListView.builder(
                itemCount: state.reviews.length,
                scrollDirection: Axis.horizontal, // Horizontal scrolling
                itemBuilder: (context, index) {
                  final review = state.reviews[index];
                  return Card(
                    child: Container(
                      decoration:  BoxDecoration(
                        color:  Colors.white,
                        border: Border.all(color: mainColor),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      width: mediaQueryHeight(context) * 0.2,
                      padding: EdgeInsets.all(8),
                      height: mediaQueryHeight(context) * 0.2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Reviewer Avatar
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                review.reviewerAvatarUrls.avatar96),
                            radius: 25, // Adjust the size of the avatar
                          ),
                          SizedBox(height: 8),
                          // Spacing between avatar and text
                          // Reviewer Name
                          Text(
                            review.reviewer ?? 'Anonymous',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          // Spacing between name and review
                          // Review Text
                          Expanded(
                            child: Text(
                              _stripHtmlTags(review.review),
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                              maxLines: 3, // Limit the number of lines
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis for overflow
                            ),
                          ),
                          SizedBox(height: 4),
                         Text(
                            review.rating.toString(),
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: buildRatingIcons(review.rating
                                .toDouble()), // Helper function to build star icons
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

  // Add fully filled stars
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
