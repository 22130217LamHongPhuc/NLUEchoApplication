import 'dart:io';

import 'package:echo_nlu/core/constants/app_text_size.dart';
import 'package:echo_nlu/core/enums/echo_type.dart';
import 'package:echo_nlu/features/echo/controllers/create_echo_state.dart';
import 'package:echo_nlu/features/echo/providers/create_echo_provider.dart';
import 'package:echo_nlu/features/echo/widgets/item_audio.dart';
import 'package:echo_nlu/features/echo/widgets/location_text.dart';
import 'package:echo_nlu/features/echo/widgets/item_anonymous.dart';
import 'package:echo_nlu/features/echo/widgets/item_capsule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/components/button_custom.dart';
import '../../../core/components/loading_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/toast_message.dart';

class CreateEchoScreen extends ConsumerStatefulWidget {
  final EchoType echoType;

  const CreateEchoScreen({super.key, required this.echoType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CreateImageTextEchoScreenState();
  }
}

class _CreateImageTextEchoScreenState
    extends ConsumerState<CreateEchoScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  final titleFocusNode = FocusNode();
  final contentFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(createEchoProvider.notifier).getNearbyLocation();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    contentController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CreateEchoState>(createEchoProvider, (previous, next) {
      if (next.errorMessage != null) {
        showErrorToast(context, next.errorMessage!);
      }

      if (next.status == CreateEchoStatus.success) {
        showSuccessToast(context, 'Tạo Echo thành công!');
        Navigator.of(context).pop();
      }
    });

    final theme = Theme.of(context);
    final state = ref.watch(createEchoProvider.select((state) => state.status));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.accent,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        actions: [
          Center(
            child: Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tạo Echo',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppTextSize.lg,
                fontWeight: FontWeight.bold,
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(
                  createEchoProvider.select(
                        (state) => state.nearbyLocationState,
                  ),
                );

                return LocationText(
                  locationName: state.selectedLocation?.name,
                  isLoading: state.isLoading,
                );
              },
            ),
          ],
        ),
        backgroundColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          // padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              state == CreateEchoStatus.loading
                  ? Center(child: const LoadingBar(text: 'Đang tạo Echo...'))
                  : buildContentEcho(theme, widget.echoType),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContentEcho(ThemeData theme, EchoType echoType) {
    return echoType == EchoType.image
        ? Column(
      children: [
        SizedBox(height: AppSpacing.xl),
        _buildTitle(theme, titleController, titleFocusNode),
        SizedBox(height: AppSpacing.xl),
        _builDescription(theme, contentController, contentFocusNode),
        SizedBox(height: AppSpacing.xl),
        ChooseImagePlaceholder(),
        SizedBox(height: AppSpacing.xl),
        ItemAnonymous(),
        SizedBox(height: AppSpacing.xl),
        ItemCapsule(
          contentFocus: contentFocusNode,
          titleFocus: titleFocusNode,
        ),
        SizedBox(height: AppSpacing.xl),
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: ButtonCustom(
            titleButton: 'Tạo Echo',
            onNextPressed: () {
              ref
                  .read(createEchoProvider.notifier)
                  .createEcho(
                title: titleController.text,
                content: contentController.text,
                echoType: EchoType.image
              );
            },
          ),
        ),
      ],
    )
        : Column(
        children: [
          ItemAudio(),
          SizedBox(height: AppSpacing.xl),
          _buildTitle(theme, titleController, titleFocusNode),
          SizedBox(height: AppSpacing.xl),
          _builDescription(theme, contentController, contentFocusNode),
          SizedBox(height: AppSpacing.xl),
          ItemAnonymous(),
          SizedBox(height: AppSpacing.xl),
          ItemCapsule(
            contentFocus: contentFocusNode,
            titleFocus: titleFocusNode,
          ),
          SizedBox(height: AppSpacing.xl),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: ButtonCustom(
              titleButton: 'Tạo Echo',
              onNextPressed: () {
                ref
                    .read(createEchoProvider.notifier)
                    .createEcho(
                  title: titleController.text,
                  content: contentController.text,
                  echoType: EchoType.audio
                );
              },
            ),
          ),
        ],

    );
  }

  Widget _buildTitle(ThemeData theme,
      TextEditingController titleController,
      FocusNode titleFocusNode,) {
    return TextField(
      controller: titleController,
      focusNode: titleFocusNode,
      maxLines: 1,
      maxLength: 100,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: 'Tiêu đề Echo của bạn...',
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }

  Widget _builDescription(ThemeData theme,
      TextEditingController contentController,
      FocusNode contentFocusNode,) {
    return TextField(
      controller: contentController,
      focusNode: contentFocusNode,
      maxLines: 5,
      maxLength: 1000,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: AppColors.textSecondary,
      ),
      decoration: InputDecoration(
        hintText: 'Mô tả Echo của bạn...',
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }

  Widget _itemGhost(ThemeData theme) {
    bool isOn = false; // Giá trị mặc định của switch
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.accent,
          child: Icon(
            Icons.ac_unit_rounded,
            color: AppColors.white,
            size: AppTextSize.xl,
          ),
        ),

        title: Text('Ẩn danh'),
        subtitle: Text('Bạn sẽ là người ẩn danh khi tạo Echo này.'),
        trailing: Switch(
          value: isOn,
          onChanged: (value) {
            isOn = value;
          },

          activeColor: Colors.white,
          activeTrackColor: AppColors.primaryLight,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.white,

          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }
            return Colors.grey;
          }),
        ),
      ),
    );
  }


}

class ChooseImagePlaceholder extends ConsumerWidget {
  const ChooseImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFiles = ref.watch(
      createEchoProvider.select((state) => state.imageFiles),
    );
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1,
      ),
      itemCount: imageFiles.length + 1,
      itemBuilder: (context, index) {
        return index == 0
            ? GestureDetector(
          onTap: () {
            ref.read(createEchoProvider.notifier).pickImage();
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              color: AppColors.textMuted,
              size: AppTextSize.xxxl,
            ),
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  imageFiles[index - 1],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(createEchoProvider.notifier)
                        .removeImage(index - 1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: AppTextSize.xl,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
