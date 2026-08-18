/// أدوات مساعدة لرقم الهاتف — الباك اند صار يشترط صيغة دولية كاملة
/// (E.164)، مثلاً `+963933123456`، وما عاد يقبل الصيغة المحلية القديمة
/// `933123456`.
///
/// [normalizeSyrianPhone] بتحوّل أي صيغة كانت المستخدمة كاتبها (محلية
/// سورية أو دولية) لصيغة `+963xxxxxxxxx` قبل ما نرسلها للباك اند، بدون
/// ما نغيّر تجربة الإدخال بالنسبة للمستخدمة (لسا فيها تكتب 9xxxxxxxx
/// عادي متل ما اعتادت).
class PhoneUtils {
  PhoneUtils._();

  static const String _defaultCountryCode = '963'; // سوريا

  /// يحوّل النص المدخل لصيغة دولية كاملة تبلش بـ "+".
  ///
  /// أمثلة:
  ///   933123456      → +963933123456
  ///   0933123456     → +963933123456
  ///   00963933123456 → +963933123456
  ///   963933123456   → +963933123456
  ///   +963933123456  → +963933123456 (بدون تغيير)
  static String normalizeSyrianPhone(String raw) {
    var value = raw.trim().replaceAll(RegExp(r'[\s-]+'), '');

    if (value.isEmpty) return value;

    // أصلاً دولية (+...) — منرجعها متل ما هي.
    if (value.startsWith('+')) {
      return value;
    }

    // صيغة "00" الدولية (00963...) → +963...
    if (value.startsWith('00')) {
      return '+${value.substring(2)}';
    }

    // صفر محلي بالأول (0933...) → نشيله ونحط +963
    if (value.startsWith('0')) {
      return '+$_defaultCountryCode${value.substring(1)}';
    }

    // مكتوب أصلاً بكود الدولة بدون + (963933...) → نضيف +
    if (value.startsWith(_defaultCountryCode)) {
      return '+$value';
    }

    // الصيغة المحلية المعتادة (933123456 أو 9xxxxxxxx) → نضيف +963
    if (RegExp(r'^[89][0-9]{8}$').hasMatch(value)) {
      return '+$_defaultCountryCode$value';
    }

    // أي صيغة تانية ما قدرنا نتعرف عليها: منرجعها متل ما هي وخلي الباك
    // اند هو يرفضها برسالة الخطأ المناسبة، بدل ما نخمّن غلط.
    return value;
  }
}
