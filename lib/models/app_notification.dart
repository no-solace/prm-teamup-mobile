/// A received push notification kept in the in-app notification center
/// (users/{uid}/notifications/{id}).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.route,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;

  /// Route to open on tap (D7), for example "/proposals". Only known routes are accepted.
  final String? route;
  final bool read;
}
