import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/models/admin_models.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminOrderListPage extends StatefulWidget {
  const AdminOrderListPage({super.key});

  @override
  State<AdminOrderListPage> createState() => _AdminOrderListPageState();
}

class _AdminOrderListPageState extends State<AdminOrderListPage> {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Future<List<AdminOrder>> fetchOrders(CookieRequest request) async {
    final response = await request.get(apiPath('/useradmin/api/orders/'));
    List<AdminOrder> list = [];
    if (response['ok'] == true) {
      for (var d in response['orders']) {
        list.add(AdminOrder.fromJson(d));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(title: "All Orders"),
      body: FutureBuilder(
        future: fetchOrders(request),
        builder: (context, AsyncSnapshot<List<AdminOrder>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: LumeColors.sageGreen));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 237, 233, 222),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order #${order.id.substring(0, 8)}", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        Text(order.date, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("User: ${order.userName}", style: GoogleFonts.inter(color: LumeColors.darkText)),
                    const Divider(),
                    ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text("${item.qty}x ${item.name}", style: GoogleFonts.inter(fontSize: 13))),
                          Text(currencyFormatter.format(item.price), style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        Text(currencyFormatter.format(order.amount), style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: LumeColors.sageGreen)),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
