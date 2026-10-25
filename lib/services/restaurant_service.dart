import '../core/supabase_client.dart';

/// Narrow client for merchant operations used by the restaurant app.
/// Authorization and merchant scoping remain enforced by Supabase RPC/RLS.
class RestaurantService {
  Future<List<Map<String, dynamic>>> marketplaceMyMerchantAccess() async {
    final result = await supabase.rpc('marketplace_my_merchant_access');
    return result is List
        ? result.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList()
        : const [];
  }

  Future<List<Map<String, dynamic>>> marketplaceMerchantOrders(
    String merchantId, {
    int limit = 50,
  }) async {
    final result = await supabase.rpc('marketplace_merchant_orders', params: {
      'p_merchant_id': merchantId,
      'p_limit': limit,
    });
    return result is List
        ? result.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList()
        : const [];
  }

  Future<Map<String, dynamic>> marketplaceOrderDetail(String orderId) async =>
      _map(await supabase.rpc('marketplace_order_detail', params: {
        'p_order_id': orderId,
      }));

  Future<Map<String, dynamic>> marketplaceAcceptTransferOrder(String orderId) async =>
      _map(await supabase.rpc('marketplace_merchant_accept_transfer', params: {
        'p_order_id': orderId,
      }));

  Future<Map<String, dynamic>> marketplaceSendOrderMessage({
    required String orderId,
    String? body,
    String? attachmentUrl,
    String messageType = 'text',
  }) async => _map(await supabase.rpc('marketplace_send_order_message', params: {
        'p_order_id': orderId,
        'p_body': body,
        'p_attachment_url': attachmentUrl,
        'p_message_type': messageType,
      }));

  Future<Map<String, dynamic>> marketplaceReviewTransfer({
    required String orderId,
    required bool approve,
    String? note,
  }) async => _map(await supabase.rpc('marketplace_review_transfer', params: {
        'p_order_id': orderId,
        'p_approve': approve,
        'p_note': note,
      }));

  Future<Map<String, dynamic>> marketplaceSetOrderStatus({
    required String orderId,
    required String status,
  }) async => _map(await supabase.rpc('marketplace_order_set_status', params: {
        'p_order_id': orderId,
        'p_status': status,
      }));

  Future<Map<String, dynamic>> marketplaceMarkDriverPaid(
    String orderId, {
    String? note,
  }) async => _map(await supabase.rpc('marketplace_mark_driver_paid', params: {
        'p_order_id': orderId,
        'p_note': note,
      }));

  Future<Map<String, dynamic>> marketplaceSettleBalance({
    required String orderId,
    required String balanceKey,
    String? note,
  }) async => _map(await supabase.rpc('marketplace_settle_balance', params: {
        'p_order_id': orderId,
        'p_balance_key': balanceKey,
        'p_note': note,
      }));

  Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};
}
