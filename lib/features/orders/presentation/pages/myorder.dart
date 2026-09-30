import 'package:flutter/material.dart';
import 'package:nyxproject/features/orders/presentation/pages/orderHistory.dart';

class myOrder extends StatefulWidget {
  const myOrder({super.key});

  @override
  State<myOrder> createState() => _myOrderState();
}

class _myOrderState extends State<myOrder> {
  final List<String> status = [
    "All",
    "Pending",
    "Delivered",
    "Cancelled",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 10),
              _filterBar(),
              SizedBox(height: 10),
              _ongoingOrderCard(),
              SizedBox(height: 10),
              _finishedOrderCard(),
            ],
          ),
        )
      ),
    );
  }

  Widget _header() {
    return Container(
      color: const Color.fromARGB(255, 13, 27, 42),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: (){
                Navigator.pop(context);
            }, 
            icon: Icon(
              Icons.arrow_back_ios_new_rounded, 
              color: Colors.white,
              ),
          ),
          Expanded(
            child: const Text(
              "My Orders", 
              style: TextStyle(
                fontFamily: "Custom",
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          Text(
            "Order History",
            style: TextStyle(
              fontFamily: "Custom",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white
            ),
          ),
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => orderHistory()),
              );
            }, 
            icon: Icon(Icons.calendar_month_rounded,color: Colors.white,)
          )
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Container(
      height: 45,
      // margin: const EdgeInsets.all(10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: status.length,
        itemBuilder: (context, index) {
          final statu = status[index];
          final isSelected = statu == statu;

          return GestureDetector(
            onTap: () {
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color(0xFF0D1B2A)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  statu,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ongoingOrderCard(){
    return Container(
      height: 210,
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Stack(
        children: [
          Positioned(
            left: -5,
            child: Icon(
              Icons.image,
              size: 190,
              color: Colors.white,
            )
          ),
          Positioned(
            left: 190,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Badminton Shuttlecock",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Price: 25,000 Ks",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Size: 3.7",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Brand: Addidas",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Pending",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 5,
            bottom: 0,
            child: Container(
              width: 230,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (){}, 
                    child: Text(
                      "Track Order",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Custom",
                        fontWeight: FontWeight.w500,
                        color: Colors.black
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size (110, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(15))
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){}, 
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Custom",
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size (110, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
                      ),
                      backgroundColor: Colors.red
                    ),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  Widget _finishedOrderCard(){
    return Container(
      height: 210,
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 13, 27, 42),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Stack(
        children: [
          Positioned(
            left: -5,
            child: Icon(
              Icons.image,
              size: 190,
              color: Colors.white,
            )
          ),
          Positioned(
            left: 190,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Adidas Shoes",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Price: 45,000 Ks",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Size: 42",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Brand: Addidas",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Delivered",
                  style: TextStyle(
                    fontFamily: "Custom",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 5,
            bottom: 0,
            child: Container(
              width: 230,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (){}, 
                    child: Text(
                      "Reorder",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Custom",
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size (110, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(15))
                      ),
                      backgroundColor: const Color.fromARGB(255, 39, 242, 46)
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){}, 
                    child: Text(
                      "Rate Us",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Custom",
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size (110, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(15)),
                      ),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        width: 2,
                        color: Colors.white
                      )
                    ),
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}