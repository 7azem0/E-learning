lib/
├── main.dart                → بداية التطبيق (Entry Point)
│                             يشغل app ويحدد أول شاشة وroutes

└── authentication/
    ├── screens/
    │   ├── login.dart        → UI شاشة تسجيل الدخول
    │   │                      بياخد email/password ويبعتهم للـ service
    │   │
    │   └── register_screen.dart → UI شاشة إنشاء حساب
    │                             بياخد البيانات ويبعتها للـ service
    │
    └── service.dart          → Logic الـ authentication
                               يكلم API / Firebase
                               فيه login و register



main code

import 'package:flutter/material.dart'; 
// استيراد مكتبة Flutter الأساسية اللى فيها كل Widgets الجاهزة زى MaterialApp وScaffold

import 'authentication/screens/register_screen.dart'; 
// استيراد شاشة التسجيل عشان نستخدمها فى التنقل

import 'authentication/screens/login.dart'; 
// استيراد شاشة تسجيل الدخول

void main() { 
  // دى أول function بتشتغل لما التطبيق يبدأ
  runApp(const ELearningApp()); 
  // بتشغل التطبيق وبتحط الـ Widget الأساسية (ELearningApp) كنقطة بداية
}

class ELearningApp extends StatelessWidget { 
// تعريف Widget رئيسية للتطبيق من نوع Stateless (مش بتتغير حالتها)

  const ELearningApp({super.key}); 
  // constructor ثابت + بيمرر key للـ parent class

  @override
  Widget build(BuildContext context) { 
  // build مسؤولة ترجع شكل الـ UI

    return MaterialApp( 
    // دى أساس التطبيق وبتوفر navigation + theme + title

      title: 'E-Learning', 
      // اسم التطبيق (يظهر أحيانًا فى system)

      debugShowCheckedModeBanner: false, 
      // يشيل علامة DEBUG اللى بتظهر فوق

      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true), 
      // إعدادات الثيم (اللون الأساسي + تفعيل Material 3)

      // Initial screen
      home: RegisterScreen(), 
      // أول شاشة هتظهر لما التطبيق يفتح

      // Future navigation routes
      routes: { 
      // تعريف طرق التنقل بالأسماء (Named Routes)

        '/register': (context) => RegisterScreen(), 
        // لما تنادى /register يفتح شاشة التسجيل

        '/login': (context) => LoginScreen(), 
        // لما تنادى /login يفتح شاشة تسجيل الدخول

        '/home': (context) => const HomePage(), 
        // لما تنادى /home يفتح الصفحة الرئيسية
      },
    );
  }
}

class HomePage extends StatelessWidget { 
// تعريف Widget للصفحة الرئيسية

  const HomePage({super.key}); 
  // constructor ثابت

