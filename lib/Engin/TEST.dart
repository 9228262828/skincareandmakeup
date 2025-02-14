import 'package:Gomla/shared/utils/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewBottomSheet extends StatelessWidget {
  final String url;

  WebViewBottomSheet(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: mediaQueryHeight(context) * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),

          // Title
          Text(
            "Download App",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // WebView with URL handling
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(url)),
              onLoadError: (controller, url, code, message) {
                print("Failed to load URL: $url with error: $message");
              },
              onLoadHttpError: (controller, url, statusCode, description) {
                print("HTTP error: $statusCode for URL: $url");
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri != null && uri.scheme == "intent") {
                  // Launch external intent links
                  final fallbackUrl = uri.queryParameters['url'] ?? "";
                  if (await canLaunch(fallbackUrl)) {
                    await launch(fallbackUrl);
                  } else {
                    print("Cannot launch URL: $fallbackUrl");
                  }
                  return NavigationActionPolicy.CANCEL;
                } else if (uri != null && await canLaunch(uri.toString())) {
                  // Launch external links in the default browser
                  await launch(uri.toString());
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),

          // Close button
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the bottom sheet
              },
              child: Text("Close"),
            ),
          ),
        ],
      ),
    );
  }
}


final Map<String, Map<String, Map<String, String>>> featureConcernsEnglish = {
  "moisture": {
    "Hydration Level": {
      "Good": "The moisture level of your skin is acceptable, but you should pay attention to drinking enough water throughout the day. Additionally, use a daily moisturizer rich in vitamins and nutrients that help hydrate the skin and restore its vitality, along with a night cream to maintain hydration until morning.",
      "Average": "Your skin needs extra hydration, so pamper yourself with a rich daily moisturizer and a nourishing night cream to restore moisture by morning. Additionally, use a vitamin cream that revitalizes your skin, giving it radiance and vitality.",
      "Weak": "You need a little extra care! Keep using your daily cleanser twice a day to help remove dirt and unclog pores."
    },
  },
  "oiliness": {
    "Oil Production": {
      "Good": "Your skin looks radiant and non-greasy. Keep using a cleansing and purifying cleanser along with a gentle toner daily. Don’t forget to use a face mask once a week to keep your skin clear, healthy, and more vibrant.",
      "Average": "Is there a little shine on your skin? Use a cleansing and purifying wash that gently exfoliates to clean the pores without drying out your skin. Continue to use a gentle toner daily, and don’t forget to apply a face mask once a week.",
      "Weak": "You should start immediately to maintain skin balance and regulate excess oil by using a daily purifying cleanser along with a toner that helps keep your skin balanced and vibrant. Don’t forget to use a face mask once or twice a week to eliminate impurities and purify the skin."
    },

  },
  "redness": {
    "Redness Appearance": {
      "Good": "Your skin looks amazing! Keep up your skincare routine by using moisturizers and vitamin-rich serums to maintain healthy, irritation-free skin. And don't forget to use sunscreen to keep your skin vibrant and healthy.",
      "Average": "The redness of your skin is acceptable, so managing and reducing it at this stage is easy. Use a moisturizer and a serum rich in vitamins, especially B5 and B3, which significantly help soothe inflammation and irritation, strengthening the skin and keeping it healthy. And don’t forget sunscreen to maintain your skin's vitality.",
      "Weak": "No need to worry! You can still manage and reduce irritation and redness by consistently using a gentle exfoliator along with a moisturizer rich in herbs that help alleviate redness and hydrate the skin. Additionally, use a moisturizer and serum rich in pro-vitamin B5 and B3, which help balance the skin and reduce irritation and inflammation. And don't forget to use sunscreen to keep your skin vibrant."
    },

  },
  "texture": {
    "Skin Smoothness": {
      "Good": "Your skin looks good, so don’t forget to use sunscreen as well as a vitamin serum rich in antioxidants to maintain that beautiful face.",
      "Average": "Your skin texture is acceptable, but it needs a boost by using a vitamin C serum rich in antioxidants to help repair and protect the skin from environmental harming factors, giving your face an instant healthy glow. Maintain a good moisturizing routine, and don't forget to use a gentle exfoliator.",
      "Weak": "No need to worry; you can improve your skin texture by using an exfoliator once or twice a week to gently remove any dead skin cells, and by using a serum that helps deeply hydrate the skin, making it look beautiful and radiant. Also, pay attention to your daily routine with deep moisturizing creams.."
    },

  },
  "wrinkle": {
    "Wrinkle Depth": {
      "Good": "Your skin score is good. It doesn't require much care, but always follow a diet rich in essential vitamins and collagen to boost skin defenses and prevent early wrinkles. Also, sunscreen is essential in this case.",
      "Average": "It cannot be denied that wrinkle-free skin appears younger. You are experiencing early signs of wrinkles, so it is important to maintain a daily routine to reduce them and achieve a more youthful appearance. Use collagen and retinol creams to tighten the skin, maintain good hydration levels, and use a high-quality sunscreen.",
      "Weak": "Early signs of wrinkles are appearing, but nothing that can't be treated. Using collagen and retinol is essential to eliminate wrinkles, along with consistently applying sunscreen and reapplying it every four hours to prevent new wrinkles from forming."
    },

  },
  "age_spot": {
    "Dark Spots": {
      "Good": "Your skin is excellent and almost free of spots. Always take care by using a daily cleanser and a lightweight cream, while maintaining the use of sunscreen.",
      "Average": "The skin score is average. To always achieve spot-free and perfect skin, follow a daily skincare routine consisting of a cleanser, serum, retinol, and sunscreen, while avoiding sun exposure as much as possible.",
      "Weak": "The skin score is poor, so proper care is necessary. Use a daily routine to treat spots and improve skin appearance, consisting of a cleanser, serum, day cream, and sunscreen, along with a night cream to address the effects of harmful factors on the skin."
    },

  },
  "acne": {
    "Acne Severity": {
      "Good": "Your skin is amazing! Keep your hands away from your face and don’t forget to use sunscreen and reapply it throughout the day, as well as a daily moisturizer to keep your skin clear and protected.",
      "Average": "Be gentle with your skin and keep it clean and hydrated. Use a gentle cleanser and a moisturizer that helps maintain hydration, which can restore balance to the oil glands in your skin to control acne and improve healing.",
      "Weak": "Your skin needs to maintain cleanliness by using a gentle cleanser and replenishing moisture with a lightweight moisturizer that contains salicylic acid and/or azelaic acid. These ingredients help tighten pores in oily skin and prevent the formation of blemishes and blackheads without clogging pores. And don’t forget to clean your makeup brushes as well!"
    },

  },
  "dark_circle_v2": {
    "Dark Circle Appearance": {
      "Good": "You look great, and dark circles aren't very noticeable. Don't forget to continue with your daily routine using brightening creams and serums, especially those rich in vitamins and antioxidants around the eyes.",
      "Average": "There's no need to fear the presence of dark circles; you still have time to improve and conceal them. Use an antioxidant-rich cream under the eyes to help stimulate and brighten the area, along with brightening creams for the lower eye area, and maintain the use of a brightening serum.",
      "Weak": "It may be time to look for retinoids to help stimulate collagen production and restore volume and firmness to the sensitive skin under your eyes. Use brightening creams and vitamin-rich creams for the under-eye area to help lighten dark circles and make the skin look fresh and radiant, and don't forget your daily serum."
    },

  },
  "pore": {
    "Pore Size": {
      "Good": "Clear and beautiful skin! Keep up your daily routine by continuing to use your daily cleanser, moisturizer, and non-comedogenic makeup that won't clog your pores.",
      "Average": "You need a little extra care! Keep using your daily cleanser twice a day to help remove dirt and unclog pores.",
      "Weak": "Your skin needs cleansing and help to remove clogged pores. Use a gentle cleanser twice daily, along with creams that contain salicylic acid, which helps tighten pores in oily skin and prevents the formation of blemishes and blackheads."
    },

  },
  "radiance": {
    "Skin Glow": {
      "Good": "Your skin is glowing, radiant, and beautiful! Keep up your daily skincare routine and don’t forget sunscreen to maintain the elasticity and vitality of your skin, reapplying it every four hours.",
      "Average": "Do you want to enhance the glow and radiance of your skin? Use a daily skincare routine with a gentle daily cleanser and continuous hydration, along with sunscreen to maintain your skin's vitality and refresh it throughout the day.",
      "Weak": "Your skin looks dull! Don’t worry, you can start with four steps: cleanse, exfoliate, moisturize, and protect to restore its glow and vitality. Use a gentle cleanser and exfoliator, along with a rich, deep moisturizer to give your skin radiance and brightness. And don’t forget to use sunscreen and reapply it throughout the day to maintain your skin's freshness and vitality."
    },

  },
};

