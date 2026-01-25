import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/widgets/glass_container.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'monthly'; // monthly, yearly, student

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image/Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E2742), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header (Close Button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      GlassContainer(
                        onTap: () => context.pop(),
                        padding: const EdgeInsets.all(8),
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.star_rounded, size: 64, color: AppColors.warning)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
                        const SizedBox(height: 16),
                        
                        Text(
                          'Upgrade to PRO',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: 0.2),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Unlock unlimited vocabulary, personalized AI reels, and advanced games.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        const SizedBox(height: 48),

                        // Plans
                        _PlanCard(
                          title: 'Annual',
                          price: '19,990 ₸ / year',
                          subtitle: 'Best Value (1,665 ₸/mo)',
                          isSelected: _selectedPlan == 'yearly',
                          isBestValue: true,
                          onTap: () => setState(() => _selectedPlan = 'yearly'),
                        ).animate().fadeIn(delay: 300.ms).slideX(),
                        
                        const SizedBox(height: 16),
                        
                        _PlanCard(
                          title: 'Monthly',
                          price: '2,490 ₸ / month',
                          subtitle: 'Flexible cancellation',
                          isSelected: _selectedPlan == 'monthly',
                          onTap: () => setState(() => _selectedPlan = 'monthly'),
                        ).animate().fadeIn(delay: 400.ms).slideX(),
                        
                        const SizedBox(height: 16),
                        
                        _PlanCard(
                          title: 'Student',
                          price: '1,990 ₸ / month',
                          subtitle: 'Verify student ID',
                          isSelected: _selectedPlan == 'student',
                          onTap: () => setState(() => _selectedPlan = 'student'),
                        ).animate().fadeIn(delay: 500.ms).slideX(),
                        
                        // Student ID Upload Section
                        if (_selectedPlan == 'student')
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: GlassContainer(
                              padding: const EdgeInsets.all(16),
                              color: Colors.white,
                              opacity: 0.1,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Student ID uploaded successfully!')),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Upload Student ID',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn().slideY(),

                        const SizedBox(height: 32),
                        
                        // Action Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _handlePurchase(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms).scale(),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'Restore Purchase',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(BuildContext context) {
    // Mock purchase flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Purchase Successful!', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You are now a PRO member.\n(This is a mockup, no charge involved)',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Close screen
            },
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool isSelected;
  final bool isBestValue;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    this.isBestValue = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white12,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.premiumGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BEST OFFER',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryLight : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade600,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
