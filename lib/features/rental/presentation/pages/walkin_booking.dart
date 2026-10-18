import 'package:flutter/material.dart';
import 'package:nyxproject/features/rental/data/datasources/RentelApi/walkin_booking_list_api.dart';
import 'package:nyxproject/features/rental/domain/entities/walkin_booking_list.dart';
import 'package:nyxproject/features/user/data/datasources/session_manager.dart';
import 'package:provider/provider.dart';

class Walkinbooking extends StatefulWidget {
  const Walkinbooking({super.key});

  @override
  State<Walkinbooking> createState() => _WalkinbookingState();
}

class _WalkinbookingState extends State<Walkinbooking> {
  late Future<List<WalkinBookingList>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchBookings();
  }

  Future<List<WalkinBookingList>> _fetchBookings() async {
    final token = context.read<SessionService>().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please log in to view your walk-in bookings.');
    }

    final response = await WalkinBookingListApi.getBookings(token: token);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to load bookings');
    }
    return List<WalkinBookingList>.from(response['data'] as List);
  }

  Future<void> _reload() async {
    final bookingsFuture = _fetchBookings();
    setState(() {
      _bookingsFuture = bookingsFuture;
    });
    try {
      await bookingsFuture;
    } catch (_) {
      // FutureBuilder displays the failure state; refresh should still finish.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walk-in Booking List')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<WalkinBookingList>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _scrollableMessage(
                const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _scrollableMessage(
                _MessageState(
                  icon: Icons.error_outline,
                  message: snapshot.error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
                  action: _reload,
                ),
              );
            }

            final bookings = snapshot.data ?? const <WalkinBookingList>[];
            if (bookings.isEmpty) {
              return _scrollableMessage(
                const _MessageState(
                  icon: Icons.event_busy_outlined,
                  message: 'No walk-in bookings found',
                ),
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _BookingCard(booking: bookings[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _scrollableMessage(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [SizedBox(height: 320, child: child)],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final WalkinBookingList booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.venueName.isEmpty
                        ? 'Walk-in booking'
                        : booking.venueName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('Booking #${booking.bookingId}'),
              ],
            ),
            const Divider(),
            _DetailRow(label: 'Court', value: booking.courtName),
            _DetailRow(label: 'Name', value: booking.bookingName),
            _DetailRow(label: 'Phone', value: booking.phone),
            _DetailRow(label: 'Date', value: booking.date),
            _DetailRow(label: 'Time', value: booking.time),
            _DetailRow(label: 'Payment', value: booking.paymentMethod),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${booking.amount} Ks',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 86, child: Text(label)),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? action;

  const _MessageState({required this.icon, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: action, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
