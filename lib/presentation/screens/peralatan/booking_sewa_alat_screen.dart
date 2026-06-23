import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

import '../../../data/repositories/booking_repository_api.dart';

import '../pembayaran/pembayaran_screen.dart';


class ItemAlatCamp {

  final int id;
  final String nama;
  final int hargaPerHari;
  final String unit;

  int jumlahSewa;


  ItemAlatCamp({
    required this.id,
    required this.nama,
    required this.hargaPerHari,
    required this.unit,
    this.jumlahSewa = 0,
  });

}




class BookingSewaAlatScreen extends StatefulWidget {


  final int wisataId;


  const BookingSewaAlatScreen({
    super.key,
    required this.wisataId,
  });



  @override
  State<BookingSewaAlatScreen> createState()
      => _BookingSewaAlatScreenState();

}





class _BookingSewaAlatScreenState
extends State<BookingSewaAlatScreen> {


  // FIX: gunakan API repository baru
  final BookingRepositoryApi _bookingRepo =
      BookingRepositoryApi();



  int _durasiHari = 1;

  bool _isSubmitting = false;



  final List<ItemAlatCamp> _katalogAlat = [


    ItemAlatCamp(
      id:1,
      nama:'Tenda Dome Kapasitas 4 Orang',
      hargaPerHari:45000,
      unit:'Unit',
    ),


    ItemAlatCamp(
      id:2,
      nama:'Sleeping Bag Thermal Wool',
      hargaPerHari:15000,
      unit:'Pcs',
    ),


    ItemAlatCamp(
      id:3,
      nama:'Matras Camping Karet Spons',
      hargaPerHari:7000,
      unit:'Pcs',
    ),


    ItemAlatCamp(
      id:4,
      nama:'Kompor Portable & Gas Mini',
      hargaPerHari:25000,
      unit:'Set',
    ),


    ItemAlatCamp(
      id:5,
      nama:'Lampu Tenda LED Rechargeable',
      hargaPerHari:10000,
      unit:'Unit',
    ),


  ];




  int get _total {


    int total = 0;


    for(final item in _katalogAlat){

      total +=
          item.jumlahSewa *
          item.hargaPerHari *
          _durasiHari;

    }


    return total;

  }





  int get _jumlahItem {


    return _katalogAlat.fold(
      0,
      (sum,item)=>
          sum + item.jumlahSewa,
    );

  }






  Future<void> _prosesBookingAlat() async {



    if(_jumlahItem == 0){


      ScaffoldMessenger.of(context)
      .showSnackBar(

        const SnackBar(
          content:
          Text(
            "Pilih alat terlebih dahulu"
          ),
        ),

      );


      return;

    }




    setState((){

      _isSubmitting=true;

    });






    final items = _katalogAlat
    .where(
      (e)=>e.jumlahSewa>0
    )
    .map((e){


      return {

        "peralatan_id":
        e.id,


        "jumlah":
        e.jumlahSewa,

      };


    })
    .toList();






    final result =
    await _bookingRepo.createBookingAlat(


      {


        "tanggal_mulai":
        _tanggal(DateTime.now()),



        "tanggal_selesai":
        _tanggal(
          DateTime.now()
          .add(
            Duration(
              days:_durasiHari
            )
          )
        ),



        "items":
        items,



        "total_harga":
        _total,

      }



    );






    if(!mounted)return;



    setState((){

      _isSubmitting=false;

    });






    if(result['success']==true){



      Navigator.push(

        context,

        MaterialPageRoute(

          builder:(_)=>

          PembayaranScreen(

            paymentUrl:
            result['payment_url'] ?? "",


            kodeBooking:
            result['booking_id'] ?? "",


            totalHarga:
            _total,


            layanan:
            "Sewa Peralatan Camping",

          ),

        ),

      );


    }else{


      ScaffoldMessenger.of(context)
      .showSnackBar(

        SnackBar(

          content:
          Text(
            result['message'] ??
            "Booking gagal"
          ),

        ),

      );


    }



  }




  String _tanggal(DateTime d){

    return
    "${d.year}-"
    "${d.month.toString().padLeft(2,'0')}-"
    "${d.day.toString().padLeft(2,'0')}";

  }
  @override
Widget build(BuildContext context) {


  return Scaffold(

    backgroundColor:
    AppColors.background,


    body:

    Column(

      children:[


        _buildHeader(),



        Expanded(

          child:

          SingleChildScrollView(

            padding:
            const EdgeInsets.all(20),


            child:

            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children:[


                _buildDurasi(),


                const SizedBox(
                  height:20
                ),



                _buildKatalog(),



                const SizedBox(
                  height:20
                ),



                _buildTotal(),



              ],


            ),


          ),

        ),



        _buildButton(),


      ],


    ),


  );


}






