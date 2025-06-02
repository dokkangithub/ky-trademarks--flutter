
import 'package:flutter/material.dart';

import '../presentation/Screens/HomeScreen.dart';
import '../presentation/Screens/login/Login.dart';
import '../presentation/Screens/OuterMainTabs.dart';
import '../presentation/Screens/PinScreen.dart';
import '../presentation/Screens/SplashScreen.dart';
import '../presentation/Screens/InnerMainTabs.dart';

class Routes {
  static const String splashRoute = "/";
  static const String welcomeRoute = "/Welcome";
  static const String onBoardingRoute = "/onBoarding";
  static const String loginRoute = "/login";
  static const String addressRoute = "/address";
  static const String registerRoute = "/register";
  static const String verifyRoute = "/verify";
  static const String homeRoute = "/home";
  static const String internalWelcomeRoute = "/internalWelcome";
  static const String tabBarRoute = "/tabBar";
  static const String categoriesRoute = "/categories";
  static const String myLocation = "/location";
  static const String mapRoute = "/mapScreen";
  static const String cartRoute = "/CartScreen";
  static const String noInternetScreenRoute = "/NoInternetScreen";
  static const String checkOutRoute = "/CheckOutScreen";
  static const String mainRoute = "/MainTabs";
  static const String pinRoute = "/PinScreen";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      // case Routes.myLocation:
      //   return MaterialPageRoute(builder: (_) => const MyLocationScreen());
      // case Routes.checkOutRoute:
      //   return MaterialPageRoute(builder: (_) =>   CheckOutScreen());
      // case Routes.noInternetScreenRoute:
      //   return MaterialPageRoute(builder: (_) => const NoInternetScreen());
      case Routes.mainRoute:
        return MaterialPageRoute(builder: (_) =>   OuterMainTabs());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.pinRoute:
        return MaterialPageRoute(builder: (_) =>   PinScreen());
      // case Routes.categoriesRoute:
      //   return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      // case Routes.verifyRoute:
      //   return MaterialPageRoute(builder: (_) => const VertifyScreen());
      // case Routes.registerRoute:
      //   return MaterialPageRoute(builder: (_) => const RegisterScreen(email: '',));
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) =>  HomeScreen());
      // case Routes.internalWelcomeRoute:
      //   return MaterialPageRoute(builder: (_) => const WelcomInternal());
      // case Routes.welcomeRoute:
      //   return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case Routes.tabBarRoute:
        return MaterialPageRoute(builder: (_) => const InnerMainTabs());
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(appBar: AppBar(title: const Text("No Route Found"),),
              body: const Center(child: Text("No Route Found")),
            ));
  }
}
