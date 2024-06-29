import 'package:back_office/admin.dart';
import 'package:back_office/component/new_food.dart';
import 'package:back_office/component/new_table.dart';
import 'package:back_office/component/new_ticket.dart';
import 'package:back_office/finance_report_page.dart';
import 'package:back_office/firebase_options.dart';
import 'package:back_office/food_management.dart';
import 'package:back_office/homepage.dart';
import 'package:back_office/login_screen.dart';
import 'package:back_office/model/bill_order_model.dart';
import 'package:back_office/model/food_model.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/register_user.dart';
import 'package:back_office/component/verify_qr_table.dart';
import 'package:back_office/component/verify_qr_ticket.dart';
import 'package:back_office/table_management.dart';
import 'package:back_office/ticket_management.dart';
import 'package:back_office/verify_reservation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => MemberUserModel(),
      ),
      ChangeNotifierProvider(
        create: (context) => BillOrderProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ReserveTableProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ReservationTicketProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ProductModel(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrinkXplorer (Back office)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF455A64)!,
              onPrimary: const Color.fromRGBO(38, 50, 56, 1)!,
              secondary: Color.fromARGB(255, 247, 151, 18),
              onSecondary: Colors.teal[600]!,
              error: const Color(0xFFF32424),
              onError: const Color.fromARGB(255, 231, 100, 13),
              background: const Color.fromARGB(255, 231, 230, 230),
              onBackground: const Color(0xFF000000),
              surface: const Color(0xFFFFFFFF),
              onSurface: Colors.grey[600]!),
          textTheme: const TextTheme(
              bodyMedium: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              bodySmall: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.normal)),
          useMaterial3: true),

      //register sub class
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterScreen(),
        // '/profile': (context) => ProfilePage(),
        '/home': (context) => NewHomePage(),
        '/verify': (context) => VerifyReservationPage(),
        '/qrtable': (context) => VerifyTablePage(),
        '/qrticket': (context) => VerifyTicketPage(),
        '/food': (context) => FoodAndBeverageManagement(),
        '/newfood': (context) => NewProductPage(),
        '/table': (context) => TableManagementScreen(),
        '/newtable': (context) => AddNewTablePage(),
        '/ticket': (context) => TicketManagementScreen(),
        '/newticket': (context) => AddTicketPage(),
        '/report': (context) => FinancialReportPage(),

        '/admin': (context) => AdminHomePage(),
      },
    );
  }
}
