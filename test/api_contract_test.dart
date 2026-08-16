import 'package:customer_app/features/auth/models/order_model.dart';
import 'package:customer_app/features/auth/models/user_model.dart';
import 'package:customer_app/features/return/models/return_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login customer payload retains the bearer token', () {
    final payload = <String, dynamic>{
      'id': 7,
      'full_name': 'Test Customer',
      'email': 'customer@example.com',
      'phone_number': '933123456',
      'token': 'plain-text-token',
    };

    final user = UserModel.fromJson(payload);

    expect(user.id, 7);
    expect(user.token, 'plain-text-token');
  });

  test('order detail payload matches Laravel OrderDetailResource', () {
    final order = OrderModel.fromJson({
      'id': 10,
      'warehouse_id': 2,
      'status': 'pending',
      'payment_status': 'not_started',
      'total_price': '25.50',
      'order_date': '2026-08-16T12:00:00.000000Z',
      'customer_location': 'Damascus',
      'order_qr_code': 'ORDER-10',
      'can_pay': true,
      'can_prepare': false,
      'items': [
        {
          'id': 1,
          'product_id': 3,
          'product_name': 'Product',
          'quantity': 2,
          'unit_price': '12.75',
          'subtotal': '25.50',
        },
      ],
    });

    expect(order.totalPrice, 25.5);
    expect(order.canPay, isTrue);
    expect(order.items.single.productId, 3);
  });

  test('return payload matches CustomerReturnResource', () {
    final result = ReturnModel.fromJson({
      'id': 4,
      'status': 'pending',
      'return_type': 'customer_return',
      'return_reason': 'Damaged',
      'can_cancel': true,
      'created_at': '2026-08-16T12:00:00.000000Z',
      'updated_at': '2026-08-16T12:00:00.000000Z',
      'order': {
        'id': 10,
        'status': 'delivered',
        'total_price': '25.50',
        'order_date': '2026-08-15T12:00:00.000000Z',
        'customer_location': 'Damascus',
        'order_qr_code': 'ORDER-10',
        'warehouse': {'id': 2, 'warehouse_name': 'Main'},
      },
      'items': [
        {
          'id': 8,
          'quantity': 1,
          'product': {'id': 3, 'name': 'Product'},
          'unit_price': '12.75',
          'subtotal': '12.75',
        },
      ],
    });

    expect(result.canCancel, isTrue);
    expect(result.warehouseName, 'Main');
    expect(result.dueAmount, 12.75);
  });
}
