// lib/pages/account.dart
import 'package:flutter/material.dart';
import 'package:nyxproject/features/profile/presentation/accountpages/changepassword.dart';
import 'package:nyxproject/features/profile/presentation/accountpages/contactus.dart';
import 'package:nyxproject/features/profile/presentation/accountpages/deleteaccount.dart';
import 'package:nyxproject/features/profile/presentation/accountpages/editprofile.dart';
import 'package:nyxproject/features/training/presentation/myclasses.dart';
import 'package:nyxproject/features/rental/presentation/myBookingList.dart';
// import 'package:nyxproject/features/orders/presentation/orderHistory.dart';
import 'package:nyxproject/features/orders/presentation/orderHistory.dart';
import 'package:nyxproject/features/rental/presentation/walkinBooking.dart';
import 'package:nyxproject/features/auth/presentation/terms.dart';
import 'package:nyxproject/features/profile/presentation/widgets/accountWidgets/account_menu_item.dart';
import 'package:nyxproject/features/profile/presentation/widgets/accountWidgets/account_section.dart';
import 'package:nyxproject/features/profile/presentation/widgets/accountWidgets/login_prompt_card.dart';
import 'package:nyxproject/features/profile/presentation/widgets/accountWidgets/logout_button.dart';

import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:nyxproject/features/cart/domain/cart_service.dart';

class AccountPage extends StatefulWidget {
  final SessionService sessionService;
  final CartService? cartService;

  const AccountPage({
    super.key,
    required this.sessionService,
    this.cartService,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.sessionService.isLoggedIn();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),

              // Show login/signup section only when NOT logged in
              if (!isLoggedIn) ...[
                LoginPromptCard(
                  sessionService: widget.sessionService,
                  cartService: widget.cartService,
                ),
                const Divider(),
              ],

              const AccountSection(title: "Account"),

              // Edit Profile - Only show when logged in
              if (isLoggedIn) ...[
                AccountMenuItem(
                  icon: Icons.edit,
                  title: "Edit Profile",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfile(sessionService: widget.sessionService),
                      ),
                    );
                  },
                ),
              ],

              AccountMenuItem(
                icon: Icons.shopping_cart_outlined,
                title: "My Orders",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const orderHistory(),
                    ),
                  );
                },
              ),
              AccountMenuItem(
                icon: Icons.shopping_cart_outlined,
                title: "Walkin Booking List",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Walkinbooking(),
                    ),
                  );
                },
              ),

              AccountMenuItem(
                icon: Icons.favorite,
                title: "My Booking List",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const myBookingList(),
                    ),
                  );
                },
              ),

              AccountMenuItem(
                icon: Icons.list_alt,
                title: "My Classes",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Classes()),
                  );
                },
              ),

              const Divider(),
              // const AccountSection(title: "Settings"),

              // AccountMenuItem(
              //   icon: Icons.settings,
              //   title: "Setting & Preferences",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const Setting()),
              //     );
              //   },
              // ),

              // const Divider(),
              const AccountSection(title: "Others"),

              AccountMenuItem(
                icon: Icons.phone,
                title: "Contact Us",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ContactUs()),
                  );
                },
              ),
              AccountMenuItem(
                icon: Icons.lock_outline,
                title: "Change Password",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Changepassword(),
                    ),
                  );
                },
              ),

              // AccountMenuItem(
              //   icon: Icons.help_outline,
              //   title: "Help Center",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => const helpPage()),
              //     );
              //   },
              // ),
              if (isLoggedIn)
                AccountMenuItem(
                  icon: Icons.delete,
                  title: "Delete Account",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DeleteAccount(sessionService: widget.sessionService),
                      ),
                    );
                  },
                ),
              AccountMenuItem(
                icon: Icons.policy,
                title: "Terms & Policies",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const termsPage()),
                  );
                },
              ),

              const Divider(),
              const SizedBox(height: 10),

              // Show logout button only when logged in
              if (isLoggedIn)
                LogoutButton(
                  sessionService: widget.sessionService,
                  cartService: widget.cartService,
                ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
