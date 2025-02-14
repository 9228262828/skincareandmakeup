import 'package:flutter/material.dart';

ButtonStyle settingPageButtonStyle() {
  return TextButton.styleFrom(
    textStyle: const TextStyle(fontSize: 20),
    minimumSize: const Size.fromHeight(80),
    splashFactory: NoSplash.splashFactory
  );
}

Positioned backButton(BuildContext context) {
  return Positioned(
    top: 30.0,
    left: 16.0,
    child: Stack (
      children: [

        IconButton(
          alignment: Alignment.center,
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30,),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ],
    ),
  );
}

StatelessWidget lightQualityIcon(String label, String result, BuildContext context) {
  Color containerColor;

  // Determine the container color based on the result
  switch (result) {
    case "Good":
      containerColor = Colors.green;
      break;
    case "Normal":
      containerColor = Colors.orange;
      break;
    case "Unknown":
      containerColor = Colors.grey;
      break;
    default:
      containerColor = Colors.red;
      break;
  }

  return Container(
    width: MediaQuery.of(context).size.width * 0.29,
    height: 50,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: containerColor,
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            result,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

Positioned lightQualityBox(String faceLighting, String faceFront, String faceArea, BuildContext context) {
  return Positioned(
    top: 50,
    right: 1,

    left: 10,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment:   CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Box for Lighting Quality
          lightQualityIcon("Lighting", faceLighting, context),
          SizedBox(width: 10),


          // Box for Face Frontal Quality
          lightQualityIcon("Face frontal", faceFront, context),
          SizedBox(width: 10),


          // Box for Face Area Quality
          lightQualityIcon("Face area", faceArea, context),
            SizedBox(width: 10),

        ],
      ),
    ),
  );
}


Stack flashView() {
  return Stack (
    children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          color: Colors.white,
        ),
      )
    ]
  );
}

Column scoreView(Size scoreSize, String score, String featureName, bool isSelected,Color backColor,Color borderColor, Color scoreColor, Shadow shadow) {
  return Column(children: [
    Container(
      width:scoreSize.width,
      height:scoreSize.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? borderColor : Colors.transparent,
        border: Border.all(
              color: borderColor,
              width:3,
            ),
      ),
      child: Center(
        child:
          Text(score, style: TextStyle(
            color: scoreColor,
          //  shadows:   <Shadow>[shadow ],
          ))
        ),
      ),
      Text(featureName, style: TextStyle(
        color: Colors.white
      ))
    ],
  );
}
Column scoreViewAll(Size scoreSize, String score, String featureName, bool isSelected,Color backColor,Color borderColor) {
  return Column(children: [
    Container(
      width:scoreSize.width,
      height:scoreSize.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.black.withAlpha(70) : Colors.transparent,
        border: Border.all(
              color: borderColor,
              width:3,
            ),
      ),
      child: Center(
        child:
          Text(score, style: TextStyle(
            color: backColor,
            fontSize: 25,
            fontWeight: FontWeight.bold
          ))
        ),
      ),
      Text(featureName, style: TextStyle(
        color: Colors.white
      ))
    ],
  );
}

TextStyle glowingText() {
  return const TextStyle(
    color: Colors.black,
    fontWeight:FontWeight.bold, 
    shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 2.0)]
  );
}

SnackBar showErrorDialog(String errorMessage) {
  return SnackBar(
    content: Text(errorMessage),
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.pink,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
    ),
  );
}

Container loadingIndicator() {
  return Container(
    color: Colors.black.withOpacity(0.3), // Transparent overlay
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}


Widget cameraButton(VoidCallback callback) {
  return GestureDetector(
    onTap: callback,
    child: Container(
      width: 70.0,
      height: 70.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
              width: 2.0,
              color: Colors.black
          )
      ),
    ),
  );
}

Column functionalButton(String text, Color color, VoidCallback callback) {
  return Column(
      children: [
        SizedBox(
            height:35,
            width:90,
            child: TextButton(
              onPressed: callback,
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  )
              ),
              child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
            )
        ),
        const SizedBox(height: 5)
      ]
  );
}










SnackBar showSuccessDialog(String errorMessage) {
  return SnackBar(
    content: Text(errorMessage),
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.green,
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
    ),
  );
}


Container progressIndicator(double progressValue) {
  return Container(
    color: Colors.black.withOpacity(0.3), // Transparent overlay
    child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                backgroundColor: Colors.blueGrey,
              ),
              const SizedBox(height: 15.0),
              SizedBox(
                  width: 300,
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 5.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                    backgroundColor: Colors.white,
                  )
              ),
              const SizedBox(height: 10.0),
              Text(
                "${(progressValue * 100).toStringAsFixed(2)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ]
        )
    ),
  );
}