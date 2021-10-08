import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DbWalletManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(join(await getDatabasesPath(), "ss.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE wallet(id INTEGER PRIMARY KEY autoincrement, name TEXT, walletAddress TEXT, balance TEXT)");
      });
    }
  }

  Future<int> insertWallet(Wallet wallet) async {
    await openDb();
    return await _database.insert('wallet', wallet.toMap());
  }

  Future<List<Wallet>> getWalletList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database.query('wallet');
    return List.generate(maps.length, (i) {
      return Wallet(
          id: maps[i]['id'],
          name: maps[i]['name'],
          walletAddress: maps[i]['walletAddress'],
          balance: maps[i]['balance']);
    });
  }

  Future<int> updateWallet(Wallet wallet) async {
    await openDb();
    return await _database.update('wallet', wallet.toMap(),
        where: "id = ?", whereArgs: [wallet.id]);
  }

  Future<void> deleteWallet(int id) async {
    await openDb();
    await _database.delete('wallet', where: "id = ?", whereArgs: [id]);
  }

  query(String s) {}
}

class Wallet {
  int id;
  String name;
  String walletAddress;
  String balance;
  Wallet({
    @required this.name,
    @required this.walletAddress,
    @required this.balance,
    this.id,
  });
  Map<String, dynamic> toMap() {
    return {'name': name, 'walletAddress': walletAddress, 'balance': balance};
  }
}
