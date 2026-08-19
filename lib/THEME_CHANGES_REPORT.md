# تقرير تعديل نظام الـ Theme (Light/Dark)

## المشكلة في الكود الأصلي
كان التبديل بين الوضعين يتم عبر **فلتر لوني عام (`ColorFilter.matrix`)** يُطبَّق فوق
شجرة الـWidgets بالكامل عبر `ColorFiltered` في `main.dart`. هذا الأسلوب:
- يعكس **كل** الألوان في التطبيق بدون تمييز (بما فيها البرتقالي، الأخضر، حدود
  الحقول...)، رغم أنها مطلوب أن تبقى ثابتة.
- `AppTheme.lightTheme` (المبني بـ `ColorScheme` حقيقية) لم يكن حتى مُستخدَمًا؛
  كان هناك `ThemeData` مختلف مُعرَّف يدويًا داخل `main.dart` نفسه.

## الحل المطبَّق
تم استبدال الفلتر العام بحل **مركزي عبر `AppColors`**:

### 1. `lib/core/constants/app_colors.dart`
- `primary` و `cardBg` أصبحا **getters** (بدل `static const`) يقرآن
  `ThemeController.instance.isDark`:
  - Light: `primary = Navy (0xff1D2D44)`, `cardBg = Beige (0xFFFFF8F4)`.
  - Dark: `primary = Beige`, `cardBg = Navy` (الانعكاس المطلوب فقط لهذين
    اللونين، وليس عبر فلتر عام).
- تمت إضافة `textOnPrimary` و `textOnCard`: ألوان نصوص تتغيّر تلقائياً
  لضمان التباين فوق `primary`/`cardBg` تحديداً (أبيض/كحلي حسب الحاجة).
- **بقيت كما هي تمامًا (const، لم تُمس إطلاقًا)**:
  `iconColor` (البرتقالي)، `textLink`، `border`، `borderFocused`،
  `textPrimary`، `textSecondary`، `textHint`، `purple`، `uploadBox`،
  وكل ألوان الحالات (`statusShipping*`, `statusPending*`,
  `statusApproved*` الأخضر، `statusCancelled*`, `warehouseBg`).

### 2. `lib/core/theme/app_theme.dart`
- حُذفت مصفوفة الفلتر (`darkFilterMatrix`) والـ `ColorFilter` بالكامل.
- أصبح هناك `AppTheme.buildTheme({isDark})` تُنتج `ThemeData` حقيقية لكل
  وضع، و`AppTheme.lightTheme` / `AppTheme.darkTheme` جاهزتين للاستخدام.
- `inputDecorationTheme` (شكل وألوان حقول الإدخال) **لم يتغيّر** — نفس
  `AppColors.border` / `AppColors.borderFocused` الثابتة في كل الأوضاع.

### 3. `lib/core/theme/theme_controller.dart`
- لا تغيير في المنطق (لا يزال يخزّن الاختيار في `SharedPreferences`)،
  فقط تحديث تعليق قديم كان يشير للفلتر المحذوف.

### 4. `lib/main.dart`
- إزالة `ColorFiltered` / `AppTheme.filterFor`.
- ربط `MaterialApp` بـ `theme: AppTheme.lightTheme`,
  `darkTheme: AppTheme.darkTheme`, و
  `themeMode: isDark ? ThemeMode.dark : ThemeMode.light`.

### 5. `lib/core/constants/app_text_styles.dart`
- `screenTitle` و `screenhomeTitle` كانا `static const TextStyle` يستخدمان
  `AppColors.primary` — تم تحويلهما إلى **getters** (`static TextStyle get`)
  لأن `AppColors.primary` لم يعد قيمة ثابتة وقت الترجمة. باقي الـ Styles
  (التي تعتمد على ألوان ثابتة مثل `textSecondary`, `textHint`, `iconColor`)
  **بقيت `const` كما هي بدون أي تغيير**.

### 6. إصلاح 44 حالة `const` كانت ستفشل بالبناء
بعد تحويل `primary`/`cardBg` إلى getters، أي مكان كان يستخدمهما داخل تعبير
`const` (مثل `const BorderSide(color: AppColors.primary)`,
`const Icon(..., color: AppColors.cardBg)`, `const ColorScheme.light(...)`)
أصبح غير صالح للترجمة. تم فحص المشروع بالكامل (بحث نصي دقيق يشمل الحالات
متعددة الأسطر) وإزالة كلمة `const` فقط من هذه المواضع الـ 44 (في 25 ملفًا)،
دون تغيير أي شيء آخر في نفس الأسطر (لا Layout، لا Padding، لا حجم).

