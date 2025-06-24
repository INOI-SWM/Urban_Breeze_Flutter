import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/data/repositories/user_session_repository_impl.dart';
import 'package:ridingmate/features/auth/domain/repositories/user_session_repository.dart';

final Provider<UserSessionRepository> userSessionRepositoryProvider =
    Provider<UserSessionRepository>((Ref<UserSessionRepository> ref) {
      return UserSessionRepositoryImpl();
    });
