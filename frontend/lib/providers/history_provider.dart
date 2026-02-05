import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/audit_api.dart';
import '../models/change_record.dart';
import '../models/page_result.dart';
import '../api/api_client_provider.dart';


final auditApiProvider = Provider<AuditApi>((ref) => AuditApi(ref.read(apiClientProvider)));

final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<PageResult<ChangeRecord>>>(
      (ref) => HistoryNotifier(ref.read(auditApiProvider)),
);

class HistoryNotifier extends StateNotifier<AsyncValue<PageResult<ChangeRecord>>> {
  final AuditApi api;
  int _page = 0;
  final int pageSize = 20;
  int? productId;
  String? action;

  HistoryNotifier(this.api) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch({int page = 0, int? productId, String? action}) async {
    _page = page;
    this.productId = productId ?? this.productId;
    this.action = action ?? this.action;
    state = const AsyncValue.loading();
    try {
      final res = await api.getHistory(page: _page, size: pageSize, productId: this.productId, action: this.action);
      state = AsyncValue.data(res);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> nextPage() async {
    final cur = state.value;
    if (cur == null) return;
    if (cur.number + 1 >= cur.totalPages) return;
    await fetch(page: cur.number + 1);
  }

  Future<void> refresh() async => fetch(page: 0);
}
