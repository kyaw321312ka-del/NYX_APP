import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nyxproject/features/rental/presentation/walkin/walkin.dart';
import 'package:nyxproject/features/tournament/presentation/tournamentMain.dart';
import 'package:provider/provider.dart';
import 'package:nyxproject/features/dashboard/presentation/dashboard.dart';
import 'package:nyxproject/features/dashboard/presentation/services.dart';
import 'package:nyxproject/features/shop/presentation/shop.dart';
import 'package:nyxproject/features/profile/presentation/account.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';

class MainDashboard extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const MainDashboard({
    super.key,
    required this.sessionService,
    this.cartService,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int currentPageIndex = 0;
  String? language;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashBoard(
        sessionService: widget.sessionService,
        cartService: widget.cartService,
      ),
      ShopPage(cartService: widget.cartService),
      const Services(),
      const WalkInScreen(),
      AccountPage(sessionService: widget.sessionService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 0),
            Expanded(
              child: IndexedStack(index: currentPageIndex, children: _pages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 13, 27, 42),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: "Services"),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk_outlined),
            label: "Walk-In",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 48,
            child: Image.asset(
              'assets/images/logo1.png',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'NYX',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                );
              },
            ),
          ),
          Row(
            children: [
              // GestureDetector(
              //   onTap: () {
              //     showModalBottomSheet(
              //       context: context,
              //       backgroundColor: Colors.white,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.vertical(
              //           top: Radius.circular(20),
              //         ),
              //       ),
              //       builder: (context) {
              //         List<String> languages = [
              //           "English",
              //           "Myanmar",
              //           "Chinese",
              //         ];
              //         return Padding(
              //           padding: const EdgeInsets.all(20),
              //           child: ListView.builder(
              //             shrinkWrap: true,
              //             itemCount: languages.length,
              //             itemBuilder: (context, index) {
              //               return ListTile(
              //                 leading: Icon(Icons.language),
              //                 title: Text(languages[index]),
              //                 onTap: () {
              //                   Navigator.pop(context);
              //                 },
              //               );
              //             },
              //           ),
              //         );
              //       },
              //     );
              //   },
              //   child: Icon(
              //     Icons.language,
              //     color: Colors.white,
              //   ),
              // ),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.notifications_none, color: Colors.white),
              // ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const tournamentMain(),
                    ),
                  );
                },
                icon: FaIcon(
                  FontAwesomeIcons.trophy,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // Navigate to cart page when cart icon is pressed
                      setState(() {
                        currentPageIndex = 3; // Cart page index
                      });
                    },
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                  ),
                  // Cart badge
                  Consumer<CartService>(
                    builder: (context, cartService, child) {
                      if (cartService.itemCount > 0) {
                        return Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartService.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
