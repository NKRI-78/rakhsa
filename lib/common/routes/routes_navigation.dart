import 'package:flutter/material.dart';
import 'package:rakhsa/features/document/presentation/pages/passport_document_page.dart';
import 'package:rakhsa/features/document/presentation/pages/visa_document_page.dart';
import 'package:rakhsa/features/event/persentation/pages/list.dart';
import 'package:rakhsa/features/information/presentation/pages/list.dart';
import 'package:rakhsa/features/nearme/presentation/pages/near_me_page.dart';
import 'package:rakhsa/features/nearme/presentation/pages/near_me_page_list_type.dart';
import 'package:rakhsa/features/news/persentation/pages/detail.dart';
import 'package:rakhsa/features/news/persentation/pages/list.dart';
import 'package:rakhsa/views/screens/ecommerce/product/products.dart';

class RoutesNavigation {
  RoutesNavigation._();

  static const initialRoute = '/';
  static const mart = '/mart';
  static const nearMe = '/near-me';
  static const nearMeTypeList = '/near-me-type-list';
  static const information = '/information';
  static const news = '/news';
  static const newsDetail = '/news-detail';
  static const visaDocument = '/visa-document';
  static const passportDocument = '/passport-document';
  static const itinerary = '/itinerary';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mart: 
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case information:
        return MaterialPageRoute(builder: (_) => const InformationListPage());
      case nearMeTypeList:
        return MaterialPageRoute(builder: (_) => const NearMeListTypePage());
      case visaDocument: 
        return MaterialPageRoute(builder: (_) => const VisaDocumentPage());
      case passportDocument: 
        return MaterialPageRoute(builder: (_) => const PassportDocumentPage());
      case nearMe:
        final type = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => NearMePage(type: type));
      case news:
        return MaterialPageRoute(builder: (_) => const NewsListPage());
      case newsDetail:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => NewsDetailPage(
          id: data['id'],
          type: data['type'],
        ));
      case itinerary:
        return MaterialPageRoute(builder: (_) => const EventListPage());
      default:
        return MaterialPageRoute(builder: (_) => const _InvalidRoute());
    }
  }
}

class _InvalidRoute extends StatelessWidget {
  const _InvalidRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Text(
          'INVALID ROUTE',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}