  @override
  Widget build(BuildContext context) { 
  // build مسؤولة عن رسم الصفحة

    return Scaffold( 
    // الهيكل الأساسي للشاشة (AppBar + Body + BottomBar)

      appBar: AppBar( 
      // شريط أعلى الصفحة

        title: const Text('E-Learning App'), 
        // عنوان الـ AppBar

        centerTitle: true, 
        // يخلى العنوان فى النص

        actions: [ 
        // عناصر تظهر يمين الـ AppBar

          IconButton( 
          // زرار أيقونة

            icon: const Icon(Icons.logout), 
            // أيقونة تسجيل الخروج

            tooltip: 'Logout', 
            // نص يظهر لما تقف على الأيقونة

            onPressed: () { 
            // يتنفذ لما المستخدم يدوس

              Navigator.pushReplacementNamed(context, '/login'); 
              // ينقل المستخدم لشاشة login ويمنع الرجوع (replace)
            },
          ),
        ],
      ),

      body: Center( 
      // يخلى المحتوى فى نص الشاشة

        child: Column( 
        // ترتيب العناصر بشكل عمودى

          mainAxisAlignment: MainAxisAlignment.center, 
          // يخلى العناصر فى نص العمود

          children: [ 
          // العناصر اللى هتظهر

            const Text( 
              'Welcome to E-Learning', 
              // نص ترحيبى

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
              // تنسيق النص (حجم + عريض)
            ),

            const SizedBox(height: 20), 
            // مسافة بين العناصر

            ElevatedButton( 
            // زرار

              onPressed: () { 
              // لما المستخدم يدوس

                ScaffoldMessenger.of(context).showSnackBar( 
                // يظهر رسالة مؤقتة تحت الشاشة

                  const SnackBar(content: Text('Start building features 🚀')), 
                  // محتوى الرسالة
                );
              },

              child: const Text('Get Started'), 
              // نص الزرار
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar( 
      // شريط تنقل أسفل الشاشة

        items: const [ 
        // العناصر اللى فيه

          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), 
          // زرار Home

          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'), 
          // زرار الكورسات

          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), 
          // زرار البروفايل
        ],
      ),
    );
  }
}





































import 'dart:convert'; 
// مكتبة لتحويل البيانات بين JSON و Map (encode / decode)

import 'dart:io'; 
// مكتبة للتعامل مع الملفات (قراءة / كتابة)

import 'package:path_provider/path_provider.dart'; 
// مكتبة تجيبلك مكان تخزين آمن داخل الجهاز للتطبيق

class AuthService {   
// class مسؤول عن تسجيل المستخدمين وتسجيل الدخول

  // Singleton pattern
  static final AuthService _instance = AuthService._internal(); 
  // إنشاء instance واحدة فقط من الكلاس (Singleton)

  factory AuthService() => _instance; 
  // أى حد ينادى AuthService يرجع نفس الـ instance

  AuthService._internal() { 
  // constructor داخلى (private) يتنفذ مرة واحدة بس

    _loadUsers(); 
    // أول ما الكلاس يشتغل يحمل بيانات المستخدمين من الملف
  }

  // Simulated user database (email -> user details Map)
  Map<String, dynamic> _users = {}; 
  // Map لتخزين المستخدمين (الإيميل مفتاح + بياناته)

  Future<File> get _usersFile async { 
  // getter بيرجع ملف المستخدمين

    final directory = await getApplicationDocumentsDirectory(); 
    // يجيب مسار التخزين الخاص بالتطبيق

    return File('${directory.path}/users.json'); 
    // يرجع ملف users.json داخل المسار
  }

  Future<File> get _adminsFile async { 
  // getter بيرجع ملف الأدمن

    final directory = await getApplicationDocumentsDirectory(); 
    // يجيب مسار التخزين

    return File('${directory.path}/admins.json'); 
    // يرجع ملف admins.json
  }

  Future<void> _loadUsers() async { 
  // function لتحميل المستخدمين من الملف

    try { 
    // محاولة التنفيذ

      final file = await _usersFile; 
      // يجيب ملف المستخدمين

      if (await file.exists()) { 
      // لو الملف موجود

        final contents = await file.readAsString(); 
        // يقرأ البيانات كنص

        _users = Map<String, dynamic>.from(jsonDecode(contents)); 
        // يحول JSON لـ Map ويحطه فى _users
      }

    } catch (e) { 
    // لو حصل خطأ

      print('Error loading users: $e'); 
      // يطبع الخطأ فى الكونسول
    }
  }

  Future<void> _loadAdmins() async { 
  // تحميل قائمة الإيميلات المسموح لها تبقى Admin

    try {

      final file = await _adminsFile; 
      // يجيب ملف الأدمن

      if (await file.exists()) { 
      // لو موجود

        final contents = await file.readAsString(); 
        // يقرأ البيانات

        _allowedAdminEmails = List<String>.from(jsonDecode(contents)); 
        // يحولها لقائمة ويحطها فى المتغير

      } else { 
      // لو مش موجود

        // Create file with default 20 admin emails if it doesn't exist
        _allowedAdminEmails = List.generate( 
          20, 
          (index) => 'admin${index + 1}@example.com', 
        ); 
        // ينشئ 20 إيميل افتراضى للأدمن

        await file.writeAsString(jsonEncode(_allowedAdminEmails)); 
        // يحفظهم فى الملف
      }

    } catch (e) { 
      print('Error loading admins: $e'); 
      // يطبع الخطأ لو حصل
    }
  }

  Future<void> _saveUsers() async { 
  // function لحفظ المستخدمين فى الملف

    try {

      final file = await _usersFile; 
      // يجيب الملف

      await file.writeAsString(jsonEncode(_users)); 
      // يحفظ البيانات كـ JSON

    } catch (e) {

      print('Error saving users: $e'); 
      // يطبع الخطأ لو حصل
    }
  }

  // List of emails allowed to register as Admin
  List<String> _allowedAdminEmails = []; 
  // قائمة الإيميلات المسموح لها تسجل كأدمن

  // Register method
  Future<String> registerUser({ 
  // function للتسجيل

    required String name, 
    // اسم المستخدم

    required String email, 
    // الإيميل

    required String password, 
    // الباسورد

    String role = 'User', 
    // الرول الافتراضى User

  }) async {

    await Future.delayed(const Duration(milliseconds: 500)); 
    // تأخير بسيط لمحاكاة network request

    await _loadUsers(); 
    // يحمل أحدث بيانات المستخدمين

    await _loadAdmins(); 
    // يحمل قائمة الأدمن

    if (role == 'Admin' && !_allowedAdminEmails.contains(email)) { 
    // لو عايز يسجل أدمن ومش مسموح له

      return 'You are not authorized to register as an Admin'; 
      // يرجع رسالة رفض
    }

    if (_users.containsKey(email)) { 
    // لو الإيميل موجود بالفعل

      return 'Email already exists'; 
      // يرجع رسالة

    } else {

      _users[email] = { 
        'name': name, 
        'password': password, 
        'role': role, 
      }; 
      // يضيف المستخدم للـ Map

      await _saveUsers(); 
      // يحفظ البيانات فى الملف

      return 'Success'; 
      // يرجع نجاح
    }
  }

  // Login method
  Future<String> loginUser({ 
  // function تسجيل الدخول

    required String email, 
    // الإيميل

    required String password, 
    // الباسورد

  }) async {

    await Future.delayed(const Duration(milliseconds: 500)); 
    // تأخير لمحاكاة السيرفر

    await _loadUsers(); 
    // تحميل أحدث بيانات

    if (!_users.containsKey(email)) { 
    // لو الإيميل مش موجود

      return 'Email not registered'; 
      // يرجع رسالة

    } else if (_users[email]['password'] != password) { 
    // لو الباسورد غلط

      return 'Incorrect password'; 
      // يرجع رسالة

    } else {

      // Returning the role on successful login
      String role = _users[email]['role'] ?? 'User'; 
      // يجيب الرول ولو مش موجود يخليه User

      return 'Success:$role'; 
      // يرجع نجاح + نوع المستخدم
    }
  }
}




























import 'package:flutter/material.dart'; 
// استيراد مكتبة Flutter الأساسية اللى فيها كل عناصر الواجهة (Widgets)

import '../service.dart'; 
// استيراد ملف الـ service عشان نستخدم AuthService لتسجيل الدخول

class LoginScreen extends StatefulWidget { 
// تعريف شاشة تسجيل الدخول كـ StatefulWidget عشان فيها بيانات بتتغير

  const LoginScreen({super.key}); 
  // constructor ثابت + بيمرر key للكلاس الأب

  @override
  State<LoginScreen> createState() => _LoginScreenState(); 
  // بيربط الـ widget بالـ state الخاص بيه
}

class _LoginScreenState extends State<LoginScreen> { 
// كلاس الـ state اللى فيه كل الـ logic والـ variables

  final _formKey = GlobalKey<FormState>(); 
  // مفتاح للتحكم فى الـ Form (للتحقق من صحة البيانات)

  final TextEditingController emailController = TextEditingController(); 
  // controller بيخزن ويتحكم فى النص المكتوب فى حقل الإيميل

  final TextEditingController passwordController = TextEditingController(); 
  // controller بيخزن ويتحكم فى النص المكتوب فى حقل الباسورد

  bool _isLoading = false; 
  // متغير لتحديد هل فيه loading شغال ولا لأ

  @override
  Widget build(BuildContext context) { 
  // function build مسؤولة عن رسم واجهة الشاشة

    return Scaffold( 
    // الهيكل الأساسى للشاشة (AppBar + Body + ...)

      appBar: AppBar(title: const Text("Login")), 
      // شريط أعلى الشاشة بعنوان Login

      body: SingleChildScrollView( 
      // يخلى الشاشة قابلة للسكرول لو الكيبورد ظهر

        child: Padding( 
        // إضافة مسافة حوالين المحتوى

          padding: const EdgeInsets.all(20), 
          // مسافة 20 من كل الاتجاهات

          child: Form( 
          // Widget للفورم

            key: _formKey, 
            // ربط الفورم بالمفتاح للتحكم فى validation

            child: Column( 
            // ترتيب العناصر بشكل عمودى

              children: [ 
              // العناصر داخل العمود

                const SizedBox(height: 40), 
                // مسافة فوق

                const Text(
                  "Welcome Back", 
                  // نص ترحيبى

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
                  // تنسيق النص (حجم + bold)
                ),

                const SizedBox(height: 40), 
                // مسافة

                TextFormField( 
                // حقل إدخال للإيميل

                  controller: emailController, 
                  // ربط الحقل بالـ controller

                  keyboardType: TextInputType.emailAddress, 
                  // نوع الكيبورد يبقى مناسب للإيميل

                  decoration: const InputDecoration(
                    labelText: 'Email Address', 
                    // النص اللى يظهر فوق الحقل

                    border: OutlineInputBorder(), 
                    // شكل البوردر

                    prefixIcon: Icon(Icons.email), 
                    // أيقونة قبل الحقل
                  ),

                  validator: (value) { 
                  // function للتحقق من صحة الإيميل

                    if (value == null || value.isEmpty) { 
                      return 'Please enter your email'; 
                      // لو فاضى يرجع رسالة خطأ
                    }

                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    ).hasMatch(value)) { 
                      return 'Please enter a valid email address'; 
                      // لو الإيميل مش صحيح
                    }

                    return null; 
                    // لو تمام
                  },
                ),

                const SizedBox(height: 20), 
                // مسافة بين الحقول

                TextFormField( 
                // حقل إدخال الباسورد

                  controller: passwordController, 
                  // ربط الحقل بالـ controller

                  obscureText: true, 
                  // يخفى النص المكتوب

                  decoration: const InputDecoration(
                    labelText: 'Password', 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.lock), 
                  ),

                  validator: (value) { 
                  // التحقق من صحة الباسورد

                    if (value == null || value.isEmpty) { 
                      return 'Please enter your password'; 
                    }

                    if (value.length < 6) { 

                      
                      return 'Password must be at least 6 characters'; 
                    }

                    return null; 
                  },
                ),

                const SizedBox(height: 30), 
                // مسافة

                _isLoading 1
                // لو loading شغال

                    ? const CircularProgressIndicator() 
                    // يظهر loader

                    : ElevatedButton( 
                    // غير كده يظهر زرار login

                        onPressed: () async { 
                        // لما المستخدم يدوس الزرار

                          if (_formKey.currentState!.validate()) { 
                          // يشغل validation للفورم

                            setState(() => _isLoading = true); 
                            // يشغل loading

                            String email = emailController.text.trim(); 
                            // يجيب الإيميل بدون مسافات

                            String password = passwordController.text.trim(); 
                            // يجيب الباسورد

                            String result = await AuthService().loginUser(
                              email: email,
                              password: password,
                            ); 
                            // ينادى AuthService يعمل login

                            setState(() => _isLoading = false); 
                            // يقفل loading

                            if (result.startsWith('Success')) { 
                            // لو login نجح

                              final role = result.split(':')[1]; 
                              // يجيب نوع المستخدم من النص

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login successful! Logged in as $role')),
                              ); 
                              // يظهر رسالة نجاح

                              Navigator.pushReplacementNamed(context, '/home'); 
                              // يروح للهوم ويمنع الرجوع

                            } else { 
                            // لو login فشل

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result)),
                              ); 
                              // يظهر رسالة الخطأ
                            }
                          }
                        },

                        child: const Padding( 
                        // مسافة داخل الزرار

                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 50,
                          ),

                          child: Text('Login', style: TextStyle(fontSize: 18)), 
                          // نص الزرار
                        ),
                      ),

                const SizedBox(height: 20), 
                // مسافة

                Row( 
                // صف أفقى

                  mainAxisAlignment: MainAxisAlignment.center, 
                  // العناصر فى النص

                  children: [

                    const Text("Don't have an account? "), 
                    // نص

                    GestureDetector( 
                    // يخلى النص clickable

                      onTap: () { 
                        Navigator.pushReplacementNamed(context, '/register'); 
                        // يروح لشاشة التسجيل
                      },

                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




















import 'package:flutter/material.dart'; 
// استيراد مكتبة Flutter الأساسية اللى فيها كل عناصر الواجهة (Widgets)

import '../service.dart'; 
// استيراد AuthService من ملف service عشان نستخدمه فى التسجيل

class RegisterScreen extends StatefulWidget { 
// تعريف شاشة التسجيل كـ StatefulWidget عشان فيها بيانات بتتغير

  const RegisterScreen({super.key}); 
  // constructor ثابت + بيمرر key للكلاس الأب

  @override
  State<RegisterScreen> createState() => _RegisterScreenState(); 
  // بيربط الـ widget بالـ state الخاص بيها
}

class _RegisterScreenState extends State<RegisterScreen> { 
// كلاس الـ state اللى فيه المتغيرات والـ logic

  final _formKey = GlobalKey<FormState>(); 
  // مفتاح للتحكم فى الفورم وتشغيل validation

  final TextEditingController nameController = TextEditingController(); 
  // controller لحقل الاسم

  final TextEditingController emailController = TextEditingController(); 
  // controller لحقل الإيميل

  final TextEditingController passwordController = TextEditingController(); 
  // controller لحقل الباسورد

  final TextEditingController confirmPasswordController =
      TextEditingController(); 
  // controller لحقل تأكيد الباسورد

  String _selectedRole = 'User'; 
  // المتغير اللى بيخزن نوع المستخدم المختار (افتراضى User)

  bool _isLoading = false; 
  // متغير يحدد هل فيه loading ولا لأ

  @override
  Widget build(BuildContext context) { 
  // build مسؤولة عن رسم واجهة الشاشة

    return Scaffold( 
    // الهيكل الأساسى للشاشة

      appBar: AppBar(title: const Text("Register")), 
      // شريط أعلى الشاشة بعنوان Register

      body: SingleChildScrollView( 
      // يخلى الشاشة قابلة للسكرول لو الكيبورد ظهر

        child: Padding( 
        // إضافة مسافة حوالين المحتوى

          padding: const EdgeInsets.all(20), 
          // مسافة 20 من كل الاتجاهات

          child: Form( 
          // Widget للفورم

            key: _formKey, 
            // ربط الفورم بالمفتاح للتحكم فى validation

            child: Column( 
            // ترتيب العناصر عموديًا

              children: [

                const SizedBox(height: 20), 
                // مسافة فوق

                const Text(
                  "Create Account", 
                  // عنوان الشاشة

                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
                  // تنسيق النص (حجم + عريض)
                ),

                const SizedBox(height: 20), 
                // مسافة

                TextFormField( 
                // حقل إدخال الاسم

                  controller: nameController, 
                  // ربط الحقل بالـ controller

                  keyboardType: TextInputType.name, 
                  // نوع الكيبورد مناسب للاسم

                  decoration: const InputDecoration(
                    labelText: 'Full Name', 
                    // النص اللى يظهر فوق الحقل

                    border: OutlineInputBorder(), 
                    // شكل البوردر

                    prefixIcon: Icon(Icons.person), 
                    // أيقونة قبل الحقل
                  ),

                  validator: (value) { 
                  // التحقق من الاسم

                    if (value == null || value.isEmpty) { 
                      return 'Please enter your full name'; 
                      // لو فاضى يرجع رسالة
                    }

                    return null; 
                    // لو تمام
                  },
                ),

                const SizedBox(height: 20), 
                // مسافة

                TextFormField( 
                // حقل إدخال الإيميل

                  controller: emailController, 
                  // ربط الحقل بالـ controller

                  keyboardType: TextInputType.emailAddress, 
                  // كيبورد مناسب للإيميل

                  decoration: const InputDecoration(
                    labelText: 'Email Address', 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.email), 
                  ),

                  validator: (value) { 
                  // التحقق من الإيميل

                    if (value == null || value.isEmpty) { 
                      return 'Please enter your email'; 
                    }

                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                    ).hasMatch(value)) { 
                      return 'Please enter a valid email address'; 
                    }

                    return null; 
                  },
                ),

                const SizedBox(height: 20), 
                // مسافة

                TextFormField( 
                // حقل الباسورد

                  controller: passwordController, 
                  // ربطه بالـ controller

                  obscureText: true, 
                  // يخفى النص

                  decoration: const InputDecoration(
                    labelText: 'Password', 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.lock), 
                  ),

                  validator: (value) { 
                  // التحقق من الباسورد

                    if (value == null || value.isEmpty) { 
                      return 'Please enter your password'; 
                    }

                    if (value.length < 6) { 
                      return 'Password must be at least 6 characters'; 
                    }

                    return null; 
                  },
                ),

                const SizedBox(height: 20), 
                // مسافة

                TextFormField( 
                // حقل تأكيد الباسورد

                  controller: confirmPasswordController, 
                  obscureText: true, 
                  // يخفى النص

                  decoration: const InputDecoration(
                    labelText: 'Confirm Password', 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.lock), 
                  ),

                  validator: (value) { 
                  // التحقق من التطابق

                    if (value == null || value.isEmpty) { 
                      return 'Please confirm your password'; 
                    }

                    if (value != passwordController.text) { 
                      return 'Passwords do not match'; 
                    }

                    return null; 
                  },
                ),

                const SizedBox(height: 20), 
                // مسافة

                DropdownButtonFormField<String>( 
                // قائمة اختيار نوع المستخدم

                  value: _selectedRole, 
                  // القيمة الحالية المختارة

                  decoration: const InputDecoration(
                    labelText: 'Role', 
                    border: OutlineInputBorder(), 
                    prefixIcon: Icon(Icons.security), 
                  ),

                  items: const [
                    DropdownMenuItem(value: 'User', child: Text('User')), 
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')), 
                  ],

                  onChanged: (value) { 
                  // لما المستخدم يغير الاختيار

                    setState(() { 
                      _selectedRole = value!; 
                      // تحديث القيمة المختارة
                    });
                  },
                ),

                const SizedBox(height: 30), 
                // مسافة

                _isLoading 
                // لو loading شغال

                    ? const CircularProgressIndicator() 
                    // يظهر loader

                    : ElevatedButton( 
                    // غير كده يظهر زرار التسجيل

                        onPressed: () async {

                          if (_formKey.currentState!.validate()) { 
                          // يشغل validation

                            setState(() => _isLoading = true); 
                            // يشغل loading

                            String name = nameController.text.trim(); 
                            String email = emailController.text.trim(); 
                            String password = passwordController.text.trim(); 
                            // يجيب القيم من الحقول

                            String result = await AuthService().registerUser(
                              name: name,
                              email: email,
                              password: password,
                              role: _selectedRole,
                            ); 
                            // ينادى AuthService يعمل تسجيل

                            setState(() => _isLoading = false); 
                            // يقفل loading

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result == 'Success'
                                      ? 'Registration successful! Please login.'
                                      : result,
                                ),
                              ),
                            ); 
                            // يظهر رسالة

                            if (result == 'Success') { 
                              Navigator.pushReplacementNamed(context, '/home'); 
                              // يروح للهوم
                            }
                          }
                        },

                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 50,
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),

                const SizedBox(height: 20), 
                // مسافة

                const SizedBox(height: 20), 
                // مسافة إضافية

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text("Already have an account? "), 
                    // نص

                    GestureDetector(
                      onTap: () { 
                        Navigator.pushReplacementNamed(context, '/login'); 
                        // يروح لشاشة login
                      },

                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}