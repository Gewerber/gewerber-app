import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/guidance.dart';

/// Maps between the domain guidance entities and the protocol models.
@Injectable()
class GuidanceMapper {
  const GuidanceMapper();

  GuidanceTip tipFromModel(sdk.GuidanceTip model) {
    return GuidanceTip(
      topic: model.topic,
      title: model.title,
      body: model.body,
    );
  }

  GuidanceChecklist checklistFromModel(sdk.ChecklistDefinition model) {
    return GuidanceChecklist(
      key: model.key,
      title: model.title,
      items: model.items.map(itemFromModel).toList(),
    );
  }

  GuidanceChecklistItem itemFromModel(sdk.ChecklistItemDefinition model) {
    return GuidanceChecklistItem(
      key: model.key,
      title: model.title,
      body: model.body,
    );
  }
}
