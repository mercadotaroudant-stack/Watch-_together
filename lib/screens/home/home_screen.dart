import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/home_providers.dart';
import '../../widgets/app_drawer/app_drawer.dart';
import 'widgets/continue_watching_section.dart';
import 'widgets/home_search_sheet.dart';
import 'widgets/home_top_header.dart';
import 'widgets/premium_banner_card.dart';
import 'widgets/public_rooms_section.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/user_welcome_card.dart';

/// WatchTogether's real Home screen (Phase 4) — replaces the temporary
/// `FoundationScreen` at [RouteNames.home].
///
/// Every section reads real data from the app's existing repositories/
/// providers (auth, rooms, watch history, premium, notifications) via
/// Riverpod — nothing here is mocked. See each `widgets/` file for the
/// specific provider it watches.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldBodyContext) {
            return RefreshIndicator(
              color: AppColors.homePrimary,
              backgroundColor: AppColors.homeCard,
              onRefresh: () async {
                ref.invalidate(publicRoomsStreamProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeTopHeader(
                      onSearchTap: () => HomeSearchSheet.show(context),
                      onMenuTap: () => Scaffold.of(scaffoldBodyContext).openDrawer(),
                    ),
                    const SizedBox(height: 12),
                    UserWelcomeCard(user: user),
                    const SizedBox(height: 28),
                    const QuickActionsSection(),
                    const SizedBox(height: 28),
                    const PublicRoomsSection(),
                    const SizedBox(height: 28),
                    const ContinueWatchingSection(),
                    const SizedBox(height: 20),
                    const PremiumBannerCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
