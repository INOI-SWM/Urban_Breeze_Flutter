import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('profile_screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 40,
                backgroundImage:
                    widget.user.photoUrl != null
                        ? NetworkImage(widget.user.photoUrl!)
                        : null,
                child:
                    //TODO: 프로필 기본이미지 추가
                    widget.user.photoUrl == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
              ),
              const Expanded(
                child: InfoItem(label: '총 주행시간', value: '100시간 30분'),
              ),
              const Expanded(child: InfoItem(label: '총 주행거리', value: '1000km')),
            ],
          ),

          const SizedBox(height: 12),
          Text(
            widget.user.displayName ?? '이름 없음',
            style: AppTextStyles.body1.readingBold,
          ),
          Text('한줄소개입니다', style: AppTextStyles.body1.normalRegular),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ButtonOutlined(
              textColor: colors.labelNormal,
              borderColor: colors.lineNormalNeutral,
              onPressed: () => _onProfileEditPressed(context),
              text: '프로필 수정',
              size: ButtonSize.medium,
            ),
          ),

          const SizedBox(height: 30),

          // 탈퇴 기능은 설정 > 계정 관리로 이동
        ],
      ),
    );
  }

  void _onProfileEditPressed(BuildContext context) {
    AmplitudeAnalytics.logButtonClick('profile_edit_button');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProfileEditScreen(user: widget.user),
      ),
    );
  }
}
