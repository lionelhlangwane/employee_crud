import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/pages/employee_form.dart';
import 'package:firebase_crud/services/database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Streambuilder to read the data from firebase
  // Create a stream, it can be optional
  Stream? EmployeeStream;

  getontheload() async {
    EmployeeStream = await DatabaseMethods().getEmployeeDetails();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allEmployeeDetails() {
    return StreamBuilder(
      stream: EmployeeStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Name: " + ds["Name"],
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    EditEmployeeDetails(ds["id"]);
                                    _nameController.text = ds["Name"];
                                    _ageController.text = ds["Age"];
                                    _genderController.text = ds["Gender"];
                                    _departmentController.text =
                                        ds["Department"];
                                    _locationController.text = ds["Branch"];
                                  },
                                  child: Icon(Icons.edit),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await DatabaseMethods()
                                        .deleteEmployeeDetails(ds["id"]);
                                  },
                                  child: Icon(Icons.delete),
                                ),
                              ],
                            ),
                            Text("Age: " + ds["Age"]),
                            Text("Gender: " + ds["Gender"]),
                            Text("Department: " + ds["Department"]),
                            Text("Branch: " + ds["Branch"]),
                          ],
                        ),
                      ),
                    ),
                  );
                })
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Employee List",
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeForm(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body: _employeeCard(context),
    );
  }

  Widget _employeeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Expanded(child: allEmployeeDetails()),
        ],
      ),
    );
  }

// Update employee details
  Future EditEmployeeDetails(String id) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // Adjust the width
            height:
                MediaQuery.of(context).size.height * 0.8, // Adjust the height
            child: SingleChildScrollView(
              // Make the dialog scrollable
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Edit Details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // Name Field
                  _buildTextField(
                      context, "Name", "Enter Employee Name", _nameController),
                  const SizedBox(height: 15),

                  // Age Field
                  _buildTextField(
                      context, "Age", "Enter Employee Age", _ageController),
                  const SizedBox(height: 15),

                  // Gender Field
                  _buildTextField(context, "Gender", "Enter Employee Gender",
                      _genderController),
                  const SizedBox(height: 15),

                  // Department Field
                  _buildTextField(context, "Department",
                      "Enter Employee Department", _departmentController),
                  const SizedBox(height: 15),

                  // Location Field
                  _buildTextField(context, "Branch", "Enter Employee Location",
                      _locationController),
                  const SizedBox(height: 40),

                  // Button
                  GestureDetector(
                    onTap: () async {
                      Map<String, dynamic> updateInfo = {
                        "id": id,
                        "Name": _nameController.text,
                        "Age": _ageController.text,
                        "Gender": _genderController.text,
                        "Department": _departmentController.text,
                        "Branch": _locationController.text,
                      };
                      await DatabaseMethods()
                          .updateEmployeeDetails(id, updateInfo)
                          .then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Save Changes",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildTextField(BuildContext context, String labelText,
      String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(5)),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }
}
