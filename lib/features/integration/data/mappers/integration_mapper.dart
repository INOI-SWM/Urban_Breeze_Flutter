import 'package:urban_breeze/features/integration/data/models/integration_response_model.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';

class IntegrationMapper {
  const IntegrationMapper._();

  static IntegrationAuth fromResponseModel(IntegrationResponseModel model) {
    return IntegrationAuth(url: model.url);
  }
}
