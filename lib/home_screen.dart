import 'package:crudsqlite/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Map<String, dynamic>> _todasAsTarefas = [];

  bool _isLoading = true;

  //Obter todas as tarefas do banco de dados
  void _refreshTarefas() async {
    final data = await SQLHelper.obterTodas();
    setState(() {
      _todasAsTarefas = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTarefas();
  }

  Future<void> _addData() async {
    await SQLHelper.adicionar(_tituloController.text, _descricaoController.text);
    _refreshTarefas();
  }

  Future<void> _updateData(int id) async {
    await SQLHelper.editar(id, _tituloController.text, _descricaoController.text);
    _refreshTarefas();
  }

  void _deleteData(int id) async {
    await SQLHelper.deletar(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Tarefa apagada"),
    ));
    _refreshTarefas();
  }

  final TextEditingController _tituloController  = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  void exibirModalInferior(int? id) async {

    if (id != null) {
      final tarefaExistente =
      _todasAsTarefas.firstWhere((element) => element['id'] == id);
      _tituloController.text = tarefaExistente['titulo'];
      _descricaoController.text = tarefaExistente['descricao'];
    }

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Título"
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Descrição",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (id == null) {
                        await _addData();
                      }
                      if (id != null) {
                        await _updateData(id);
                      }

                      _tituloController.text = "";
                      _descricaoController.text = "";

                      //Ocultar modal inferior.
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(id == null ? "Adicionar" : "Editar",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
        itemCount: _todasAsTarefas.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _todasAsTarefas[index]['titulo'],
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text(_todasAsTarefas[index]['descricao']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            exibirModalInferior(_todasAsTarefas[index]['id']);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.indigo,
                          ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteData(_todasAsTarefas[index]['id']);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  exibirModalInferior(null),
        child: Icon(Icons.add),
      ),
    );
  }
}

