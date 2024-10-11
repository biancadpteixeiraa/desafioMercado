// lib/main.dart
import 'package:flutter/material.dart';
import 'package:alimento/models/alimento.dart';
import 'package:alimento/helpers/sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Mercado',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();

  List<Alimento> _alimentos = [];
  bool _isLoading = false;

  Future<void> _loadAlimentos() async {
    setState(() => _isLoading = true);
    final alimentos = await SqlHelper().getAllAlimentos();
    setState(() {
      _alimentos = alimentos;
      _isLoading = false;
    });
  }

  Future<void> _showAddAlimentoDialog() async {
    _nomeController.clear();
    _precoController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Alimento'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do Alimento'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do alimento.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o preço.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  await SqlHelper().insertAlimento(
                    Alimento(
                      nome: _nomeController.text,
                      preco: double.parse(_precoController.text),
                    ),
                  );
                  await _loadAlimentos();
                  Navigator.of(context).pop(); // Fechar o diálogo após adicionar
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditAlimentoDialog(Alimento alimento) async {
    _nomeController.text = alimento.nome;
    _precoController.text = alimento.preco.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Alimento'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do Alimento'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do alimento.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o preço.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  await SqlHelper().updateAlimento(
                    Alimento(
                      id: alimento.id,
                      nome: _nomeController.text,
                      preco: double.parse(_precoController.text),
                    ),
                  );
                  await _loadAlimentos();
                  Navigator.of(context).pop(); // Fechar o diálogo após atualizar
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAlimento(int id) async {
    setState(() => _isLoading = true);
    await SqlHelper().deleteAlimento(id);
    await _loadAlimentos();
  }

  @override
  void initState() {
    super.initState();
    _loadAlimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Mercado'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _alimentos.length,
              itemBuilder: (context, index) {
                final alimento = _alimentos[index];
                return ListTile(
                  title: Text(alimento.nome),
                  subtitle: Text('Preço: R\$${alimento.preco.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditAlimentoDialog(alimento),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteAlimento(alimento.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlimentoDialog,
        tooltip: 'Adicionar Alimento',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Tela de visualização de dados
class DataViewerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dados')),
      body: FutureBuilder<List<Alimento>>(
        future: SqlHelper().getAllAlimentos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final alimento = snapshot.data![index];
              return ListTile(
                title: Text(alimento.nome),
                subtitle: Text('Preço: R\$${alimento.preco.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}