Widget _buildHeader()=>Container(


padding:
const EdgeInsets.fromLTRB(
16,
50,
16,
24
),


decoration:

const BoxDecoration(

gradient:

LinearGradient(

colors:[

AppColors.purpleDark,
AppColors.purplePrimary,

],

),

borderRadius:

BorderRadius.only(

bottomLeft:
Radius.circular(24),

bottomRight:
Radius.circular(24),

),

),



child:

Row(

children:[


GestureDetector(

onTap:
()=>Navigator.pop(context),


child:

const Icon(
Icons.arrow_back_ios_new,
color:Colors.white,
),


),



const SizedBox(
width:14
),



Text(

"Sewa Peralatan",

style:

GoogleFonts.plusJakartaSans(

color:Colors.white,

fontWeight:
FontWeight.w800,

fontSize:18,

),

),


],


),


);









Widget _buildDurasi()=>Container(


padding:
const EdgeInsets.all(16),


decoration:

BoxDecoration(

color:Colors.white,

borderRadius:
BorderRadius.circular(18),

),



child:

Row(

mainAxisAlignment:
MainAxisAlignment.spaceBetween,


children:[


const Text(
"Durasi Sewa"
),



Row(

children:[



IconButton(

onPressed:

_durasiHari>1

?

(){

setState((){

_durasiHari--;

});

}

:

null,


icon:
const Icon(
Icons.remove_circle_outline
),

),





Text(
"$_durasiHari Hari"
),





IconButton(

onPressed:

(){

setState((){

_durasiHari++;

});

},


icon:
const Icon(
Icons.add_circle_outline
),

),



],



),


],


),


);









Widget _buildKatalog()=>Column(


children:

_katalogAlat.map((item){



return Container(


margin:
const EdgeInsets.only(
bottom:12
),


padding:
const EdgeInsets.all(14),



decoration:

BoxDecoration(

color:
Colors.white,

borderRadius:
BorderRadius.circular(18),

border:

Border.all(
color:
AppColors.borderColor
),

),




child:

Row(

children:[



Expanded(

child:

Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[



Text(

item.nama,

style:
const TextStyle(
fontWeight:
FontWeight.bold
),

),



Text(

CurrencyFormatter.format(
item.hargaPerHari
),

),


],


),


),





IconButton(

onPressed:

item.jumlahSewa>0

?

(){

setState((){

item.jumlahSewa--;

});

}

:

null,


icon:
const Icon(
Icons.remove_circle
),

),





Text(
"${item.jumlahSewa}"
),





IconButton(

onPressed:

(){

setState((){

item.jumlahSewa++;

});

},


icon:
const Icon(
Icons.add_circle
),

),



],


),


);


}).toList(),



);









Widget _buildTotal()=>Container(


padding:
const EdgeInsets.all(16),


decoration:

BoxDecoration(

color:
Colors.white,

borderRadius:
BorderRadius.circular(18),

),




child:

Row(

mainAxisAlignment:
MainAxisAlignment.spaceBetween,


children:[


const Text(
"Total"
),



Text(

CurrencyFormatter.format(_total),

style:

const TextStyle(

fontWeight:
FontWeight.bold,

color:
AppColors.primaryGreen,

),

),



],


),


);









Widget _buildButton()=>Container(


padding:
const EdgeInsets.all(20),


color:
Colors.white,



child:

SizedBox(

width:
double.infinity,


height:52,



child:

ElevatedButton(


onPressed:

(_isSubmitting || _total==0)

?

null

:

_prosesBookingAlat,



child:


_isSubmitting

?

const CircularProgressIndicator()

:

const Text(
"Sewa Sekarang"
),


),


),


);






}