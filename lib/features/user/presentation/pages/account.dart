import 'package:flutter/material.dart';

import 'package:nyxproject/features/user/presentation/pages/changepassword.dart';
import 'package:nyxproject/features/user/presentation/pages/contactus.dart';
import 'package:nyxproject/features/user/presentation/pages/deleteaccount.dart';
import 'package:nyxproject/features/user/presentation/pages/editprofile.dart';
import 'package:nyxproject/features/training/presentation/pages/myclasses.dart';
import 'package:nyxproject/features/rental/presentation/pages/my_booking_list.dart';
import 'package:nyxproject/features/orders/presentation/pages/order_history.dart';
import 'package:nyxproject/features/rental/presentation/pages/walkin_booking.dart';
import 'package:nyxproject/features/user/presentation/pages/terms.dart';

import 'package:nyxproject/features/user/presentation/widgets/account_menu_item.dart';
import 'package:nyxproject/features/user/presentation/widgets/account_section.dart';
import 'package:nyxproject/features/user/presentation/widgets/login_prompt_card.dart';
import 'package:nyxproject/features/user/presentation/widgets/logout_button.dart';

import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:nyxproject/features/cart/presentation/bloc/cart_service.dart';

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
  static const Color _navy = Color(0xFF0D1B2A);
  static const Color _red = Color(0xFFEF3340);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _muted = Color(0xFF788292);

  void _navigate(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _muted,
                letterSpacing: 0.7,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = widget.sessionService.isLoggedIn();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page heading
              const Text(
                'My Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isLoggedIn
                    ? 'Manage your account and activities.'
                    : 'Sign in to manage your activities.',
                style: const TextStyle(fontSize: 14, color: _muted),
              ),

              const SizedBox(height: 22),

              // Guest login prompt
              if (!isLoggedIn) ...[
                LoginPromptCard(
                  sessionService: widget.sessionService,
                  cartService: widget.cartService,
                ),
                const SizedBox(height: 20),
              ],

              // Account and activity
              _sectionCard(
                title: 'ACCOUNT & ACTIVITY',
                children: [
                  if (isLoggedIn)
                    AccountMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () => _navigate(
                        EditProfile(sessionService: widget.sessionService),
                      ),
                    ),

                  AccountMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'My Orders',
                    onTap: () => _navigate(const OrderHistory()),
                  ),

                  AccountMenuItem(
                    icon: Icons.event_available_outlined,
                    title: 'Walk-in Booking List',
                    onTap: () => _navigate(const Walkinbooking()),
                  ),

                  AccountMenuItem(
                    icon: Icons.sports_tennis_rounded,
                    title: 'My Booking List',
                    onTap: () => _navigate(const MyBookingList()),
                  ),

                  AccountMenuItem(
                    icon: Icons.school_outlined,
                    title: 'My Classes',
                    onTap: () => _navigate(const Classes()),
                  ),
                ],
              ),

              // Support and legal
              _sectionCard(
                title: 'SUPPORT & LEGAL',
                children: [
                  AccountMenuItem(
                    icon: Icons.support_agent_rounded,
                    title: 'Contact Us',
                    onTap: () => _navigate(const ContactUs()),
                  ),

                  AccountMenuItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    onTap: () => _navigate(const Changepassword()),
                  ),

                  AccountMenuItem(
                    icon: Icons.policy_outlined,
                    title: 'Terms & Policies',
                    onTap: () => _navigate(const TermsPage()),
                  ),

                  if (isLoggedIn)
                    AccountMenuItem(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Account',
                      onTap: () => _navigate(
                        DeleteAccount(sessionService: widget.sessionService),
                      ),
                    ),
                ],
              ),

              // Logout
              if (isLoggedIn) ...[
                const SizedBox(height: 2),
                LogoutButton(
                  sessionService: widget.sessionService,
                  cartService: widget.cartService,
                ),
              ],

              const SizedBox(height: 12),

              // Footer
              const Center(
                child: Text(
                  'NYX',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: Color(0xFFADB4BF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
