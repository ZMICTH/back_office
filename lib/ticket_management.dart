import 'package:back_office/component/drawer.dart';
import 'package:back_office/component/edit_ticket.dart';
import 'package:back_office/controller/reserve_ticket_controller.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/services/reserve_ticket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TicketManagementScreen extends StatefulWidget {
  @override
  State<TicketManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TicketManagementScreen> {
  late TicketConcertController ticketconcertcontroller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());
    _loadAllTickets();
  }

  Future<void> _loadAllTickets() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      var tickets = await ticketconcertcontroller.fetchTicketConcertModel();

      // Filter orders where userId == partnerId and paymentStatus is false
      tickets = tickets.where((order) => order.partnerId == userId).toList();

      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setTicketCatalog(tickets);
    } catch (e) {
      print('Error fetching ConcertTickets: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketModel = Provider.of<ReservationTicketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Ticket Management"),
        foregroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Move between page
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_sharp),
            iconSize: 40,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/newticket');
                                },
                                child: const Text(
                                  "Add New Ticket",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _buildTicketSection(
                              "Upcoming Concerts", ticketModel.upcomingTickets),
                          SizedBox(height: 10),
                          _buildTicketSection(
                              "Past Concerts", ticketModel.pastTickets),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSection(String title, List<TicketConcertModel> tickets) {
    bool isPastConcerts = title == "Past Concerts";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            Color cardColor;
            String stockText;
            Color colorText;

            if (ticket.numberOfTickets == 0) {
              cardColor = Colors.red[100]!;
              stockText = "Sold Out";
              colorText = Colors.red;
            } else {
              cardColor = Colors.grey[400]!;
              stockText = 'Tickets Available: ${ticket.numberOfTickets}';
              colorText = Colors.white;
            }

            return SingleChildScrollView(
              child: Card(
                color: cardColor,
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 4,
                          ),
                          Flexible(
                            flex: 2,
                            child: Image.network(
                              ticket.imageEvent,
                              width: 700,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${ticket.eventName}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Event Date:\n ${DateFormat('dd-MM-yyyy').format(ticket.eventDate)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                      'Opening Sale:\n ${DateFormat('dd-MM-yyyy').format(ticket.openingSaleDate)}'),
                                  Text(
                                      'Ending Sale:\n ${DateFormat('dd-MM-yyyy').format(ticket.endingSaleDate)}'),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'Price: ${ticket.ticketPrice} THB',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    stockText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (!isPastConcerts)
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  print("Edit tapped for ${ticket.eventName}");
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => EditTicketPage(
                                        ticket: ticket,
                                        ticketImagePath: ticket.imageEvent,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Confirm Delete"),
                                        content: Text(
                                            "Are you sure you want to delete ${ticket.eventName}?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _deleteTicket(ticket);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _deleteTicket(TicketConcertModel ticket) async {
    try {
      await FirebaseFirestore.instance
          .collection('ticket_concert_catalog')
          .doc(ticket.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ticket.eventName} deleted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
        ),
      );

      _loadAllTickets();
    } catch (e) {
      print('Error deleting ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete ${ticket.eventName}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
