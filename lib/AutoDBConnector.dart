library autoform;


abstract class AutoDbConnector {

  Future delete({required Map<String,dynamic> query});

  Future deletebyId({required String id});

  Future findById({required String id});

  Future<List<dynamic>> find({required Map<String,dynamic> query ,required int pageSize ,required int page ,required String table});

}


class AutoDbConnectorMongoDb extends AutoDbConnector{
  @override
  Future<List> find({required Map<String, dynamic> query, required int pageSize, required int page, required String table}) {
    return Future.value([]);
  }

  @override
  Future delete({required Map<String, dynamic> query}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future deletebyId({required String id}) {
    // TODO: implement deletebyId
    throw UnimplementedError();
  }

  @override
  Future findById({required String id}) {
    // TODO: implement findById
    throw UnimplementedError();
  }




  
}