/// A utility service responsible for handling outbound communications.
///
/// This service abstracts the logic required to send messages to the user
/// via different channels, such as email or SMS notifications.
class EmailSmsService {
  /// Sends an email to the specified [to] address.
  ///
  /// Includes the [subject] line and the main [body] content.
  /// Currently prints the output to the console for debugging purposes.
  Future<void> sendEmail(String to, String subject, String body) async {
    print('Sending email to $to: $subject');
  }

  /// Sends an SMS text [message] to the provided [phone] number.
  ///
  /// Currently prints the output to the console for debugging purposes.
  Future<void> sendSms(String phone, String message) async {
    print('Sending SMS to $phone: $message');
  }
}
