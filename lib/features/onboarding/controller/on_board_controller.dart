import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/onboarding_item.dart';

class OnboardingState {
  final List<OnboardingItem> items;
  final int currentPage;

  const OnboardingState({
    required this.items,
    required this.currentPage,
  });

  bool get isLastPage => currentPage == items.length - 1;

  OnboardingState copyWith({
    List<OnboardingItem>? items,
    int? currentPage,
  }) {
    return OnboardingState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}


class OnboardingController extends Notifier<OnboardingState>{
  @override
  OnboardingState build() {

    return OnboardingState(
      currentPage: 0,
      items: const [
        OnboardingItem(
          title: 'Khám phá Tiếng vọng',
          description: 'Xem, nghe và trải nghiệm những Echo được để lại quanh bạn. Mỗi bước chân đều có thể mở ra một câu chuyện mới.',
          image: 'assets/images/on_board_1.png',
        ),
        OnboardingItem(
          title: 'Chia sẻ ký ức',
          description: 'Thả tim, bình luận và theo dõi những người để lại Echo thú vị. Tạo nên mạng xã hội cảm xúc ngay tại khuôn viên NLU.',
          image: 'assets/images/on_board_2.png',
        ),
        OnboardingItem(
          title: 'Gửi lời nhắn cho tương lai',
          description: 'Đặt Echo của bạn để mở khóa sau này. Lời nhắn cho chính mình ngày tốt nghiệp hay bí kíp cho khóa sau – tất cả đều trong tầm tay khi đến đúng địa điểm.',
          image: 'assets/images/on_board_3.png',
        ),
      ],
    );
  }



  void nextPage() {
    if (!state.isLastPage) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setCurrentPage(int index) {
    if (index >= 0 && index < state.items.length) {
      state = state.copyWith(currentPage: index);
    }
  }

}