### 7. النصوص/الأيقونات الثابتة فوق `AppColors.primary`
هذه هي الحالة الحرجة التي طلبت الانتباه لها: أي نص/أيقونة بيضاء **ثابتة**
(`Colors.white`) كانت مرسومة فوق خلفية `AppColors.primary` ستختفي في
الوضع الداكن (لأن الخلفية تصبح بيج فاتح). تم إصلاح:
- `lib/features/home/widgets/app_bottom_nav.dart`: أيقونات الـ Navigation
  Bar غير النشطة (البيضاء) → `AppColors.textOnPrimary`. الأيقونة النشطة
  (البرتقالية) **لم تتغيّر**. خلفية الشريط نفسها (`NavBarClipper`) بالفعل
  تستخدم `AppColors.primary` فتنعكس Navy↔Beige تلقائيًا (هذا تحديدًا ما طلبته
  في بند الـ Navigation Bar).
- `lib/features/home/widgets/app_header.dart` و `app_header_out.dart`
  (الهيدر المشترك المستخدم في شاشات كثيرة): نصوص/أيقونات العنوان البيضاء
  فوق خلفية `AppColors.primary` → `AppColors.textOnPrimary`.
- 6 أزرار (`backgroundColor: AppColors.primary` + `foregroundColor:
  Colors.white`) في: `order_inshipping_view.dart` (×2)، `my_cart_view.dart`
  (×2)، `return_process_view.dart`، `refund_confirm_view.dart` →
  `foregroundColor: AppColors.textOnPrimary`.
- 9 أزرار مشابهة بنمط `textColor: Colors.white` في: `profile_view.dart`،
  `edit_profile_view.dart`، `change_password_view.dart`،
  `confirm_delivery_view.dart`، `order_approved_view.dart` (×3)،
  `transaction_details_view.dart`، `order_pending_view.dart` →
  `AppColors.textOnPrimary`.

> ملاحظة: `lib/features/orders/widgets/app_header_in.dart` يستخدم
> `AppColors.primary` كخلفية أيضًا، لكن نصوصه البيضاء معرّفة عبر
> `AppTextStyles.screenhomeTitle.copyWith(color: Colors.white, ...)` وهي
> جزء من نمط تصميم داخلي مختلف — تم تفحّصه والتأكد أن الخلفية والنص فيه
> يتبعان نفس منطق `AppColors.primary`/الأبيض الثابت الموجود أصلًا، ولم يُمس
> لتفادي أي تغيير غير مطلوب في التصميم؛ يمكن تطبيق نفس نمط `textOnPrimary`
> عليه لاحقًا إذا لاحظت ضعف تباين فيه بعد الاختبار الفعلي على الجهاز.

### 8. الـ Cards والـ Input Fields
- الكارد (`AppColors.cardBg`) يتبع فقط انعكاس Beige↔Navy لأنه **هو نفسه**
  اللون الأساسي البيج (وليس لونًا عشوائيًا آخر) — تمامًا كما حددت في طلبك.
  أي كارد يستخدم لونًا مختلفًا (أبيض، أو شفاف، أو تدرّج أحمر لسبب الإلغاء
  في `order_card.dart` مثلًا) **لم يُمس إطلاقًا**.
- خلفية حقول الإدخال (`Colors.white` في `inputDecorationTheme` وفي كل
  `TextField`/`TextFormField` بالمشروع) وحدودها (`AppColors.border`,
  `AppColors.borderFocused`) **ثابتة 100% في كلا الوضعين**، لم تُمس.
- النص داخل الكارد الذي يستخدم `AppColors.primary` (مثل "عرض التفاصيل" في
  `order_card.dart`) يبقى مقروءًا تلقائيًا في الوضعين، لأن `primary` و
  `cardBg` معكوسان دائمًا مع بعض (كلما كانت الخلفية Navy يكون النص Beige
  والعكس)، دون أي كود إضافي.

## ما لم يتغيّر إطلاقًا (بحسب طلبك)
- البرتقالي (`iconColor`) والأخضر (حالة `Approved`) وبقية ألوان الحالات.
- Layout، الـ Padding، الـ Border Radius، الأيقونات، أحجام الخطوط، ترتيب
  العناصر.
- منطق الـ Backend/الـ API — لم يُلمس أي ملف خارج `lib/` الخاص بالـ UI/Theme.

## التحقق النهائي
- تم فحص المشروع بالكامل (92 ملف Dart) بحثًا عن أي بقايا استخدام للفلتر
  القديم — لا يوجد.
- تم فحص كل حالات `const` المرتبطة بـ `AppColors.primary`/`cardBg` و
  `AppTextStyles.screenTitle`/`screenhomeTitle` بعد كل التعديلات — 0 حالة
  متبقية قد تكسر البناء.
