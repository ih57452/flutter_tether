import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import your models, providers, and managers as needed
// import 'package:example/database/models.g.dart';
// import 'package:example/database/managers/authors_client_manager.g.dart'; // Example for Author CRUD

class CrudTab extends ConsumerStatefulWidget {
  const CrudTab({super.key});

  @override
  ConsumerState<CrudTab> createState() => _CrudTabState();
}

class _CrudTabState extends ConsumerState<CrudTab> {
  final _formKey = GlobalKey<FormState>();
  // Example: Controllers for an Author form
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  String?
  _editingAuthorId; // To keep track if we are editing an existing author

  // Example: Provider for a list of authors to display
  // final authorsListProvider = FutureProvider.autoDispose<List<AuthorModel>>((ref) async {
  //   final authorManager = ref.watch(authorsClientManagerProvider);
  //   return await authorManager.query().get(); // Or .remoteOnly(), .localOnly()
  // });

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _bioController.clear();
    setState(() {
      _editingAuthorId = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // final authorManager = ref.read(authorsClientManagerProvider);
      // final authorData = AuthorModel(
      //   id: _editingAuthorId ?? Uuid().v4(), // Generate new ID if creating
      //   firstName: _firstNameController.text,
      //   lastName: _lastNameController.text,
      //   bio: _bioController.text,
      //   // createdAt and updatedAt will be handled by Supabase/triggers or set manually
      // );

      try {
        // if (_editingAuthorId == null) {
        //   // Create
        //   await authorManager.query().insert(authorData);
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Author created successfully!')),
        //   );
        // } else {
        //   // Update
        //   await authorManager.query().update(authorData);
        //    ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Author updated successfully!')),
        //   );
        // }
        _clearForm();
        // ref.invalidate(authorsListProvider); // Refresh the list
        print("Form submitted (Create/Update logic to be implemented)");
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // void _editAuthor(AuthorModel author) {
  //   setState(() {
  //     _editingAuthorId = author.id;
  //     _firstNameController.text = author.firstName;
  //     _lastNameController.text = author.lastName;
  //     _bioController.text = author.bio ?? '';
  //   });
  // }

  // Future<void> _deleteAuthor(String authorId) async {
  //   try {
  //     final authorManager = ref.read(authorsClientManagerProvider);
  //     await authorManager.query().deleteById(authorId); // Assuming a deleteById method
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Author deleted successfully!')),
  //     );
  //     ref.invalidate(authorsListProvider); // Refresh the list
  //     if (_editingAuthorId == authorId) _clearForm();
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error deleting author: $e')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final authorsAsyncValue = ref.watch(authorsListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingAuthorId == null ? 'Create New Author' : 'Edit Author',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter a first name' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter a last name' : null,
                ),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'Biography'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_editingAuthorId != null)
                      TextButton(
                        onPressed: _clearForm,
                        child: const Text('Cancel Edit'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(
                        _editingAuthorId == null ? 'Create' : 'Update',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Existing Authors (CRUD operations to be fully implemented)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'CRUD Tab Content - Implement Form and List Logic Here',
            ),
          ),
          // authorsAsyncValue.when(
          //   data: (authors) => ListView.builder(
          //     shrinkWrap: true,
          //     physics: const NeverScrollableScrollPhysics(),
          //     itemCount: authors.length,
          //     itemBuilder: (context, index) {
          //       final author = authors[index];
          //       return Card(
          //         margin: const EdgeInsets.symmetric(vertical: 4.0),
          //         child: ListTile(
          //           title: Text('${author.firstName} ${author.lastName}'),
          //           subtitle: Text(author.bio ?? 'No bio available', maxLines: 1, overflow: TextOverflow.ellipsis),
          //           trailing: Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               IconButton(
          //                 icon: const Icon(Icons.edit, color: Colors.blue),
          //                 onPressed: () => _editAuthor(author),
          //               ),
          //               IconButton(
          //                 icon: const Icon(Icons.delete, color: Colors.red),
          //                 onPressed: () => _deleteAuthor(author.id),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          //   loading: () => const Center(child: CircularProgressIndicator()),
          //   error: (err, stack) => Center(child: Text('Error loading authors: $err')),
          // ),
        ],
      ),
    );
  }
}
