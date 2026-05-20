import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expert.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/app_providers.dart';

class BookExpertScreen extends ConsumerStatefulWidget {
  final Expert expert;

  const BookExpertScreen({super.key, required this.expert});

  @override
  ConsumerState<BookExpertScreen> createState() => _BookExpertScreenState();
}

class _BookExpertScreenState extends ConsumerState<BookExpertScreen> {
  int _selectedServiceIndex = 0;
  DateTime? _selectedDate;
  String _selectedTime = '10:00 AM';
  final TextEditingController _noteController = TextEditingController();
  bool _isBooked = false;
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    if (price >= 1000) return '\u20a6${(price / 1000).toStringAsFixed(0)}K';
    return '\u20a6$price';
  }

  @override
  Widget build(BuildContext context) {
    if (_isBooked) return _buildSuccessScreen(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Book Expert',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExpertMiniCard(),
            const SizedBox(height: 20),

            if (widget.expert.services.isNotEmpty) ...[
              _buildSectionTitle('Select Service'),
              const SizedBox(height: 10),
              ...widget.expert.services.asMap().entries.map((entry) {
                final i = entry.key;
                final service = entry.value;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedServiceIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedServiceIndex == i
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade200,
                        width: _selectedServiceIndex == i ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(service.icon,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(service.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.textDark)),
                              Text(service.description,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                        Text(_formatPrice(service.price),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.primaryBlue)),
                        const SizedBox(width: 6),
                        Icon(
                          _selectedServiceIndex == i
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _selectedServiceIndex == i
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade300,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            _buildSectionTitle('Select Date'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 60)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryBlue),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDate != null
                        ? AppTheme.primaryBlue
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate == null
                          ? 'Choose a date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(
                          color: _selectedDate == null
                              ? AppTheme.textMuted
                              : AppTheme.textDark,
                          fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppTheme.textMuted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Select Time'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedTime == slot;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(slot,
                        style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textMuted,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Project Notes (Optional)'),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe what you need help with...',
                hintStyle: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(widget.expert.services.isEmpty
                        ? 'Confirm Booking'
                        : 'Confirm  \u2022  ${_formatPrice(widget.expert.services[_selectedServiceIndex].price)}'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: AppTheme.primaryBlue),
      );
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final service = widget.expert.services.isNotEmpty
          ? widget.expert.services[_selectedServiceIndex]
          : null;

      final booking = Booking(
        id: '',
        clientId: user.uid,
        clientName: user.name,
        expertId: widget.expert.id,
        expertName: widget.expert.name,
        serviceName: service?.name ?? 'Consultation',
        servicePrice: service?.price ?? widget.expert.startingPrice,
        scheduledAt: _selectedDate!,
        notes: _noteController.text.trim(),
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref.read(bookingServiceProvider).createBooking(booking);

      if (mounted) setState(() { _isBooked = true; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Booking failed: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildExpertMiniCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
            child: Text(widget.expert.name[0],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.expert.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textDark)),
                Text(widget.expert.title,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  size: 14, color: AppTheme.warningAmber),
              const SizedBox(width: 2),
              Text('${widget.expert.rating}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark));
  }

  Widget _buildSuccessScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      size: 48, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('Booking Confirmed!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark)),
                const SizedBox(height: 12),
                Text(
                  'Your booking with ${widget.expert.name} has been confirmed for $_selectedTime on ${_selectedDate?.day}/${_selectedDate?.month}/${_selectedDate?.year}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: const BorderSide(
                          color: AppTheme.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View Booking'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
