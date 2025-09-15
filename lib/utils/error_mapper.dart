import 'package:flutter/material.dart';
import '../services/solana_service.dart';

/// Maps RPC errors to user-friendly Russian messages with suggested actions
class ErrorMapper {
  static UserFriendlyError mapRpcError(SolanaRpcException exception) {
    // Find the most relevant error type
    final errors = exception.errors;
    
    // Prioritize access denied errors
    final accessDenied = errors.where((e) => e.type == RpcErrorType.accessDenied).firstOrNull;
    if (accessDenied != null) {
      return UserFriendlyError(
        title: 'Ошибка доступа к RPC',
        message: 'Ключ API не разрешён для этого узла. Попробуйте другой RPC-сервер.',
        action: UserAction.switchToAnkr,
        details: 'Endpoint: ${accessDenied.endpoint}',
      );
    }

    // Check for rate limiting
    final rateLimited = errors.where((e) => e.type == RpcErrorType.rateLimited).firstOrNull;
    if (rateLimited != null) {
      return UserFriendlyError(
        title: 'Превышен лимит запросов',
        message: 'Слишком много запросов к RPC. Попробуйте через несколько секунд.',
        action: UserAction.retry,
        details: 'Endpoint: ${rateLimited.endpoint}',
      );
    }

    // Check for server errors
    final serverError = errors.where((e) => e.type == RpcErrorType.serverError).firstOrNull;
    if (serverError != null) {
      return UserFriendlyError(
        title: 'Ошибка сервера RPC',
        message: 'Проблемы на стороне RPC-сервера. Попробуйте другой узел.',
        action: UserAction.switchToAnkr,
        details: 'HTTP ${serverError.statusCode}',
      );
    }

    // Network errors
    final networkError = errors.where((e) => e.type == RpcErrorType.networkError).firstOrNull;
    if (networkError != null) {
      return UserFriendlyError(
        title: 'Проблемы с сетью',
        message: 'Проверьте подключение к интернету и повторите попытку.',
        action: UserAction.retry,
        details: 'Сетевая ошибка',
      );
    }

    // Generic fallback
    return UserFriendlyError(
      title: 'Ошибка загрузки',
      message: 'Произошла ошибка при загрузке токенов. Попробуйте ещё раз.',
      action: UserAction.retry,
      details: '${errors.length} endpoints failed',
    );
  }

  static UserFriendlyError mapGenericError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('timeout') || errorStr.contains('connection')) {
      return UserFriendlyError(
        title: 'Проблемы с сетью',
        message: 'Проверьте подключение к интернету и повторите попытку.',
        action: UserAction.retry,
        details: error.toString(),
      );
    }

    if (errorStr.contains('format') || errorStr.contains('parse')) {
      return UserFriendlyError(
        title: 'Ошибка данных',
        message: 'Получены некорректные данные от сервера.',
        action: UserAction.retry,
        details: 'Parsing error',
      );
    }

    return UserFriendlyError(
      title: 'Произошла ошибка',
      message: 'Попробуйте ещё раз или используйте демо-кошелёк.',
      action: UserAction.demo,
      details: error.toString(),
    );
  }

  static String getEmptyTokensMessage() {
    return 'Токены не найдены для этого кошелька. Убедитесь, что адрес содержит SPL-токены.';
  }

  static String getLoadingMessage() {
    return 'Загрузка токенов...';
  }

  static String getEnrichingMessage() {
    return 'Обновление цен и анализа...';
  }
}

class UserFriendlyError {
  final String title;
  final String message;
  final UserAction action;
  final String details;

  UserFriendlyError({
    required this.title,
    required this.message,
    required this.action,
    required this.details,
  });
}

enum UserAction {
  retry,
  switchToAnkr,
  demo,
  dismiss,
}

extension UserActionExt on UserAction {
  String get buttonText {
    switch (this) {
      case UserAction.retry:
        return 'Повторить';
      case UserAction.switchToAnkr:
        return 'Попробовать Ankr';
      case UserAction.demo:
        return 'Демо кошелёк';
      case UserAction.dismiss:
        return 'Закрыть';
    }
  }

  IconData get icon {
    switch (this) {
      case UserAction.retry:
        return Icons.refresh;
      case UserAction.switchToAnkr:
        return Icons.swap_horiz;
      case UserAction.demo:
        return Icons.play_arrow;
      case UserAction.dismiss:
        return Icons.close;
    }
  }
}
