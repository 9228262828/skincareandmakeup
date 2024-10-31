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
    top: 46.0,
    left: 16.0,
    child: Stack (
      children: [
        IconButton(
          icon: const Icon(Icons.lens, color: Colors.white, shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 1.0)],),
          onPressed: () {},
        ),
        IconButton(
          padding: const EdgeInsets.only(left: 4),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 12,),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
      ],
    ),
  );
}

Icon lightQualityIcon(String result) {
  switch (result) {
    case "Good":
      return const Icon(Icons.circle, color: Colors.green, size: 20);
    case "Normal":
      return const Icon(Icons.circle, color: Colors.orange, size: 20);
    case "Unknown":
      return const Icon(Icons.circle, color: Colors.grey, size: 20);
    default:
      return const Icon(Icons.circle, color: Colors.red, size: 20);
  }
  
}

Positioned lightQualityBox(String faceLighting, String faceFront, String faceArea) {
  return Positioned(
    top: 56.0,
    right: 16.0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 15,
            ),
            children: [
              const TextSpan(text:"Lighting: ", style: TextStyle(fontWeight: FontWeight.bold)),
              WidgetSpan(child: lightQualityIcon(faceLighting)),
              TextSpan(text:" $faceLighting")
            ]
          ),
        ),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 15,
            ),
            children: [
              const TextSpan(text:"Face frontal: ", style: TextStyle(fontWeight: FontWeight.bold)),
              WidgetSpan(child: lightQualityIcon(faceFront)),
              TextSpan(text:" $faceFront")
            ]
          ),
        ),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 15,
            ),
            children: [
              const TextSpan(text:"Face area: ", style: TextStyle(fontWeight: FontWeight.bold)),
              WidgetSpan(child: lightQualityIcon(faceArea)),
              TextSpan(text:" $faceArea")
            ]
          ),
        ),
        const SizedBox(height: 20),
      ],
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

Column scoreView(Size scoreSize, String score, String featureName, bool isSelected) {
  return Column(children: [
    Container(
      width:scoreSize.width,
      height:scoreSize.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.black.withAlpha(70) : Colors.transparent,
        border: Border.all(
              color: Colors.pink,
              width: 2.0,
            ),
      ),
      child: Center(
        child: 
          Text(score, style: glowingText())
        ),
      ),
      Text(featureName, style: glowingText())
    ],
  ); 
}

TextStyle glowingText() {
  return const TextStyle(
    color: Colors.white, 
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