final Map<String, Map<String, Map<String, String>>> featureConcernsArabic = {
  "moisture": {
    "Hydration Level": {
      "Good": "مستوى الرطوبة في بشرتك مقبول، ولكن يُفضل الاهتمام بشرب كمية كافية من الماء على مدار اليوم. بالإضافة إلى ذلك، استخدمي مرطب يومي غني بالفيتامينات والعناصر المغذية التي تساعد في ترطيب البشرة واستعادة نضارتها، مع كريم ليلي للحفاظ على الترطيب حتى الصباح.",
      "Average": "بشرتك بحاجة إلى مزيد من الترطيب، لذا دللي نفسك باستخدام مرطب يومي غني وكريم ليلي مغذي لاستعادة الرطوبة بحلول الصباح. بالإضافة إلى ذلك، استخدمي كريم فيتامين يعيد النضارة لبشرتك ويمنحها الحيوية.",
      "Weak": "أنت بحاجة إلى عناية إضافية! استمري في استخدام المنظف اليومي مرتين يومياً للمساعدة في إزالة الأوساخ وفتح المسام."
    },
  },
  "oiliness": {
    "Oil Production": {
      "Good": "بشرتك تبدو مشرقة وغير دهنية. استمري في استخدام منظف ومنقي بشكل يومي، مع التونر الخفيف. ولا تنسي استخدام قناع للوجه مرة أسبوعياً للحفاظ على صفاء وصحة ونضارة البشرة.",
      "Average": "هل يوجد بعض اللمعان في بشرتك؟ استخدمي غسولاً منظفاً ومنقياً لطيفاً يقشر بلطف لتنظيف المسام دون أن يجفف البشرة. استمري في استخدام التونر يومياً، ولا تنسي تطبيق قناع للوجه مرة أسبوعياً.",
      "Weak": "يجب أن تبدأي على الفور للحفاظ على توازن البشرة وتنظيم إفراز الزيوت باستخدام منظف يومي منقي مع تونر يساعد على تحقيق التوازن والحيوية للبشرة."
    },
  },
  "redness": {
    "Redness Appearance": {
      "Good": "بشرتك تبدو رائعة! استمري في روتين العناية بالبشرة باستخدام المرطبات والسيرومات الغنية بالفيتامينات للحفاظ على بشرة صحية وخالية من التهيج. ولا تنسي استخدام واقي الشمس للحفاظ على حيوية وصحة البشرة.",
      "Average": "احمرار بشرتك مقبول، لذا من السهل السيطرة عليه وتقليله في هذه المرحلة. استخدمي مرطباً وسيروم غني بالفيتامينات، خاصة B5 و B3، التي تساعد بشكل كبير في تهدئة الالتهابات.",
      "Weak": "لا داعي للقلق! يمكنك التحكم في وتقليل التهيج والاحمرار باستخدام مقشر لطيف بانتظام مع مرطب غني بالأعشاب التي تساعد على تقليل الاحمرار وترطيب البشرة."
    },
  },
  "texture": {
    "Skin Smoothness": {
      "Good": "بشرتك تبدو جيدة، لذا لا تنسي استخدام واقي الشمس وسيروم الفيتامينات الغني بمضادات الأكسدة للحفاظ على جمال الوجه.",
      "Average": "ملمس بشرتك مقبول، لكنه يحتاج إلى تعزيز باستخدام سيروم فيتامين سي الغني بمضادات الأكسدة للمساعدة في إصلاح وحماية البشرة من العوامل الضارة البيئية، مما يمنح وجهك إشراقاً صحياً فورياً.",
      "Weak": "لا داعي للقلق، يمكنك تحسين ملمس البشرة باستخدام مقشر مرة أو مرتين أسبوعياً لإزالة أي خلايا جلد ميتة بلطف، واستخدام سيروم يساعد في ترطيب البشرة."
    },
  },
  "wrinkle": {
    "Wrinkle Depth": {
      "Good": "درجات بشرتك جيدة ولا تتطلب الكثير من العناية، لكن دائماً حافظي على نظام غذائي غني بالفيتامينات الأساسية والكولاجين لتعزيز دفاعات البشرة ومنع التجاعيد المبكرة.",
      "Average": "لا يمكن إنكار أن البشرة الخالية من التجاعيد تبدو أصغر سناً. تظهر لديك بعض علامات التجاعيد المبكرة، لذلك من المهم اتباع روتين يومي لتقليلها والحصول على مظهر أكثر شباباً.",
      "Weak": "تظهر بعض علامات التجاعيد المبكرة، ولكن يمكن علاجها باستخدام الكولاجين والريتينول للتخلص من التجاعيد، مع الالتزام باستخدام واقي الشمس."
    },
  },
  "age_spot": {
    "Dark Spots": {
      "Good": "بشرتك ممتازة وخالية من البقع تقريباً. حافظي دائماً على استخدامها يومياً مع منظف خفيف وكريم، مع استخدام واقي الشمس.",
      "Average": "درجة بشرتك متوسطة. لتحقيق بشرة خالية من البقع ودائمة الجمال، اتبعي روتين العناية اليومي المكون من منظف، سيروم، ريتينول، وواقي الشمس.",
      "Weak": "درجة بشرتك ضعيفة، لذا يلزم العناية الجيدة. استخدمي روتيناً يومياً لمعالجة البقع وتحسين مظهر البشرة، المكون من منظف، سيروم، كريم يومي، وواقي الشمس، إلى جانب كريم ليلي."
    },
  },
  "acne": {
    "Acne Severity": {
      "Good": "بشرتك رائعة! حافظي على نظافتها ولا تلمسي وجهك، ولا تنسي استخدام واقي الشمس وتطبيقه باستمرار، إلى جانب مرطب يومي للحفاظ على صفاء وحماية البشرة.",
      "Average": "كوني لطيفة على بشرتك واحرصي على نظافتها وترطيبها. استخدمي منظفاً لطيفاً ومرطباً يساعد على ترطيب البشرة، ما يساعد على إعادة توازن الغدد الدهنية للتحكم في حب الشباب.",
      "Weak": "بشرتك بحاجة للحفاظ على النظافة باستخدام منظف لطيف واستعادة الرطوبة بمرطب خفيف يحتوي على حمض الساليسيليك و/أو حمض الأزيليك."
    },
  },
  "dark_circle_v2": {
    "Dark Circle Appearance": {
      "Good": "تبدو رائعاً، والهالات السوداء ليست بارزة. لا تنسي الاستمرار في روتينك اليومي باستخدام الكريمات والسيرومات المضيئة الغنية بالفيتامينات ومضادات الأكسدة حول العينين.",
      "Average": "لا داعي للخوف من وجود الهالات السوداء؛ لديك الوقت لتحسينها وإخفائها. استخدمي كريماً غنياً بمضادات الأكسدة تحت العين لتحفيز وتفتيح المنطقة.",
      "Weak": "قد يكون الوقت قد حان للبحث عن الرتينويدات للمساعدة في تحفيز إنتاج الكولاجين واستعادة الحجم والصلابة للبشرة الحساسة تحت عينيك."
    },
  },
  "pore": {
    "Pore Size": {
      "Good": "بشرتك تبدو صافية وجميلة! استمري في روتينك اليومي باستخدام المنظف والمرطب والمكياج الخالي من المكونات المسدودة للمسام.",
      "Average": "أنت بحاجة إلى مزيد من العناية! استمري في استخدام المنظف اليومي مرتين يومياً لإزالة الأوساخ وفتح المسام.",
      "Weak": "بشرتك بحاجة إلى تنظيف لإزالة المسام المسدودة. استخدمي منظفاً لطيفاً مرتين يومياً."
    },
  },
  "radiance": {
    "Skin Glow": {
      "Good": "بشرتك مشرقة، نضرة، وجميلة! استمري في روتينك اليومي ولا تنسي استخدام واقي الشمس للحفاظ على مرونة ونضارة البشرة.",
      "Average": "هل ترغبين في زيادة توهج بشرتك؟ استخدمي روتين العناية اليومي مع منظف لطيف وترطيب مستمر.",
      "Weak": "بشرتك تبدو باهتة! لا تقلقي، ابدئي بالتنظيف والتقشير والترطيب للحفاظ على نضارتها."
    },
  },
};