- تم فحص توازن الأقواس في كل ملف Dart كتحقق إضافي (الاختلالات الظاهرة في
  ملفات لم تُعدَّل أصلًا سببها علامات ترقيم مثل "1)" داخل تعليقات عربية،
  وليست أخطاء حقيقية).
- **تنبيه مهم**: لا تتوفر بيئة Flutter/Dart SDK في هذه الجلسة لتشغيل
  `flutter analyze` أو `flutter build` فعليًا. الفحص تم يدويًا ونصيًا بدقة
  عالية، لكن يُستحسن تشغيل `flutter pub get && flutter analyze` على جهازك
  كخطوة أخيرة قبل الدمج، والتأكد بصريًا من كل شاشة على المحاكي.

## الملفات المعدَّلة (35 ملفًا)
```
lib/core/constants/app_colors.dart
lib/core/constants/app_text_styles.dart
lib/core/theme/app_theme.dart
lib/core/theme/theme_controller.dart
lib/main.dart
lib/features/auth/views/change_password_view.dart
lib/features/auth/views/create_password_view.dart
lib/features/auth/views/edit_profile_view.dart
lib/features/auth/views/forget_password_view.dart
lib/features/auth/views/forgot_password_wait_view.dart
lib/features/auth/views/login_view.dart
lib/features/auth/views/profile_view.dart
lib/features/auth/views/register_view.dart
lib/features/auth/views/verify_Identity_view.dart
lib/features/home/views/filter_dialog.dart
lib/features/home/views/my_cart_view.dart
lib/features/home/views/product_details_view.dart
lib/features/home/widgets/app_bottom_nav.dart
lib/features/home/widgets/app_header.dart
lib/features/home/widgets/app_header_out.dart
lib/features/orders/views/confirm_delivery_view.dart
lib/features/orders/views/my_orders_view.dart
lib/features/orders/views/order_approved_view.dart
lib/features/orders/views/order_inshipping_view.dart
lib/features/orders/views/order_pending_view.dart
lib/features/orders/views/order_recireved_detail_view.dart
lib/features/orders/views/return_order_view.dart
lib/features/orders/views/transaction_details_view.dart
lib/features/orders/widgets/order_card.dart
lib/features/return/views/archived_detail_view.dart
lib/features/return/views/myReturnsView.dart
lib/features/return/views/pending_return_view.dart
lib/features/return/views/refund_confirm_view.dart
lib/features/return/views/return_detail_view.dart
lib/features/return/views/return_process_view.dart
```

---

## تحديث إضافي — إصلاح البند 5 و10 (Bug: عدم تحديث الصفحة الحالية فوراً)

### السبب الحقيقي (تم تشخيصه بدقة)
`AppColors.primary` / `AppColors.cardBg` كانا (ولا يزالان) عبارة عن
`static Color get` عاديين يقرآن `ThemeController.instance.isDark` مباشرة —
وهذه القراءة **غير مرتبطة بأي `InheritedWidget`**. عند الضغط على تبديل
الـTheme من الـDrawer:
- `ThemeController.notifyListeners()` يُعيد بناء `MaterialApp` فقط (عبر
  `ListenableBuilder` في `main.dart`) — وهذا يُحدّث `theme`/`darkTheme`/
  `themeMode` بشكل صحيح.
- لكن الصفحة **المعروضة فعلياً حالياً** (مثل `HomeView`) هي `Route` مبني
  ومُخزَّن مسبقاً من طرف الـ`Navigator`، ولا تُعاد Flutter بناءه تلقائياً
  لمجرد أن أحد أسلافه (`MaterialApp`) أعاد البناء — هذا سلوك أساسي في
  Flutter (الصفحات المُدفوعة مسبقاً لا تُعاد بناؤها إلا إذا اعتمدت فعلياً
  على `InheritedWidget` تغيّر، أو استُبدل الـRoute نفسه — وهو بالضبط ما
  يحدث عند "الانتقال لأيقونة أخرى بالـNavigation Bar ثم الرجوع"، لأن ذلك
  يستبدل HomeView بنسخة جديدة تقرأ القيم المحدّثة).
- نفس المشكلة تنطبق تماماً على `'key'.tr()` من مكتبة `easy_localization`:
  التوثيق الرسمي للمكتبة يذكر صراحة أن استخدام `.tr()` بدون `context` "غير
  مستحسن داخل build methods لأن الـwidget لن يُعاد بناؤه عند تغيّر اللغة".

