import 'package:backend/database/database.dart';
import 'package:backend/utils/utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/middleware/cors.dart';
import 'package:backend/router/auth.dart';
import 'package:backend/router/user.dart';
import 'package:backend/router/websocket.dart';

void main() async {
  // ### Criando instancia do banco de dados ###
  final databaseConnection = DatabaseConnection();
  //  ### END ###

  // ### Configurando serviço ###
  final routerMain = Router();

  // ### Arquivos estaticos ###

  routerMain.get(
      "/",
      (Request request) async =>
          await getFile("public/index.html", "text/html"));

  routerMain.get("/style.css",
      (Request request) async => await getFile("public/style.css", "text/css"));

  routerMain.get("/main.js",
      (Request request) async => await getFile("public/main.js", "text/js"));

  // ### Adicionando rotas ###

  routerMain.mount("/user", routerUser(databaseConnection).call);
  routerMain.mount("/auth", routerAuth(databaseConnection).call);
  routerMain.mount("/websocket", routerWebsocket().call);

  final handler = const Pipeline()
      .addMiddleware(middlewareCors())
      .addMiddleware(logRequests())
      .addHandler(routerMain.call);

  final server = await shelf_io.serve(handler, 'localhost', 8080);

  print('Servidor rodando em http://${server.address.host}:${server.port}');
  // ### END ###
}