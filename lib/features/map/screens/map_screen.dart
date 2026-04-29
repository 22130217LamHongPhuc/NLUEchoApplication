import 'dart:ui';
import 'package:echo_nlu/core/router/app_infor_router.dart';
import 'package:echo_nlu/core/utils/toast_message.dart';
import 'package:echo_nlu/features/map/controllers/map_home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trackasia_gl/trackasia_gl.dart';

import '../../echo/screens/choose_create_echo.dart';
import '../controllers/map_home_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/create_echo_fab.dart';
import '../widgets/echo_preview_card.dart';
import '../widgets/location_status_banner.dart';
import '../widgets/near_by_echo_pager.dart';
import '../widgets/near_by_guidance_card.dart';
import '../widgets/top_panel_floating.dart';

class MapHomeScreen extends ConsumerStatefulWidget {
  const MapHomeScreen({super.key});

  @override
  ConsumerState<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends ConsumerState<MapHomeScreen> {
  late final ProviderSubscription<MapHomeState> listen;

  @override
  void initState() {
    super.initState();

    listen = ref.listenManual(mapHomeProvider, (previous, next) {
      if (next.errorMessage != null) {
        showToast(
          context,
          message: next.errorMessage!,
          backgroundColor: Colors.deepOrangeAccent,
          icon: Icons.warning_amber_outlined,
        );
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    listen.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapHomeProvider);
    final controller = ref.read(mapHomeProvider.notifier);
    final mediaQuery = MediaQuery.of(context);

    debugPrint(
      'MapHomeScreen rebuild: selectedEcho=${state.selectedEcho?.id}, nearestEcho=${state.nearestEcho?.id}, nearbyCount=${state.nearbyEchoes.length}, showTips=${state.showTips}',
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          TrackAsiaMap(
            styleString:
                'https://maps.track-asia.com/styles/v1/simple.json?key=dba0fc3359f300e4d5917746880615a4ae',
            initialCameraPosition: const CameraPosition(
              target: MapHomeController.nluCenter,
              zoom: 18.6,
            ),
            // minMaxZoomPreference: const MinMaxZoomPreference(14, 20),
            myLocationEnabled: true,
            onMapCreated: controller.onMapCreated,
          ),

          // const _MapPremiumOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  TopFloatingPanel(
                    statusText: controller.locationBannerText(),
                    accessState: state.accessState,
                    filters: controller.filters,
                    selectedIndex: state.selectedFilter,
                    onFilterSelected: controller.selectFilter,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height / 2,
            child: _MapQuickActions(
              onFocusCampus: controller.focusToNLU,
              onFocusUser: controller.focusToUser,
              showIconTips: !state.showTips,
              onShowTips: controller.onShowTips,
            ),
          ),

          Positioned(
            left: 5,
            right: 5,
            bottom: mediaQuery.padding.bottom + 110,
            child: _MapBottomPanel(
              state: state,
              controller: controller,
              onClose: () => controller.onCloseTips(),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CreateEchoFab(
        enabled: controller.canCreateEcho(),
        onTap: () {
          if (!controller.canCreateEcho()) {
            showToast(
              context,
              message: 'Bạn cần ở trong khuôn viên NLU để tạo Echo mới',
              backgroundColor: Colors.amberAccent,
            );
            return;
          }

          showEchoTypeSelectorSheet(
            context,
            onSelected: (type) {
              context.push(AppInforRouter.createEchoPath, extra: type);
            },
          );
        },
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _MapQuickActions extends StatelessWidget {
  final bool showIconTips;
  final VoidCallback onFocusCampus;
  final VoidCallback onFocusUser;
  final VoidCallback onShowTips;

  const _MapQuickActions({
    required this.onFocusCampus,
    required this.onFocusUser,
    required this.showIconTips,
    required this.onShowTips,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RoundGlassActionButton(
          icon: Icons.school_rounded,
          onTap: onFocusCampus,
        ),
        const SizedBox(height: 12),
        _RoundGlassActionButton(
          icon: Icons.my_location_rounded,
          onTap: onFocusUser,
        ),
        const SizedBox(height: 12),

        showIconTips
            ? _RoundGlassActionButton(
                icon: Icons.tips_and_updates_outlined,
                onTap: onShowTips,
              )
            : SizedBox.shrink(),
      ],
    );
  }
}

class _MapBottomPanel extends StatelessWidget {
  final MapHomeState state;
  final MapHomeController controller;
  final VoidCallback onClose;
  final PageController _pageController = PageController(viewportFraction: 0.92);

  _MapBottomPanel({
    required this.state,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (state.selectedEcho != null) {
      debugPrint(
        'Showing EchoPreviewCard for echo id: ${state.selectedEcho!.id}',
      );
      child = EchoPreviewCard(
        key: ValueKey('selected_${state.selectedEcho!.id}'),
        echo: state.selectedEcho!,
        onClose: controller.clearSelectedEcho,
        isGuiding: state.isGuiding,
        onGuide: controller.showGuideLine,
        onOpen: (echo) {
          final check = controller.checkCondition(echo);

          if (check) {
            context.push(
              AppInforRouter.echoDetailPath,
              extra: state.selectedEcho!,
            );
          }
        },
      );
    } else if (!state.showTips) {
      child = SizedBox.shrink();
    } else {
      final listNearEchoes = state.nearbyEchoes;

      if(listNearEchoes.isNotEmpty){
        if(state.showNearbyPager){
          child = NearbyEchoPager(
            echoes: listNearEchoes,
            isGuiding: state.isGuiding,
            onGuide: controller.showGuideLine,
            onOpen: (echo) {
              final check = controller.checkCondition(echo);

              debugPrint(
                'Attempting to open echo id: ${echo.id}, check result: $check',
              );

              if (check) {
                context.push(
                  AppInforRouter.echoDetailPath,
                  extra: echo,
                );
              }
            },
            onClose: controller.closeNearbyPager,
          );
        }else{
          final echo = state.nearestEcho!;
          final remaining =
          (echo.distance - MapHomeController.echoUnlockRadiusInMeters)
              .clamp(0, double.infinity);

          child = NearbyGuidanceCard(
            key: ValueKey('nearby_${echo.id}'),
            nearbyCount: state.nearbyEchoes.length,
            title: echo.title,
            distanceText: '${echo.distance.round()}m',
            hintText: echo.distance <= MapHomeController.echoUnlockRadiusInMeters
                ? 'Bạn đã ở trong vùng mở Echo'
                : 'Đi thêm ${remaining.round()}m để mở Echo',
            onOpenList: controller.openNearbyPager,
            onGoTo: controller.openNearbyPager,
            onClose: onClose,
          );
        }
      }else{
        child = EmptyDiscoveryCard(
          onExploreCampus: controller.focusToNLU,
        );
      }

    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.18),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: child,
    );
  }
}

class _MapPremiumOverlay extends StatelessWidget {
  const _MapPremiumOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.22),
              Colors.transparent,
              Colors.black.withOpacity(0.34),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopGlassBar extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onAvatarTap;

  const _TopGlassBar({
    required this.onNotificationTap,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64F4AC), Color(0xFF6C7BFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64F4AC).withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(Icons.waves_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NLU Echo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Lưu giữ ký ức tại nơi bạn đứng',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              _MiniGlassButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                    border: Border.all(color: Colors.white.withOpacity(0.16)),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniGlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;

  const _FilterChipsRow({required this.filters, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            // onTap: () => onSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isSelected
                    ? const Color(0xFF66F5AF).withOpacity(0.22)
                    : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF66F5AF).withOpacity(0.9)
                      : Colors.white.withOpacity(0.12),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF66F5AF).withOpacity(0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoundGlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundGlassActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.11),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.map_rounded, label: 'Map', active: true),
          _NavItem(icon: Icons.grid_view_rounded, label: 'Wall'),
          SizedBox(width: 60),
          _NavItem(icon: Icons.favorite_rounded, label: 'Saved'),
          _NavItem(icon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2E7D32) : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class EchoMarker extends StatefulWidget {
  final Color color;
  final IconData icon;

  const EchoMarker({super.key, required this.color, required this.icon});

  @override
  State<EchoMarker> createState() => _EchoMarkerState();
}

class _EchoMarkerState extends State<EchoMarker> {
  @override
  Widget build(BuildContext context) {
    final baseSize = 40.0;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: baseSize + 42 * 0.6,
            height: baseSize + 42 * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.22 * 1),
            ),
          ),
          Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.66),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(widget.icon, size: 13, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class PulseEchoMarker extends StatefulWidget {
  final Color color;
  final IconData icon;
  final bool isSelected;

  const PulseEchoMarker({
    super.key,
    required this.color,
    required this.icon,
    this.isSelected = false,
  });

  @override
  State<PulseEchoMarker> createState() => _PulseEchoMarkerState();
}

class _PulseEchoMarkerState extends State<PulseEchoMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = 55.0;

    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 0.6 + (_controller.value * 1.15);
          final opacity = (1 - _controller.value).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: baseSize + 42 * scale,
                height: baseSize + 42 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.22 * opacity),
                ),
              ),
              Container(
                width: baseSize,
                height: baseSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.66),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(widget.icon, size: 26, color: Colors.white),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MarkerVisual {
  final double top;
  final double? left;
  final double? right;
  final Color color;
  final IconData icon;

  const _MarkerVisual({
    required this.top,
    this.left,
    this.right,
    required this.color,
    required this.icon,
  });
}

_MarkerVisual _markerVisualById(String id) {
  switch (id) {
    case '1':
      return const _MarkerVisual(
        top: 250,
        left: 125,
        color: Color(0xFF66F5AF),
        icon: Icons.lock_open_rounded,
      );
    case '2':
      return const _MarkerVisual(
        top: 350,
        right: 90,
        color: Color(0xFF8B7BFF),
        icon: Icons.lock_rounded,
      );
    case '3':
      return const _MarkerVisual(
        top: 430,
        left: 210,
        color: Color(0xFFFFB84D),
        icon: Icons.hourglass_top_rounded,
      );
    default:
      return const _MarkerVisual(
        top: 250,
        left: 125,
        color: Color(0xFF66F5AF),
        icon: Icons.place_rounded,
      );
  }
}
