// lib/data/mock_data.dart
class MockData {
  static Map<String, dynamic> userCart = {
    "cartId": "cart123",
    "userId": "user456",
    "items": [],
    "subtotal": 0.0,
    "tax": 0.0,
    "total": 0.0,
    "createdAt": "2025-03-15T10:00:00Z",
    "updatedAt": "2025-03-15T10:00:00Z"
  };

  static List<Map<String, dynamic>> orders = [
    // Initially empty, will be populated when orders are placed
  ];

  static List<Map<String, dynamic>> paymentMethods = [
    {
      "id": "pm1",
      "type": "credit_card",
      "name": "Visa ending in 4242",
      "isDefault": true,
      "expiryDate": "12/26",
      "cardHolderName": "John Doe"
    },
    {
      "id": "pm2",
      "type": "paypal",
      "name": "PayPal Account",
      "isDefault": false,
      "email": "john.doe@example.com"
    }
  ];

  static Map<String, dynamic> shippingAddress = {
    "id": "addr1",
    "fullName": "John Doe",
    "addressLine1": "123 Main St",
    "addressLine2": "Apt 4B",
    "city": "San Francisco",
    "state": "CA",
    "postalCode": "94105",
    "country": "USA",
    "phoneNumber": "+1-555-123-4567",
    "isDefault": true
  };

  static List<Map<String, dynamic>> availableShippingMethods = [
    {
      "id": "ship1",
      "name": "Standard Shipping",
      "price": 5.99,
      "estimatedDelivery": "3-5 business days"
    },
    {
      "id": "ship2",
      "name": "Express Shipping",
      "price": 15.99,
      "estimatedDelivery": "1-2 business days"
    },
    {
      "id": "ship3",
      "name": "Next Day Delivery",
      "price": 29.99,
      "estimatedDelivery": "Next business day"
    }
  ];
}