import '../db/DatabaseHelper.dart';
import '../model/user.dart';

class AuthController {
  final dbHelper = DatabaseHelper.instance;

  Future<User?> login(String email, String password) async {
    try {
      final user = await dbHelper.queryFirstRows(email, password);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<int?> register(User user) async {
    try {
      return await dbHelper.insert(user);
    } catch (e) {
      return null;
    }
  }
}
