class EmailSmsService {
  Future<void> sendEmail(String to, String subject, String body) async {
    print('Sending email to $to: $subject');
  }
  Future<void> sendSms(String phone, String message) async {
    print('Sending SMS to $phone: $message');
  }
}