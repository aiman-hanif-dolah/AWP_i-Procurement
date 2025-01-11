import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tender_provider.dart';

class TenderCreationScreen extends StatefulWidget {
  const TenderCreationScreen({Key? key}) : super(key: key);

  @override
  State<TenderCreationScreen> createState() => _TenderCreationScreenState();
}

class _TenderCreationScreenState extends State<TenderCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _submissionDeadline;

  void _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _submissionDeadline = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Tender')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _selectDeadline,
                    child: const Text('Select Deadline'),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _submissionDeadline != null
                        ? 'Deadline: ${_submissionDeadline!.toLocal()}'
                        : 'No deadline selected',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      _submissionDeadline != null) {
                    Provider.of<TenderProvider>(context, listen: false)
                        .createTender({
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'isOpen': true,
                      'submissionDeadline': _submissionDeadline,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tender created!')),
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please complete all fields and select a deadline.')),
                    );
                  }
                },
                child: const Text('Create Tender'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
