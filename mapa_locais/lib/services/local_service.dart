import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/local.dart';

class LocalService {
  final CollectionReference locaisCollection =
      FirebaseFirestore.instance.collection('locais');

  Stream<List<Local>> listarLocais() {
    return locaisCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Local.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> adicionar(Local local) async {
    await locaisCollection.add(local.toMap());
  }

  Future<void> atualizar(Local local) async {
    await locaisCollection.doc(local.id).update(local.toMap());
  }

  Future<void> excluir(String id) async {
    await locaisCollection.doc(id).delete();
  }

  Future<void> alterarFavorito(String id, bool favorito) async {
    await locaisCollection.doc(id).update({
      'favorito': favorito,
    });
  }
}