### الإصلاح المطبَّق
تم لف الـ`Scaffold` في الصفحات التي تملك الـDrawer فعلياً (`HomeView` و
`WarehouseDetailsView`) بـ:
```dart
return ListenableBuilder(
  listenable: ThemeController.instance,
  builder: (context, _) {
    context.locale; // يُسجّل اعتماد إعادة البناء على تغيّر اللغة أيضاً
    return Scaffold(...);
  },
);
```
هذا يضمن أن هذه الصفحة **بالذات** (وهي الوحيدة التي يمكن أن تكون معروضة أثناء
فتح الـDrawer والضغط على تبديل الـTheme/اللغة) تُعيد بناء نفسها فوراً — دون
أي Navigation أو setState يدوي، باستخدام آلية `Listenable`/`InheritedWidget`
قياسية في Flutter (بند 5 من الطلب: "يجب استخدام آلية صحيحة لإدارة الحالة").

كما تمت إزالة `const` من `drawer: const _HomeDrawer()` / `const _AppDrawer()`
— لأن Flutter يتجاهل إعادة بناء أي widget `const` حتى لو أعاد أبوه البناء
(لأن المرجع نفسه يبقى مطابقاً)، وهذا كان سيُبقي نصوص وألوان الـDrawer نفسه
قديمة رغم إصلاح بقية الصفحة.

**تم أيضاً اكتشاف وإصلاح خلل منفصل**: في `_AppDrawer` (داخل
`warehouse_details_view.dart`) كان بندا "Theme" و"Language" غير مربوطين
بأي منطق فعلي إطلاقاً (`onTap` كان يكتفي بإغلاق الـDrawer فقط دون استدعاء
`ThemeController.instance.toggle()` أو `context.setLocale(...)`). تم ربطهما
الآن بنفس الأسلوب المستخدم في `HomeView`.

**بند 4 (تسمية "فاتح"/"Light")**: كانت تسمية بند الـTheme في الـDrawer ثابتة
دائماً (`'drawer.theme'.tr()`) والأيقونة فقط هي التي كانت تتغيّر. تم تعديلها
لتعرض `'theme.light'.tr()` / `'theme.dark'.tr()` حسب الوضع الحالي في كلا
الـDrawer (`HomeView` و`WarehouseDetailsView`).

> ⚠️ **يتطلب إجراء يدوي منك**: مفاتيح الترجمة `theme.light` و `theme.dark`
> غير موجودة (لم يتم تضمين مجلد `assets/translations` في الملف المرفوع، فقط
> `lib/`). أضفهما يدوياً في `assets/translations/en.json` و `ar.json`، مثلاً:
> ```json
> "theme": { "light": "Light", "dark": "Dark" }
> ```
> وفي `ar.json`:
> ```json
> "theme": { "light": "فاتح", "dark": "غامق" }
> ```

### نطاق الإصلاح — ولماذا هو كافٍ
الصفحات الأربع الوحيدة التي عُدِّلت في هذه الجولة:
```
lib/features/home/views/home_view.dart              (تملك الـDrawer فعلياً)
lib/features/home/views/warehouse_details_view.dart (تملك الـDrawer فعلياً + إصلاح ربط منطق مفقود)
lib/features/auth/views/edit_profile_view.dart       (لا تملك Drawer، عُدِّلت للتناسق فقط)
lib/features/auth/views/change_password_view.dart    (لا تملك Drawer، عُدِّلت للتناسق فقط)
```
بقية صفحات المشروع (الطلبات، المرتجعات، السلة، الخ) **ليس فيها Drawer**، ولا
يمكن أن تكون معروضة أثناء الضغط على زر تبديل الـTheme/اللغة — فهي تُبنى من
جديد في كل مرة تُفتح فيها عبر `Navigator.push`/`pushReplacement`، وتقرأ
القيم الحالية (المحدَّثة بالفعل) مباشرة دون أي مشكلة. لذلك لم تُعدَّل، تفادياً
لتغييرات غير ضرورية عبر عشرات الملفات (35+) دون توفر Flutter SDK في هذه
الجلسة للتحقق من نجاح الـbuild بعد كل تعديل.

### لم يتم فحصه/اختباره فعلياً
لا تتوفر بيئة Flutter/Dart SDK ولا اتصال شبكة في هذه الجلسة (لا `pubspec.yaml`
مرفق أيضاً)، لذا لم يتم تشغيل `flutter analyze`/`flutter build`. تم التحقق
يدوياً بدقة من توازن كل الأقواس `()`/`{}`/`[]` في الملفات الأربعة المعدَّلة
(مع تجاهل صحيح للتعليقات والنصوص) وفي كامل المشروع. يُنصح بتشغيل
`flutter pub get && flutter analyze` ثم اختبار فعلي على الجهاز/المحاكي قبل
الدمج النهائي.
